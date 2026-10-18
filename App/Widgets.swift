import SwiftUI
import WidgetKit

// Widget theo dõi task dài - giống ShellFish có Live Activity + PiP

struct SSHWidgetEntry: TimelineEntry {
    let date: Date
    let serverName: String
    let runningCommand: String
    let logTail: String
}

struct SSHWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SSHWidgetEntry {
        SSHWidgetEntry(date: Date(), serverName: "My VPS", runningCommand: "tail -f /var/log/syslog", logTail: "Server started...")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SSHWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SSHWidgetEntry>) -> Void) {
        let entry = SSHWidgetEntry(date: Date(), serverName: "My VPS", runningCommand: "npm run build", logTail: "Building...")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SSHWidgetView: View {
    var entry: SSHWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "terminal.fill")
                Text(entry.serverName).bold()
            }
            Text(entry.runningCommand).font(.caption).lineLimit(1)
            Text(entry.logTail).font(.caption2).foregroundColor(.secondary).lineLimit(3)
        }
        .padding()
    }
}

struct SSHWidget: Widget {
    let kind = "SSHWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SSHWidgetProvider()) { entry in
            SSHWidgetView(entry: entry)
        }
        .configurationDisplayName("SSH Task")
        .description("Theo dõi lệnh đang chạy, tail log")
    }
}

// Live Activity cho task dài (iOS 17.4+)
// Khi chạy RunCommandIntent background, tạo Live Activity:
// ActivityKit: SSHLiveActivityAttributes với command + output streaming
