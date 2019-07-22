import UIKit

// 100 Days of Swift
// Project 24

var str = "Hello, playground"

let name = "Taylor"
for letter in name {
    print("Give me a \(letter)")
}

print(name[name.index(name.startIndex, offsetBy: 3)])

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

print(name[3])

let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

extension String {
    func removePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    func removeSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

let weather = "it's going to rain"
print(weather.capitalized)

extension String {
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

print(weather.capitalizedFirst)

let input = "Swift is like Objective-C without the C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }

        return false
    }
}

input.containsAny(of: languages)

languages.contains(where: input.contains)

let string = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]
let attributedString = NSMutableAttributedString(string: string, attributes: attributes)

attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

attributedString

// Challenge 1
extension String {
    func withPrefix(_ prefix: String) -> String {
        guard !self.hasPrefix(prefix) else { return self }
        return "\(prefix)\(self)"
    }
}

"pet".withPrefix("Car")
"Carpet".withPrefix("Car")

// Challenge 2
extension String {
    var isNumeric: Bool {
        if Double(self) != nil {
            return true
        }

        return false
    }
}

"pet".isNumeric
"3".isNumeric

// Challenge 3
extension String {
    var lines: [String.SubSequence] {
        return self.split(separator: "\n")
    }
}

"pet".lines
"""
This
is
a
pet
""".lines
