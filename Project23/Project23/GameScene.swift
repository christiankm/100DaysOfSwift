//
//  GameScene.swift
//  Project23
//
//  Created by Christian Mitteldorf on 21/07/2019.
//  Copyright © 2019 Christian Mitteldorf. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameplayKit

enum ForceBomb {
    case never, always, random
}

class GameScene: SKScene {

    private typealias Enemy = SKSpriteNode

    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }

    var livesImages = [SKSpriteNode]()
    var lives = 3

    var activeSliceBackground: SKShapeNode!
    var activeSliceForeground: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    private var activeEnemies = [Enemy]()
    private var bombSoundEffect: AVAudioPlayer?

    var isSwooshSoundActive = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85

        createScore()
        createLives()
        createSlices()
    }

    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)

        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }

    func createLives() {
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "slideLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    }

    func createSlices() {
        activeSliceBackground = SKShapeNode()
        activeSliceBackground.zPosition = 2
        activeSliceBackground.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBackground.lineWidth = 9
        addChild(activeSliceBackground)

        activeSliceForeground = SKShapeNode()
        activeSliceForeground.zPosition = 3
        activeSliceForeground.strokeColor = .white
        activeSliceForeground.lineWidth = 5
        addChild(activeSliceForeground)
    }

    func redrawActiveSlice(with points: [CGPoint]) {
        guard points.count >= 2 else {
            activeSliceForeground.path = nil
            activeSliceBackground.path = nil
            return
        }

        var p = points
        if p.count > 12 {
            p.removeFirst(points.count - 12)
        }

        let path = UIBezierPath()
        path.move(to: p[0])

        for i in 1..<p.count {
            path.addLine(to: p[i])
        }

        activeSliceBackground.path = path.cgPath
        activeSliceForeground.path = path.cgPath
    }

    func playSwooshSound() {
        isSwooshSoundActive = true
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"

        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)

        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }

    func createEnemy(forceBomb: ForceBomb = .random) {
        func enemyType(forceBomb: ForceBomb) -> Int {
            switch forceBomb {
            case .always:
                return 0
            case .random:
                return Int.random(in: 0...6)
            case .never:
                return 1
            }
        }

        let enemy: Enemy
        if enemyType(forceBomb: forceBomb) == 0 {
            // Create bomb
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"

            // 2
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)

            // 3
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }

            // 4
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try?  AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }

            // 5
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else {
            enemy = Enemy(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }

        // Position enemy
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition

        // 2
        let randomAngularVelocity = CGFloat.random(in: -3...3 )
        let randomXVelocity: Int

        // 3
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }

        // 4
        let randomYVelocity = Int.random(in: 24...32)

        // 5
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0

        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        activeSlicePoints.removeAll(keepingCapacity: true)

        let location = touch.location(in: self)
        activeSlicePoints.append(location)

        redrawActiveSlice(with: activeSlicePoints)

        activeSliceForeground.removeAllActions()
        activeSliceBackground.removeAllActions()

        activeSliceForeground.alpha = 1
        activeSliceBackground.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice(with: activeSlicePoints)

        if !isSwooshSoundActive {
            playSwooshSound()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fadeDuration = 0.25
        activeSliceBackground.run(SKAction.fadeOut(withDuration: fadeDuration))
        activeSliceForeground.run(SKAction.fadeOut(withDuration: fadeDuration))
    }

    override func update(_ currentTime: TimeInterval) {
        var bombCount = 0
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }

        if bombCount == 0 {
            // no bombs, stop the fuse sound
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
}
