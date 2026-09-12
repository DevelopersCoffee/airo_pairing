import 'package:airo_pairing/airo_pairing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiroPairingEngine End-to-End Orchestration Tests', () {
    test(
      'Client and Server engines execute pairing handshake over transport pair',
      () async {
        final (clientTransport, serverTransport) =
            AiroInMemoryTransportLayer.createPair();
        final clientStorage = AiroInMemoryStorageAdapter();
        final serverStorage = AiroInMemoryStorageAdapter();

        final clientEngine = AiroPairingEngine(
          transport: clientTransport,
          storage: clientStorage,
        );
        final serverEngine = AiroPairingEngine(
          transport: serverTransport,
          storage: serverStorage,
        );

        final now = DateTime.utc(2026, 9, 12, 12, 0, 0);

        final serverChallenges = <AiroPairingChallenge>[];
        serverEngine.onChallengeReceived.listen(serverChallenges.add);

        final clientPairingSuccesses = <AiroTrustedDeviceRecord>[];
        clientEngine.onPairingSuccess.listen(clientPairingSuccesses.add);

        // 1. Client sends challenge
        final challenge = AiroPairingChallenge(
          challengeId: 'ch-500',
          receiverDeviceId: 'tv-livingroom',
          receiverRole: AiroDeviceRole.tvReceiver,
          requestedScopes: {AiroPairingScope.playbackControl},
          issuedAt: now,
          expiresAt: now.add(const Duration(minutes: 5)),
        );

        await clientEngine.sendChallenge(challenge);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(serverChallenges.length, equals(1));
        expect(serverChallenges.first.challengeId, equals('ch-500'));

        // 2. Server approves challenge and creates trusted device record
        final relationship = AiroTrustedDeviceRecord(
          relationshipId: 'rel-500',
          controllerDeviceId: 'mobile-controller-1',
          receiverDeviceId: 'tv-livingroom',
          controllerRole: AiroDeviceRole.mobileController,
          receiverRole: AiroDeviceRole.tvReceiver,
          scopes: challenge.requestedScopes,
          createdAt: now,
          trustLevel: AiroTrustedDeviceTrustLevel.trusted,
        );

        await serverEngine.approveChallenge(
          serverChallenges.first,
          relationship,
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(clientPairingSuccesses.length, equals(1));
        expect(clientPairingSuccesses.first.relationshipId, equals('rel-500'));

        final storedClientRecord = await clientStorage.getDeviceRecord(
          'tv-livingroom',
        );
        expect(storedClientRecord, equals(relationship));

        final storedServerRecord = await serverStorage.getDeviceRecord(
          'tv-livingroom',
        );
        expect(storedServerRecord, equals(relationship));

        await clientEngine.close();
        await serverEngine.close();
      },
    );

    test(
      'Playback ticket issuance & redemption via AiroPairingEngine',
      () async {
        final (clientTransport, serverTransport) =
            AiroInMemoryTransportLayer.createPair();
        final clientStorage = AiroInMemoryStorageAdapter();
        final serverStorage = AiroInMemoryStorageAdapter();

        final clientEngine = AiroPairingEngine(
          transport: clientTransport,
          storage: clientStorage,
        );
        final serverEngine = AiroPairingEngine(
          transport: serverTransport,
          storage: serverStorage,
        );

        final now = DateTime.utc(2026, 9, 12, 12, 0, 0);

        final relationship = AiroTrustedDeviceRecord(
          relationshipId: 'rel-ticket-1',
          controllerDeviceId: 'mobile-1',
          receiverDeviceId: 'tv-1',
          controllerRole: AiroDeviceRole.mobileController,
          receiverRole: AiroDeviceRole.tvReceiver,
          scopes: {
            AiroPairingScope.playbackControl,
            AiroPairingScope.playbackTicketIssue,
          },
          createdAt: now,
          trustLevel: AiroTrustedDeviceTrustLevel.trusted,
          keyDescriptor: AiroTrustedDeviceKeyDescriptor(
            keyId: 'key-1',
            algorithm: AiroTrustedDeviceKeyAlgorithm.ed25519,
            publicKeyFingerprint: 'fp-123',
            createdAt: now,
            notBefore: now,
            expiresAt: now.add(const Duration(days: 30)),
          ),
        );

        final issueRequest = AiroPlaybackTicketIssueRequest(
          requestId: 'req-1',
          ticketId: 't-1',
          receiverDeviceId: 'tv-1',
          sessionId: 'sess-1',
          sourceHandle: AiroPlaybackSourceHandle.redacted('source-token-9'),
          scopes: {AiroPairingScope.playbackControl},
          issuerDeviceId: 'mobile-1',
          issuedAt: now,
          notBefore: now,
          expiresAt: now.add(const Duration(minutes: 3)),
        );

        final decision = await clientEngine.requestTicket(
          issueRequest,
          relationship,
          now: now,
        );
        expect(decision.accepted, isTrue);

        final serverRedeems = <AiroPlaybackTicketServiceDecision>[];
        serverEngine.onTicketRedeemed.listen(serverRedeems.add);

        final redeemRequest = AiroPlaybackTicketRedeemRequest(
          requestId: 'red-1',
          ticketId: decision.ticket!.ticketId,
          receiverDeviceId: 'tv-1',
          sessionId: 'sess-1',
          requiredScope: AiroPairingScope.playbackControl,
          redeemedAt: now,
        );

        final redeemDecision = await clientEngine.redeemTicket(redeemRequest);
        expect(redeemDecision.accepted, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(serverRedeems.length, equals(1));
        expect(serverRedeems.first.accepted, isTrue);

        await clientEngine.close();
        await serverEngine.close();
      },
    );
  });
}
