# AGENTS

## Scope

This repository is the `SKHelper` Swift Package. Treat it as a reusable upstream library, not as an app project.

Primary goals:

- Keep the public API small, understandable, and stable.
- Keep StoreKit-only code separate from SwiftUI UI code.
- Avoid package defaults that make SKHelper harder to consume as a dependency.
- Prefer changes that an upstream maintainer can review and merge without project-specific context.

## Language

- Reply to the user in Ukrainian unless they explicitly ask otherwise.
- Code, commit messages, public documentation, and PR text should be in English.
- Do not use invisible Unicode characters in responses or files.

## Package Layout

The Swift 6 manifest is the source of truth:

- `Package.swift`

Do not reintroduce Swift 5.9 or Swift 5.10 fallback manifests unless the maintainer explicitly changes the support matrix.

Current library products:

| Product | Target | Import | Purpose |
|---|---|---|---|
| `SKHelperCore` | `SKHelperCore` | `import SKHelperCore` | StoreKit 2 product loading, purchases, entitlements, transactions, subscriptions, cache/config support. |
| `SKHelperUI` | `SKHelperUI` | `import SKHelperUI` | SwiftUI and StoreKit Views helpers built on top of `SKHelperCore`. |

There is intentionally no compatibility product named `SKHelper`. Existing clients should migrate from `import SKHelper` to `import SKHelperUI` or `import SKHelperCore`. Because this removes a product, the next release must be `2.0.0` or later, not a `1.x` minor release.

## Module Boundaries

### SKHelperCore

`SKHelperCore` must stay free of SwiftUI.

Allowed imports in core code are normally:

- `Foundation`
- `Observation`
- `StoreKit`
- `os.log`

`SKHelperCore` owns:

- `Sources/SKHelperCore/Core/`
- `Sources/SKHelperCore/Support/`
- `Sources/SKHelperCore/Resources/PrivacyInfo.xcprivacy`

Do not add UI images, DocC assets, demo screenshots, or SwiftUI-only resources to the core runtime resource bundle.

`SKHelperConfiguration` intentionally reads product configuration from `Bundle.main`. Do not switch it to `Bundle.module` unless the behavior change is explicitly requested.

### SKHelperUI

`SKHelperUI` owns:

- `Sources/SKHelperUI/SKHelperUI.swift`
- `Sources/SKHelperUI/Views/`
- `Sources/SKHelperUI/Styles/`
- `Sources/SKHelperUI/ViewModifiers/`
- `Sources/SKHelperUI/Documentation.docc/`

`SKHelperUI` may import SwiftUI and StoreKit. It re-exports core through:

```swift
@_exported import SKHelperCore
```

Public UI APIs that expose SwiftUI or StoreKit types should use public imports where Swift 6 requires them, for example:

```swift
public import SwiftUI
```

## Swift And Concurrency

- The package requires Swift 6 / Xcode 16.
- Do not add `.unsafeFlags` to package targets as default settings.
- Do not enable actor data-race runtime checks in `Package.swift`; keep that kind of validation in app/debug/CI configuration.
- Prefer real Swift concurrency correctness over suppressions such as `@unchecked Sendable`, `nonisolated(unsafe)`, or blanket conformances.
- If a public type crosses task or actor boundaries, prefer making it naturally `Sendable` by design.
- Avoid introducing Combine for new code; prefer async/await, `Task`, `AsyncSequence`, and Observation where appropriate.

## Public API And Behavior

Before editing public declarations, answer these questions:

- Is this source-breaking for existing users?
- Does it change purchase, entitlement, transaction, subscription, cache, or configuration behavior?
- Does it move functionality between `SKHelperCore` and `SKHelperUI`?
- Does it change generated documentation paths?

If yes, call it out clearly before or during the change. For upstream PRs, document the behavior change in README, DocC, or the PR description.

## Documentation

Source documentation lives in:

- `Sources/SKHelperUI/Documentation.docc/`
- Source comments in `Sources/SKHelperCore/` and `Sources/SKHelperUI/`

Generated static docs live under `docs/` and are for GitHub Pages.

Use `doc-build.sh` for release docs. It should generate one combined static archive for `SKHelperCore` and `SKHelperUI`, with root routes like:

- `/documentation/skhelpercore/`
- `/documentation/skhelperui/`

Do not generate nested `docs/*.doccarchive` directories for committed GitHub Pages output.

Do not use `--exclude-extended-types` in the default documentation script because public SwiftUI view modifier extension APIs should remain documented. Use `--experimental-skip-synthesized-symbols` to keep inherited/synthesized SwiftUI API noise from dominating output size.

When updating imports in docs or snippets:

- SwiftUI examples should use `import SKHelperUI`.
- Core-only examples should use `import SKHelperCore`.
- Do not add new examples with `import SKHelper` unless a compatibility product is intentionally restored.

## Tests And Validation

Current test targets:

- `SKHelperCoreTests`: verifies core-only import and public type availability without SwiftUI.
- `SKHelperUITests`: verifies `SKHelperUI` import and public SwiftUI API availability.

Use Xcode tools when working from Xcode:

- `BuildProject(buildForTesting: true)` for structural package changes.
- `RunAllTests()` for the active package scheme.
- `GetBuildLog(severity: "warning")` after builds when warning cleanliness matters.

Do not report `0 tests` as a successful validation.

For this package, a meaningful PR validation pass should include at least:

1. Full build for testing.
2. All tests.
3. A DocC generation smoke test, preferably to `/private/tmp`, confirming root `skhelpercore` and `skhelperui` routes.
4. A grep/check that `SKHelperCore` has no `import SwiftUI`.

StoreKit runtime behavior still needs app-level or StoreKit configuration validation; unit tests here are compile/API smoke tests, not full purchase-flow tests.

## Git And Review Hygiene

- Do not rewrite unrelated user changes.
- Do not touch generated `docs/` unless the task is documentation generation or release preparation.
- Keep PR-sized changes focused. Avoid mixing module split, docs regeneration, API redesign, and runtime behavior changes unless explicitly requested.
- Prefer clear commit messages in English.
- Before committing, inspect staged changes and avoid accidentally committing local scratch files.

## Shell Usage

Prefer Xcode-aware tools for project/package files when available.

Use shell commands for git, focused grep, DocC smoke tests, or file-size checks when they are the clearest option. Avoid long recursive scans over generated docs unless the task specifically requires it.

Do not use Ruby or Perl unless explicitly approved.

## File Creation

When creating package source/test files, use Xcode-aware file tools where possible so Xcode sees the files correctly. For SwiftPM packages, target membership is primarily controlled by folder layout and `Package.swift`:

- `Sources/SKHelperCore/...` belongs to `SKHelperCore`.
- `Sources/SKHelperUI/...` belongs to `SKHelperUI`.
- `Tests/SKHelperCoreTests/...` belongs to `SKHelperCoreTests`.
- `Tests/SKHelperUITests/...` belongs to `SKHelperUITests`.

If a new folder or target is added, update `Package.swift` and validate with a build.
