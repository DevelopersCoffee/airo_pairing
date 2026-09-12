# `airo_pairing`

[![pub package](https://img.shields.io/pub/v/airo_pairing.svg)](https://pub.dev/packages/airo_pairing)
[![CI](https://github.com/DevelopersCoffee/airo_pairing/actions/workflows/ci.yml/badge.svg)](https://github.com/DevelopersCoffee/airo_pairing/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Trusted device pairing, secret playback ticket verification, cryptographic envelope signing, and cross-device session handoff contracts for Flutter applications.

---

## Features

- **Device Pairing Handshake**: Pure-logic challenge and trusted device relationship models (`AiroPairingChallenge`, `AiroTrustedDeviceRecord`).
- **Cryptographic Helpers**: Public key SHA-256 fingerprint generation & HMAC-SHA256 payload envelope signing/verification (`AiroCryptoUtils`, `AiroSignedPayload`).
- **Structured JSON Wire Serialization**: Full `.toJson()` & `.fromJson()` serialization across all enums and models with `schemaVersion` support.
- **Short-Lived Playback Tickets**: Issuance, timing checks, and single-use redemption policies for secondary screens (TV, Web, Tablet).
- **Restricted Receiver Enforcement**: Fine-grained access control policy evaluation (`AiroRestrictedReceiverTrustPolicy`).

---

## Installation

```yaml
dependencies:
  airo_pairing: ^1.0.0
```

---

## Quick Example

```dart
import 'dart:convert';
import 'package:airo_pairing/airo_pairing.dart';

void main() async {
  final now = DateTime.utc(2026, 9, 12, 12, 0, 0);

  // 1. Create a pairing challenge
  final challenge = AiroPairingChallenge(
    challengeId: 'ch-9001',
    receiverDeviceId: 'airo-tv-livingroom-01',
    receiverRole: AiroDeviceRole.tvReceiver,
    requestedScopes: {AiroPairingScope.playbackControl},
    issuedAt: now,
    expiresAt: now.add(const Duration(minutes: 5)),
  );

  // 2. Compute key fingerprint and build trusted relationship
  final rawPublicKey = utf8.encode('controller-public-key-bytes');
  final fingerprint = AiroCryptoUtils.computePublicKeyFingerprint(rawPublicKey);

  final keyDescriptor = AiroTrustedDeviceKeyDescriptor(
    keyId: 'key-ctrl-01',
    algorithm: AiroTrustedDeviceKeyAlgorithm.ed25519,
    publicKeyFingerprint: fingerprint,
    createdAt: now,
    notBefore: now,
    expiresAt: now.add(const Duration(days: 90)),
  );

  final relationship = AiroTrustedDeviceRecord(
    relationshipId: 'rel-ctrl-tv-01',
    controllerDeviceId: 'mobile-controller-alex',
    receiverDeviceId: challenge.receiverDeviceId,
    controllerRole: AiroDeviceRole.mobileController,
    receiverRole: AiroDeviceRole.tvReceiver,
    scopes: challenge.requestedScopes,
    createdAt: now,
    keyDescriptor: keyDescriptor,
  );

  // 3. Issue and sign a playback ticket
  final ticketService = AiroFakePlaybackTicketService();
  final issueRequest = AiroPlaybackTicketIssueRequest(
    requestId: 'req-01',
    ticketId: 'ticket-01',
    receiverDeviceId: challenge.receiverDeviceId,
    sessionId: 'session-99',
    sourceHandle: AiroPlaybackSourceHandle.redacted('opaque-asset-token'),
    scopes: {AiroPairingScope.playbackControl},
    issuerDeviceId: relationship.controllerDeviceId,
    issuedAt: now,
    notBefore: now,
    expiresAt: now.add(const Duration(minutes: 3)),
  );

  final decision = await ticketService.issue(request: issueRequest, issuer: relationship, now: now);
  print('Ticket Issued: ${decision.accepted}');

  // 4. Sign payload container
  final secret = utf8.encode('shared-session-secret-key-32bytes');
  final signedContainer = AiroSignedPayload.createHmac(
    payload: jsonEncode(decision.ticket!.toJson()),
    keyId: keyDescriptor.keyId,
    secretKeyBytes: secret,
    timestamp: now,
  );
  print('Signature Valid: ${signedContainer.verifyHmac(secret)}');
}
```

Run the complete executable sample with:
```bash
dart run example/pairing_example.dart
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.
