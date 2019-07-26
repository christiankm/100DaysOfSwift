//
//  GameViewController.swift
//  Project29
//
//  Created by Christian Mitteldorf on 26/07/2019.
//  Copyright © 2019 MobilePay. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var gameScene: GameScene!

    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var playerNumber: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)

                gameScene = scene as? GameScene
                gameScene.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func activatePlayer(_ number: Int) {
        playerNumber.text = number == 1 ? "PLAYER ONE <<<" : "PLAYER TWO >>>"
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        launchButton.isHidden = false
    }

    @IBAction func angleChanged(_ sender: UISlider) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }

    @IBAction func velocityChanged(_ sender: UISlider) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }

    @IBAction func launch(_ sender: UIButton) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        launchButton.isHidden = true

        gameScene.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
}
