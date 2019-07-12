//
//  WhackSlot.swift
//  Project14
//
//  Created by Christian Mitteldorf on 12/07/2019.
//  Copyright © 2019 Mitteldorf. All rights reserved.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    
    var charNode: SKSpriteNode!
    
    var isVisible = false
    var isHit = false
    
    private let showDuration = 0.05

    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        guard !isVisible else { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: showDuration))
        isVisible = true
        isHit = false
        
        if isGood() {
            charNode.texture = goodChar()
            charNode.name = "charFriend"
        } else {
            charNode.texture = evilChar()
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        guard isVisible else { return }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: showDuration))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in
            self.isVisible = false
        }
        charNode.run(SKAction.sequence([
            delay,
            hide,
            notVisible
        ]))
    }
    
    func isGood() -> Bool {
        return Int.random(in: 0...2) == 0
    }
    
    func goodChar() -> SKTexture {
//        return SKTexture(imageNamed: "penguinGood")
        return SKTexture(imageNamed: "chrisGood")
    }
    
    func evilChar() -> SKTexture {
//        return SKTexture(imageNamed: "penguinEvil")
        return SKTexture(imageNamed: "chrisEvil\(Int.random(in: 1...6))")
    }
}
