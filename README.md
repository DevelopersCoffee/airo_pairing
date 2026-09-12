# `airo_pairing`

[![pub package](https://img.shields.io/pub/v/airo_pairing.svg)](https://pub.dev/packages/airo_pairing)
[![CI](https://github.com/DevelopersCoffee/airo_pairing/actions/workflows/ci.yml/badge.svg)](https://github.com/DevelopersCoffee/airo_pairing/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Trusted device pairing, secret playback ticket verification, cryptographic envelope signing, pluggable network transport, storage adapters, and high-level pairing session orchestrator for Flutter applications.

---

## Features

- **Automated Handshake Orchestrator (`AiroPairingEngine`)**: Pure-logic & network-driven pairing engine managing challenges, verification, ticket issuance, and reactive state streams.
- **Pluggable Network Transport Interface (`AiroTransportLayer`)**: Abstract wire medium contract (`AiroNetworkMessage`) supporting WebSockets, BLE, WebRTC, or local Wi-Fi, with built-in `AiroInMemoryTransportLayer` for testing & local handoffs.
- **Pluggable Storage Adapter Interface (`AiroStorageAdapter`)**: Abstract device record storage contract supporting iOS Keychain, Android Keystore, Hive, Isar, or pure Dart backends, with built-in `AiroInMemoryStorageAdapter`.
- **Cryptographic Helpers (`AiroCryptoUtils`, `AiroSignedPayload`)**: Public key SHA-256 fingerprint generation & HMAC-SHA256 payload envelope signing/verification.
- **Structured JSON Wire Serialization**: Full `.toJson()` & `.fromJson()` serialization across all enums and models with `schemaVersion` support.
- **Short-Lived Playback Tickets**: Issuance, timing checks, and single-use redemption policies for secondary screens (TV, Web, Tablet).

---

## Installation

```yaml
dependencies:
  airo_pairing: ^1.2.0
```

---

## Quick Example: Ecosystem Pairing Engine

```dart
import 'dart:convert';
import 'package:airo_pairing/airo_pairing.dart';

void main() async {
  final now = DateTime.utc(2026, 9, 12, 12, 0, 0);

  // 1. Create bi-directional transport pair and in-memory storage adapters
  final (clientTransport, serverTransport) = AiroInMemoryTransportLayer.createPair();
  final clientStorage = AiroInMemoryStorageAdapter();
  final serverStorage = AiroInMemoryStorageAdapter();

  final clientEngine = AiroPairingEngine(transport: clientTransport, storage: clientStorage);
  final serverEngine = AiroPairingEngine(transport: serverTransport, storage: serverStorage);

  // 2. Listen to reactive pairing events
  serverEngine.onChallengeReceived.listen((challenge) {
    print('Received Challenge: ${challenge.challengeId}');
  });

  clientEngine.onPairingSuccess.listen((record) {
    print('Connected to ${record.receiverDeviceId}');
  });

  // 3. Client initiates pairing challenge over network transport
  final challenge = AiroPairingChallenge(
    challengeId: 'ch-v120-001',
    receiverDeviceId: 'airo-tv-livingroom',
    receiverRole: AiroDeviceRole.tvReceiver,
    requestedScopes: {AiroPairingScope.playbackControl},
    issuedAt: now,
    expiresAt: now.add(const Duration(minutes: 5)),
  );

  await clientEngine.sendChallenge(challenge);

  // 4. Server approves challenge & persists trusted relationship
  final relationship = AiroTrustedDeviceRecord(
    relationshipId: 'rel-ctrl-tv-01',
    controllerDeviceId: 'mobile-controller-alex',
    receiverDeviceId: challenge.receiverDeviceId,
    controllerRole: AiroDeviceRole.mobileController,
    receiverRole: AiroDeviceRole.tvReceiver,
    scopes: challenge.requestedScopes,
    createdAt: now,
    trustLevel: AiroTrustedDeviceTrustLevel.trusted,
  );

  await serverEngine.approveChallenge(challenge, relationship);
}
```

Run the executable example:
```bash
dart run example/pairing_example.dart
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.
