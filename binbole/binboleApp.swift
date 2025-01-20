//
//  binboleApp.swift
//  binbole
//
//  Created by Ammar Sura on 19/01/25.
//

import SwiftUI
import HotKey

extension Color {
    static var darkPurple: Color {
        return (Color(red: 0.67, green: 0.27, blue: 0.69))
    }
    
    static var lightPurple: Color {
        return (Color(red: 0.77, green: 0.68, blue: 0.78))
    }
}
@main
struct binboleApp: App {
    @StateObject private var windowController = WindowController()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 200, height: 300)
        .defaultPosition(.center)
        .commands {
            // Disable the standard "Close Window" command to prevent accidental termination
            CommandGroup(replacing: .windowSize) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set as accessory app
        NSApp.setActivationPolicy(.accessory)
        
//         Prevent window from being released when closed
        if let window = NSApplication.shared.windows.first {
            window.isReleasedWhenClosed = false
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

class WindowController: ObservableObject {
    private var hotKey: HotKey?

    init() {
        // Set window level to screenSaver when app launches
        if let window = NSApplication.shared.windows.first {
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }

        hotKey = HotKey(key: .d, modifiers: [.command, .shift])
        hotKey?.keyDownHandler = { [weak self] in
            self?.toggleWindow()
        }
    }

    func toggleWindow() {
        if let window = NSApplication.shared.windows.first {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                // Get the current mouse location
                let mouseLocation = NSEvent.mouseLocation
                // Convert screen coordinates to window coordinates
                window.setFrameTopLeftPoint(mouseLocation)

                window.level = .screenSaver  // Ensure window stays above fullscreen apps
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}
