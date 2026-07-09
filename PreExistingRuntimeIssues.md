# Potential Pre-Existing Runtime and Lifecycle Issues

## Context

These findings were discovered while reviewing the `SKHelperCore` and `SKHelperUI` split, but the relevant code paths existed before that refactor. They are not regressions caused by the module split.

This document records code-level risks, not confirmed production incidents. The reviewing app has used SKHelper without an observed failure, and no dedicated StoreKit reproduction suite was run for these findings. The suggested priorities therefore combine potential impact with how likely each condition is in a typical integration.

Most apps create one `SKHelper` instance at launch, keep it alive for the process lifetime, load products automatically, and install callbacks on stable root views. That usage pattern avoids or hides many of the scenarios below.

## Suggested triage

| Finding | Suggested priority | Confidence in code path | Expected frequency |
|---|---|---:|---:|
| A listener exits after one exceptional StoreKit event | P2 | High | Low to medium |
| Listener tasks strongly retain `SKHelper` | P2 | High | Low for app-scoped instances |
| An entitlement update can arrive before products are loaded | P2 | High | Medium for manual/core-only loading |
| Custom configuration cache can return values from another file | P3 | High | Low |
| SwiftUI callback registration has no lifecycle ownership | P2 | High | Medium in navigation-heavy UI |

None of these findings is classified as P1 without a reproducible production-impact case. The listener and entitlement-cache findings are the best candidates to investigate first because they can affect purchase state within a running session.

## 1. StoreKit listeners can stop after one exceptional event

**Suggested issue title:** Keep StoreKit listeners alive after per-event validation, revocation, and decoding failures

**Suggested priority:** P2  
**Confidence:** High  
**Relevant code:** [transaction listener](Sources/SKHelperCore/Core/SKHelper.swift#L879), [subscription listener](Sources/SKHelperCore/Core/SKHelper.swift#L958)

### What may happen

The transaction update loop uses `return` after an unverified transaction, an unsupported non-renewable transaction, or a revoked transaction. The subscription update loop also uses `return` when one status payload cannot be unwrapped.

Because these returns are inside the task closure, they end the entire long-lived listener instead of rejecting only the current event. Later refunds, cross-device purchases, renewals, or other transaction updates may no longer update callbacks and cached state until `SKHelper` is recreated or the app relaunches.

Purchases made directly through `SKHelper.purchase(...)` still process their immediate result, which limits the blast radius.

### Why an app may never notice

- Verification failures and unsupported product events are uncommon.
- A revocation is uncommon, and many sessions end before another transaction arrives.
- Relaunching the app creates fresh listener tasks.
- Explicit entitlement queries may repair some stale state.

### Suggested reproduction

1. Keep one `SKHelper` instance alive.
2. Deliver a revoked or deliberately unverified transaction update.
3. Deliver a second valid update without recreating the helper.
4. Verify whether the second update reaches `transactionUpdateListener`.

For deterministic tests, inject the transaction and subscription async sequences instead of depending directly on StoreKit static sequences.

### Suggested direction

Use `continue` for recoverable per-event rejection paths and reserve `return` for cancellation or sequence completion. Log rejected events and keep cancellation checks explicit. This is a behavior change and should be covered by listener tests before release.

## 2. Listener tasks may retain `SKHelper` indefinitely

**Suggested issue title:** Break the SKHelper-to-listener Task retain cycle and provide deterministic shutdown

**Suggested priority:** P2  
**Confidence:** High  
**Relevant code:** [task ownership](Sources/SKHelperCore/Core/SKHelper.swift#L90), [deinit cancellation](Sources/SKHelperCore/Core/SKHelper.swift#L135), [task capture](Sources/SKHelperCore/Core/SKHelper.swift#L884)

### What may happen

`SKHelper` stores three long-lived task handles, and each task closure strongly captures `self`. Cancellation currently happens only in `deinit`, but the ownership chain can be circular:

`SKHelper -> Task -> closure -> SKHelper`

If the cycle keeps the helper alive, `deinit` cannot be relied on to break it. Replacing a helper could leave old listeners and callback closures active alongside the replacement helper.

### Why an app may never notice

The common integration creates one environment-owned `SKHelper` that intentionally lives until process termination. In that model, the retained lifetime looks normal and no replacement listener is created.

The issue is more relevant to previews, tests, dependency containers, account switching, or core-only clients that create temporary helper instances.

### Suggested reproduction

1. Create `SKHelper(autoRequestProducts: false)` on the main actor.
2. Keep a weak reference to it.
3. Release the only external strong reference and yield execution.
4. Check whether the weak reference becomes `nil`.
5. Create another helper and check for duplicate event processing.

### Suggested direction

Provide an explicit, idempotent shutdown operation that cancels and clears the tasks. Task closures should avoid retaining the helper across long sequence suspensions. Keep `deinit` cancellation as a safety net rather than the only lifecycle mechanism.

## 3. Early transaction updates can miss the entitlement cache

**Suggested issue title:** Persist entitlement updates received before product metadata is loaded

**Suggested priority:** P2  
**Confidence:** High  
**Relevant code:** [initialization order](Sources/SKHelperCore/Core/SKHelper.swift#L116), [cache update](Sources/SKHelperCore/Core/SKHelper.swift#L1001)

### What may happen

StoreKit listeners start before `products` is populated. `updatePurchasedProducts` persists a change only when it finds the matching in-memory `SKHelperProduct`.

An unfinished, revoked, or external transaction may therefore be finished while its entitlement update is silently skipped. Possible symptoms include a temporarily stale cached purchase, a revoked product remaining cached, or an incorrect fallback entitlement until a later StoreKit reconciliation succeeds.

This is more relevant to core-only clients using `autoRequestProducts: false` or intentionally delayed product loading.

### Why an app may never notice

- Automatic product loading often completes before a relevant update arrives.
- Most launches have no unfinished or external transaction waiting.
- An existing cache may already hold the correct value.
- Later calls to `isPurchased` or `isSubscribed` can query StoreKit directly.

### Suggested reproduction

1. Initialize `SKHelper` with `autoRequestProducts: false`.
2. Preseed a cached entitlement for a product.
3. Deliver a revocation before requesting product metadata.
4. Request the products and inspect the cached entitlement.
5. Repeat with a successful transaction and an initially empty cache.

### Suggested direction

Update the persisted product-ID set independently of the in-memory product array. Mutate a matching `SKHelperProduct` when it becomes available, and reconcile current entitlements after product loading. Any asynchronous reconciliation should have clear cancellation and stale-result ownership.

## 4. Custom configuration caching is not filename-aware

**Suggested issue title:** Make SKHelper custom configuration caching filename-aware

**Suggested priority:** P3  
**Confidence:** High  
**Relevant code:** [global configuration state](Sources/SKHelperCore/Core/SKHelperConfiguration.swift#L89), [cached lookup](Sources/SKHelperCore/Core/SKHelperConfiguration.swift#L155)

### What may happen

The custom configuration dictionary is loaded only while empty and is not keyed by filename. A later helper that requests another configuration file can receive values from the first file. Creating a helper without a custom configuration also does not reset the previous static filename.

Potentially stale values include privacy-policy URLs, terms URLs, contact links, and redeem-code visibility.

### Why an app may never notice

Most production apps create one helper and use one immutable configuration for the entire process lifetime. Multiple files are more common in previews, tests, white-label builds, or runtime environment switching.

### Suggested reproduction

1. Add two configuration plists with different values for the same key.
2. Read the key from file A.
3. Read the same key from file B.
4. Verify whether B incorrectly returns A's value.
5. Create a helper with no custom configuration and verify whether the previous static file remains active.

### Suggested direction

Cache dictionaries by filename, or reload whenever the requested filename changes. A stronger design would make configuration immutable and owned by each `SKHelper` instance instead of using process-global mutable state.

## 5. SwiftUI callback registration has no lifecycle ownership

**Suggested issue title:** Give SKHelper UI event subscriptions explicit SwiftUI lifecycle ownership

**Suggested priority:** P2  
**Confidence:** High  
**Relevant code:** [products callback](Sources/SKHelperUI/ViewModifiers/OnProductsAvailable.swift#L27), [transaction callback](Sources/SKHelperUI/ViewModifiers/OnTransaction.swift#L27), [subscription callback](Sources/SKHelperUI/ViewModifiers/OnSubscriptionChange.swift#L27)

### What may happen

`onProductsAvailable` appends another closure on every appearance and never removes it. Transaction and subscription modifiers overwrite a single callback slot and do not restore or clear it when their view disappears.

Possible symptoms include duplicate product callbacks, repeated analytics or UI actions, the most recently appearing screen replacing another subscriber, and off-screen views continuing to receive events.

### Why an app may never notice

An app that installs each modifier once on a stable root view normally gets one registration for the process lifetime. The problem becomes more visible when modifiers are placed in sheets, tabs, navigation destinations, or conditionally rendered content.

### Suggested reproduction

1. Present and dismiss a view containing `onProductsAvailable` three times.
2. Trigger another product notification and count callback invocations.
3. Present two views using `onTransaction`.
4. Verify which view receives updates before and after the latest view disappears.

### Suggested direction

Return cancellable observer tokens and unregister them with view lifecycle, or expose events as an `AsyncStream` consumed by a SwiftUI `.task`. If only one consumer is supported, document and enforce that ownership explicitly.

## Recommended next step

Open separate issues rather than changing these behaviors inside the mechanical Core/UI split. Start with deterministic tests for listener continuation and early entitlement updates. The task-lifetime, configuration, and UI subscription changes can then be evaluated independently without obscuring the package-structure review.
