[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frussell-archer%2FSKHelper%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/russell-archer/SKHelper)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frussell-archer%2FSKHelper%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/russell-archer/SKHelper)
[![](https://img.shields.io/github/license/russell-archer/SKHelper)](https://img.shields.io/github/license/russell-archer/SKHelper)

---

# SKHelper

`SKHelper` is a lightweight Swift package that enables developers to add in-app purchase and subscription functionality to their apps.

Designed to be an easier-to-use refactoring of my [StoreHelper](https://github.com/russell-archer/StoreHelper) package, it makes use of Apple's **StoreKit Views** to provide a standard and easily customizable UI. The package is split into a reusable StoreKit core module and an optional SwiftUI module, so apps with custom paywalls can depend on the StoreKit helper layer without compiling the UI layer.

- Note that `SKHelper` requires **Xcode 16.3+, iOS 17+** and **macOS 14.6+**
- Support for **consumable** transactions requires **iOS 18+** and **macOS 15+**
- Supports **Swift 6 Strict Concurrency Checking**

Check out the [Quick Start Tutorial](https://russell-archer.github.io/SKHelper/tutorials/quickstart) to get a fast overview of how things work.

![](./Sources/SKHelperUI/Documentation.docc/Resources/images/skhelper-logo.png)

- [SKHelper Documentation Landing Page](https://russell-archer.github.io/SKHelper/documentation/skhelperui) - `SKHelperUI` documentation landing page
- [SKHelper Core Documentation](https://russell-archer.github.io/SKHelper/documentation/skhelpercore) - StoreKit-only core API documentation
- [SKHelper Quick Start](https://russell-archer.github.io/SKHelper/tutorials/quickstart) - `SKHelper` quick-start guide
- [SKHelper In-Depth Guide](https://russell-archer.github.io/SKHelper/documentation/skhelperui/guide) - `SKHelper` and `StoreKit2` in-depth guide
- [SKHelper Demo Project](https://github.com/russell-archer/SKHelperDemo) - Example Xcode `SKHelper` project

---

## Overview of SKHelper

`SKHelper` is a Swift Package Manager package that enables developers using **Xcode 16.3+** to easily add in-app purchase support to **iOS 17+** and **macOS 14.6+** apps.

`SKHelper` provides the following features:

- Multi-platform iOS and macOS SwiftUI support for purchasing **Consumable**, **Non-consumable** and **Subscription** products
- Supports **Swift 6 Strict Concurrency Checking**
- Makes use of Apple's **StoreKit Views** to provide a standard and easily customizable UI
- Provides a StoreKit-only `SKHelperCore` module for apps that use a custom paywall or purchase UI
- Keeps SwiftUI views and modifiers in the optional `SKHelperUI` module
- Designed to be **lightweight**, simple and an easier-to-use refactoring of the `StoreHelper` package
- Detailed **documentation** and an example project
- Supports **transaction validation**, **pending ("ask to buy") transactions**, **cancelled** and **failed** transactions
- Support for direct App Store purchases of **promoted in-app purchases** via Purchase Intents
- Supports customer **refunds** and management of **subscriptions**
- Provides detailed **transaction information and history** for non-consumables and subscriptions

## Package Products

`SKHelper` provides two library products:

| Product | Import | Use case |
|---|---|---|
| `SKHelperUI` | `import SKHelperUI` | SwiftUI and StoreKit Views integration built on top of `SKHelperCore`. |
| `SKHelperCore` | `import SKHelperCore` | StoreKit 2 product loading, purchase, entitlement, transaction, subscription, and cache logic without SwiftUI views. |

Add `SKHelperUI` if you want the built-in SwiftUI purchase views and modifiers. Add `SKHelperCore` if your app has a custom paywall or purchase UI.

`SKHelperUI` re-exports `SKHelperCore`, so SwiftUI clients only need `import SKHelperUI`.

## Requirements

`SKHelper` uses the newest features of Apple's `StoreKit2` and requires **iOS 17+**, **macOS 14.6+** and **Xcode 16.3+**.

## Getting Started

For the full SwiftUI experience, depend on the `SKHelperUI` product and follow the [SKHelper Quick Start](https://russell-archer.github.io/SKHelper/tutorials/quickstart) guide.

For a custom paywall or purchase UI, depend on `SKHelperCore` and use `SKHelper` to request products, purchase products, listen for transactions, and query entitlements.

## Migration Note

This split intentionally does not keep a compatibility product named `SKHelper`, so it must ship as `2.0.0` or later rather than a `1.x` minor update. Existing clients that used `import SKHelper` should migrate to `import SKHelperUI` for the previous SwiftUI surface, or `import SKHelperCore` for core StoreKit functionality.

In Xcode's package product picker, remove the old `SKHelper` product from the app target and add either `SKHelperUI` or `SKHelperCore`. SwiftPM clients should update target dependencies from `.product(name: "SKHelper", package: "SKHelper")` to `.product(name: "SKHelperUI", package: "SKHelper")` or `.product(name: "SKHelperCore", package: "SKHelper")`.

## License

MIT license, copyright (c) 2024 Russell Archer. This software is provided "as-is" without warranty and may be freely used, copied, modified and redistributed, including as part of commercial software.

See [License](https://russell-archer.github.io/SKHelper/documentation/skhelperui/license) for details.
