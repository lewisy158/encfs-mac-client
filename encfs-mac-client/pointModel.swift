
import Foundation

struct Point: Codable, Identifiable {
    var id = UUID()
    var name: String
    var sourcePath: String
    var mountPath: String
    var mountState: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case sourcePath
        case mountPath
    }

    mutating func mount(password: String) -> (code: Int32, errorString: String) {
        if self.mountState {
            return (-1, "already mount")
        }
        
        if let encfsPath = UserDefaults.standard.string(forKey: "encfsPath") {
            let command = "echo '\(password)' | \(encfsPath) --stdinpass '\(self.sourcePath)' '\(self.mountPath)'"
            let result = shell(command)
            if (result.code == 0) {
                self.mountState = true
            }
            return (result.code, result.errorString)
        } else {
            return (-1, "can not get encfsPath")
        }
    }
    
    mutating func umount() -> (code: Int32, errorString: String) {
        if !self.mountState {
            return (-1, "already umount")
        }
        
        if let encfsPath = UserDefaults.standard.string(forKey: "encfsPath") {
            let command = "\(encfsPath) -u '\(self.mountPath)'"
            let result = shell(command)
            if (result.code == 0) {
                self.mountState = false
            }
            return (result.code, result.errorString)
        } else {
            return (-1, "can not get encfsPath")
        }
    }
}

class PointManager: ObservableObject {
    @Published var points: [Point]
    
    init() {
        self.points = []
        if let data = UserDefaults.standard.data(forKey: "points") {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([Point].self, from: data) {
                self.points = decodedData
            }
        }
    }

    func createPoint(point: inout Point, password: String) -> (state: Bool, errorString: String) {
        if (!points.contains(where: { $0.name == point.name })) {
            if let encfsPath = UserDefaults.standard.string(forKey: "encfsPath") {
                let command = #"echo '\n\n"# + password + #"\n"# + password + #"\n' | "# + encfsPath + " --stdinpass '\(point.sourcePath)' '\(point.mountPath)'"
                let result = shell(command)
                if (result.code == 0) {
                    point.mountState = true
                    self.points.append(point)
                    saveData()
                }
                return (result.code==0 ? false : true, result.errorString)
            } else {
                return (true, "Can not get encfsPath")
            }
        } else {
            return (true, "Name repeated")
        }
    }
    
    func importPoint(point: Point) -> (state: Bool, errorString: String) {
        if (!points.contains(where: { $0.name == point.name })) {
            self.points.append(point)
            saveData()
            return (false, "")
        } else {
            return (true, "Name repeated")
        }
    }
    
    func updatePoint(index: Int, point: Point) {
        points[index] = point
        saveData()
    }
    
    func deletePoint(index: Int) {
        self.points.remove(at: index)
        saveData()
        print(self.points.count)
    }
    
    func canExist() -> Bool {
        if (!points.contains(where: { $0.mountState == true })) {
            return false
        } else {
            return true
        }
    }
    
    func umount() {
        for index in 0...points.count {
            if points[index].mountState {
                _ = points[index].umount()
            }
        }
    }
    
    private func saveData() {
        let encoder = JSONEncoder()
        if let encoderdData = try? encoder.encode(self.points) {
            UserDefaults.standard.set(encoderdData, forKey: "points")
        }
    }
}

func shell(_ command: String) -> (code: Int32, errorString: String) {
//    print("command: \(command)")
    
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    do {
        try task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        return (task.terminationStatus, output)
    } catch {
        return (-1, "Error executing command: \(error.localizedDescription)")
    }
}
