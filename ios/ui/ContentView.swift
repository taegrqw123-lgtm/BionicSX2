// PORTED FROM: PCSX2 macOS UI — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 8.4
// STATUS: NEW — Touch input overlay, game list browser, settings UI

import SwiftUI
import UniformTypeIdentifiers

// Audit Sec 8.4: Touch input abstraction layer
// Audit Sec 2.6: iOS uses file-based game loading only

struct ContentView: View {
    @State private var showingFilePicker = false
    @State private var selectedGame: URL?
    @State private var gameList: [URL] = []
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Games")) {
                    if gameList.isEmpty {
                        Text("No games found. Tap + to add ISO files.")
                            .foregroundColor(.secondary)
                    }

                    ForEach(gameList, id: \.self) { game in
                        Button(action: {
                            selectedGame = game
                        }) {
                            HStack {
                                Image(systemName: "gamecontroller")
                                    .foregroundColor(.blue)
                                Text(game.lastPathComponent)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .navigationTitle("BionicSX2")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilePicker = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [UTType.data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedGame = url
                    }
                case .failure(let error):
                    print("File picker error: \(error)")
                }
            }
            .sheet(item: $selectedGame) { game in
                MetalViewControllerWrapper(gameURL: game)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .onAppear {
            scanForGames()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GameFileOpened"))) { notification in
            if let url = notification.object as? URL {
                selectedGame = url
            }
        }
    }

    func scanForGames() {
        // Audit Sec 2.6: iOS uses ISO file reading only
        let documentsDir = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask).first!
        let gamesDir = documentsDir.appendingPathComponent("Games")

        guard FileManager.default.fileExists(atPath: gamesDir.path) else {
            return
        }

        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: gamesDir,
                includingPropertiesForKeys: nil)
            gameList = files.filter { url in
                let ext = url.pathExtension.lowercased()
                // Audit Sec 10.3: Supported file types: iso, cso, chd, elf
                return ["iso", "cso", "chd", "elf"].contains(ext)
            }
        } catch {
            print("Error scanning games: \(error)")
        }
    }
}

// Wrapper for MetalViewController (UIKit bridge)
struct MetalViewControllerWrapper: View, Identifiable {
    let gameURL: URL
    var id: String { gameURL.absoluteString }

    var body: some View {
        MetalViewControllerRepresentable(gameURL: gameURL)
    }
}

struct MetalViewControllerRepresentable: UIViewControllerRepresentable {
    let gameURL: URL

    func makeUIViewController(context: Context) -> UIViewController {
        return MetalViewController(gameURL: gameURL)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct SettingsView: View {
    @State private var biosPath: String = ""
    @State private var enableAudio: Bool = true
    @State private var enableGPU: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("System")) {
                    Text("BIOS: \(biosPath.isEmpty ? "Default" : biosPath)")
                    Text("Documents: \(getDocumentsPath())")
                }
                Section(header: Text("Performance")) {
                    Toggle("Audio Enabled", isOn: $enableAudio)
                    Toggle("Hardware Renderer", isOn: $enableGPU)
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            biosPath = getDocumentsPath() + "/BIOS"
        }
    }

    func getDocumentsPath() -> String {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
