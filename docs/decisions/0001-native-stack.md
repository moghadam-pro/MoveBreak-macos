# ADR 0001 — Native SwiftUI desktop app

Status: accepted, 2026-10-03.

Use SwiftUI for native views, AppKit for the reminder panel, and a Foundation-only Swift core for deterministic timer policy. Target macOS 14+. Use SwiftPM as the reproducible source build and Xcode entry point. Keep dependencies limited to Apple frameworks.

This fits the existing Mac development environment and avoids shipping a Windows runtime or web shell. Separate the timer policy from the OS sampling mechanism. Use schema-versioned atomic JSON storage initially because the dataset is small; introduce migrations and consider SQLite when scale or query requirements justify it. The initial tradeoff is unbounded in-memory history, documented for follow-up.

Initial UI is English by user choice. Preserve multilingual catalog data. Presentation deferral is manual until automatic detection has a tested macOS implementation. The first release number is 0.1.0 for the native port; Windows version numbers remain in the preserved Git history.
