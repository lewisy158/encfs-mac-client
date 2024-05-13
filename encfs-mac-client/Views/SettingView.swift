
import SwiftUI

struct SettingsView: View {
    var window: NSWindow?
    @State var encfsPath: String
    
    var body: some View {
        VStack {
            HStack {
                TextField("encfs path", text: $encfsPath)
                    .padding(4)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                Button {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = false
                    panel.begin { result in
                        if result == .OK, let url = panel.urls.first {
                            encfsPath = url.path()
                        }
                    }
                } label: {
                    HStack {
                        Text("Browse")
                    }
                    .padding(2)
                }
            }
            
            Button {
                UserDefaults.standard.set(encfsPath, forKey: "encfsPath")
                window?.close()
            } label: {
                HStack {
                    Text("Set")
                }
                .padding(6)
                .frame(width: 60)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
        }
        .padding()
        .frame(width: 300, height: 120)
    }
}

#Preview {
    SettingsView(encfsPath: DefaultEncfsPath)
}
