import UIKit

// 100 Days of Swift
// Day 82 Challenge

// Challenge 1
extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

let view = UIView()
view.backgroundColor = .red
view.bounceOut(duration: 1.0)

// Challenge 2
extension Int {
    func times(_ closure: @escaping () -> Void) {
        guard self > 0 else { return }
        for _ in 0..<self {
            closure()
        }
    }
}

0.times { print("Hello!") }
5.times { print("Hello!") }
let count = -5
count.times { print("Hello!") }

// Challenge 3
extension Array where Element: Comparable {
    mutating func remove(item: Element) -> Array {
        if let index = firstIndex(of: item) {
            remove(at: index)
        }

        return self
    }
}

var someArray = [1, 2, 3, 4, 5]
print(someArray.remove(item: 2))

var someDoubleArray = [1, 2, 2, 3, 4, 5]
print(someDoubleArray.remove(item: 2))
