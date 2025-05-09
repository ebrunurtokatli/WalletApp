import UIKit

class PieChartView: UIView {

    var data: [(value: CGFloat, color: UIColor)] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - 10
        var startAngle: CGFloat = -.pi / 2

        let total = data.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        for item in data {
            let endAngle = startAngle + 2 * .pi * (item.value / total)
            context.setFillColor(item.color.cgColor)
            context.move(to: center)
            context.addArc(center: center, radius: radius,
                           startAngle: startAngle,
                           endAngle: endAngle,
                           clockwise: false)
            context.closePath()
            context.fillPath()
            startAngle = endAngle
        }
    }
}
