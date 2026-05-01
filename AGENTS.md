# AGENTS

Rules and guidelines for working on this Xcode project.

## Scope and intent
- This is a SwiftUI Apple-platform app.
- Prefer small, incremental changes that preserve existing behavior unless a redesign is explicitly requested.

## Project structure
- Keep views `struct`-based SwiftUI views.
- Keep types in their own files (enums, views, models, etc.); only co-locate tiny, private helpers that are tightly coupled to a single type.
- Default to one view type per file, even for small helper/accessory views; only keep a view in the same file when it is truly tiny and splitting would add noise.
- Previews should live in their corresponding view files when practical.
- When a type grows or has clearly separable logic, extract it into extensions and add `// MARK: - <Description>` immediately above each extension.

## File conventions
- Default to one primary (non-accessory) type per file; the filename should match that type.
- Use individual files per type by default, including package code; only keep tiny, private helpers in the same file when splitting would add noise.
- Keep views in their own files in most cases; only co-locate a view when it is a tiny accessory tightly coupled to one primary type.
- Extract helper/accessory types into dedicated files; keep tiny, private helpers alongside the primary type only when splitting would add noise.
- Keep extracted types in the closest logical folder.
- Preserve the standard header comment at the top of new files.
- New source files should use a single-line copyright header: `// Copyright © <year> Jonas Frey. All rights reserved.`

## SwiftUI conventions
- Keep view modifiers in a consistent top-to-bottom order: layout -> style -> overlay -> padding.
- Avoid heavy logic in views; move formatting and derived values into computed properties or models.
- Provide `#Preview` entries for new views or variants when possible.
- Follow DRY: avoid duplicated code when a shared abstraction is appropriate.
- Prefer modern native observation/state patterns already used by the codebase.

## Localization and content
- Route user-facing copy through `Strings` helpers backed by `Localizable.xcstrings`.
- Do not inline visible UI strings with concatenation or interpolation in views when text can be localized.
- When dynamic text is needed, add `Strings` static functions with localized format keys.
- Keep changes localized to the feature you are working on; avoid broad copy rewrites unless requested.

## Analytics
- Follow `ANALYTICS.md` for all tracking work.
- Analytics must remain explicit opt-in, anonymous-only, and allowlist-only unless the user explicitly changes policy.
- Never send titles, IDs, notes, tags, ratings, search text, file names, URLs with content data, or other free-form/user-provided data.
- Any new event or property requires a doc update in `ANALYTICS.md` and user approval before implementation.

## Xcode project hygiene
- Minimize changes to `project.pbxproj`; only edit when necessary for new files or resources.
- Prefer adding assets to asset catalogs and referencing them by name in SwiftUI.
- Do not change code signing, bundle identifiers, or build settings unless explicitly requested.

## Safety checks
- Avoid force unwraps and unsafe casts; prefer optional handling and safe casting unless there is an established, justified local pattern.
- Keep behavior deterministic; avoid unnecessary async or random UI behavior.
- Do not re-add code that disappeared between work passes; treat missing or changed code as an intentional user or concurrent edit unless the user explicitly asks to restore it.

## Testing
- Run relevant verification after making changes.
- Fix any build or lint violations introduced by your changes.
- Prefer Xcode MCP build/test tools when available for project verification.
- For test execution, prefer Xcode MCP test actions (`xcode_RunSomeTests` / `xcode_RunAllTests`) over shell-based `xcodebuild test` when possible.
- Always run `xcodebuild` commands with `| xcbeautify` to reduce output size and keep logs readable.
- Fall back to `xcodebuild | xcbeautify` only when Xcode MCP is unavailable or not suitable for the task.
- Rerun plain `xcodebuild` only when raw output is needed because `xcbeautify` hides context required to diagnose an issue.

## Documentation
- If you learn a new generalized project rule or receive a reusable instruction, persist it in `AGENTS.md`.
- Prefer reusable, clean, maintainable, and human-readable implementations over one-off feature code.
- When adding an extension with a `// MARK: - <Description>` comment, place the extension immediately after the MARK without a blank line.
- For long `Logger` messages, prefer direct interpolation plus a targeted `swiftlint:disable:next line_length` comment over building the message from temporary strings.

## Git usage
- Never commit or push changes unless explicitly requested.
- Never stage files unless explicitly requested.
- Read-only git commands are fine when needed.
- Do not assume files you create or modify remain unstaged; staging may change while you work.
