import SwiftUI

@main
struct SecureShellCloneApp: App {
    @StateObject var serverStore = ServerStore()
    
    var body: some Scene {
        WindowGroup {
            ServerListView()
                .environmentObject(serverStore)
        }
    }
}

class ServerStore: ObservableObject {
    @Published var servers: [Server] = [] {
        didSet { save() }
    }
    
    init() { load() }
    
    func load() {
        if let data = UserDefaults(suiteName: "group.com.shellfish.clone")?.data(forKey: "servers"),
           let decoded = try? JSONDecoder().decode([Server].self, from: data) {
            servers = decoded
        }
    }
    func save() {
        if let data = try? JSONEncoder().encode(servers) {
            UserDefaults(suiteName: "group.com.shellfish.clone")?.set(data, forKey: "servers")
        }
    }
    
    func addServer(_ server: Server) {
        servers.append(server)
    }
    func delete(at offsets: IndexSet) {
        servers.remove(atOffsets: offsets)
    }
}
