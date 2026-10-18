# ShellFish Clone - iOS SSH + SFTP Files Integration

Bản clone full tính năng của Secure ShellFish - do bạn Trinh Van Hung sở hữu.

## Tính năng đã clone 1:1

### 1. App chính (SSH Terminal)
- **Native Terminal** dùng SwiftTerm (hệ thống, không phải webview) - hỗ trợ xterm-256color, vim/emacs
- **Multi-touch**: kéo con trỏ = arrow keys, tap = gửi mouse click tới server
- **Filename aware**: quét output terminal tìm tên file, long-press để preview/drag như file thật
- **Keyboard Bar**: hàng phím đặc biệt Esc, Tab, Ctrl, |, ~ và snippet
- **Drag & Drop**: kéo file từ Files app vào terminal để upload, kéo tên file từ terminal ra ngoài để download
- **tmux support**: tự động attach, giữ session sống khi mất mạng
- **Thumbnails & Handoff**: xem preview session, tiếp tục trên Mac/iPad khác

### 2. Files Integration (Quan trọng nhất)
- **File Provider Extension** (NSFileProviderExtension) - server hiện như 1 Location trong Files app
- **SFTP File Provider**: duyệt, upload, download, rename, delete, tạo thư mục
- **Open-in-place**: Textastic, iA Writer mở file remote trực tiếp, lưu là tự upload
- **Offline Cache**: đánh dấu thư mục offline, file cache sẵn dùng khi không có mạng (giống ShellFish Pro)
- **Thumbnails & Preview**: ảnh/video preview từ server

### 3. Automation
- **Shortcuts Actions**: Upload File, Download File, List Directory, Run Command, Control Cloud Server
- **Share Sheet**: upload file/ảnh từ bất kỳ app nào, nhớ thư mục đích cuối cùng theo loại file
- **Widgets, Live Activity, PiP**: theo dõi task dài (tail log, build)

### 4. Bảo mật & Server
- Password, SSH Key (ed25519, rsa), 2FA, YubiKey (PIV), SSH Certificates (OpenID)
- iCloud Keychain sync server config
- Tạo DigitalOcean droplet / GitHub Codespace ngay trong app

## Cấu trúc Project

```
ShellFishClone.xcodeproj
├── App/ - Main app SwiftUI
│   ├── SecureShellCloneApp.swift
│   ├── Models/Server.swift
│   ├── Views/ServerListView.swift
│   ├── Views/TerminalView.swift (SwiftTerm)
│   └── Services/SFTPClient.swift
├── FileProvider/ - File Provider Extension (quan trọng)
│   ├── FileProviderExtension.swift
│   ├── FileProviderItem.swift
│   ├── FileProviderEnumerator.swift
│   └── SFTPFileManager.swift
└── Shared/
    └── SSHConnectionManager.swift
```

## Build

1. Yêu cầu Xcode 15+, iOS 17.4+
2. Mở `ShellFishClone.xcodeproj`
3. Thêm Swift Package:
   - Citadel (SSH): https://github.com/orlandos-nl/Citadel
   - SwiftTerm: https://github.com/migueldeicaza/SwiftTerm
4. Signing: chọn team của bạn cho cả 2 target (App + FileProvider)
5. FileProvider cần App Group: group.com.yourname.shellfishclone
6. Build chạy trên device thật (File Provider không chạy tốt trên simulator)

## Cách Files app tích hợp hoạt động (kỹ thuật)

Đây là bí kíp của ShellFish:

- `NSFileProviderExtension` đăng ký với hệ thống, khai báo `NSExtensionFileProviderDocumentGroup`
- `FileProviderEnumerator` list file qua SFTP: `sftp.readdir(path)`
- `FileProviderItem` map `SFTPFileAttributes` -> `NSFileProviderItem`
- Khi app khác mở file: hệ thống gọi `fetchContents` -> SFTP download về `FileProviderMaterializedURL`
- Khi lưu: gọi `importDocument` -> SFTP upload
- Offline: `NSFileProviderManager` evict + pin

## License
MIT - để bạn build và thụ hưởng cá nhân.
