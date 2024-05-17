
import SwiftUI

struct CreationView: View {
    @ObservedObject var pointManager: PointManager
    
    @State private var newPointName: String = ""
    @State private var newPassword: String = ""
    @State private var newSourcePath: String = ""
    @State private var newMountPath: String = ""
    
    @State private var createState: Bool = false
    @State private var createErrorString: String = ""
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $newPointName)
                SecureField("Password", text: $newPassword)
                ActionView(
                    text: "Source Path",
                    subtitle: newSourcePath,
                    actionName: "Browse"
                ) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = false
                    panel.begin { result in
                        if result == .OK, let url = panel.urls.first {
                            newSourcePath = url.path(percentEncoded: false)
                        }
                    }
                }
                ActionView(
                    text: "Mount Path",
                    subtitle: newMountPath,
                    actionName: "Browse"
                ) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = true
                    panel.begin { result in
                        if result == .OK, let url = panel.urls.first {
                            newMountPath = url.path(percentEncoded: false)
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
                    .disabled(
                        newPointName.isEmpty ||
                        newPassword.isEmpty ||
                        newSourcePath.isEmpty ||
                        newMountPath.isEmpty)
                }
            }
            .onSubmit {
                submit()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: 400)
        .alert(createErrorString, isPresented: $createState) {
            Button("OK", role: .cancel) {}
        }
    }

    func submit() {
        var point = Point(
            name: newPointName,
            sourcePath: newSourcePath,
            mountPath: newMountPath)
        let result = pointManager.createPoint(point: &point, password: newPassword)
        if !result.state {
            createErrorString = result.errorString
        }
        createState = result.state
        if !createState {
            dismiss()
        }
    }
}

#Preview {
    CreationView(pointManager: PointManager())
}
