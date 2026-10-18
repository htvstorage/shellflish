import FileProvider
import UniformTypeIdentifiers

class FileProviderItem: NSObject, NSFileProviderItem {
    let itemIdentifier: NSFileProviderItemIdentifier
    let parentItemIdentifier: NSFileProviderItemIdentifier
    let filename: String
    let isDirectory: Bool
    let remotePath: String
    let fileSize: NSNumber?
    let modifiedDate: Date?
    
    init(identifier: NSFileProviderItemIdentifier, parent: NSFileProviderItemIdentifier, name: String, isDir: Bool, path: String, size: Int64 = 0, modDate: Date = Date()) {
        self.itemIdentifier = identifier
        self.parentItemIdentifier = parent
        self.filename = name
        self.isDirectory = isDir
        self.remotePath = path
        self.fileSize = NSNumber(value: size)
        self.modifiedDate = modDate
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading, .allowsWriting, .allowsRenaming, .allowsDeleting, .allowsAddingSubItems, .allowsContentEnumerating]
    }
    
    var contentType: UTType {
        if isDirectory { return .folder }
        let ext = (filename as NSString).pathExtension.lowercased()
        if let type = UTType(filenameExtension: ext) { return type }
        return .data
    }
    
    var childItemCount: NSNumber? { isDirectory ? 0 : nil }
    
    var documentSize: NSNumber? { fileSize }
    var itemVersion: NSFileProviderItemVersion {
        // Dùng modDate làm version
        let versionStr = "\(modifiedDate?.timeIntervalSince1970 ?? 0)"
        return NSFileProviderItemVersion(contentVersion: versionStr.data(using: .utf8)!, metadataVersion: versionStr.data(using: .utf8)!)
    }
}

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    let enumeratedItemIdentifier: NSFileProviderItemIdentifier
    let server: Server
    let sftpClient: SFTPClient
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, server: Server) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        self.server = server
        self.sftpClient = SFTPConnectionPool.shared.client(for: server)
        super.init()
    }
    
    func invalidate() {}
    
    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        let path = enumeratedItemIdentifier == .rootContainer ? server.initialPath : enumeratedItemIdentifier.rawValue
        
        Task {
            do {
                try await sftpClient.connect()
                let files = try await sftpClient.listDirectory(path)
                
                let items: [FileProviderItem] = files
                    .filter { $0.name != "." && $0.name != ".." }
                    .map { file in
                        let identifier = NSFileProviderItemIdentifier(file.path)
                        return FileProviderItem(
                            identifier: identifier,
                            parent: enumeratedItemIdentifier,
                            name: file.name,
                            isDir: file.isDirectory,
                            path: file.path,
                            size: file.size,
                            modDate: file.modDate
                        )
                    }
                
                observer.didEnumerate(items)
                observer.finishEnumerating(upTo: nil)
            } catch {
                observer.finishEnumeratingWithError(error)
            }
        }
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from syncAnchor: NSFileProviderSyncAnchor) {
        // ShellFish Pro dùng syncAnchor để offline cache
        // Đơn giản: trả về toàn bộ là changed
        observer.finishEnumeratingChanges(upTo: NSFileProviderSyncAnchor("1".data(using: .utf8)!), moreComing: false)
    }
    
    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(NSFileProviderSyncAnchor("1".data(using: .utf8)!))
    }
}
