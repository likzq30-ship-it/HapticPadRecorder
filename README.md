# HapticPadRecorder

macOS 触控板震动录制回放 App。基于 CoreHaptics + SwiftUI，支持触觉强度调节、节奏录制、精确回放。

> 仅适用于配备 Force Touch 触控板的 MacBook（2015+）。

## 功能

- **触觉反馈** — 点击交互区域触发触控板震动，强度可调 5% ~ 100%
- **节奏录制** — 录制点击时间间隔，精确到毫秒
- **节奏回放** — 按录制的时间偏移依次播放震动
- **多种触觉模式** — CoreHaptics 引擎 + NSHapticFeedbackManager 回退

## 运行

```bash
git clone https://github.com/likzq30-ship-it/HapticPadRecorder.git
cd HapticPadRecorder
open HapticPadRecorder.xcodeproj
```

Xcode 中 `⌘R` 运行。或下载 [Releases](../../releases) 中的 DMG 直接安装。

## 系统要求

- macOS 14.0+
- 配备 Force Touch 触控板的 MacBook（2015 及更新）
- 系统设置 → 触控板 → 力度触控与触觉反馈 已开启

## 技术栈

- SwiftUI + AppKit 混编
- CoreHaptics (`CHHapticEngine`)
- Swift Concurrency (`Task`, `@MainActor`)
- `NSViewRepresentable` 自定义事件处理

## 限制

macOS 公开 API 无法自由控制触控板马达。本项目只能：
- 调用 CoreHaptics 的一次性和持续性触觉事件
- 调节强度参数 (0.0 ~ 1.0)

不支持自定义波形、频率、包络等底层马达控制。

## 项目结构

```
├── HapticPadRecorder.xcodeproj
└── HapticPadRecorder/
    ├── HapticPadRecorderApp.swift   # App 入口
    ├── ContentView.swift            # 主界面
    ├── HapticController.swift       # CoreHaptics 封装
    ├── RecordingModel.swift         # 录制/回放模型
    ├── PressDetector.swift          # NSView 事件桥接
    └── AppIcon.icns                 # 图标
```
