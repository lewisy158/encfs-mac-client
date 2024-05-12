
import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject var pointModel: PointModel

    @State private var showImportation: Bool = false
    @State private var deleteConfirmation: Bool = false
    @State private var selectedIndex: Int = -1
    @State private var selectedMountState: Bool = false
    @State private var password: String = ""
    @State private var errorState: Bool = false
    @State private var errorString: String = ""

    var body: some View {
        NavigationSplitView {
            pointView
        } detail: {
            Text("Select a point")
        }
        .toolbar {
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
                .disabled(pointModel.points.isEmpty || selectedMountState)
            }
        }
        .sheet(isPresented: $showImportation) {
            ImportView(pointModel: pointModel)
        }
        .alert(isPresented: $deleteConfirmation) {
            Alert(
                title: Text("Delete Point"),
                message: Text("Are you sure you want to delete this point?"),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Delete")) {
                    pointModel.deletePoint(index: selectedIndex)
                }
            )
        }
    }
    
    @ViewBuilder
    var pointView: some View {
        List(selection: $selectedIndex) {
            ForEach(pointModel.points.indices, id: \.self) { index in
                NavigationLink {
                    HStack {
                        if (!pointModel.points[index].mountState) {
                            SecureField("Password", text: $password)
                                .frame(width: 120)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            Button {
                                let result = pointModel.points[index].mount(password: password)
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
                        } else {
                            Button {
                                let result = pointModel.points[index].umount()
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
                        }
                    }
                } label: {
                    Text(pointModel.points[index].name)
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        .alert(errorString, isPresented: $errorState) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: selectedIndex) {
            password = ""
            if (0 <= selectedIndex && selectedIndex+1 <= pointModel.points.count) {
                selectedMountState = pointModel.points[selectedIndex].mountState
            }
        }
    }
}

#Preview {
    ContentView(pointModel: PointModel())
}
