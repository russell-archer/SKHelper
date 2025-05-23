# ``SKHelper``

@Metadata {
    @PageImage(purpose: icon, source: skhelper-logo-small) 
}

`SKHelper` is a Swift Package Manager (SPM) package that enables developers using **Xcode 16** to easily add in-app purchase 
support to **iOS 17+** and **macOS 14.6+** SwiftUI apps. 

## Overview

`SKHelper` is a Swift Package Manager (SPM) package that enables developers using **Xcode 16** to easily add in-app purchase 
support to **iOS 17+** and **macOS 14.6+** SwiftUI apps. 

`SKHelper` provides the following features:

- Multi-platform (iOS, macOS) SwiftUI support for purchasing **Consumable**, **Non-consumable** and **Subscription** products
- Makes use of Apple's **StoreKit Views** to provide a standard and easily customizable UI
- Supports **Swift 6 Strict Concurrency Checking** 
- Designed to be **lightweight**, simple and an easier-to-use refactoring of the `StoreHelper` package
- Detailed **documentation** and an example project
- Supports **transaction validation**, **pending ("ask to buy") transactions**, **cancelled** and **failed** transactions
- Support for direct App Store purchases of **promoted in-app purchases** via Purchase Intents
- Supports customer **refunds** and management of **subscriptions** (not yet implemented)
- Provides detailed **transaction information and history** for non-consumables and subscriptions (not yet implemented)

## License

MIT license, copyright (c) 2024, 2025 Russell Archer. This software is provided "as-is" without warranty and may be freely used, copied, 
modified and redistributed, including as part of commercial software. 

See the `SKHelper` <doc:LICENSE> for details.

## Requirements

- `SKHelper` uses Apple's `StoreKit2`, which requires **iOS 17**, **macOS 14+** and **Xcode 16**.

## Getting Started

- For a quick, step-by-step overview of how to use `SKHelper` refer to the <doc:quickstart> 
- For an in-depth treatment of in-app purchases, `StoreKit2` and `SKHelper` refer to the <doc:guide>

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
