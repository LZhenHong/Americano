import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

// 2560x1600 marketing canvas: headline + subtitle on top, window shot with soft shadow below.
// Usage: compose <in.png> <headline> <subtitle> <out.png>

let args = CommandLine.arguments
let (inPath, headline, subtitle, outPath) = (args[1], args[2], args[3], args[4])
let W = 2560, H = 1600

guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: inPath) as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
  print("bad input"); exit(1)
}

guard let cs = CGColorSpace(name: CGColorSpace.sRGB),
      let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8,
                          bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
  print("context failed"); exit(1)
}

// Background: warm off-white
ctx.setFillColor(CGColor(colorSpace: cs, components: [0xFA / 255.0, 0xF9 / 255.0, 0xF7 / 255.0, 1])!)
ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

func drawCentered(_ text: String, font: CTFont, color: CGColor, topY: CGFloat) -> CGFloat {
  let attrs: [CFString: Any] = [
    kCTFontAttributeName: font,
    kCTForegroundColorAttributeName: color,
  ]
  let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs as [NSAttributedString.Key: Any]))
  let b = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
  let bounds = CTLineGetBoundsWithOptions(line, [])
  let x = (CGFloat(W) - b.width) / 2 - b.minX
  let baselineY = topY - bounds.maxY
  ctx.textPosition = CGPoint(x: x, y: baselineY)
  CTLineDraw(line, ctx)
  return bounds.height
}

let headlineFont = CTFontCreateUIFontForLanguage(.emphasizedSystem, 132, nil)!
let subtitleFont = CTFontCreateUIFontForLanguage(.system, 58, nil)!
let ink = CGColor(colorSpace: cs, components: [0x1D / 255.0, 0x1D / 255.0, 0x1F / 255.0, 1])!
let gray = CGColor(colorSpace: cs, components: [0x6E / 255.0, 0x6E / 255.0, 0x73 / 255.0, 1])!

let topMargin: CGFloat = 150
let hh = drawCentered(headline, font: headlineFont, color: ink, topY: CGFloat(H) - topMargin)
_ = drawCentered(subtitle, font: subtitleFont, color: gray, topY: CGFloat(H) - topMargin - hh - 46)

let winTop = CGFloat(H) - topMargin - hh - 46 - 84 - 90
let winBottom: CGFloat = 90
let availH = winTop - winBottom
let maxW: CGFloat = 1900
let iw = CGFloat(img.width), ih = CGFloat(img.height)
let scale = min(maxW / iw, availH / ih)
let dw = round(iw * scale), dh = round(ih * scale)
let dx = (CGFloat(W) - dw) / 2
let dy = winBottom + (availH - dh) / 2

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -28), blur: 70,
              color: CGColor(colorSpace: cs, components: [0, 0, 0, 0.25])!)
ctx.interpolationQuality = .high
ctx.draw(img, in: CGRect(x: dx, y: dy, width: dw, height: dh))
ctx.restoreGState()

guard let out = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outPath) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
  print("output failed"); exit(1)
}
CGImageDestinationAddImage(dest, out, nil)
guard CGImageDestinationFinalize(dest) else { print("finalize failed"); exit(1) }
print("\(outPath): window \(Int(dw))x\(Int(dh)) @(\(Int(dx)),\(Int(dy)))")
