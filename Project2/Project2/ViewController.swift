//
//  ViewController.swift
//  Project2
//
//  Created by Christian Mitteldorf on 25/04/2019.
//  Copyright © 2019 MobilePay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!

    var countries = [String]()
    var score = 0

    var correctAnswer = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        topButton.layer.borderWidth = 1
        middleButton.layer.borderWidth = 1
        bottomButton.layer.borderWidth = 1

        topButton.layer.borderColor = UIColor.lightGray.cgColor
        middleButton.layer.borderColor = UIColor.lightGray.cgColor
        bottomButton.layer.borderColor = UIColor.lightGray.cgColor

        countries += [
            "estonia",
            "france",
            "germany",
            "ireland",
            "italy",
            "monaco",
            "nigeria",
            "poland",
            "russia",
            "spain",
            "uk",
            "us"
        ]

        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        topButton.setImage(UIImage(named: countries[0]), for: .normal)
        middleButton.setImage(UIImage(named: countries[1]), for: .normal)
        bottomButton.setImage(UIImage(named: countries[2]), for: .normal)

        correctAnswer = Int.random(in: 0...2)
        title = "\(countries[correctAnswer].uppercased()) -- Score: \(score)"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong. This is \(countries[sender.tag].uppercased())"
            score -= 1
        }


        if score == 5 {
            let alertController2 = UIAlertController(title: title, message: "BOOM! You got \(score)!", preferredStyle: .alert)
            alertController2.addAction(UIAlertAction(title: "Bummer", style: .default, handler: { (action) in
                self.score = 0
                self.askQuestion()
            }))
            present(alertController2, animated: true)
        } else {
            let alertController = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(alertController, animated: true)
        }
    }
}
