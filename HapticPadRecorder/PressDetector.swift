import AppKit
import SwiftUI

/// NSView 封装：直接拿 mouseDown / mouseUp，解决 DragGesture 在触控板上静止按不触发的问题。
final class PressDetectorView: NSView {
    var onMouseDown: (() -> Void)?
    var onMouseUp: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        onMouseDown?()
    }

    override func mouseUp(with event: NSEvent) {
        onMouseUp?()
    }

    // 让视图接受事件
    override var acceptsFirstResponder: Bool { true }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

struct PressDetector: NSViewRepresentable {
    let onMouseDown: () -> Void
    let onMouseUp: () -> Void

    func makeNSView(context: Context) -> PressDetectorView {
        let view = PressDetectorView()
        view.onMouseDown = onMouseDown
        view.onMouseUp = onMouseUp
        return view
    }

    func updateNSView(_ nsView: PressDetectorView, context: Context) {
        nsView.onMouseDown = onMouseDown
        nsView.onMouseUp = onMouseUp
    }
}
