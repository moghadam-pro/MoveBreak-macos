# Contributing to MoveBreak

MoveBreak is free to use and intended to be developed openly. The current macOS tree is MIT licensed, including inherited artwork/content with confirmed permission. Retain LICENSE and the original attribution in THIRD_PARTY_NOTICES.md when redistributing.

Start with docs/README.md, then DEVELOPMENT.md and IMPLEMENTATION.md. For an issue, include version, macOS/architecture, minimal reproduction, expected/actual behavior, and relevant redacted screenshots. Keep health histories, credentials, and unrelated system logs private.

For changes, use a focused branch and pull request that explains the problem, resulting behavior, validation, and remaining limitations. Preserve original artwork attribution. Add meaningful policy tests when behavior changes; avoid tests that only duplicate implementation. Validate every language when adding UI text, including Persian RTL and long German labels.

Documentation is mandatory with every change. Follow AGENTS.md: update affected layer documentation, README when needed, CHANGELOG for visible changes, and PLAN for completed stages. Add decision records for significant architecture choices. Screenshots must show the actual current app. Never claim signing, notarization, hardware compatibility, or manual tests that were not performed.

There is no contribution account inside the app, telemetry, payment flow, or external runtime requirement. Keep end-user distribution a complete app and keep maintenance tooling outside user flows.
