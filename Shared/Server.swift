import Foundation

struct Server: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var host: String
    var port: Int = 22
    var username: String
    var authType: AuthType = .password
    var password: String? // lưu trong Keychain thực tế, đây là demo
    var privateKey: String?
    var useTMUX: Bool = true
    var initialPath: String = "~"
    var isOfflineEnabled: Bool = false
    
    enum AuthType: String, Codable {
        case password, key, yubikey, certificate
    }
    
    var displayHost: String { "\(username)@\(host):\(port)" }
}

// MARK: - SFTP File Attributes
struct SFTPFile: Identifiable {
    var id: String { path }
    var name: String
    var path: String
    var isDirectory: Bool
    var size: Int64
    var modDate: Date
    var permissions: Int
}
