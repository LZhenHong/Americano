//
//  main.swift
//  Americano
//
//  Created by Eden on 2023/12/26.
//

import Cocoa

// https://sarunw.com/posts/how-to-create-macos-app-without-storyboard/#assign-appdelegate-to-nsapplication

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
