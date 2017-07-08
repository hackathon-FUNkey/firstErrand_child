//
//  SpeechViewController.swift
//  firstErrand_child
//
//  Created by 河辺雅史 on 2017/07/09.
//  Copyright © 2017年 funkey. All rights reserved.
//

import UIKit
import APIKit

class SpeechViewController: UIViewController {
    var parentMessages: [ParentMessage] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let request = ParentMessageRequest()
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.parentMessages = response
                print(self.parentMessages)
            case .failure(let error):
                print(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
