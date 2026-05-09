import AppKit
import CoreHaptics

/// CoreHaptics 主力引擎 + NSHapticFeedbackManager 回退。
/// 支持一次震动、持续震动、强度控制。
final class HapticController {
    static let shared = HapticController()

    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticPatternPlayer?
    private let legacy = NSHapticFeedbackManager.defaultPerformer
    private var engineReady = false

    private init() {
        setupEngine()
    }

    // MARK: - Engine setup

    private func setupEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { [weak self] _ in
                self?.engineReady = false
            }
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
                self?.engineReady = true
            }
            try engine?.start()
            engineReady = true
        } catch {
            engine = nil
            engineReady = false
        }
    }

    // MARK: - One-shot

    func trigger(intensity: Double) {
        guard engineReady, let engine = engine else {
            // 回退：CoreHaptics 硬件不可用
            legacy.perform(.generic, performanceTime: .now)
            return
        }
        do {
            let intensityP = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
            let sharpnessP = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityP, sharpnessP], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            legacy.perform(.generic, performanceTime: .now)
        }
    }

    // MARK: - Continuous

    func startContinuous(intensity: Double) {
        guard engineReady, let engine = engine else { return }
        do {
            let intensityP = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
            let sharpnessP = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityP, sharpnessP], relativeTime: 0, duration: 100)
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [])
            continuousPlayer = try engine.makePlayer(with: pattern)
            try continuousPlayer?.start(atTime: 0)
        } catch {}
    }

    func stopContinuous() {
        try? continuousPlayer?.stop(atTime: 0)
        continuousPlayer = nil
    }
}
