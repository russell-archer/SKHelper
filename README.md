# SKHelper

# Recent Major Changes
- 5 Aug, 2024
    - First proof-of-concept public release of `SKHelper` on GitHub

---

## Overview of SKHelper

`SKHelper` is a Swift Package Manager (SPM) package that enables developers using **Xcode 16** to easily add in-app purchase 
support to **iOS 16.4+** and **macOS 14.6+** SwiftUI apps. 

`SKHelper` provides the following features:

- Multi-platform (iOS, macOS) SwiftUI support for purchasing **Consumable** (not yet implemented), **Non-consumable** and **Subscription** products
- Makes use of Apple's **StoreKit Views** to provide a standard and easily customizable UI
- Designed to be **lightweight**, simple and an easier-to-use refactoring of the `StoreHelper` package
- Detailed **documentation** and an example project
- Supports **transaction validation**, **pending ("ask to buy") transactions**, **cancelled** and **failed** transactions
- Supports customer **refunds** and management of **subscriptions** (not yet implemented)
- Provides detailed **transaction information and history** for non-consumables and subscriptions (not yet implemented)
- Support for direct App Store purchases of **promoted in-app purchases** via Purchase Intents
- Supports Xcode 16's "complete" **Strict Concurrency Checking** 

## License

MIT license, copyright (c) 2024 Russell Archer. This software is provided "as-is" without warranty and may be freely used, copied, 
modified and redistributed, including as part of commercial software. 

See [License](https://russell-archer.github.io/SKHelper/documentation/skhelper/license) for details.

## Requirements
`StoreHelper` uses the newest features of Apple's `StoreKit2` and which requires **iOS 16.4+**, **macOS 14.6+** and **Xcode 16**.

## Getting Started

Jump to the [StoreHelper Quick Start](https://russell-archer.github.io/SKHelper/documentation/skhelper/quickstart) guide.

## TODO
- DONE: complete getHighestValueActiveSubscription()
- DONE: complete subscriptionInformation(): add all previous transactions for a subscription 
- DONE: (for subscription store view only - not supported on other view, will need to add manually for StoreView) privacy and terms of service buttons
- DONE: switch from using StoreKit views with ids to products
- There’s a modifier that returns a view that’s dependent on an in-app purchase - demo usage (.currentEntitlementTask(for:))

