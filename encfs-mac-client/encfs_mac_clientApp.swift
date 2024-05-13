
import SwiftUI
import SwiftData
import os.log

let DefaultEncfsPath = "/opt/homebrew/bin/encfs"
var pointModel = PointModel()

//func pbkdf2SHA1(password: String, salt: Data, iterations: Int, keyLength: Int) -> Data? {
//    var derivedKeyData = Data(repeating: 0, count: keyLength)
//    let result = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes -> Int32 in
//        salt.withUnsafeBytes { saltBytes -> Int32 in
//            CCKeyDerivationPBKDF(
//                CCPBKDFAlgorithm(kCCPBKDF2),                  // Algorithm
//                password,                                     // Password
//                password.count,                           // Password length
//                saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self), // Salt
//                salt.count,                                   // Salt length
//                CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),   // PRF
//                UInt32(iterations),                                   // Iterations
//                derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self), // Derived key
//                keyLength                                      // Derived key length
//            )
//        }
//    }
//    
//    return result == kCCSuccess ? derivedKeyData : nil
//}

@main
struct encfs_mac_clientApp: App {
    
    init() {
//        let data = decodeBase64ToData(base64String: "NUUoOMjixr9sElUnlRGfnSPCbgw=")
//        let data1 = pbkdf2SHA1(password: "110524", salt: data, iterations: 778309, keyLength: 44)
//        let array = [UInt8](data1!)
//        print(array)//[10]
        
        
//        let password     = "110524"
//        let keyByteCount = 44
//        let rounds       = 778309
//
//        let data1 = pbkdf2SHA1(password:password, salt:data, iterations:keyByteCount, rounds:rounds)
//        print("derivedKey (SHA1): \(data1! as NSData)")
//        
//        print(data1!.map { String(format: "%02x", $0) }.joined())
//        print(data1!.base64EncodedString())

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
