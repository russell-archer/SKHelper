# SKHelper Core/UI Split Refactor Plan

## Goal

Split the previous single-target `SKHelper` package into two explicit library products:

- `SKHelperCore`: StoreKit 2 product loading, purchase, entitlement, transaction, subscription and cache logic.
- `SKHelperUI`: SwiftUI and StoreKit Views integration built on top of `SKHelperCore`.

This is intentionally a source-breaking split for existing clients that used `import SKHelper`. SwiftUI clients should migrate to `import SKHelperUI`; core-only clients should use `import SKHelperCore`.

## Target Layout

Package products:

```swift
products: [
    .library(name: "SKHelperCore", targets: ["SKHelperCore"]),
    .library(name: "SKHelperUI", targets: ["SKHelperUI"]),
]
```

Targets:

```swift
targets: [
    .target(
        name: "SKHelperCore",
        resources: [.process("Resources")]
    ),
    .target(
        name: "SKHelperUI",
        dependencies: ["SKHelperCore"]
    ),
    .testTarget(
        name: "SKHelperCoreTests",
        dependencies: ["SKHelperCore"]
    ),
    .testTarget(
        name: "SKHelperUITests",
        dependencies: ["SKHelperUI"]
    ),
]
```

The package does not keep a compatibility target named `SKHelper`. This avoids a third product in Xcode's package product picker and makes the dependency choice explicit.

## Module Boundaries

### SKHelperCore

`SKHelperCore` must not import SwiftUI.

Allowed imports:

- `Foundation`
- `Observation`
- `StoreKit`
- `os.log`

Moved into `SKHelperCore`:

- `Core/*`
- `Support/*`
- `Resources/PrivacyInfo.xcprivacy`

The privacy manifest belongs with core because core accesses `UserDefaults` for cached entitlements. Documentation logos stay in the DocC catalog and are not packaged as runtime core resources.

Core public API includes:

- `SKHelper`
- `SKHelperProduct`
- `SKHelperPurchaseInfo`
- `SKHelperSubscriptionInfo`
- `SKHelperPurchaseState`
- `SKHelperSubscriptionState`
- `SKHelperEntitlementState`
- `SKHelperTransactionUpdateReason`
- `SKHelperUnwrappedVerificationResult`
- `ProductId`
- `TransactionId`
- transaction/subscription/products callback type aliases

### SKHelperUI

`SKHelperUI` imports SwiftUI, StoreKit where needed, and re-exports `SKHelperCore` so package clients can see core types with a single `import SKHelperUI`. The re-export is a client convenience, not a replacement for clear file-scoped imports inside the package implementation.

```swift
@_exported import SKHelperCore
```

Moved into `SKHelperUI`:

- `Views/*`
- `Styles/*`
- `ViewModifiers/*`
- `Documentation.docc/*`

UI public API includes:

- `SKHelperStoreView`
- `SKHelperSubscriptionStoreView`
- `SKHelperProductView`
- `SKHelperPurchasesView`
- `SKHelperManagePurchaseView`
- `SKHelperProductViewStyle`
- `onProductsAvailable(...)`
- `onTransaction(...)`
- `onSubscriptionChange(...)`
- UI button/tap helpers

Public UI files that expose SwiftUI or StoreKit types in public declarations should use public imports where required by Swift 6 diagnostics.

## Required Code Changes

1. Use only the Swift 6 manifest.

- Keep `Package.swift` with `swift-tools-version: 6.1`.
- Remove `Package@swift-5.9.swift` and `Package@swift-5.10.swift` because the package requires Xcode 16.3 and uses the iOS 18.4 SDK.

2. Move source files into target folders:

```text
Sources/
  SKHelperCore/
    Core/
    Support/
    Resources/
      PrivacyInfo.xcprivacy
  SKHelperUI/
    SKHelperUI.swift
    Views/
    Styles/
    ViewModifiers/
    Documentation.docc/
```

3. Remove SwiftUI imports from core files.

Known change:

- `SKHelperCore/Core/SKHelper.swift` should import `Foundation`, `Observation`, and `StoreKit`, not SwiftUI.

4. Keep explicit `import SKHelperCore` in UI implementation files that reference core types. `SKHelperUI` re-exports core for downstream clients, but implementation files should keep their dependencies visible.

Examples:

- Views that use `@Environment(SKHelper.self)`.
- View modifiers that use `ProductsAvailableClosure`, `TransactionUpdateClosure`, `SubscriptionStatusChangeClosure`.
- Styles/views that use `ProductId`, `SKHelperPurchaseState`, `SKHelperPurchaseInfo`, `SKHelperSubscriptionInfo`, or `SKHelperConfiguration`.

5. Keep current runtime product configuration behavior documented.

`SKHelperConfiguration` reads product configuration plist files from `Bundle.main`, so host apps continue to provide `Products.plist` or a custom configuration plist in the app bundle. The package resource bundle is not used for product identifiers.

6. Update README and DocC usage notes.

Document two usage modes:

- SwiftUI package: `import SKHelperUI`.
- Core-only package: `import SKHelperCore`.

7. Add migration notes.

```swift
// Previous SwiftUI clients
import SKHelper

// New explicit SwiftUI clients
import SKHelperUI

// New core-only clients
import SKHelperCore
```

## Validation Checklist

Core-only validation:

- A client app can depend on `SKHelperCore` without compiling SwiftUI views.
- `SKHelperCoreTests` imports `SKHelperCore` without importing SwiftUI and verifies core public types compile.
- `import SKHelperCore` exposes `SKHelper`, `SKHelperProduct`, purchase states and entitlement APIs.
- `SKHelperCore` builds without SwiftUI imports.
- Product loading works via `requestProducts(...)`.
- Purchase flow still returns expected `SKHelperPurchaseState`.
- `isPurchased(productId:)` and `isSubscribed(productId:)` still work.
- Transaction updates listener still starts and cancels correctly.
- Subscription listener still starts and cancels correctly.
- Cached entitlements still read/write the same keys.
- Privacy manifest remains attached to the target that accesses `UserDefaults`.

UI validation:

- `SKHelperStoreView` compiles and can access `SKHelper` from the environment.
- `SKHelperSubscriptionStoreView` compiles.
- `SKHelperManagePurchaseView` compiles.
- `SKHelperProductViewStyle` compiles.
- View modifiers compile and update callbacks.
- README examples and DocC snippets use `import SKHelperUI` for SwiftUI APIs.

Documentation validation:

- `doc-build.sh` generates one combined static DocC archive for `SKHelperCore` and `SKHelperUI`.
- The generated output contains `/documentation/skhelpercore/` and `/documentation/skhelperui/` at the root of `docs`.
- Documentation generation uses `--experimental-skip-synthesized-symbols` so inherited SwiftUI synthesized APIs do not dominate the archive size.
- Documentation generation does not use `--exclude-extended-types`, so public view modifier extension APIs remain documented.

## Risk Areas

- Removing the `SKHelper` compatibility product is a breaking change for existing users; the README must make the migration path clear.
- `SKHelper.swift` combines observable state and StoreKit listeners, so changes to imports or isolation should be validated with a full build.
- `SKHelperConfiguration` intentionally reads product configuration from `Bundle.main`; changing that to `Bundle.module` would be a behavior change.
- Keep the generated docs under `docs/` synchronized with the DocC sources by regenerating them with `doc-build.sh` before release.
- `SKHelperCoreTests` verifies core-only imports and public type availability. `SKHelperUITests` verifies the explicit UI product import and public SwiftUI API availability. StoreKit runtime behavior still needs app-level or StoreKit configuration validation.

## Swift 6 Notes

The primary package manifest uses `swift-tools-version: 6.1`. Keep the split compiling cleanly through the Swift 6.1 manifest as part of release validation.

## Release Recommendation

This split removes the `SKHelper` product and changes the package product selection contract, so it must ship as `2.0.0` or later. Do not release it as `1.1.x` or `1.2.x`, because existing clients could otherwise receive a source-breaking product removal as a minor update.

The release notes should call out both migration steps:

- Replace `import SKHelper` with `import SKHelperUI` for the previous SwiftUI surface, or `import SKHelperCore` for StoreKit-only usage.
- Replace package product dependencies from `SKHelper` to `SKHelperUI` or `SKHelperCore` in Xcode and SwiftPM manifests.
