//
//  CreationView.swift
//  mac_test
//
//  Created by 应璐暘 on 2024/5/10.
//

import SwiftUI

struct CreationView: View {
    @State private var newPointName: String = ""
    @State private var newSourceURL: URL = (UserDefaults.standard.url(forKey: "defaultBottleLocation") ?? FileManager.default.temporaryDirectory)
    @State private var newTargetURL: URL = (UserDefaults.standard.url(forKey: "defaultBottleLocation") ?? FileManager.default.temporaryDirectory)
    @State private var nameValid: Bool = false
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $newPointName)
                    .onChange(of: newPointName) { _, name in
                        nameValid = !name.isEmpty
                    }
                ActionView(
                    text: "Source Path",
                    subtitle: newSourceURL.path(),
                    actionName: "Browse"
                ) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = true
                    panel.begin { result in
                        if result == .OK, let url = panel.urls.first {
                            newSourceURL = url
                        }
                    }
                }
                ActionView(
                    text: "Target Path",
                    subtitle: newTargetURL.path(),
                    actionName: "Browse"
                ) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = true
                    panel.begin { result in
                        if result == .OK, let url = panel.urls.first {
                            newTargetURL = url
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Create")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Create") {
                        submit()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!nameValid)
                }
            }
            .onSubmit {
                submit()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: 400)
    }

    func submit() {
        print("提交")
    }
}

#Preview {
    CreationView()
}
