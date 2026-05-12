# gptom

Flutter plugin for **GP tom** payments (**Android App2App** + **iOS Deeplinks**).

> **Important:** You must call `GpTomManager.init()` as the **first** method before using anything else.

---

## Features

- `isInstalled()`
- `register()`
- `transaction()` (sale / storno / refund / closeBatch)
- `closeBatch()` / `closeBatchLegacy()`
- `getState()`
- `getDetail()`
- `cancelPolling()` (Android only — stops waiting on a state poll)
- Event streams for results (sale / refund / cancel / closeBatch / state / detail)

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## Installation

Add dependency to your `pubspec.yaml`:

```yaml
dependencies:
  gptom:
    git:
      url: https://github.com/AppsDevTeam/flutter-gptom.git
      ref: v1.3.0
```

Then run:

```bash
flutter pub get
```

> Pin to a specific tag (`ref: v1.3.0`) to avoid breakage when new versions land on `main`.

### Contributors only

After cloning this repo, enable git hooks:

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
    iosRedirectScheme: "myapp://gptom", // iOS only (required on iOS)
  ),
);
```

---

### 2) Listen to results (recommended)

```dart
GpTomManager.saleResults.listen((r) {
  print("EVENT SALE: $r");
});

GpTomManager.refundResults.listen((r) {
  print("EVENT REFUND: $r");
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

### 7) Refund example

Refund is a standalone return of funds (not linked to an original transaction).

```dart
final res = await GpTomManager.refund(
  GpTomTransactionRequest.refund(
    transactionId: txId!,
    amount: 100, // minor units
    originReferenceNum: "flutter_ref_1",
  ),
);

print(res);
```

---

### 8) Close batch example

```dart
final res = await GpTomManager.closeBatch();
print(res);
```

On Android `closeBatch()` resolves the result via state polling + `transactionInquire`,
which returns minimal data (no batch totals like `saleAmount`, `voidAmount`, ...).
On iOS it opens the `batch/close` deeplink and reads the full `Batch` from the response.

#### Legacy (full batch totals on Android)

If you need full batch totals on Android (saleAmount, totalAmount, voidAmount, ...),
use the legacy V2 callback flow:

```dart
final res = await GpTomManager.closeBatchLegacy();
print(res);
```

- Android: bypasses state polling and reads `TransactionResultV2Entity` directly via `BatchMapper`.
- iOS: identical to `closeBatch()` (deeplink flow).

Both methods deliver the result via the `closeBatchResults` stream.

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
    iosRedirectScheme: "myapp://gptom",
  ),
);
```

---

## Android Setup

Android uses **App2App (AIDL)** integration.

No special manifest setup is required besides having GP tom installed.

**Current bundled AAR version:** `1.28.0`

### State polling

Android resolves transaction results via periodic state polling (every 500 ms, 5 min timeout). When `state == COMPLETED`, the plugin calls `transactionInquire` to fetch the full result. You can stop the wait early:

```dart
await GpTomManager.cancelPolling(transactionId);
```

The matching result stream receives a `cancelled` event. iOS returns `unsupportedOnPlatform` (no polling there).

---

## Result codes

Each `GpTomResult` returns two kinds of codes:

### 1) Plugin code — `GpTomResultCode` (`result.code`)

Tells you whether the plugin call itself succeeded or how it failed.

| Code | Meaning |
|---|---|
| `ok` | Call succeeded; `result.data` is populated |
| `cancelled` | User cancelled the operation (PIN cancel, polling cancel, deeplink cancel) |
| `timeout` | Operation timed out (Android polling > 5 min) |
| `failed` | Generic failure (declined, refused, ...) |
| `internalError` | Unexpected error (parse error, native crash, ...) |
| `notInitialized` | `GpTomManager.init()` wasn't called |
| `notInstalled` | GP tom app is not installed |
| `unsupportedOnPlatform` | Feature not available on this OS (e.g. `cancelPolling` on iOS) |
| `invalidArgument` | Missing or malformed request parameter |
| `invalidDeeplink` | iOS deeplink could not be parsed |
| `invalidClientId` | `clientId` rejected by GP tom |
| `invalidCredentials` | User logged out, wrong password, expired session |
| `invalidCode` | Auth code invalid or expired |
| `invalidUserName` | Wrong username |
| `invalidAmount` | Amount out of range |
| `passwordChangeRequired` | Password change required before continuing |
| `passwordPendingConfirmation` | Password change is pending confirmation |
| `merchantInfoMissing` | Merchant configuration missing |
| `tidNotAssignedToThisUser` | TID not assigned / not active / not selected |
| `tidAlreadyOccupied` | TID already reserved by another user/device |
| `anotherTidUsedOnThisDevice` | Different TID is already in use on this device |
| `terminalSetupFailed` | Terminal setup failed |
| `cannotBeVoided` | Transaction already cancelled / completed and not voidable |
| `unsupportedTransactionOperationOrType` | Operation/type not allowed for this merchant |
| `networkError` | Network unavailable / HTTP error |
| `failedTapToPay` | SoftPOS / tap-to-pay error |
| `failedToCloseBatch` | Batch close was declined |
| `serviceBindFailed` | Could not bind to GP tom AIDL service (Android) |

### 2) ECR transaction code — `GpTomEcrResultCode` (`result.data.ecrResultCode`)

For transactions (`saleResults`, `refundResults`, `cancelResults`), the ECR code carries the transaction outcome:

| Code | Name | Meaning |
|---|---|---|
| `0` | `ecrSuccess` | Transaction was successful |
| `-1` | `ecrFailed` | Transaction failed |
| `-2` | `ecrTransactionIdInvalid` | Invalid transaction ID |
| `-3` | `ecrTransactionNotFound` | Transaction not found (you can retry) |
| `-4` | `ecrTransactionDecline` | Transaction declined |
| `-5` | `ecrTransactionAlreadyVoided` | Transaction was already cancelled |
| `-6` | `ecrParameterInvalid` | Invalid parameters |
| `-7` | `ecrUnauthorized` | User not authorized |
| `-8` | `ecrNotAllowed` | Operation not allowed |
| `-9` | `ecrWrongStatus` | Input from user needed in GP tom app |

See [GP tom result codes](https://www.gptom.com/docs/api/app2app/result-codes/) for full reference.

### Recommended handling

```dart
if (result.code != GpTomResultCode.ok) {
  // plugin / communication error
  showError(result.message);
} else if (result.data?.ecrResultCode != GpTomEcrResultCode.ecrSuccess) {
  // transaction was processed but not approved
  showDeclined(result.data?.responseMessage);
} else {
  // success
  showSuccess(result.data!);
}
```

---

## Notes

- `transactionId` is required by GP tom for each transaction.
- For `storno` you typically need `originTransactionId` (the original transaction to cancel).
- Results are delivered through event streams.

---

## Third-party notices

This plugin bundles **GP tom iOS SDK** (MIT License).
Source: https://github.com/GP-tom/tom-ios-sdk
Bundled commit: [`7f6e963`](https://github.com/GP-tom/tom-ios-sdk/commit/7f6e963bfbb3be35e3617802950b906ff760e011) (2026-04-28)
See `THIRD_PARTY_NOTICES.md` for details.
