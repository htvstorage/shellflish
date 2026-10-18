import SwiftUI

struct ServerListView: View {
    @EnvironmentObject var store: ServerStore
    @State private var showingAdd = false
    @State private var selectedServer: Server?
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(store.servers) { server in
                    NavigationLink(value: server) {
                        ServerRow(server: server)
                    }
                }
                .onDelete(perform: store.delete)
            }
            .navigationTitle("Servers")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Files") {
                        // Mở Files app
                        if let url = URL(string: "shareddocuments://") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddServerView { server in
                    store.addServer(server)
                    showingAdd = false
                }
            }
        } detail: {
            if let server = selectedServer {
                TerminalView(server: server)
            } else {
                ContentUnavailableView("Chọn server", systemImage: "server.rack", description: Text("Hoặc vào Files app để duyệt file SFTP"))
            }
        }
        .navigationDestination(for: Server.self) { server in
            TerminalView(server: server)
        }
    }
}

struct ServerRow: View {
    let server: Server
    var body: some View {
        HStack {
            Image(systemName: "server.rack")
                .font(.title2)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(server.name).bold()
                Text(server.displayHost).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            if server.isOfflineEnabled {
                Image(systemName: "arrow.down.circle.fill").foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddServerView: View {
    @State private var name = ""
    @State private var host = ""
    @State private var username = "root"
    @State private var password = ""
    var onSave: (Server) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Thông tin") {
                    TextField("Tên gợi nhớ", text: $name)
                    TextField("Host / IP", text: $host)
                    TextField("Username", text: $username)
                    SecureField("Password hoặc key", text: $password)
                }
                Section("Tuỳ chọn ShellFish") {
                    Toggle("Tự động tmux", isOn: .constant(true))
                    Toggle("Offline folders", isOn: .constant(false))
                }
            }
            .navigationTitle("Thêm Server")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Huỷ") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        let s = Server(name: name.isEmpty ? host : name, host: host, username: username, password: password)
                        onSave(s)
                    }.disabled(host.isEmpty)
                }
            }
        }
    }
}
