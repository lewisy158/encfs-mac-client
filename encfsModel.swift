
import Foundation

class EncfsModel: ObservableObject {
    @Published var url = "/opt/homebrew/bin/encfs"
    
    init() {
        if let encfsUrl = UserDefaults.standard.string(forKey: "encfsUrl") {
            self.url = encfsUrl
        }
    }
    
    func update(url: String) {
        self.url = url
        UserDefaults.standard.set(url, forKey: "encfsUrl")
    }
}
