import Foundation
import AppKit
class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [String] = []
    @Published var pinnedItems: [String] = []
    private let maxHistoryItems = 50
    private var lastChangeCount: Int
    private let pinnedItemsKey = "PinnedClipboardItems"

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
        // Load pinned items from UserDefaults
        pinnedItems = UserDefaults.standard.stringArray(forKey: pinnedItemsKey) ?? []
        startMonitoring()
    }

    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            if let newString = pasteboard.string(forType: .string) {
                DispatchQueue.main.async {
                    if !self.clipboardHistory.contains(newString) && !self.pinnedItems.contains(newString) {
                        self.clipboardHistory.insert(newString, at: 0)
                        if self.clipboardHistory.count > self.maxHistoryItems {
                            self.clipboardHistory.removeLast()
                        }
                    }
                }
            }
        }
    }

    func copyToClipboard(_ text: String) {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)

            // Remove the old entry of this text if it exists
            if let index = clipboardHistory.firstIndex(of: text) {
                clipboardHistory.remove(at: index)
            }
            // Add the text at the beginning
            clipboardHistory.insert(text, at: 0)
        }

    func removeFromHistory(_ text: String) {
        if let index = clipboardHistory.firstIndex(of: text) {
            clipboardHistory.remove(at: index)
        }
    }

    func pinItem(_ text: String) {
        if !pinnedItems.contains(text) {
            objectWillChange.send()
            pinnedItems.append(text)
            clipboardHistory.removeAll(where: { $0 == text })
            UserDefaults.standard.set(pinnedItems, forKey: pinnedItemsKey)
        }
    }

    func unpinItem(_ text: String) {
        objectWillChange.send()
        pinnedItems.removeAll(where: { $0 == text })
        UserDefaults.standard.set(pinnedItems, forKey: pinnedItemsKey)
    }
}

