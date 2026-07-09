# ``SKHelperUI``

@Metadata {
    @PageImage(purpose: icon, source: skhelper-logo-small)
}

`SKHelper` is a Swift Package Manager package for adding in-app purchase and subscription support to apps that use Apple's StoreKit 2 APIs.

## Overview

The package is split into two library products:

| Product | Import | Use case |
|---|---|---|
| `SKHelperUI` | `import SKHelperUI` | SwiftUI and StoreKit Views integration built on top of `SKHelperCore`. |
| `SKHelperCore` | `import SKHelperCore` | StoreKit 2 product loading, purchase, entitlement, transaction, subscription, and cache logic without SwiftUI views. |

Use `SKHelperUI` when you want the built-in SwiftUI views, view modifiers, product buttons, and StoreKit Views wrappers. Use `SKHelperCore` directly when your app has a custom paywall or purchase UI.

`SKHelperUI` re-exports `SKHelperCore`, so SwiftUI clients only need `import SKHelperUI`.

## Features

- Multi-platform iOS and macOS SwiftUI support for purchasing consumable, non-consumable and subscription products
- StoreKit Views wrappers for a standard and customizable purchase UI
- A StoreKit-only `SKHelperCore` module for custom paywalls and non-SwiftUI purchase surfaces
- Swift 6 package manifest and strict-concurrency-friendly public API
- Transaction validation, pending transactions, cancellations and failures
- Support for direct App Store purchases of promoted in-app purchases via Purchase Intents
- Documentation and an example project

## License

MIT license, copyright (c) 2024, 2025 Russell Archer. This software is provided "as-is" without warranty and may be freely used, copied, modified and redistributed, including as part of commercial software.

See the `SKHelper` <doc:LICENSE> for details.

## Requirements

- Xcode 16.3+
- iOS 17+
- macOS 14.6+
- iOS 18+ and macOS 15+ for consumable transaction support

## Getting Started

- For the SwiftUI package product, add `SKHelperUI` to your app target and follow the <doc:quickstart>
- For apps with custom paywalls, add `SKHelperCore` and use `SKHelper` to request products, make purchases, listen for transactions, and query entitlements
- For an in-depth treatment of in-app purchases, StoreKit 2 and SKHelper, refer to the <doc:guide>
