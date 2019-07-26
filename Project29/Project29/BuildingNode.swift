//
//  BuildingNode.swift
//  Project29
//
//  Created by Christian Mitteldorf on 26/07/2019.
//  Copyright © 2019 MobilePay. All rights reserved.
//

import UIKit
import SpriteKit
import CoreGraphics

class BuildingNode: SKSpriteNode {

    var currentImage: UIImage!

    func setup() {
        name = "building"

        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)

        configurePhysics()
    }

    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionType.building.rawValue
        physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
    }

    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rectangle = CGRect(origin: .zero, size: size)
            let color: UIColor

            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }

            color.setFill()
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fill)

            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)

            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    Bool.random() ? lightOnColor.setFill() : lightOffColor.setFill()
                    context.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }

        return image
    }
}
