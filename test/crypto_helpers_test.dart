import 'dart:convert';
import 'package:airo_pairing/airo_pairing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cryptographic Helpers & Signed Payload Tests', () {
    test(
      'computePublicKeyFingerprint returns a deterministic SHA-256 hex string',
      () {
        final rawPublicKey = utf8.encode('ed25519-public-key-sample-bytes');
        final fingerprint = AiroCryptoUtils.computePublicKeyFingerprint(
          rawPublicKey,
        );

        expect(fingerprint.length, equals(64)); // 32-byte hex digest
        expect(
          fingerprint,
          equals(AiroCryptoUtils.computePublicKeyFingerprint(rawPublicKey)),
        );
      },
    );

    test('AiroSignedPayload creates, verifies, and round-trips via JSON', () {
      final secretKey = utf8.encode('secret-shared-key-32-bytes-long!');
      final now = DateTime.utc(2026, 9, 12, 12, 0, 0);
      const payloadString = '{"action":"pair","controllerId":"mobile-1"}';

      final signed = AiroSignedPayload.createHmac(
        payload: payloadString,
        keyId: 'key-123',
        secretKeyBytes: secretKey,
        timestamp: now,
      );

      // Verify correct key
      expect(signed.verifyHmac(secretKey), isTrue);

      // Verify wrong key fails
      final wrongSecret = utf8.encode('wrong-key-32-bytes-long!');
      expect(signed.verifyHmac(wrongSecret), isFalse);

      // Verify JSON round-trip
      final json = signed.toJson();
      final recovered = AiroSignedPayload.fromJson(json);
      expect(recovered, equals(signed));
      expect(recovered.verifyHmac(secretKey), isTrue);
    });
  });
}
