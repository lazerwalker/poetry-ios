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

    var previousSentence:String?
    var running = false

    override func viewDidLoad() {
        super.viewDidLoad()
        running = true
        fetchPoetry()
    }

    func fetchPoetry() {
        var text:String = "Today is when"
        if let previousSentence = previousSentence {
            text = previousSentence
        }
        networkInterface.fetchPoetryWithText(text, temperature: 0.4, callback: poetryHandler)
    }

    func poetryHandler(result:String) {
        var sentence = result
        print(sentence)
        let lines = result.componentsSeparatedByString("\n")
        let firstLine = lines[0]
        let lastLine = lines[lines.count - 2]

        if let previousSentence = previousSentence {
            if firstLine.containsString(previousSentence) {
                sentence = sentence.stringByReplacingOccurrencesOfString(previousSentence, withString: "")
                print("MODIFIED")
            }
        }
        previousSentence = lastLine

        self.voice.speak(sentence)

        if running {
            fetchPoetry()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

