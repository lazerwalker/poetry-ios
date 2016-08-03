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

    override func viewDidLoad() {
        super.viewDidLoad()

        networkInterface.fetchPoetryWithText("This is", temperature: 0.4) { (result) in
            print(result)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

