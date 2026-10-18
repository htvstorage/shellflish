import Foundation
import Citadel // SSH client Swift - add via SPM: https://github.com/orlandos-nl/Citadel

// SFTP Client wrapper dùng cho cả App và FileProvider
actor SFTPClient {
    let server: Server
    private var sshClient: SSHClient?
    private var sftpClient: SFTPClientImpl?
    
    init(server: Server) {
        self.server = server
    }
    
    func connect() async throws {
        let auth: SSHAuthenticationMethod
        if let key = server.privateKey {
            auth = try .privateKey(pem: key)
        } else {
            auth = .passwordBased(username: server.username, password: server.password ?? "")
        }
        
        sshClient = try await SSHClient.connect(
            host: server.host,
            port: server.port,
            authenticationMethod: auth,
            hostKeyValidator: .acceptAnything() // production: check known_hosts
        )
        sftpClient = try await sshClient!.openSFTP()
    }
    
    func listDirectory(_ path: String) async throws -> [SFTPFile] {
        guard let sftp = sftpClient else { throw NSError(domain: "Not connected", code: 0) }
        let list = try await sftp.listDirectory(atPath: path)
        return list.map { entry in
            SFTPFile(
                name: entry.filename,
                path: (path as NSString).appendingPathComponent(entry.filename),
                isDirectory: entry.attributes.isDirectory,
                size: Int64(entry.attributes.size ?? 0),
                modDate: entry.attributes.modificationDate ?? Date(),
                permissions: Int(entry.attributes.permissions ?? 0)
            )
        }
    }
    
    func downloadFile(remotePath: String, localURL: URL) async throws {
        try await sftpClient?.downloadFile(atPath: remotePath, to: localURL.path)
    }
    
    func uploadFile(localURL: URL, remotePath: String) async throws {
        try await sftpClient?.uploadFile(atPath: localURL.path, to: remotePath)
    }
    
    func createDirectory(at path: String) async throws {
        try await sftpClient?.createDirectory(atPath: path)
    }
    
    func deleteFile(at path: String) async throws {
        try await sftpClient?.removeFile(atPath: path)
    }
    
    func rename(from oldPath: String, to newPath: String) async throws {
        try await sftpClient?.renameFile(atPath: oldPath, to: newPath)
    }
}

// Singleton cache cho FileProvider (vì FileProvider extension chạy process riêng)
class SFTPConnectionPool {
    static let shared = SFTPConnectionPool()
    private var clients: [String: SFTPClient] = [:] // key = server.id
    
    func client(for server: Server) -> SFTPClient {
        let key = server.id.uuidString
        if let c = clients[key] { return c }
        let newClient = SFTPClient(server: server)
        clients[key] = newClient
        return newClient
    }
}
