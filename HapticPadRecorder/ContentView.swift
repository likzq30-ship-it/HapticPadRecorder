import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: RecordingModel

    var body: some View {
        VStack(spacing: 0) {
            interactionPad
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            controlPanel
                .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 480, minHeight: 460)
    }

    // MARK: - Interaction Pad

    private var interactionPad: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.08))

            VStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 36))
                    .foregroundColor(model.isRecording ? .red : .secondary)

                Text(model.isRecording
                     ? "录制中 — 点击此区域记录节奏"
                     : "点击此处触发触觉反馈")
                    .font(.title3)
                    .foregroundColor(model.isRecording ? .red : .secondary)

                Text(model.stateDisplay)
                    .font(.subheadline)
                    .foregroundColor(model.isPlaying || model.isRecording
                                     ? .accentColor : .secondary)
                    .opacity(model.isPlaying || model.isRecording ? 1 : 0.5)
            }
        }
        .overlay {
            PressDetector(
                onMouseDown: {},
                onMouseUp: {
                    handleTap()
                }
            )
        }
    }

    // MARK: - Control Panel

    private var controlPanel: some View {
        VStack(spacing: 12) {
            intensitySlider
                .padding(.horizontal)

            HStack(spacing: 10) {
                recordButton
                stopRecordButton
                playButton
                clearButton
            }
            .padding(.horizontal)

            infoArea
                .padding(.horizontal, 12)
        }
        .padding(.vertical, 14)
    }

    // MARK: - Intensity

    private var intensitySlider: some View {
        HStack(spacing: 8) {
            Text("触觉强度:")
                .font(.callout)
            Slider(value: $model.intensity, in: 0.05...1.0)
            Text(String(format: "%d%%", Int(model.intensity * 100)))
                .font(.caption.monospacedDigit())
                .frame(width: 36, alignment: .trailing)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Buttons

    private var recordButton: some View {
        Button {
            model.startRecording()
        } label: {
            Label("开始录制", systemImage: "record.circle")
        }
        .disabled(model.isRecording)
    }

    private var stopRecordButton: some View {
        Button {
            model.stopRecording()
        } label: {
            Label("停止录制", systemImage: "stop.circle")
        }
        .disabled(!model.isRecording)
    }

    private var playButton: some View {
        Button {
            guard !model.intervals.isEmpty else { return }
            model.startPlayback { intensity in
                HapticController.shared.trigger(intensity: intensity)
            }
        } label: {
            Label("播放记录", systemImage: "play.circle")
        }
        .disabled(model.isPlaying)
    }

    private var clearButton: some View {
        Button {
            model.clearRecording()
        } label: {
            Label("清空记录", systemImage: "trash.circle")
        }
        .disabled(model.intervals.isEmpty && !model.isPlaying)
    }

    // MARK: - Info Area

    private var infoArea: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("点击次数: \(model.tapCount)  |  状态: \(model.stateDisplay)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(model.intervals.isEmpty
                 ? "暂无记录。请先点「开始录制」，点击交互区域，然后「停止录制」并「播放记录」。"
                 : model.intervalsDisplay)
                .font(.caption.monospaced())
                .foregroundColor(model.intervals.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Actions

    private func handleTap() {
        HapticController.shared.trigger(intensity: model.intensity)
        model.recordTap()
    }
}
