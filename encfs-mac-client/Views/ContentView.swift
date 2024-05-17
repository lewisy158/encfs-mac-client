
import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject var pointManager: PointManager

    @State private var showCreation: Bool = false
    @State private var showImportation: Bool = false
    @State private var deleteConfirmation: Bool = false
    @State private var selectedIndex: Int = -1
    @State private var selectedMountState: Bool = false
    
    @State private var password: String = ""
    @State private var errorState: Bool = false
    @State private var errorString: String = ""

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedIndex) {
                pointView
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .alert(errorString, isPresented: $errorState) {
                Button("OK", role: .cancel) {}
            }
            .onChange(of: selectedIndex) {
                password = ""
                if (0 <= selectedIndex && selectedIndex+1 <= pointManager.points.count) {
                    selectedMountState = pointManager.points[selectedIndex].mountState
                }
            }
        } detail: {
            Text("Select a point")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showCreation.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showImportation.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    deleteConfirmation.toggle()
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(pointManager.points.isEmpty || selectedMountState)
            }
        }
        .sheet(isPresented: $showCreation) {
            CreationView(pointManager: pointManager)
        }
        .sheet(isPresented: $showImportation) {
            ImportView(pointManager: pointManager)
        }
        .alert(isPresented: $deleteConfirmation) {
            Alert(
                title: Text("Delete Point"),
                message: Text("Are you sure you want to delete this point?"),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Delete")) {
                    pointManager.deletePoint(index: selectedIndex)
                }
            )
        }
    }
    
    @ViewBuilder
    var pointView: some View {
        ForEach(pointManager.points.indices, id: \.self) { index in
            NavigationLink {
                Form {
                    ActionView(
                        text: "Source Path",
                        subtitle: pointManager.points[index].sourcePath,
                        actionName: "Browse"
                    ) {
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true
                        panel.allowsMultipleSelection = false
                        panel.canCreateDirectories = true
                        panel.begin { result in
                            if result == .OK, let url = panel.urls.first {
                                var point = pointManager.points[index]
                                point.sourcePath = url.path(percentEncoded: false)
                                pointManager.updatePoint(index: index, point: point)
                            }
                        }
                    }
                    .disabled(pointManager.points[index].mountState)
                    
                    ActionView(
                        text: "Mount Path",
                        subtitle: pointManager.points[index].mountPath,
                        actionName: "Browse"
                    ) {
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true
                        panel.allowsMultipleSelection = false
                        panel.canCreateDirectories = true
                        panel.begin { result in
                            if result == .OK, let url = panel.urls.first {
                                var point = pointManager.points[index]
                                point.mountPath = url.path(percentEncoded: false)
                                pointManager.updatePoint(index: index, point: point)
                            }
                        }
                    }
                    .disabled(pointManager.points[index].mountState)
                    
                    if (!pointManager.points[index].mountState) {
                        SecureField("Password:", text: $password)
                        HStack {
                            Spacer()
                            Button {
                                let result = pointManager.points[index].mount(password: password)
                                password = ""
                                if result.code != 0 {
                                    errorString = result.errorString
                                    errorState = true
                                } else {
                                    selectedMountState = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "externaldrive.badge.plus")
                                    Text("Mount")
                                }
                                .padding(6)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                            .disabled(password.isEmpty)
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button {
                                let result = pointManager.points[index].umount()
                                if result.code != 0 {
                                    errorString = result.errorString
                                    errorState = true
                                } else {
                                    selectedMountState = false
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "externaldrive.badge.minus")
                                    Text("Umount")
                                }
                                .padding(6)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                            Spacer()
                        }
                    }
                }
                .formStyle(.grouped)
                .frame(width: 400)
            } label: {
                Text(pointManager.points[index].name)
            }
        }
    }
}

#Preview {
    ContentView(pointManager: PointManager())
}
