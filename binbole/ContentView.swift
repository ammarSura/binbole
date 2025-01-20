import SwiftUI

struct ContentView: View {
    @StateObject private var clipboardManager = ClipboardManager()

    var body: some View {
        ScrollView {
            Text("Binbole Clipboard Manager")
                .font(.title)
                .padding(.top)

            LazyVStack(alignment: .leading, spacing: 10) {
                // Pinned Items Section
                if !clipboardManager.pinnedItems.isEmpty {
                    Text("Pinned Items")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(clipboardManager.pinnedItems, id: \.self) { item in
                        ClipboardItemView(text: item, isPinned: true, clipboardManager: clipboardManager)
                    }

                    Divider()
                        .padding(.vertical)
                }

                // Regular History Section
                ForEach(clipboardManager.clipboardHistory, id: \.self) { item in
                    ClipboardItemView(text: item, isPinned: false, clipboardManager: clipboardManager)
                }
            }
            .padding()
        }
    }
}

struct ClipboardItemView: View {
    let text: String
    let isPinned: Bool
    let clipboardManager: ClipboardManager
    var body: some View {
        HStack {
            Button(action: {
                clipboardManager.copyToClipboard(text)
            }) {
                VStack(alignment: .leading) {
                    Text(text)
                        .lineLimit(3)
                        .padding(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !isPinned {
                Button(action: {
                    clipboardManager.pinItem(text)
                }) {
                    Image(systemName: "pin")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                }
            }

            Button(action: {
                if isPinned {
                    clipboardManager.unpinItem(text)
                } else {
                    clipboardManager.removeFromHistory(text)
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(.trailing, 8)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

