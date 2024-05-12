
import SwiftUI
import SwiftData
import os.log

let DefaultEncfsUrl = "/opt/homebrew/bin/encfs"
var pointModel = PointModel()

@main
struct encfs_mac_clientApp: App {
    
    init() {
        if (UserDefaults.standard.string(forKey: "encfsUrl") == nil) {
            UserDefaults.standard.set(DefaultEncfsUrl, forKey: "encfsUrl")
            Logger.encfs.log("set default encfsUrl")
        }
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView(pointModel: pointModel)
        }
    }
    
    class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
        func applicationDidFinishLaunching(_ notification: Notification) {
            let mainWindow = NSApp.windows[0]
            mainWindow.delegate = self
        }
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            if !pointModel.canExist() {
                NSApplication.shared.terminate(self)
                return true
            }
            
            let alert = NSAlert()
            alert.messageText = "Confirm Close"
            alert.informativeText = "Are you sure you want to umount all and close this window?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Umount && Close")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                pointModel.umount()
                NSApplication.shared.terminate(self)
                return true
            } else {
                return false
            }
        }
    }
}
