# Localization and Persian RTL

Version 0.2.0-beta.2 supports `en`, `fa`, `es`, `tr`, and `de`. Application-owned strings live in `Sources/MoveBreakCore/Resources/strings.<code>.json`; the stable English phrase is the lookup key. Exercise titles and instructions remain keyed by language in the bundled exercise catalog. Original English, Persian, and Spanish text is retained; Turkish and German translations are added for all 18 exercises.

The first supported preferred macOS language is used before an explicit selection. A saved `languageCode` overrides that choice. The optional field preserves decoding compatibility with the existing version-1 local document. Changing languages persists immediately without restarting countdowns or clearing data.

SwiftUI receives the selected locale and layout direction in all app scenes and the AppKit-hosted break panel. Persian uses RTL, mirrored tab order with stable selection tags, leading/trailing alignment, mirrored form controls and dashboard columns, and localized categories, outcomes, numbers, dates, and accessibility labels. Countdown content uses LTR direction to keep minute/second order stable. Exercise art is not mirrored because the actual movement illustrations should remain unchanged.

macOS-owned permission dialogs and generated system menus use macOS's own language; app-owned controls and the menu bar extra use the selected app language. Raw operating-system diagnostic details may also follow the system language, while app error explanations are translated.

Localization coverage is checked by Swift Testing for key parity, nonempty strings, argument parity, preferred-language selection, and Persian direction. `scripts/validate-localization.py` checks catalog coverage, literal UI keys, every exercise language field, unique IDs, and illustration existence. All translations should still receive native-speaker editorial review before a stable public release, especially long German labels and wellness instructions.
