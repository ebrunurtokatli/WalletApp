import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

let categoryColors: [String: UIColor] = [
    "Maaş": UIColor(hex: "#AA60C8"),
    "Hediye": UIColor(hex: "#D69ADE"),
    "Yatırım": UIColor(hex: "#EABDE6"),
    "Yemek": UIColor(hex: "#FFDFEF"),
    "Ulaşım": UIColor(hex: "#B771E5"),
    "Fatura": UIColor(hex: "#441752"),
    "Diğer": UIColor(hex: "#A888B5"),
    "Alışveriş": UIColor(hex: "#7E5CAD"),
    "Sağlık": UIColor(hex: "#A294F9"),
    "Eğlence": UIColor(hex: "#8174A0")
]
