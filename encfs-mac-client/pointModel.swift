
import Foundation
import os.log

let encodedKeySize = 44
let saltLength = 20

let keySize = 192
let blockSize = 1024

struct Point: Codable, Identifiable {
    var id = UUID()
    var name: String
    var sourceUrl: String
    var targetUrl: String
    var mountState: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case sourceUrl
        case targetUrl
    }
    
    mutating func mount(password: String) -> (code: Int32, errorString: String) {
        if self.mountState {
            return (-1, "already mount")
        }
        
        if let encfsPath = UserDefaults.standard.string(forKey: "encfsPath") {
            let command = "echo '\(password)' | \(encfsPath) --stdinpass '\(self.sourceUrl)' '\(self.targetUrl)'"
            let result = shell(command)
            if (result.code == 0) {
                self.mountState = true
            }
            return (result.code, result.errorString)
        } else {
            Logger.encfs.error("can not get encfsPath")
            return (-1, "can not get encfsPath")
        }
        
    }
    
    mutating func umount() -> (code: Int32, errorString: String) {
        if !self.mountState {
            return (-1, "already umount")
        }
        
        if let encfsPath = UserDefaults.standard.string(forKey: "encfsPath") {
            let command = "\(encfsPath) -u '\(self.targetUrl)'"
            let result = shell(command)
            if (result.code == 0) {
                self.mountState = false
            }
            return (result.code, result.errorString)
        } else {
            Logger.encfs.error("can not get encfsPath")
            return (-1, "can not get encfsPath")
        }
    }
}

class PointModel: ObservableObject {
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
    
//    func createPoint(point: Point, password: String) -> Bool {
//        if (!points.contains(where: { $0.name == point.name })) {
//            
//            let kdfIterations = Int.random(in: 700000...800000)
//            
//            self.points.append(point)
//            saveData()
//            return false
//        } else {
//            return true
//        }
//    }
    
    func importPoint(point: Point) -> Bool {
        if (!points.contains(where: { $0.name == point.name })) {
            self.points.append(point)
            saveData()
            return false
        } else {
            return true
        }
    }
    
    func updatePoint(index: Int, point: Point) {
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
//    Logger.encfs.info("command: \(command)")
    
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
        Logger.encfs.error("An error occurred: \(error)")
        return (-1, "Error executing command: \(error.localizedDescription)")
    }
}

//func generateSalt(length: Int) -> Data {
//    var salt = Data(count: length)
//    salt.withUnsafeMutableBytes { buffer in
//        _ = SecRandomCopyBytes(kSecRandomDefault, length, buffer.baseAddress!)
//    }
//    return salt
//}



func generateKey(password: String) {
    
}
