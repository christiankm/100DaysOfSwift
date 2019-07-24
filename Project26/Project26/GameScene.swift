//
//  GameScene.swift
//  Project26
//
//  Created by Christian Mitteldorf on 24/07/2019.
//  Copyright © 2019 MobilePay. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

enum CollisionType: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene {

    var player: SKSpriteNode!
    var lastTouchPoint: CGPoint?
    var motionManager: CMMotionManager!
    var isGameOver = false
    var level = 1

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 32)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        loadLevel(1)
        createPlayer()

        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }

    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.star.rawValue | CollisionType.vortex.rawValue | CollisionType.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.wall.rawValue
        addChild(player)
    }

    func loadLevel(_ level: Int) {
        guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt"),
              let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level")
        }

        let lines = levelString.components(separatedBy: "\n")

        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                switch letter {
                case "x":
                    // load wall
                    let wall = SKSpriteNode(imageNamed: "block")
                    wall.position = position
                    wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
                    wall.physicsBody?.categoryBitMask = CollisionType.wall.rawValue
                    wall.physicsBody?.isDynamic = false
                    addChild(wall)
                case "v":
                    // load vortex
                    let vortex = SKSpriteNode(imageNamed: "vortex")
                    vortex.name = "vortex"
                    vortex.position = position
                    vortex.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    vortex.physicsBody = SKPhysicsBody(circleOfRadius: vortex.size.width / 2)
                    vortex.physicsBody?.isDynamic = false
                    vortex.physicsBody?.categoryBitMask = CollisionType.vortex.rawValue
                    vortex.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                    vortex.physicsBody?.collisionBitMask = 0
                    addChild(vortex)
                case "s":
                    // load star
                    let star = SKSpriteNode(imageNamed: "star")
                    star.name = "star"
                    star.physicsBody = SKPhysicsBody(circleOfRadius: star.size.width / 2)
                    star.physicsBody?.isDynamic = false
                    star.physicsBody?.categoryBitMask = CollisionType.star.rawValue
                    star.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                    star.physicsBody?.collisionBitMask = 0
                    star.position = position
                    addChild(star)
                case "f":
                    // load finish
                    let finish = SKSpriteNode(imageNamed: "finish")
                    finish.name = "finish"
                    finish.physicsBody = SKPhysicsBody(circleOfRadius: finish.size.width / 2)
                    finish.physicsBody?.isDynamic = false
                    finish.physicsBody?.categoryBitMask = CollisionType.finish.rawValue
                    finish.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                    finish.physicsBody?.collisionBitMask = 0
                    finish.position = position
                    addChild(finish)
                case " ":
                    // empty space, do nothing
                    break
                default:
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if targetEnvironment(simulator)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPoint = location
        #endif
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if targetEnvironment(simulator)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPoint = location
        #endif
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if targetEnvironment(simulator)
        lastTouchPoint = nil
        #endif
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        #if targetEnvironment(simulator)
        if let currentTouch = lastTouchPoint {
            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
    }
}

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else {
            return
        }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }

    func playerCollided(with node: SKNode) {
        switch node.name {
        case "vortex":
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1

            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            player.run(sequence) { [weak self] in
                self?.physicsWorld.gravity = .zero
                self?.createPlayer()
                self?.isGameOver = false
            }
        case "star":
            node.removeFromParent()
            score += 1
        case "finish":
            // load next level
            player.removeFromParent()
            let nextLevel = level + 1
            loadLevel(nextLevel)
            createPlayer()
        default:
            break
        }
    }
}
