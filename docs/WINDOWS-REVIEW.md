# Windows source review

Reviewed source: `fd06a82309948143278c961c4e77d75a323311e7`, preserved as `backup/windows-2026-10-03` before replacing main. The source used .NET 8, WPF, CommunityToolkit MVVM, dependency injection, EF Core, and SQLite. The original README and ARCHITECTURE document describe a tray app with activity-aware reminders, localized exercises, and local history.

## Assessment

The layering and framework choices are conventional and appropriate for a Windows MVP. This is a useful product and asset foundation, but the source does not establish production-grade reliability or optimal design. The native macOS implementation preserves product intent rather than translating Windows APIs literally.

| Finding | Source evidence | macOS decision |
| --- | --- | --- |
| UI/platform services are separated | `Views`, `ViewModels`, `Services`, `Data`, `Models` | Preserve separation; isolate a pure policy core |
| Time uses callback count | `WorkTimerService.OnTick` increments one integer per tick | Use monotonic elapsed time with explicit inactive states |
| Eye rule is probabilistic | `ExerciseService.Next` gives eye exercises a 35% chance after 20 minutes | Use an independent eye deadline |
| Schema updates are manual | `EnsureCurrentSchema` checks one column with PRAGMA/ALTER | Version the local document and reject unsupported versions safely |
| Statistics omit unrecorded intervals | `RefreshStatsAsync` sums completed break records; sessions are not used in that path | Checkpoint active-work totals independently of break outcomes |
| Timer policy has no tests in the repository | No checked-in timer test target | Add meaningful deterministic policy tests |
| Notification/tray implementation is Windows-specific | WinForms NotifyIcon, Registry, user32, dwmapi | Replace with MenuBarExtra, UNUserNotificationCenter, SMAppService, NSWorkspace |
| Presentation state is concentrated | MainViewModel handles settings, theme, records, localization, and timer wiring | Keep views declarative; document the adapter's future extraction boundary |

## Design and provenance

All 18 exercise PNGs and the MoveBreak PNG identity were retained. Exercise durations and English/Persian/Spanish descriptions were extracted without rewriting. The original calm green palette, rounded cards, prominent countdown, exercise card, history, and preferences were adapted to native macOS controls and system appearance.

The original source did not contain a LICENSE file. This migration does not invent or grant a license for the original code or artwork. Confirm licensing with the original author before public redistribution under a new license. Attribution is retained in the README and `THIRD_PARTY_NOTICES.md`.
