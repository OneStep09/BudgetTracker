import UIKit
import Foundation

public class PieChartView: UIView {
    
    // MARK: - Properties
    
    private var entities: [Entity] = []
    private var newEntities: [Entity] = []
    private let colors: [UIColor] = [
        UIColor.systemYellow,
        UIColor.systemGreen,
        UIColor.systemBlue,
        UIColor.systemOrange,
        UIColor.systemPurple,
        UIColor.systemRed
    ]
    
    private let lineWidth: CGFloat = 8.0
    private let legendSpacing: CGFloat = 4.0
    private let legendDotSize: CGFloat = 8.0
    private let maxSeparateSegments = 5
    
    private var rotationAngle: CGFloat = 0
    private var fadeAlpha: CGFloat = 1.0
    private var isAnimating = false
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private let animationDuration: CFTimeInterval = 1.0
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
    }
    

    // MARK: - Public Methods
    public func configure(with entities: [Entity]) {
        if isAnimating {
            stopAnimation()
        }
        
        // Если данные одинаковые, не анимируем
        if self.entities.elementsEqual(entities, by: { $0.value == $1.value && $0.label == $1.label }) {
            return
        }
        
        newEntities = entities
        
        if self.entities.isEmpty {
            self.entities = entities
            setNeedsDisplay()
        } else {
            startAnimation()
        }
    }
    
    // MARK: - Private Animation Methods
    
    
    private func startAnimation() {
        stopAnimation()
        
        isAnimating = true
        animationStartTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        isAnimating = false
        rotationAngle = 0
        fadeAlpha = 1.0
    }
    
    
    @objc private func updateAnimation() {
        guard isAnimating  else {
            stopAnimation()
            return
        }
        
        let currentTime = CACurrentMediaTime()
        let elapsed = currentTime - animationStartTime
        let progress = min(elapsed / animationDuration, 1.0)
        
        // Вычисляем угол поворота (0 до 2π)
        rotationAngle = CGFloat(progress * 2 * Double.pi)
        
        
        if progress <= 0.5 {
            // Первая половина - fade out старых данных
            fadeAlpha = CGFloat(1.0 - (progress * 2))
        } else {
            // Вторая половина - fade in новых данных
            fadeAlpha = CGFloat((progress - 0.5) * 2)
            // В точке 180 градусов меняем данные
            if entities != newEntities {
                entities = newEntities
            }
        }
        
        setNeedsDisplay()
        
        if progress >= 1.0 {
            stopAnimation()
        }
    }
    
    // MARK: - Private Methods
    
    // Подготовка сегментов для отрисовки
    private func prepareSegments() -> [Entity] {
        guard !entities.isEmpty else { return [] }
        
        if entities.count <= maxSeparateSegments {
            // Если сущностей 5 или меньше — отображаем все
            return entities
        } else {
            // Берём первые 5 сущностей, остальные объединяем в "Остальные"
            let firstFive = Array(entities.prefix(maxSeparateSegments))
            let remaining = Array(entities.dropFirst(maxSeparateSegments))
            
            let restValue = remaining.reduce(Decimal(0)) { $0 + $1.value }
            let restEntity = Entity(value: restValue, label: "Остальные")
            
            return firstFive + [restEntity]
        }
    }
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let segments = prepareSegments()
        guard !segments.isEmpty else { return }
        
        
        let totalValue = segments.reduce(Decimal(0)) { $0 + $1.value }
        guard totalValue > 0 else { return }
        
        // Вычисляем центр и радиус диаграммы
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2 - 10
        
        
        context.saveGState()
        
        
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: rotationAngle)
        context.translateBy(x: -center.x, y: -center.y)
        
        
        context.setAlpha(fadeAlpha)
        
        
        let backgroundPath = UIBezierPath(arcCenter: center,
                                          radius: radius,
                                          startAngle: 0,
                                          endAngle: CGFloat.pi * 2,
                                          clockwise: true)
        backgroundPath.lineWidth = lineWidth
        UIColor.systemGray5.setStroke()
        backgroundPath.stroke()
        
        // Рисуем сегменты диаграммы
        var startAngle: CGFloat = -CGFloat.pi / 2 // Начинаем сверху
        
        for (index, entity) in segments.enumerated() {
            // Вычисляем процент сегмента
            let percentage = Double(truncating: entity.value as NSNumber) / Double(truncating: totalValue as NSNumber)
            let arcLength = CGFloat(percentage * 2 * Double.pi)
            let endAngle = startAngle - arcLength
            
            // Создаём путь дуги для сегмента
            let path = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
            
            
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
            
            let color = colors[index % colors.count]
            color.setStroke()
            path.stroke()
            
            startAngle = endAngle
        }
        
        
        drawLegend(in: rect, center: center, segments: segments, totalValue: totalValue)
        
        context.restoreGState()
    }
    
    
    private func drawLegend(in rect: CGRect, center: CGPoint, segments: [Entity], totalValue: Decimal) {
        let legendItems = segments.enumerated().map { (index, entity) -> (String, UIColor, String) in
            let percentage = Double(truncating: entity.value as NSNumber) / Double(truncating: totalValue as NSNumber)
            let percentageText = String(format: "%.0f%%", percentage * 100)
            let color = colors[index % colors.count]
            return (percentageText, color, entity.label)
        }
        
        
        let font = UIFont.systemFont(ofSize: 8, weight: .regular)
        let lineHeight = font.lineHeight + legendSpacing
        let totalLegendHeight = CGFloat(legendItems.count) * lineHeight - legendSpacing
        
        
        var yOffset = center.y - totalLegendHeight / 2
        
        for (percentage, color, label) in legendItems {
            // Рисуем цветную точку
            let dotRect = CGRect(x: center.x - 44,
                                 y: yOffset + (lineHeight - legendDotSize) / 2,
                                 width: legendDotSize,
                                 height: legendDotSize)
            let dotPath = UIBezierPath(ovalIn: dotRect)
            color.setFill()
            dotPath.fill()
            
            // Рисуем текст
            let text = "\(percentage) \(label)"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.label
            ]
            
            let textRect = CGRect(x: center.x - 44 + legendDotSize + 8,
                                  y: yOffset,
                                  width: 96,
                                  height: lineHeight)
            
            text.draw(in: textRect, withAttributes: textAttributes)
            yOffset += lineHeight
        }
    }
    
}




