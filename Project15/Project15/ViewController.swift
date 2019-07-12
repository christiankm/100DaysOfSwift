//
//  ViewController.swift
//  Project15
//
//  Created by Christian Mitteldorf on 12/07/2019.
//  Copyright © 2019 Mitteldorf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    var imageView: UIImageView!
    var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
    }
    
    @IBAction func tapped(_ sender: UIButton) {
        sender.isHidden = true
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
            switch self.currentAnimation {
            case 0:
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
            case 1, 3, 5:
                self.imageView.transform = .identity
            case 2:
                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
            case 6:
                self.imageView.alpha = 0.1
                self.imageView.backgroundColor = .green
            case 7:
                self.imageView.alpha = 1
                self.imageView.backgroundColor = .clear
            default:
                break
            }
        }) { finished in
            sender.isHidden = false
        }
        
        currentAnimation = currentAnimation >= 7 ? 0 : currentAnimation + 1
    }
}
