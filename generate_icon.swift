import AppKit
import Foundation

func generateIcon(size: CGFloat, filename: String) {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    let context = NSGraphicsContext.current?.cgContext
    
    // Background: Dark Gradient
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let path = NSBezierPath(roundedRect: rect, xRadius: size * 0.22, yRadius: size * 0.22)
    path.addClip()
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1.0).cgColor,
        NSColor(red: 0.08, green: 0.08, blue: 0.15, alpha: 1.0).cgColor
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    context?.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint.zero, options: [])
    
    // Subtle Glowing Ring
    let ringPath = NSBezierPath(ovalIn: rect.insetBy(dx: size * 0.1, dy: size * 0.1))
    NSColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.15).setStroke()
    ringPath.lineWidth = size * 0.03
    ringPath.stroke()
    
    // Metro Train Symbol (Sleek Modern)
    let center = size / 2
    let w = size * 0.4
    let h = size * 0.5
    
    let trainPath = NSBezierPath()
    trainPath.move(to: NSPoint(x: center - w/2, y: center - h/2))
    trainPath.line(to: NSPoint(x: center + w/2, y: center - h/2))
    trainPath.line(to: NSPoint(x: center + w/2, y: center + h/4))
    
    // Smooth top curve
    trainPath.curve(to: NSPoint(x: center, y: center + h/2), controlPoint1: NSPoint(x: center + w/2, y: center + h/2.2), controlPoint2: NSPoint(x: center + w/4, y: center + h/2))
    trainPath.curve(to: NSPoint(x: center - w/2, y: center + h/4), controlPoint1: NSPoint(x: center - w/4, y: center + h/2), controlPoint2: NSPoint(x: center - w/2, y: center + h/2.2))
    
    trainPath.close()
    
    let trainGradientColors = [
        NSColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0).cgColor,
        NSColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0).cgColor
    ] as CFArray
    let trainGradient = CGGradient(colorsSpace: colorSpace, colors: trainGradientColors, locations: [0.0, 1.0])!
    
    context?.saveGState()
    trainPath.addClip()
    context?.drawLinearGradient(trainGradient, start: CGPoint(x: 0, y: center + h/2), end: CGPoint(x: 0, y: center - h/2), options: [])
    context?.restoreGState()
    
    // Windshield (Glassy look)
    let wsWidth = w * 0.75
    let wsHeight = h * 0.3
    let wsRect = NSRect(x: center - wsWidth/2, y: center + h*0.05, width: wsWidth, height: wsHeight)
    let wsPath = NSBezierPath(roundedRect: wsRect, xRadius: size * 0.03, yRadius: size * 0.03)
    NSColor(white: 1.0, alpha: 0.9).set()
    wsPath.fill()
    
    // Headlights
    let lightY = center - h*0.2
    let lightSize = size * 0.04
    let leftLight = NSBezierPath(ovalIn: NSRect(x: center - w*0.35, y: lightY, width: lightSize, height: lightSize))
    let rightLight = NSBezierPath(ovalIn: NSRect(x: center + w*0.35 - lightSize, y: lightY, width: lightSize, height: lightSize))
    
    NSColor.white.set()
    leftLight.fill()
    rightLight.fill()
    
    // Glow for lights
    context?.setShadow(offset: .zero, blur: size * 0.05, color: NSColor.cyan.cgColor)
    NSColor.cyan.set()
    leftLight.fill()
    rightLight.fill()
    
    image.unlockFocus()
    
    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        try? pngData.write(to: URL(fileURLWithPath: filename))
    }
}

generateIcon(size: 1024, filename: "AppIcon_1024.png")
print("Generated AppIcon_1024.png")
