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

enum SequenceType: CaseIterable {
    case oneNotBomb
    case one
    case twoWithOneBomb
    case two
    case three
    case four
    case chain
    case fastChain
}

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
    var hasGameEnded = false

    var activeSliceBackground: SKShapeNode!
    var activeSliceForeground: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    private var activeEnemies = [Enemy]()
    private var bombSoundEffect: AVAudioPlayer?

    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true

    var isSwooshSoundActive = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85

        createScore()
        createLives()
        createSlices()

        // Start making enemies
        sequence = [
            .oneNotBomb,
            .oneNotBomb,
            .twoWithOneBomb,
            .twoWithOneBomb,
            .three,
            .one,
            .four,
            .chain
        ]

        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
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
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
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

    func subtractLife() {
        lives -= 1

        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))

        var life: SKSpriteNode

        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }

        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }

    func endGame(triggeredByBomb: Bool) {
        guard !hasGameEnded else { return }

        hasGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false

        bombSoundEffect?.stop()
        bombSoundEffect = nil

        if triggeredByBomb {
            livesImages.forEach { node in
                node.texture = SKTexture(imageNamed: "sliceLifeGone")
            }
        }

        // Show Game Over
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 80
        gameOverLabel.position = CGPoint(x: self.size.width / 2 - 20, y: self.size.height / 2 + 20) // center of screen
        addChild(gameOverLabel)
    }

    func tossEnemies() {
        guard !hasGameEnded else { return }

        popupTime *= 0.99
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02

        let sequenceType = sequence[sequencePosition]

        switch sequenceType {
        case .oneNotBomb:
            createEnemy(forceBomb: .never)
        case .one:
            createEnemy()
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            createEnemies(times: 2)
        case .three:
            createEnemies(times: 3)
        case .four:
            createEnemies(times: 4)
        case .chain:
            createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5 * 4)) { [weak self] in self?.createEnemy() }
        case .fastChain:
            createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10 * 4)) { [weak self] in self?.createEnemy() }
        }

        sequencePosition += 1
        nextSequenceQueued = false
    }

    func createEnemies(times: Int = 1) {
        for _ in 1...times {
            createEnemy()
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
        let shouldBeSuperFast = Int.random(in: 0...10) == 0
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
                let fuseEnd = CGPoint(x: 76, y: 64)
                emitter.position = fuseEnd
                enemy.addChild(emitter)
            }
        } else {
            enemy = Enemy(imageNamed: "penguin")
            if shouldBeSuperFast {
                enemy.texture = SKTexture(imageNamed: "sliceLifeGone")
                enemy.xScale = 1.5
                enemy.yScale = 1.5
            }
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = shouldBeSuperFast ? "superFastEnemy" : "enemy"
        }

        // Position enemy
        let offScreenY = -128
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: offScreenY)
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
        let velocityFactor = shouldBeSuperFast ? 80 : 40
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * velocityFactor, dy: randomYVelocity * velocityFactor)
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
        guard !hasGameEnded else { return }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice(with: activeSlicePoints)

        if !isSwooshSoundActive {
            playSwooshSound()
        }

        let nodesAtPoint = nodes(at: location)
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" || node.name == "superFastEnemy" {
                // destroy penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }

                node.name = ""
                node.physicsBody?.isDynamic = false

                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([group, .removeFromParent()])
                node.run(sequence)

                score += node.name == "superFastEnemy" ? 5 : 1

                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }

                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                // die
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }

                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }

                node.name = ""
                bombContainer.physicsBody?.isDynamic = false

                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(sequence)

                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }

                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fadeDuration = 0.25
        activeSliceBackground.run(SKAction.fadeOut(withDuration: fadeDuration))
        activeSliceForeground.run(SKAction.fadeOut(withDuration: fadeDuration))
    }

    override func update(_ currentTime: TimeInterval) {
        if !activeEnemies.isEmpty {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()

                    if node.name == "enemy" || node.name == "superFastEnemy" {
                        if node.name == "enemy" {
                            subtractLife()
                        }
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }

                nextSequenceQueued = true
            }
        }

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
