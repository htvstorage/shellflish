import SwiftUI
import SwiftTerm
// Cần add package: https://github.com/migueldeicaza/SwiftTerm

struct TerminalView: UIViewRepresentable {
    let server: Server
    
    func makeUIView(context: Context) -> TerminalViewWrapper {
        let wrapper = TerminalViewWrapper()
        wrapper.connect(to: server)
        return wrapper
    }
    
    func updateUIView(_ uiView: TerminalViewWrapper, context: Context) {}
}

class TerminalViewWrapper: UIView {
    private var terminalView: TerminalView? // SwiftTerm TerminalView
    private var sshManager: SSHConnectionManager?
    private var filenameDetector: FilenameDetector?
    
    func connect(to server: Server) {
        // 1. Setup TerminalView (native, không phải WKWebView)
        let term = SwiftTerm.TerminalView(frame: self.bounds)
        term.backgroundColor = .black
        self.addSubview(term)
        term.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            term.topAnchor.constraint(equalTo: topAnchor),
            term.bottomAnchor.constraint(equalTo: bottomAnchor),
            term.leadingAnchor.constraint(equalTo: leadingAnchor),
            term.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        self.terminalView = term
        
        // 2. Kết nối SSH qua Citadel / NMSSH
        sshManager = SSHConnectionManager(server: server)
        sshManager?.onData = { [weak term] data in
            DispatchQueue.main.async {
                term?.feed(text: String(data: data, encoding: .utf8) ?? "")
            }
        }
        sshManager?.connect()
        
        // 3. Filename aware: quét output tìm file
        filenameDetector = FilenameDetector(terminal: term)
        filenameDetector?.onFileDetected = { filename in
            // Long-press sẽ hiện preview + drag như file thật
            print("Detected file: \(filename)")
        }
        
        // 4. Keyboard bar đặc biệt
        setupKeyboardBar(for: term)
        
        // 5. Drag & Drop
        setupDragDrop(term: term)
    }
    
    private func setupKeyboardBar(for termView: SwiftTerm.TerminalView) {
        // Tạo accessory view với Esc, Tab, Ctrl, |, ~
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        bar.items = [
            UIBarButtonItem(title: "Esc", style: .plain, target: self, action: #selector(sendEsc)),
            UIBarButtonItem(title: "Tab", style: .plain, target: self, action: #selector(sendTab)),
            UIBarButtonItem(title: "Ctrl", style: .plain, target: self, action: #selector(sendCtrl)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "|", style: .plain, target: self, action: #selector(sendPipe)),
        ]
        // Gắn vào inputAccessoryView
    }
    
    private func setupDragDrop(term: SwiftTerm.TerminalView) {
        // Kéo file từ Files app vào terminal => upload
        let drop = UIDropInteraction(delegate: DropDelegate(sshManager: sshManager))
        termView.addInteraction(drop)
        
        // Kéo filename từ terminal ra ngoài => download
        let drag = UIDragInteraction(delegate: DragDelegate(filenameDetector: filenameDetector, sshManager: sshManager))
        termView.addInteraction(drag)
    }
    
    @objc func sendEsc() { sshManager?.send(data: Data([0x1B])) }
    @objc func sendTab() { sshManager?.send(data: Data([0x09])) }
    @objc func sendCtrl() {}
    @objc func sendPipe() { sshManager?.send(data: Data("|".utf8)) }
}

// MARK: - SSH Manager (dùng Citadel hoặc NMSSH)
class SSHConnectionManager: ObservableObject {
    let server: Server
    var onData: ((Data) -> Void)?
    private var isTMUX = false
    
    init(server: Server) { self.server = server }
    
    func connect() {
        // Pseudocode với Citadel:
        // let client = try await SSHClient.connect(host: server.host, port: server.port, ...)
        // if server.useTMUX { client.exec("tmux attach || tmux new") }
        // Citadel cho phép shell channel
        print("Connecting to \(server.host)...")
        // Implement thật:
        // Task {
        //   let ssh = try await SSHClient...
        //   let channel = try await ssh.openShell()
        //   for try await data in channel { onData?(data) }
        // }
    }
    
    func send(data: Data) {
        // gửi xuống shell channel
    }
    
    func uploadFile(localURL: URL, remotePath: String) async throws {
        // SFTP upload
    }
    
    func downloadFile(remotePath: String, localURL: URL) async throws {
        // SFTP download
    }
}

// MARK: - Filename Detector (tính năng đỉnh của ShellFish)
class FilenameDetector {
    weak var terminal: SwiftTerm.TerminalView?
    var onFileDetected: ((String) -> Void)?
    private var buffer = ""
    
    init(terminal: SwiftTerm.TerminalView) {
        self.terminal = terminal
    }
    
    func scan(_ text: String) {
        // Regex tìm filename: /path/to/file, ./file.txt
        let regex = try! NSRegularExpression(pattern: #"[\w\/\.-]+\.[a-zA-Z0-9]{1,6}"#)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        for m in matches {
            if let range = Range(m.range, in: text) {
                onFileDetected?(String(text[range]))
            }
        }
    }
}

// MARK: - Drag & Drop Delegates
class DropDelegate: NSObject, UIDropInteractionDelegate {
    weak var sshManager: SSHConnectionManager?
    init(sshManager: SSHConnectionManager?) { self.sshManager = sshManager }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // User kéo file vào terminal => upload lên server tại pwd hiện tại
        session.loadObjects(ofClass: URL.self) { urls in
            for url in urls as! [URL] {
                Task {
                    try await self.sshManager?.uploadFile(localURL: url, remotePath: "./\(url.lastPathComponent)")
                }
            }
        }
    }
}

class DragDelegate: NSObject, UIDragInteractionDelegate {
    weak var filenameDetector: FilenameDetector?
    weak var sshManager: SSHConnectionManager?
    init(filenameDetector: FilenameDetector?, sshManager: SSHConnectionManager?) {
        self.filenameDetector = filenameDetector
        self.sshManager = sshManager
    }
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        // Khi user long-press filename trong terminal, cung cấp file thật
        // Cần download file đó về temp rồi tạo NSItemProvider
        return []
    }
}
