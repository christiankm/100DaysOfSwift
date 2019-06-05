//
//  ViewController.swift
//  Project6b
//
//  Created by Christian Mitteldorf on 05/06/2019.
//  Copyright © 2019 MobilePay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let label1 = UILabel()
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.backgroundColor = .systemRed
        label1.text = "THESE"
        label1.sizeToFit()
        view.addSubview(label1)

        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.backgroundColor = .systemBlue
        label2.text = "ARE"
        label2.sizeToFit()
        view.addSubview(label2)

        let label3 = UILabel()
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.backgroundColor = .systemYellow
        label3.text = "SOME"
        label3.sizeToFit()
        view.addSubview(label3)

        let label4 = UILabel()
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.backgroundColor = .systemGreen
        label4.text = "AWESOME"
        label4.sizeToFit()
        view.addSubview(label4)

        let label5 = UILabel()
        label5.translatesAutoresizingMaskIntoConstraints = false
        label5.backgroundColor = .systemOrange
        label5.text = "LABELS"
        label5.sizeToFit()
        view.addSubview(label5)

        let views = [
            "label1": label1,
            "label2": label2,
            "label3": label3,
            "label4": label4,
            "label5": label5
        ]
        let metrics = [
            "height": 88
        ]

//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(height@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: views))
//        for label in views.keys {
//            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: views))
//        }

        let labels = [label1, label2, label3, label4, label5]
        let spacing: CGFloat = 10.0
        let spacingToExclude = labels.count * Int(spacing)

        var previous: UILabel?
        for label in labels {
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            label.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1/CGFloat(labels.count), constant: -spacing).isActive = true

            if let previous = previous {
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: spacing).isActive = true
            } else {
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: spacing).isActive = true
            }

            previous = label
        }
    }


}

