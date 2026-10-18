import AppIntents

// Đây là Shortcuts Actions - tính năng Pro của ShellFish

struct UploadFileIntent: AppIntent {
    static var title: LocalizedStringResource = "Upload File lên Server"
    static var description = IntentDescription("Upload file vào thư mục SFTP cuối cùng đã dùng")
    
    @Parameter(title: "File")
    var file: IntentFile
    
    @Parameter(title: "Server")
    var serverName: String
    
    @Parameter(title: "Remote Path")
    var remotePath: String?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // 1. Lấy server từ tên
        // 2. SFTP upload
        // 3. Nhớ last destination theo loại file (như ShellFish)
        let dest = remotePath ?? "~/uploads/\(file.filename)"
        // try await SFTP...
        return .result(value: "Đã upload tới \(dest)")
    }
}

struct DownloadFileIntent: AppIntent {
    static var title: LocalizedStringResource = "Download File từ Server"
    
    @Parameter(title: "Server")
    var serverName: String
    
    @Parameter(title: "Remote Path")
    var remotePath: String
    
    func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
        // Download và trả về file
        // ShellFish dùng cái này cho photo backup tự động
        throw NSError(domain: "Chưa implement", code: 0)
    }
}

struct RunCommandIntent: AppIntent {
    static var title: LocalizedStringResource = "Chạy lệnh trên Server"
    static var description = IntentDescription("Chạy command không cần mở app - output trả về line by line")
    
    @Parameter(title: "Server")
    var serverName: String
    
    @Parameter(title: "Command")
    var command: String
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Dùng SSH channel exec
        // ShellFish Pro cho phép chạy background lâu, hiện Live Activity
        return .result(value: "Output của \(command)")
    }
}

struct ControlCloudServerIntent: AppIntent {
    static var title: LocalizedStringResource = "Quản lý Cloud Server"
    
    @Parameter(title: "Provider")
    var provider: String // DigitalOcean, etc
    
    @Parameter(title: "Action")
    var action: String // create, start, stop, destroy
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Tạo droplet ngay trong Shortcuts
        return .result(value: "Server \(action) done")
    }
}

struct ShellFishShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: UploadFileIntent(),
            phrases: ["Upload file với \(.applicationName)"]
        )
        AppShortcut(
            intent: RunCommandIntent(),
            phrases: ["Chạy lệnh trên \(.applicationName)"]
        )
    }
}
