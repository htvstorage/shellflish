import FileProvider
import UniformTypeIdentifiers

class FileProviderExtension: NSFileProviderExtension {
    
    var fileManager = FileManager()
    var sftpPool = SFTPConnectionPool.shared
    var server: Server?
    
    override init() {
        super.init()
        // Load server config từ App Group
        loadServer()
    }
    
    func loadServer() {
        if let data = UserDefaults(suiteName: "group.com.shellfish.clone")?.data(forKey: "servers"),
           let servers = try? JSONDecoder().decode([Server].self, from: data) {
            server = servers.first // demo: lấy server đầu tiên, thực tế map theo domain
        }
    }
    
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        guard let server = server else { throw NSFileProviderError(.serverUnreachable) }
        
        if identifier == .rootContainer {
            return FileProviderItem(
                identifier: identifier,
                parent: .rootContainer,
                name: server.name,
                isDir: true,
                path: server.initialPath
            )
        }
        
        // Parse identifier -> path (identifier chính là path đã encode)
        let path = identifier.rawValue
        // Trong thực tế cần lưu metadata trong DB
        // Ở đây demo sync gọi SFTP
        return FileProviderItem(
            identifier: identifier,
            parent: .rootContainer,
            name: (path as NSString).lastPathComponent,
            isDir: false,
            path: path
        )
    }
    
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        // Trả về URL vật lý của file đã materialize
        return NSFileProviderManager.default.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: false)
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        return NSFileProviderItemIdentifier(url.lastPathComponent)
    }
    
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        // Tạo placeholder cho file chưa tải
        guard let identifier = persistentIdentifierForItem(at: url) else {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        do {
            let placeholderURL = NSFileProviderManager.default.placeholderURL(for: url)
            try fileManager.createDirectory(at: placeholderURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            // Viết metadata placeholder
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }
    
    override func startProvidingItem(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        // Files app yêu cầu nội dung thật của file
        guard let server = server else {
            completionHandler(NSFileProviderError(.serverUnreachable))
            return
        }
        let identifier = NSFileProviderItemIdentifier(url.lastPathComponent)
        let remotePath = identifier.rawValue
        
        Task {
            do {
                let client = sftpPool.client(for: server)
                try await client.connect()
                try await client.downloadFile(remotePath: remotePath, localURL: url)
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }
    
    override func itemChanged(at url: URL) {
        // User sửa file trong Textastic / iA Writer -> upload lại
        guard let server = server else { return }
        let remotePath = url.lastPathComponent // thực tế map lại
        Task {
            let client = sftpPool.client(for: server)
            try? await client.connect()
            try? await client.uploadFile(localURL: url, remotePath: remotePath)
        }
    }
    
    override func stopProvidingItem(at url: URL) {
        // Dọn cache khi hệ thống cần dung lượng
        try? fileManager.removeItem(at: url)
    }
    
    override func supportedServiceSources(for itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping ([NSFileProviderServiceSource]?) -> Void) -> Progress {
        // Hỗ trợ thumbnails
        completionHandler(nil)
        return Progress()
    }
}
