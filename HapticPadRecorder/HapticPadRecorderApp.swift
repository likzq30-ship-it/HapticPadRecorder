import SwiftUI

@main
struct HapticPadRecorderApp: App {
    @StateObject private var model = RecordingModel()

    var body: some Scene {
        WindowGroup("Haptic Pad Recorder") {
            ContentView()
                .environmentObject(model)
        }
    }
}
