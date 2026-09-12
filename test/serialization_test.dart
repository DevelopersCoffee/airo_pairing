import 'package:airo_pairing/airo_pairing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JSON Serialization Round-Trip Tests', () {
    test('AiroPairingChallenge serializes and deserializes cleanly', () {
      final now = DateTime.utc(2026, 9, 12, 12, 0, 0);
      final challenge = AiroPairingChallenge(
        challengeId: 'ch-100',
        receiverDeviceId: 'tv-001',
        receiverRole: AiroDeviceRole.tvReceiver,
        requestedScopes: {
          AiroPairingScope.playbackControl,
          AiroPairingScope.diagnostics,
        },
        issuedAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
        status: AiroPairingChallengeStatus.pending,
      );

      final json = challenge.toJson();
      final recovered = AiroPairingChallenge.fromJson(json);

      expect(recovered, equals(challenge));
      expect(recovered.status, equals(AiroPairingChallengeStatus.pending));
    });

    test(
      'AiroTrustedDeviceKeyDescriptor serializes and deserializes cleanly',
      () {
        final now = DateTime.utc(2026, 9, 12, 12, 0, 0);
        final key = AiroTrustedDeviceKeyDescriptor(
          keyId: 'key-ed25519-1',
          algorithm: AiroTrustedDeviceKeyAlgorithm.ed25519,
          publicKeyFingerprint: 'a1b2c3d4e5f67890',
          createdAt: now,
          notBefore: now,
          expiresAt: now.add(const Duration(days: 30)),
        );

        final json = key.toJson();
        final recovered = AiroTrustedDeviceKeyDescriptor.fromJson(json);

        expect(recovered, equals(key));
      },
    );

    test('AiroTrustedDeviceRecord serializes and deserializes cleanly', () {
      final now = DateTime.utc(2026, 9, 12, 12, 0, 0);
      final key = AiroTrustedDeviceKeyDescriptor(
        keyId: 'key-1',
        algorithm: AiroTrustedDeviceKeyAlgorithm.ed25519,
        publicKeyFingerprint: 'fp-1234',
        createdAt: now,
        notBefore: now,
        expiresAt: now.add(const Duration(days: 90)),
      );
      final record = AiroTrustedDeviceRecord(
        relationshipId: 'rel-1',
        controllerDeviceId: 'mobile-1',
        receiverDeviceId: 'tv-1',
        controllerRole: AiroDeviceRole.mobileController,
        receiverRole: AiroDeviceRole.tvReceiver,
        scopes: {AiroPairingScope.playbackControl},
        createdAt: now,
        trustLevel: AiroTrustedDeviceTrustLevel.trusted,
        keyDescriptor: key,
      );

      final json = record.toJson();
      final recovered = AiroTrustedDeviceRecord.fromJson(json);

      expect(recovered, equals(record));
    });

    test('AiroPlaybackTicket serializes and deserializes cleanly', () {
      final now = DateTime.utc(2026, 9, 12, 12, 0, 0);
      final ticket = AiroPlaybackTicket(
        ticketId: 't-123',
        receiverDeviceId: 'tv-1',
        sessionId: 'sess-abc',
        sourceHandle: AiroPlaybackSourceHandle.redacted(
          'opaque-asset-handle-99',
        ),
        scopes: {AiroPairingScope.playbackControl},
        issuedAt: now,
        notBefore: now,
        expiresAt: now.add(const Duration(minutes: 2)),
      );

      final json = ticket.toJson();
      final recovered = AiroPlaybackTicket.fromJson(json);

      expect(recovered, equals(ticket));
    });

    test('AiroPlaybackTicketIssueRequest & RedeemRequest round-trip', () {
      final now = DateTime.utc(2026, 9, 12, 12, 0, 0);
      final issueRequest = AiroPlaybackTicketIssueRequest(
        requestId: 'req-1',
        ticketId: 't-100',
        receiverDeviceId: 'tv-1',
        sessionId: 'sess-1',
        sourceHandle: AiroPlaybackSourceHandle.redacted('token-source-7'),
        scopes: {AiroPairingScope.playbackControl},
        issuerDeviceId: 'mobile-1',
        issuedAt: now,
        notBefore: now,
        expiresAt: now.add(const Duration(minutes: 3)),
      );

      final issueJson = issueRequest.toJson();
      final recoveredIssue = AiroPlaybackTicketIssueRequest.fromJson(issueJson);
      expect(recoveredIssue, equals(issueRequest));

      final redeemRequest = AiroPlaybackTicketRedeemRequest(
        requestId: 'red-1',
        ticketId: 't-100',
        receiverDeviceId: 'tv-1',
        sessionId: 'sess-1',
        requiredScope: AiroPairingScope.playbackControl,
        redeemedAt: now,
      );

      final redeemJson = redeemRequest.toJson();
      final recoveredRedeem = AiroPlaybackTicketRedeemRequest.fromJson(
        redeemJson,
      );
      expect(recoveredRedeem, equals(redeemRequest));
    });

    test('Enums deserialize correctly from stableId strings', () {
      for (final role in AiroDeviceRole.values) {
        expect(AiroDeviceRole.fromStableId(role.stableId), equals(role));
      }
      for (final scope in AiroPairingScope.values) {
        expect(AiroPairingScope.fromStableId(scope.stableId), equals(scope));
      }
      for (final algo in AiroTrustedDeviceKeyAlgorithm.values) {
        expect(
          AiroTrustedDeviceKeyAlgorithm.fromStableId(algo.stableId),
          equals(algo),
        );
      }
    });
  });
}
