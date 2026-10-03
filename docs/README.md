# Documentation reading map

MoveBreak is a free desktop wellness project intended for open-source development. This map connects the product, code, development workflow, migration history, and release evidence. The current macOS tree is MIT licensed, including inherited materials with the rights holder’s permission confirmed by the project owner. See LICENSE and THIRD_PARTY_NOTICES.md.

## Start here

| Reader goal | Read in order |
| --- | --- |
| Install and try the app | Root README → [USER-GUIDE.md](USER-GUIDE.md) → [INSTALL.html](INSTALL.html) → [SECURITY-STATUS.md](SECURITY-STATUS.md) |
| Understand every implementation layer | [ARCHITECTURE.md](ARCHITECTURE.md) → [IMPLEMENTATION.md](IMPLEMENTATION.md) → [LOCALIZATION.md](LOCALIZATION.md) → [PRIVACY.md](PRIVACY.md) |
| Build and contribute | [../CONTRIBUTING.md](../CONTRIBUTING.md) → [DEVELOPMENT.md](DEVELOPMENT.md) → [TESTING.md](TESTING.md) → [../AGENTS.md](../AGENTS.md) |
| Understand how the project was created | [WINDOWS-REVIEW.md](WINDOWS-REVIEW.md) → [decisions/0001-native-stack.md](decisions/0001-native-stack.md) → [PLAN.md](PLAN.md) → [../CHANGELOG.md](../CHANGELOG.md) |
| Package and release | [RELEASING.md](RELEASING.md) → [SECURITY-STATUS.md](SECURITY-STATUS.md) → [TESTING.md](TESTING.md) → [BETA-RELEASE.md](BETA-RELEASE.md) |
| Understand ownership | [../THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md) → licensing section in root README |

The root README is the product entry point. ARCHITECTURE describes boundaries and rationale; IMPLEMENTATION maps those boundaries to functions and data. TESTING records evidence rather than inferred readiness. PLAN and CHANGELOG preserve the stages and changes. AGENTS.md makes documentation maintenance mandatory for future work.

## Documentation conventions

All repository prose is English. Each behavior change should document purpose, mechanism, verification, compatibility, and limitations. Keep historical test results dated, and label superseded artifacts. Do not rewrite history to imply an earlier build worked. Screenshots are real application captures, with provenance in [screenshots/README.md](screenshots/README.md). No future roadmap item is a current feature until implemented and verified.
