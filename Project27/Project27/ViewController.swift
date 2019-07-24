//
//  ViewController.swift
//  Project27
//
//  Created by Christian Mitteldorf on 24/07/2019.
//  Copyright © 2019 MobilePay. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var currentDrawType = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        draw(self)
    }
    
    @IBAction func draw(_ sender: Any) {
        currentDrawType += 1
        if currentDrawType < 0 || currentDrawType > 5 {
            currentDrawType = 0
        }

        let rectSize = view.bounds.width * 0.9
        let rect = CGRect(x: 0, y: 0, width: rectSize, height: rectSize)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: rect.width, height: rect.height))

        let image: UIImage
        switch currentDrawType {
        case 0:
            image = drawRectangle(in: rect, with: renderer)
        case 1:
            image = drawCircle(in: rect, with: renderer)
        case 2:
            image = drawCheckerboard(in: rect, with: renderer)
        case 3:
            image = drawRotatedSquares(in: rect, with: renderer)
        case 4:
            image = drawLines(in: rect, with: renderer)
        case 5:
            image = drawImagesAndText(in: rect, with: renderer)
        default:
            fatalError()
        }

        imageView.image = image
    }

    func drawRectangle(in rect: CGRect, with renderer: UIGraphicsImageRenderer) -> UIImage {
        renderer.image { context in
            context.cgContext.setFillColor(UIColor.orange.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            context.cgContext.addRect(rect)
            context.cgContext.drawPath(using: .fillStroke)
        }
    }

    func drawCircle(in rect: CGRect, with renderer: UIGraphicsImageRenderer) -> UIImage {
        renderer.image { context in
            context.cgContext.setFillColor(UIColor.orange.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            context.cgContext.addEllipse(in: rect.insetBy(dx: 10, dy: 10))
            context.cgContext.drawPath(using: .fillStroke)
        }
    }

    func drawCheckerboard(in rect: CGRect, with renderer: UIGraphicsImageRenderer) -> UIImage {
        renderer.image { context in
            context.cgContext.setFillColor(UIColor.clear.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(4)
            context.cgContext.addRect(rect)
            context.cgContext.drawPath(using: .fillStroke)

            let fieldSize = Int(rect.width / 8)
            context.cgContext.setFillColor(UIColor.black.cgColor)
            for row in 0..<8 {
                for col in 0..<8 {
                    if (row + col).isMultiple(of: 2) {
                        context.cgContext.fill(CGRect(x: col * fieldSize, y: row * fieldSize, width: fieldSize, height: fieldSize))
                    }
                }
            }
        }
    }

    func drawRotatedSquares(in rect: CGRect, with renderer: UIGraphicsImageRenderer) -> UIImage {
        renderer.image { context in
            let size = rect.width / 2
            context.cgContext.translateBy(x: size, y: size)

            let rotations = 64
            let amount = Double.pi / Double(rotations)

            for _ in 0..<rotations {
                context.cgContext.rotate(by: CGFloat(amount))
                context.cgContext.addRect(CGRect(x: -(size / 2), y: -(size / 2), width: size, height: size))
            }

            context.cgContext.setStrokeColor(UIColor.orange.cgColor)
            context.cgContext.strokePath()
        }
    }

    func drawLines(in rect: CGRect, with renderer: UIGraphicsImageRenderer) -> UIImage {
        renderer.image { context in
            let size = rect.width / 2
            context.cgContext.translateBy(x: size, y: size)

            var first = true
            var length: CGFloat = size

            for _ in 0..<Int(size) {
                context.cgContext.rotate(by: .pi / 2)

                if first {
                    context.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    context.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }

                length *= 0.99
            }

            context.cgContext.setStrokeColor(UIColor.orange.cgColor)
            context.cgContext.strokePath()
        }
    }

    func drawImagesAndText(in rect: CGRect, with renderer: UIGraphicsImageRenderer) -> UIImage {
        renderer.image { context in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]

            let string = """
                         The best-laid schemes o'
                         mice an' men gang aft agley.
                         """
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            attributedString.draw(with: rect.insetBy(dx: 32, dy: 32), options: .usesLineFragmentOrigin, context: nil)

            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
    }
}
