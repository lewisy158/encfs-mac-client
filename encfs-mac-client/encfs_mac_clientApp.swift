
import SwiftUI
import SwiftData
import os.log

let DefaultEncfsPath = "/opt/homebrew/bin/encfs"
var pointModel = PointModel()

@main
struct encfs_mac_clientApp: App {
    
    init() {
        if (UserDefaults.standard.string(forKey: "encfsPath") == nil) {
            UserDefaults.standard.set(DefaultEncfsPath, forKey: "encfsPath")
            Logger.encfs.log("set default encfsPath")
        }
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView(pointModel: pointModel)
        }
        .commands {
            CommandGroup(after: CommandGroupPlacement.appInfo, addition: {Button("Setting"){
                if let encfsPath = UserDefaults.standard.string(forKey: "encfsPath") {
                    let settingsWindow = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                        styleMask: [.titled, .closable],
                        backing: .buffered, defer: false)
                    settingsWindow.center()
                    settingsWindow.setFrameAutosaveName("Settings")
                    let settingsView = SettingsView(window: settingsWindow, encfsPath: encfsPath)
                    settingsWindow.contentView = NSHostingView(rootView: settingsView)
                    settingsWindow.isReleasedWhenClosed = false
                    settingsWindow.makeKeyAndOrderFront(nil)
                }
            }})
        }
    }
    
    // 设置窗口的 NSWindow 引用
//    var settingsWindow: NSWindow?

    // 方法用于打开设置窗口
    mutating func openSettings() {
        
    }
    
    class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
        func applicationDidFinishLaunching(_ notification: Notification) {
            let mainWindow = NSApp.windows[0]
            mainWindow.delegate = self
        }
        
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            let mainWindow = NSApp.windows[0]
            mainWindow.orderOut(nil)
            return false
        }
        
        func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
            let mainWindow = NSApp.windows[0]
            if !flag {
                mainWindow.makeKeyAndOrderFront(nil)
            }
            return true
        }
        
        func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
            if !pointModel.canExist() {
                return .terminateNow
            }
            
            let alert = NSAlert()
            alert.messageText = "Confirm Close"
            alert.informativeText = "Are you sure you want to umount all and close this window?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Umount && Quit")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                pointModel.umount()
                return .terminateNow
            } else {
                return .terminateCancel
            }
        }
    }
}
