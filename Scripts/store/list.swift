import CoreGraphics
import Foundation

// Usage: swift list.swift <pid>
// Prints: windowID layer x y w h title

let pid = Int32(CommandLine.arguments[1])!
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
for w in list {
  guard let owner = w[kCGWindowOwnerPID as String] as? Int32, owner == pid,
        let winNum = w[kCGWindowNumber as String] as? UInt32,
        let boundsDict = w[kCGWindowBounds as String] as? [String: Any],
        let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary)
  else { continue }
  let layer = w[kCGWindowLayer as String] as? Int ?? -1
  let title = w["kCGWindowTitle"] as? String ?? ""
  print("\(winNum)\tlayer=\(layer)\t\(Int(bounds.minX)),\(Int(bounds.minY)) \(Int(bounds.width))x\(Int(bounds.height))\t\(title)")
}
