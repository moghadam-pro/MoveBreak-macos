# Project rules

MoveBreak is intended to be free and open source. Preserve attribution and confirm licensing scope before assigning rights to inherited materials.

## Mandatory documentation rule

Every change must include accurate, complete English documentation sufficient for a new reader to understand the affected project layers, implementation decisions, development steps, validation, and limitations. This is a standing owner requirement, not an optional release task.

- Update relevant documents in `docs/` with the code change; update README when user behavior, setup, architecture, or distribution changes.
- Record user-visible changes in CHANGELOG.md and completed stages in docs/PLAN.md.
- Explain why a decision was made, how the implementation works, how to verify it, and what remains unverified. Add an architecture decision record for substantial new decisions.
- Keep commands reproducible and distinguish contributor commands from end-user installation. End users must receive a complete app without shell setup or external runtime dependencies.
- Never describe ad-hoc signing as Developer ID signing or notarization; distinguish automated checks, actual artifact tests, and pending environment-dependent checks.
- Maintain docs/README.md as the reading map. Update screenshots after meaningful visible changes, using the actual app and excluding unrelated/private screen content.
- Keep all repository documentation in English. Application translations include English, Persian RTL, Spanish, Turkish, and German.
- Preserve immutable release/backup tags and original artwork attribution. Do not commit secrets or private user state.
