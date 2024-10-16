# SKHelper Guide

@Metadata {
    @PageImage(purpose: icon, source: skhelper-logo-small)
}

Updated: October 16, 2024 11:53 PM

## Contents

- [Overview](#Overview)
- [What is StoreKit?](#What-is-StoreKit)
- [What is SKHelper?](#What-is-SKHelper)
- [Source Code](#Source-Code)
- [References](#References)
- [What does this document provide?](#What-does-this-document-provide)
- [Do I really need SKHelper?](#Do-I-really-need-SKHelper)
- [The SKHelperDemo App](#The-SKHelperDemo-App)
    - [What are we building?](#What-are-we-building)
    - [Prerequisites](#Prerequisites)
    - [Get Started](#Get-Started)
    - [Configuring products](#Configuring-products)
        - [Localized product information](#Localized-product–information)
        - [The Products.plist file](#The-Products.plist-file)
        - [Product types](#Product-types)
        - [The StoreKit Configuration file](#The-StoreKit-Configuration-file)
    - [Why do we have two product lists?!](#Why-do-we-have-two-product-lists)
    - [Enable StoreKit Testing](#Enable-StoreKit–Testing)
    - [Configure product images](#Configure-product-images)
    - [Displaying a list of products](#Displaying-a-list-of-products)
        - [Testing non-U.S. localizations](#Testing-non-U.S.-localizations)
    - [Customizing the appearance of the product list](#Customizing-the-appearance-of-the-product-list)
    - [How does SKHelperStoreView work?](#How-does-SKHelperStoreView-work)

---

## Overview

This guide describes how to implement and test in-app purchases with **SwiftUI**, `SKHelper`, `StoreKit2`, **Xcode 16, iOS 17+** and **macOS 14.6+**. 

![](skhelper-logo.png)

We will cover similar ground to that discussed in the [SKHelper Quick Start](https://russell-archer.github.io/SKHelper/tutorials/quickstart), although in much greater detail. No knowledge of `StoreKit2` or working with in-app purchases is assumed.

- View the `SKHelper` project on [GitHub](https://github.com/russell-archer/SKHelper)
- View the [Quick Start](https://russell-archer.github.io/SKHelper/tutorials/quickstart) on GitHub for an overview of how to get started
- View the [SKHelper demo](https://github.com/russell-archer/SKHelperDemo) project on GitHub

## What is StoreKit?

`StoreKit` is the Apple framework that provides API support for working the with the App Store to enable your app to offer in-app purchases and subscriptions. It’s important to distinguish between `StoreKit2` (introduced September 2021) and `StoreKit1`, which was introduced in 2009 and  **deprecated** when Xcode 16 was launched in September 2024. Apple sometimes refers to `StoreKit1` as the “original API for in-app purchase”.

> 👉 In this document whenever we refer to `StoreKit` we mean `StoreKit2`, the second major version of StoreKit.

## What is SKHelper?

`SKHelper` is  a lightweight `StoreKit` **SwiftUI** helper package that logically sits between your app and `StoreKit` to provide support for implementing in-app purchases and subscriptions in **Xcode 16, iOS 17+** and **macOS 14.6+**. Note that support for **consumable** transactions requires **iOS 18+** and **macOS 15+**.

Designed to be an easier-to-use refactoring of my [StoreHelper](https://github.com/russell-archer/StoreHelper) package, `SKHelper` makes use of Apple's **StoreKit Views** to provide a standard and easily customizable UI.

![](guide1.png)

## Source Code

The latest version of `SKHelper` is always available [on GitHub](https://github.com/russell-archer/SKHelper).

> **The source code presented here and in the `SKHelper` package is for educational purposes.** 
> **You may freely reuse and amend this code for use in your own apps. However, you do so entirely at your own risk.**

## References

[StoreKit | Apple Developer Documentation](https://developer.apple.com/documentation/storekit)

[Supporting promoted In-App Purchases in your app | Apple Developer Documentation](https://developer.apple.com/documentation/storekit/in-app_purchase/supporting_promoted_in-app_purchases_in_your_app)

[What’s new in StoreKit and In-App Purchase - WWDC24 - Videos - Apple Developer](https://developer.apple.com/videos/play/wwdc2024/10061/)

## What does this document provide?

This document discusses how to use Apple’s `StoreKit` and the `SKHelper` framework to provide in-app purchases in your **iOS** or **macOS** **SwiftUI**-based apps. Specifically, we’ll cover:

- How to use the `SKHelper` package to create iOS and macOS SwiftUI apps that allows users to purchase a range of products:
    - **Consumables**
    - **Non-consumables**
    - **Subscriptions**
- An in-depth review of how to use `SKHelper`, a Swift package that encapsulates `StoreKit` in-app purchase functionality and makes it easy to work with the App Store
- Developing a demo app for an on-line florist that sells a range of flowers and other related services like home visits to water and care for house plants
- Requesting localized **product information** from the App Store
- How to **purchase** a product and **validate the transaction**
- Handling **pending (“ask to buy”) transactions** where parental permission must be obtained before a purchase is completed
- Handling **cancelled** and **failed transactions**
- Handling customer **refunds**
- Managing **subscriptions**, including upgrading, downgrading and cancelling
- Exploring detailed **transaction information and history** for consumables, non-consumables and subscriptions
- Testing purchases locally using **StoreKit configuration** files
- Support for direct App Store purchases of **promoted in-app purchases**

## Do I really need SKHelper?

No, you don’t. You can easily develop you own code to support in-app purchases, particularly now that `StoreKit` provides SwiftUI views and view modifiers to enable user purchases. Prior to the introduction of `StoreKit2`, things were more complicated and there were three areas of particular difficulty: 

- Creating a purchase UI
- Validating purchases
- Working with delegate-based APIs.

`StoreKit2` addresses all these issues, and more:

- **StoreKit Views** enable the presentation of a standardized, customizable purchase UI
- Transactions are **automatically** validated against the App Store receipt
- The `async`/`await` pattern is used throughout the API

However, even if you develop your own in-app purchase code there are still a few areas of complexity, particularly with regard to subscriptions. You’ll probably end up creating something very similar to `SKHelper`!

## The SKHelperDemo App

![](guide2.png)

The best way to get familiar with `StoreKit` and `SKHelper` is to create a simple, but full-featured (from an in-app purchase perspective) demo app. You may be surprised how little code is required to implement in-app purchases: `SKHelper` and `StoreKit` handle all the heavy-lifting!

### What are we building?

In this guide we’ll be developing a demo app (**SKHelperDemo**) for an on-line florist that sells a range of flowers and other related services like home visits to water and care for house plants. We’ll develop the app for both macOS and iOS, using a single multi-platform Xcode project.

### Prerequisites

Before getting started you’ll need to download **Xcode 16**, along with the **iOS 18 SDK and simulator**.

### Get Started

To get started, create a new **multi-platform** Xcode project and name it **SKHelperDemo:**

![](quickstart1.png)

Once Xcode has created the project select **File > Add Package Dependencies**:

![](quickstart2.png)

In the search field enter the URL of the **SKHelper** package on GitHub and tap **Add Package:**

> 👉 The URL of the **SKHelper** package is: [https://github.com/russell-archer/SKHelper](https://github.com/russell-archer/SKHelper)

![](guide3.png)

Xcode will now retrieve the **SKHelper** package from GitHub. When prompted, tap **Add Package** to add the package to your project:

![](quickstart4.png)

We now need to add the necessary in-app purchase capabilities to our project. Select your project’s target and navigate to the **Signing & Capabilities** tab. Tap the **+ Capability** button and add the **In-App Purchase** capability to your project:

![](guide4.png)

### Configuring products

Before we do anything else we need to define the products we’ll be selling. Ultimately, this will need to be done in **App Store Connect**. However, Xcode provides us with an local, on-device way of experimenting with in-app purchases.

**StoreKit Testing**, introduced in Xcode 12, is a test environment allows you to do early testing of in-app purchases in the simulator, without having to set anything up in App Store Connect. You define your products locally in a **StoreKit Configuration** file. Furthermore, you can view and delete transactions, issue refunds, cancel subscriptions, and a whole lot more. There’s also a new **StoreKitTest** framework that enables you to do automated testing of IAPs. 

#### Localized product information

Each product that we will sell in our app is identified by a unique `ProductId`. You can either hard-code these ids into your app, or store them in an easily-modifiable property list file. In our demo app we’ll use the property list approach.

When our demo app runs it will need to get *localized* product information. This includes things like a product’s name and description in the appropriate local language, and prices in the local currency. When an app has been released, or when using **Sandbox testing** (more on this later) this information comes from the App Store. When using local Xcode StoreKit testing the information comes from the StoreKit Configuration file.

The switch between local StoreKit testing and the App Store is transparent in terms of our in-app purchase code: it’s a simple configuration change.

The following diagram shows the arrangement for requesting localized product information:

![](guide5.png)

1. We create a list of product ids and provide them to `SKHelper` via a **Products.plist** file
2. The `SKHelper.requestProducts()` method calls the 
3. StoreKit `Product.products(for:)` method, passing the list of products ids
4. In production, a call is made to the App Store to get localized product info. If the project is configured to use StoreKit testing localized product information is returned from the `Products.storekit` configuration file
5. The resulting localized product information is stored in the `SKHelper.products` property

#### The Products.plist file

Create a new **Property List** file in your project and name it **Products.plist**. Paste the contents of the example **Products.plist** file shown into your **Products.list** file. 

> 👉 The **Products.plist** file doesn’t *have* to be named **Products.plist**, but by default `SKHelper` looks for a file of that name. 

If you want to change it (and other configuration values) to something else you can create a custom configuration file in your project. See **Configuration.plist** in the **SKHelper > Samples > Configuration** folder for an example.

You can tell `SKHelper` to use the custom configuration to override default values when you initialize it: 

```swift
// Use a custom configuration file named "Configuration.plist"
@State private var store = SKHelper(customConfiguration: "Configuration")
```

In the Xcode **Project navigator** pane, right-click the property list you just created and select **Open As > Source Code**. Paste the following data into the file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Products</key>
    <array>
        <string>com.rarcher.nonconsumable.flowers.large</string>
        <string>com.rarcher.nonconsumable.flowers.small</string>
        <string>com.rarcher.consumable.plant.installation</string>
    </array>
    <key>Subscriptions</key>
    <array>
        <dict>
            <key>Group</key>
            <string>vip</string>
            <key>Products</key>
            <array>
                <string>com.rarcher.subscription.vip.gold</string>
                <string>com.rarcher.subscription.vip.silver</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

> 👉 Make sure to include **Products.plist** in the **Target Membership** for both the iOS and macOS targets. This is because we’ll need the list of product ids in both testing and release builds.

Notice **consumable** and **non-consumable** (see below for definitions) products are listed in the `Products` section, with **subscriptions** listed in the `Subscriptions` section. 

Also note that we’ve adopted a **naming convention** for our product ids: 

- *com.developer.product-type.name* for consumables and non-consumables, and
- *com.developer.subscription.group.name* for subscriptions

This isn’t strictly necessary, so product ids like “large-flowers” and “gold” are also perfectly acceptable as product ids only need to be unique within each particular app.

#### Product types

At this point we need to discuss product *types*. `SKHelper` supports three types of product.

**Consumables**

This type of product represents something that can be purchased and then “used up” in some way. The user can purchase multiples of this type of product. 

For example, a consumable product might be an “super-powers token” that grants the user extra abilities, for a limited time, in a game. In our demo we offer a consumable that represents an on-site visit to water and care for your plants. The product lasts for one visit and then expires. The user may purchase as many visits as they want.

**Non-consumables**

A non-consumable product is a something the user purchases once and which lasts “forever”. An example would be purchasing access to “pro-level” functionality in a camera app. In our demo we sell non-consumable products like flowers and chocolates.

**Auto-renewable subscriptions**

An auto-renewable subscription represents a service that requires a regular payment. For example, a specialist skiing weather app might requires a monthly subscription. The user may cancel the subscription at any time, in which case access to the service will end when the next renewal payment becomes due. 

Note that subscriptions are offered as part of a **group** of subscription products. For example, in the demo app we define a “VIP” subscription group (see Products.plist above) which contains two product **levels**: “gold” (the highest value) and “silver”. The position of the product id in the file determines the **product level** or **value**. Products that appear towards the top of the file are of higher value than those defined towards the bottom of the file. We’ll see later how easy it is to support users upgrading, downgrading or cancelling subscriptions.

> 👉 Note that SKHelper does not support the older type of *non*-renewable subscription, the use of which is discouraged by Apple.

#### The StoreKit Configuration file

We can now create the StoreKit configuration file that will be used to provide localized product data during initial development and testing.

Create a **StoreKit Configuration File** by selecting **File > New > File** and choosing the **StoreKit Configuration File** template:

![](quickstart9.png)

From Xcode 14 onwards you can choose to create a **synced** `.storekit` configuration file that is linked to in-app purchases already defined in App Store Connect. Once you’ve created the synced `.storekit` configuration file you can’t edit it locally in Xcode, all changes have to be made in App Store Connect.

After clicking **Next** you’ll be asked if you want to create a synced `.storekit` configuration file:

![](guide6.png)

If you choose to sync your StoreKit configuration file with the App Store you’ll be prompted to select one of your apps in App Store Connect:

![](guide7.png)

For the purposes of our demo we won’t create a synced configuration file.

Open the newly created **Products.storekit** file (you can name it anything you like) and click the “+” at the bottom-left of the window. You’ll be prompted to select the type of product you want to create:

![](guide8.png)

Create a **Consumable** in-app purchase and provide a **Reference Name** and **Product ID**:

![](guide9.png)

The configuration file will open, allowing you to add pricing details and localization information:

![](guide10.png)

For now, just add a **Display Name** and **Description** for English (U.S.):

![](guide11.png)

Notice under the **APP** section in the left pane you can configure various test settings and app policies:

![](guide12.png)

We’ll come back to alter some of these settings later. For now, create two new non-consumable in-app purchases with the following details:

| **Reference Name** | **Product ID** | **Price (see note below)** | **English (U.S.) 
Display Name** | **English (U.S.) 
Description** |
| --- | --- | --- | --- | --- |
| Flowers Large | `com.rarcher.nonconsumable.flowers.large` | 1.99 | Large Flowers | A beautiful large bunch of seasonal flowers. |
| Flowers Small | `com.rarcher.nonconsumable.flowers.small` | 0.99 | Small Flowers | A beautiful small bunch of seasonal flowers. |

> 👉 These price values are a hard-coded test price for the product. Before deploying to the App Store, you’ll configure real prices for your app’s in-app purchases and subscriptions in App Store Connect. In production your app will request localized price (and other) information from the App Store.

> 👉 Note also that none of the data defined in the local (non-synced) `.storekit` file is *ever* uploaded to App Store Connect. It’s only used when testing in-app purchases locally in Xcode. No real user will ever see this test data.

Your **Products.storekit** configuration file should now look like this:

![](guide13.png)

Now we’ll create our subscription products. Click the “+” and select **Add Auto-Renewable Subscription**.

You’ll first be prompted to create a new subscription group. Name your group “**vip”**:

![](guide14.png)

Next, provide a **Reference Name** of “**Silver”** and **Product ID** of `com.rarcher.subscription.vip.silver`:

![](guide15.png)

You’ll see that the StoreKit configuration file provides a range of offers and promotions. Ignore those for now and add the following details: 

- Price: 29.99
- Display Name (English U.S.): **Silver Service**
- Description (English U.S.): **Personal care for your plants**.

Now create a new “Gold” subscription with the following details:

- Reference Name: Gold
- Product ID: `com.rarcher.subscription.vip.gold`
- Price: 39.99
- Display Name (English U.S.): **Gold Service**
- Description (English U.S.): **A touch of luxury for you plants.**

Finally, let’s create an introductory offer for the Gold product.

In the **Introductory Offer** section, set the **Offer Type** to be **Free** and the **Duration** to be **3 Days**:

![](guide16.png)

If you now select the “vip” group in the left pane you’ll be able to configure settings for the group as a whole. Make sure that the “gold” subscription (the most valuable) is at the top of the list by setting its **Level value** to **1**. Also ensure that “silver” is set to level **2**:

![](guide17.png)

### Why do we have two product lists?!

At this point you may very reasonably be wondering why we have a **Products.storekit** configuration file *and* a **Products.plist** file. Couldn’t we just make do with one, because data (product ids) is duplicated in the two files? 

There is a fundamental principle in software development that may be summarized by the **DRY** mnemonic: **D**on’t **R**epeat **Y**ourself. Essentially, if you find you’ve duplicated code or data you should generally find a way of abstracting it into a single entity, and then referencing that entity as required from multiple places. Experience shows that if you’ve got basically the same thing scattered throughout your project, if you need to modify it there’s a good chance you’ll forgot to update *all* the occurrences. This can lead to difficult-to-find bugs and misery!

So, because we’ve defined our products in the StoreKit configuration file, it seems obvious that we should use **that** as the repository for our product id data. Retrieving configuration data at runtime from the `.storekit` file isn’t difficult (it’s `JSON`). However, the `.storekit`configuration file is intended for use *when testing* and it’s really **not** a good idea to use it for production too. This is why the `.storekit` file is not included in any of your targets by default. It would be all too easy to allow “test products” to somehow make it into the release build! So, in this case it’s better to violate the DRY principle, rather than risk something far worse!

### Enable StoreKit Testing

Before moving on to other topics, we’ll need to *enable* StoreKit testing in Xcode, as it’s disabled by default.

Select **Product > Scheme > Edit Scheme**. Now select **Run** and the **Options** tab. You can now select the configuration file from the **StoreKit Configuration** list:

![](quickstart12.png)

### Configure product images

In the **SKHelper** package, navigate to the **Samples/Images** folder. Select the images that have filenames that start with “com” then right-click them and select **Show in Finder**. 

Locate the file named “plant-services” and add that to your selection. 

Drag all the selected images from Finder into your project’s asset catalog:

![](quickstart10.png)

Notice that each product has an image with a filename that corresponds to the product id.

Switch back to Finder and use the files with names that start with “SKHelperDemo” to populate the asset catalog’s **AppIcon** image set:

![](guide18.png)

### Displaying a list of products

Having configured our products, let’s see how easy it is to display a list of them using `SKHelper`.

Open the project’s **SKHelperDemoApp.swift** file and replace the contents with the code as shown. Notice how we create an instance of the **SKHelper** object and add it to the view environment:

```swift
import SwiftUI
import SKHelper

@main
struct SKHelperDemoApp: App {
    @State private var store = SKHelper()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
```

Now open **ContentView.swift** file and replace the contents with the code shown:

```swift
import SwiftUI
import SKHelper

struct ContentView: View {
    @Environment(SKHelper.self) private var store
    
    var body: some View {

        // SKHelperStoreView() lists all available products for this app.
        // Purchasing is supported. Purchased products will be grayed-out.
        // Tapping on a product's image shows details for that product.
        SKHelperStoreView()
    }
}

#Preview { ContentView().environment(SKHelper()) }
```

`SKHelperStoreView()` uses a StoreKit `StoreView` (more on this later) to create a list of all our available products. When `SKHelper` is instantiated, it reads the **Products.plist** file we created previously and asks `StoreKit` to fetch a collection of localized product information. This product information is stored in `SKHelper.products`.

If you now build and run the app you should see a list of all the products we configured earlier:

![](guide19.png)

Notice that:

- Each product has a short text description, an image clipped to a circular shape and a price button
- The list of products is sorted into groups by product type, with non-consumables shown first, then consumables, with subscriptions shown at the end of the list
- Tapping on the price button starts the standard purchase process for the product
- There is a “Restore Missing Purchases” button, as required by the App Store
- Tapping on the product’s image shows a sheet containing product details:
    
    

![](guide20.png)

#### Testing non-U.S. localizations

When you run the app you’ll see that prices are in US dollars. This is because, by default in the StoreKit test environment, the App Store **Storefront** is **United States (USD)** and the localization is **English (US)**. To support testing other locales you can change this. 

Make sure the `Products.storekit` file is open, then select **Editor > Default Storefront** and change this to another value. You can also changed the localization from **English (US**) with **Editor > Default Localization**. If you change the localization settings you’ll need to make sure to add text matching that locale (e.g. French) to each product in the `.storekit` file:

![](guide21.png)

### Customizing the appearance of the product list

As you can see, you get so much functionality for just two lines of code! However, there are many ways in which you can customize how `SKHelperStoreView` behaves. For example, we can modify the display of product details like this:

```swift
struct ContentView: View {
    @Environment(SKHelper.self) private var store
    
    var body: some View {

        SKHelperStoreView() { productId in
            // When the use taps on the product's image SKHelperStoreView passes 
            // its `ProductId` to this closure, which we can use to customize 
            // the displayed details
            Group {
                Image(productId + ".info").resizable().scaledToFit()
                Text("Here is some text about why you might want to buy this product.")
                Text("We think you'll find this product very useful!")
            }
            .padding()
        }
    }
}
```

![](guide22.png)

In a production app you would need to use the `productId` parameter passed to the closure to provide different details for each product. For example, you might create a string catalog which provides product details text. The key for each string in the catalog could be the `ProductId` of the specific product.

### How does SKHelperStoreView work?

TODO - work in progress
