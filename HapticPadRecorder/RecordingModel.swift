import Foundation

// MARK: - Recording Model

@MainActor
final class RecordingModel: ObservableObject {
    @Published var timestamps: [TimeInterval] = []
    @Published var intervals: [TimeInterval] = []
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var intensity: Double = 1.0

    private var playbackTask: Task<Void, Never>?

    var tapCount: Int { timestamps.count }

    var stateDisplay: String {
        if isPlaying { return "播放中..." }
        if isRecording { return "录制中..." }
        return "空闲"
    }

    var intervalsDisplay: String {
        guard !intervals.isEmpty else { return "暂无记录" }
        return intervals.enumerated().map { idx, val in
            String(format: "[%d] %.3fs", idx, val)
        }.joined(separator: "\n")
    }

    // MARK: - Recording

    func startRecording() {
        timestamps = []
        intervals = []
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
        guard !timestamps.isEmpty else { return }
        let base = timestamps[0]
        intervals = timestamps.map { $0 - base }
    }

    func recordTap() {
        guard isRecording else { return }
        timestamps.append(Date().timeIntervalSinceReferenceDate)
    }

    // MARK: - Playback

    func startPlayback(onTick: @escaping (Double) -> Void) {
        guard !intervals.isEmpty, !isPlaying else { return }
        stopPlayback()
        isPlaying = true

        let offsets = intervals
        let currentIntensity = intensity

        playbackTask = Task { [weak self] in
            onTick(currentIntensity)

            let startTime = Date().timeIntervalSinceReferenceDate
            for i in 1..<offsets.count {
                if Task.isCancelled { break }
                let delay = offsets[i]
                let elapsed = Date().timeIntervalSinceReferenceDate - startTime
                let waitTime = max(0, delay - elapsed)
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                if Task.isCancelled { break }
                onTick(currentIntensity)
            }

            await MainActor.run { [weak self] in
                self?.isPlaying = false
            }
        }
    }

    func stopPlayback() {
        playbackTask?.cancel()
        playbackTask = nil
        isPlaying = false
    }

    func clearRecording() {
        stopPlayback()
        timestamps = []
        intervals = []
    }
}
