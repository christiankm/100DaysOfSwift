//
//  ViewController.swift
//  Project18
//
//  Created by Christian Mitteldorf on 14/07/2019.
//  Copyright © 2019 Mitteldorf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("I'm inside the viewDidLoad() method!")
        print(1, 2, 3, 4, 5)
        print(1, 2, 3, 4, 5, separator: "-")
        print("Some message", terminator: "")
        
        assert(1 == 1, "Maths failure!")
//        assert(1 == 2, "Maths failure!")
        
        for i in 1...100 {
            print("Got number \(i)")
        }
    }
}
