
import SwiftUI

struct ImportView: View {
    @ObservedObject var pointModel: PointModel
    
    @State private var newPointName: String = ""
    @State private var newSourceURL: String = ""
    @State private var newTargetURL: String = ""
    @State private var createState: Bool = false
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $newPointName)
                ActionView(
                    text: "Source Path",
                    subtitle: newSourceURL,
                    actionName: "Browse"
                ) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = false
                    panel.begin { result in
                        if result == .OK, let url = panel.urls.first {
                            newSourceURL = url.path()
                        }
                    }
                }
                ActionView(
                    text: "Target Path",
                    subtitle: newTargetURL,
                    actionName: "Browse"
                ) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = true
                    panel.begin { result in
                        if result == .OK, let url = panel.urls.first {
                            newTargetURL = url.path()
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
                    .disabled(newPointName.isEmpty || newSourceURL.isEmpty ||
                        newTargetURL.isEmpty)
                }
            }
            .onSubmit {
                submit()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: 400)
        .alert("Name repeated", isPresented: $createState) {
            Button("OK", role: .cancel) {}
        }
    }

    func submit() {
        let point = Point(
            name: newPointName,
            sourceUrl: newSourceURL,
            targetUrl: newTargetURL)
        createState = pointModel.addPoint(point: point)
        if !createState {
            dismiss()
        }
    }
}

#Preview {
    ImportView(pointModel: PointModel())
}
