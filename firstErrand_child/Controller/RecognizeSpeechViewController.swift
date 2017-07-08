//
//  RecognizeSpeechViewController.swift
//  firstErrand_child
//
//  Created by 兵藤允彦 on 2017/07/08.
//  Copyright © 2017年 funkey. All rights reserved.
//

import UIKit
import Speech
import APIKit
import AVFoundation
import CoreLocation

public class RecognizeSpeechViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate, CLLocationManagerDelegate {
    // MARK: Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
    var locationManager: CLLocationManager!
    var tmpParentMessages: [ParentMessage] = []
    var parentMessages: [ParentMessage] = []
    var timer:Timer?
    
    // MARK: UIViewController
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setParentMessages()
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(speechNewParentMessage), userInfo: nil, repeats: true)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setTmpParentMessages()
        
        // Disable the record buttons until authorization has been granted.
        recordButton.isEnabled = false
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.notDetermined) {
            if (self.locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }

    }
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                
                if self.isContainNegativeWord(speechText: result.bestTranscription.formattedString) {
                    self.sendNegativeWord(speechText: result.bestTranscription.formattedString)
                    print("send")
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textView.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    public func isContainNegativeWord(speechText: String) -> Bool {
        for negativeWord in NegativeWords().negativeWords {
            if speechText.contains(negativeWord) {
                return true
            }
        }
        
        return false
    }
    
    public func sendNegativeWord(speechText: String) {
        let request = NegativeWordRequest(negativeWordDic: ["msg": speechText])
        Session.send(request) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func setTmpParentMessages() {
        let request = ParentMessageRequest()
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.tmpParentMessages = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func setParentMessages() {
        let request = ParentMessageRequest()
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.parentMessages = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func speechNewParentMessage() {
        print("speech new parent")

        setParentMessages()
        print(self.tmpParentMessages.count)
        print(self.parentMessages.count)
        if self.tmpParentMessages.count != self.parentMessages.count {
            print("speech")
            textSpeech(str: self.parentMessages[self.parentMessages.count-1].message)
            setTmpParentMessages()
        }else{
            return
        }
    }
    
    // MARK: Interface Builder actions

    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
        } else {
            try! startRecording()
            recordButton.setTitle("Stop recording", for: [])
        }
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        sendGpsData(latitude: latitude!, longitude: longitude!)
        print("latitude: \(latitude!)\nlongitude: \(longitude!)")
    }
    
    func sendGpsData(latitude: Double, longitude: Double) {
        let postString = "lat=\(latitude)&lon=\(longitude)"
        var request = URLRequest(url: URL(string: "https://version1.xyz/spajam2017/gps.php")!)
        
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if (error == nil) {
                // API通信成功
                print("success")
                print("response: \(response!)")
                print(String(data: data!, encoding: .utf8)!)
            } else {
                // API通信失敗
                print("error")
            }
        })
        task.resume()
    }
    
    public func textSpeech(str: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: str)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.pitchMultiplier = 1.6
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    // デリゲート
    // 読み上げ開始したときに呼ばれる
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("読み上げ開始")
    }
    
    // 読み上げ終了したときに呼ばれる
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("読み上げ終了")
    }

}
