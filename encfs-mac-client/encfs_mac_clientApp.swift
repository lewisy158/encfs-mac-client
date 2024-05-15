
import SwiftUI
import SwiftData

let DefaultEncfsPath = "/opt/homebrew/bin/encfs"
var pointManager = PointManager()

@main
struct encfs_mac_clientApp: App {

    init() {
        if (UserDefaults.standard.string(forKey: "encfsPath") == nil) {
            UserDefaults.standard.set(DefaultEncfsPath, forKey: "encfsPath")
        }
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView(pointManager: pointManager)
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
            CommandGroup(replacing: .windowSize) {}
        }
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
            if !pointManager.canExist() {
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
                pointManager.umount()
                return .terminateNow
            } else {
                return .terminateCancel
            }
        }
    }
}
