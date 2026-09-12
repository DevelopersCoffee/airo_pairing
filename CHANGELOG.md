# Changelog

## 1.1.0

- Refactor `airo_pairing` architecture into modular domain files (`enums.dart`, `pairing_challenge.dart`, `trusted_device.dart`, `key_descriptor.dart`, `playback_ticket.dart`, `playback_ticket_service.dart`, `restricted_receiver_policy.dart`, `crypto_helpers.dart`).
- Add complete structured `.toJson()` and `.fromJson()` serialization support across all models and enums.
- Add cryptographic helpers (`AiroCryptoUtils.computePublicKeyFingerprint`, `AiroSignedPayload` envelope signature verification).
- Add end-to-end executable sample (`example/pairing_example.dart`) demonstrating pairing, ticket issuance, signing, and redemption.
- Add comprehensive JSON round-trip and crypto helper unit test suites.

## 1.0.0

- Initial open-source stable release.
- Trusted device pairing, secret ticket verification, and cross-device handoff contracts.

## 0.0.1

- Add initial pairing, trusted-device, and playback-ticket contracts.
