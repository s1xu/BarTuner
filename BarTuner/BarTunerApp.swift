//
//  BarTunerApp.swift
//  BarTuner
//
//  Created by s1xu on 2025/2/15.
//

import SwiftUI

@main
struct BarTuner: App {
    @State private var window: NSWindow?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        self.window = window
                        window.setContentSize(NSSize(width: 400, height: 200))
                        window.styleMask.insert(.closable)
                        centerWindow(window)
                    }
                }
        }
    }
}

private func centerWindow(_ window: NSWindow) {
    if let screen = window.screen {
        let screenFrame = screen.frame
        let windowSize = window.frame.size
        let centerX = (screenFrame.size.width - windowSize.width) / 2
        let centerY = (screenFrame.size.height - windowSize.height) / 2
        let newOrigin = CGPoint(x: centerX, y: centerY)

        window.setFrameOrigin(newOrigin)
    }
}
