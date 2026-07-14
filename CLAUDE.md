# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Scope

This repository is the `SKHelper` Swift Package — a lightweight StoreKit 2 helper that adds in-app purchase and subscription functionality to iOS/macOS apps. Treat it as a reusable upstream library, not an app project. Requires **Xcode 16.3+**, **Swift 6.1**, **iOS 17+**, **macOS 14.6+** (consumables require iOS 18+/macOS 15+).

Primary goals: keep the public API small and stable, keep StoreKit-only code separate from SwiftUI code, and prefer changes an upstream maintainer can review without project-specific context.

## Commands

Build and test with SwiftPM:

```bash
swift build
swift test
swift test --filter <TestName>          # run a single test
```

From Xcode, prefer the Xcode-aware tools (`BuildProject(buildForTesting: true)`, `RunAllTests()`, `GetBuildLog(severity: "warning")`) over shell commands when working from Xcode. Do not report `0 tests` as a successful validation.

A meaningful validation pass for a PR should include:
1. Full build for testing.
2. All tests.
3. A DocC generation smoke test (see below), preferably output to `/private/tmp`.
4. A grep/check that `SKHelperCore` has no `import SwiftUI`.

### Documentation

`doc-build.sh` generates the combined static DocC archive for GitHub Pages (outputs to `docs/`, prompts for confirmation before writing):

```bash
./doc-build.sh
```

It runs `swift package generate-documentation` for both `SKHelperCore` and `SKHelperUI` with `--enable-experimental-combined-documentation`, producing root routes `/documentation/skhelpercore/` and `/documentation/skhelperui/`. Do not use `--exclude-extended-types` (public SwiftUI view modifier extension APIs must stay documented); `--experimental-skip-synthesized-symbols` is used instead to control noise. Do not generate nested `docs/*.doccarchive` directories, and don't touch generated `docs/` output unless the task is documentation generation or release prep.

## Architecture

The package is deliberately split into two products with a hard module boundary — there is intentionally **no** compatibility product named `SKHelper`; existing clients import `SKHelperUI` or `SKHelperCore` directly.

- **`SKHelperCore`** (`Sources/SKHelperCore/{Core,Support}/`) — StoreKit 2 product loading, purchases, entitlements, transactions, subscriptions, caching, and configuration. Must stay free of SwiftUI. Allowed imports: `Foundation`, `Observation`, `StoreKit`, `os.log`. The central type is the `@MainActor @Observable` `SKHelper` class (`Core/SKHelper.swift`), which owns `products`, purchase/entitlement state, and closures for subscription-status and transaction-update notifications. `SKHelperConfiguration` intentionally reads product config from `Bundle.main` (not `Bundle.module`) — don't change that without an explicit request.
- **`SKHelperUI`** (`Sources/SKHelperUI/{Views,Styles,ViewModifiers}/`, `SKHelperUI.swift`) — SwiftUI views/modifiers built on top of `SKHelperCore`, using Apple's StoreKit Views. Re-exports core via `@_exported import SKHelperCore`, so SwiftUI consumers only need `import SKHelperUI`. Public APIs exposing SwiftUI/StoreKit types use `public import` where Swift 6 requires it (e.g. `public import SwiftUI`).

Target membership is controlled by folder layout: `Sources/SKHelperCore/...` → `SKHelperCore`, `Sources/SKHelperUI/...` → `SKHelperUI`, and correspondingly for `Tests/`. Adding a new folder/target requires updating `Package.swift` and validating with a build.

Test targets are compile/API smoke tests, not full purchase-flow tests: `SKHelperCoreTests` verifies core-only import and public type availability without SwiftUI; `SKHelperUITests` verifies `SKHelperUI` import and public SwiftUI API availability. StoreKit runtime behavior needs app-level or StoreKit configuration validation instead.

## Working in this codebase

- Do not reintroduce Swift 5.9/5.10 fallback manifests; `Package.swift` (Swift 6 tools) is the sole source of truth.
- Do not add `.unsafeFlags` to package targets, and do not enable actor data-race runtime checks in `Package.swift` (keep that in app/debug/CI config).
- Avoid Combine for new code; prefer async/await, `Task`, `AsyncSequence`, and Observation. Prefer real Swift concurrency correctness over `@unchecked Sendable` / `nonisolated(unsafe)` suppressions.
- Before editing public declarations, check whether the change is source-breaking, changes purchase/entitlement/transaction/subscription/cache/configuration behavior, moves functionality between the two modules, or changes generated documentation paths — call these out explicitly.
- Because the core/UI split removed the old `SKHelper` compatibility product, the next release must be `2.0.0`+, not a `1.x` minor.
- Don't add new doc examples with `import SKHelper`; SwiftUI examples use `import SKHelperUI`, core-only examples use `import SKHelperCore`.
- Keep PRs focused — avoid mixing module-split, docs regeneration, API redesign, and runtime-behavior changes unless explicitly requested.
- Do not use Ruby or Perl unless explicitly approved.
