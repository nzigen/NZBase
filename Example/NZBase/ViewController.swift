//
//  ViewController.swift
//  NZBase
//
//  Created by Yoshihiro Sawa on 10/24/2017.
//  Copyright (c) 2017 Yoshihiro Sawa. All rights reserved.
//

import UIKit
import NZBase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NZNetworkIndicator.shared.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

