//
//  ViewController.swift
//  Poetry
//
//  Created by Mike Lazer-Walker on 8/2/16.
//  Copyright © 2016 Mike Lazer-Walker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let networkInterface = NetworkInterface(hostname: "http://localhost:3000")
    let voice = RobotVoiceOutput()

    var running = false

    override func viewDidLoad() {
        super.viewDidLoad()
        running = true
        fetchPoetry()
    }

    func fetchPoetry() {
        networkInterface.fetchPoetryWithText("I wonder if", temperature: 0.4, callback: poetryHandler)
    }

    func poetryHandler(result:String) {
        print(result)
        self.voice.speak(result)

        if running {
            fetchPoetry()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

