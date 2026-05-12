# Changelog

## v1.2.3

- Mapped Android state ERROR error.code to specific ResultCodes with full state data passthrough
- Backfilled CHANGELOG, updated README with refund and cancelPolling, auto-update CHANGELOG in release script


## v1.2.2

- Propagate AAR register errors to Flutter with mapped error codes and full data

## v1.2.1

- Fixed iOS NSLog format string crash on URL-encoded chars, added tap-to-dismiss keyboard in example
- Set default false for tipCollect in GpTomTransactionRequest

## v1.2.0

- Added transactionId and toJson to GpTomResult, mapped CANCELLED status to cancelled code on iOS
- Added refund support, unified transactionType across platforms, updated iOS GPtomSDK
- Added Android state polling with cancellation, removed unused fields from GpTomTransactionResult
- Added unified card number masking based on EMV AID

## v1.1.0

- Added terminalId to GpTomBatchResult and Android BatchMapper
- Unified currencyCode to ISO 4217 alphabetic format (CZK instead of 203)

## v1.0.7

- Added debug logging to native callbacks on Android and iOS

## v1.0.6

- Fixed wrong JsonKeys in GpTomRegisterResult.fromJson for clientId and responseMessage
- Fixed inconsistent JsonKeys in GpTomBatchResult.toJson

## v1.0.5

- Added new result codes for iOS deeplink errors and sync across platforms

## v1.0.4

- Added GpTomEcrResultCode enum with ECR result codes

## v1.0.3

- AAR copy optimalization

## v1.0.2

- Android core-ktx downgrade
- Added git push to release script

## v1.0.1

- Added local maven repository for AAR resolution
- Release script and README update

## v1.0.0

- Initial release
