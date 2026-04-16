# gptom

Flutter plugin for **GP tom** payments (**Android App2App** + **iOS Deeplinks**).

> **Important:** You must call `GpTomManager.init()` as the **first** method before using anything else.

---

## Features

- `isInstalled()`
- `register()`
- `transaction()` (sale / storno / closeBatch)
- `getState()`
- `getDetail()`
- Event streams for results (sale/cancel/closeBatch/state/detail)

---

## Installation

Add dependency:

```yaml
dependencies:
  gptom:
    git:
      url: git@github.com:AppsDevTeam/flutter-gptom.git
      ref: v1.1.0
```

After cloning, enable git hooks:

```bash
git config core.hooksPath scripts/hooks
```

---

## Usage

### 1) Init (required)

✅ Always call init first, otherwise you will get `notInitialized`.

```dart
await GpTomManager.init(
  GpTomInitOptions(
    isDevelopment: true, // DEV / PROD
    debugLogs: true,
    iosRedirectUrl: "myapp://gptom", // iOS only (required on iOS)
  ),
);
```

---

### 2) Listen to results (recommended)

```dart
GpTomManager.saleResults.listen((r) {
  print("EVENT SALE: $r");
});

GpTomManager.cancelResults.listen((r) {
  print("EVENT CANCEL: $r");
});

GpTomManager.closeBatchResults.listen((r) {
  print("EVENT CLOSE_BATCH: $r");
});

GpTomManager.stateResults.listen((r) {
  print("EVENT STATE: $r");
});

GpTomManager.detailResults.listen((r) {
  print("EVENT DETAIL: $r");
});
```

---

### 3) Check if GP tom is installed

```dart
final res = await GpTomManager.isInstalled();
print(res);
```

---

### 4) Register transaction

GP tom requires a `transactionId` for each transaction, so you typically call register first:

```dart
final reg = await GpTomManager.register(
  GpTomRegisterRequest(
    originReferenceNum: "flutter_ref_1",
    clientId: "optional-client-id",
  ),
);

final txId = reg.data?.transactionId;
print("transactionId=$txId");
```

---

### 5) Sale example

```dart
final res = await GpTomManager.transaction(
  GpTomTransactionRequest.sale(
    transactionId: txId!,
    amount: 100, // minor units
    originReferenceNum: "flutter_ref_1",
  ),
);

print(res);
```

---

### 6) Storno example

```dart
final res = await GpTomManager.storno(
  GpTomTransactionRequest.storno(
    transactionId: txId!,
    cancelMode: GpTomCancelMode.olderTransaction,
    originTransactionId: "transactionIdToCancel",
  ),
);

print(res);
```

---

### 7) Close batch example

```dart
final res = await GpTomManager.closeBatch();
print(res);
```

---

## iOS Setup

### 1) Allow checking `isInstalled()` (required)

To allow the plugin to detect if **GP tom** app is installed using `canOpenURL`, add `gptom` into `LSApplicationQueriesSchemes` in your app’s `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>gptom</string>
</array>
```

> Without this, `canOpenURL("gptom://")` will always return `false`.

---

### 2) Add redirect URL scheme (required)

GP tom returns back to your app using deeplinks, so you must register your app scheme in `Info.plist`.

Example for scheme `myapp`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

Then provide it to init:

```dart
await GpTomManager.init(
  GpTomInitOptions(
    iosRedirectUrl: "myapp://gptom",
  ),
);
```

---

## Android Setup

Android uses **App2App (AIDL)** integration.

No special manifest setup is required besides having GP tom installed.

**Current bundled AAR version:** `1.28.0`

---

## Notes

- `transactionId` is required by GP tom for each transaction.
- For `storno` you typically need `originTransactionId` (the original transaction to cancel).
- Results are delivered through event streams.

---

## Third-party notices

This plugin bundles **GP tom iOS SDK** (MIT License).
Source: https://github.com/GP-tom/tom-ios-sdk
Bundled commit: [`36abfca`](https://github.com/GP-tom/tom-ios-sdk/commit/36abfca434cb97901ebd46983ac13f64e689e711) (2026-02-23)
See `THIRD_PARTY_NOTICES.md` for details.
