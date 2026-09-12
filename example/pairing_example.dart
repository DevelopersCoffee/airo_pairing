// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:airo_pairing/airo_pairing.dart';

void main() async {
  print('=== Airo Pairing v1.2.0 Ecosystem Orchestrator Example ===\n');

  final now = DateTime.utc(2026, 9, 12, 12, 0, 0);

  // 1. Initialize bi-directional transport pair and in-memory storage adapters
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

  // 2. Listen to reactive stream events
  serverEngine.onChallengeReceived.listen((challenge) {
    print(
      '📡 [Server Engine] Received Pairing Challenge: ${challenge.challengeId}',
    );
  });

  clientEngine.onPairingSuccess.listen((record) {
    print(
      '✅ [Client Engine] Pairing Success Event! Connected to ${record.receiverDeviceId}',
    );
  });

  serverEngine.onTicketRedeemed.listen((decision) {
    print(
      '🎬 [Server Engine] Ticket Redeemed Event! Ticket ID: ${decision.ticket?.ticketId}',
    );
  });

  // 3. Client initiates pairing challenge over transport channel
  final challenge = AiroPairingChallenge(
    challengeId: 'ch-v1.2.0-001',
    receiverDeviceId: 'airo-tv-livingroom',
    receiverRole: AiroDeviceRole.tvReceiver,
    requestedScopes: {
      AiroPairingScope.playbackControl,
      AiroPairingScope.playbackTicketIssue,
      AiroPairingScope.diagnostics,
    },
    issuedAt: now,
    expiresAt: now.add(const Duration(minutes: 5)),
  );

  print('1. Client Engine sending challenge over transport...');
  await clientEngine.sendChallenge(challenge);
  await Future<void>.delayed(const Duration(milliseconds: 50));

  // 4. Server approves challenge and registers relationship record
  final rawPublicKey = utf8.encode('controller-public-key-bytes');
  final fingerprint = AiroCryptoUtils.computePublicKeyFingerprint(rawPublicKey);

  final keyDescriptor = AiroTrustedDeviceKeyDescriptor(
    keyId: 'key-ctrl-v12',
    algorithm: AiroTrustedDeviceKeyAlgorithm.ed25519,
    publicKeyFingerprint: fingerprint,
    createdAt: now,
    notBefore: now,
    expiresAt: now.add(const Duration(days: 90)),
  );

  final relationship = AiroTrustedDeviceRecord(
    relationshipId: 'rel-ctrl-tv-v12',
    controllerDeviceId: 'mobile-controller-alex',
    receiverDeviceId: challenge.receiverDeviceId,
    controllerRole: AiroDeviceRole.mobileController,
    receiverRole: AiroDeviceRole.tvReceiver,
    scopes: challenge.requestedScopes,
    createdAt: now,
    trustLevel: AiroTrustedDeviceTrustLevel.trusted,
    keyDescriptor: keyDescriptor,
    pairingChallengeId: challenge.challengeId,
  );

  print('\n2. Server Engine approving challenge & saving to storage...');
  await serverEngine.approveChallenge(challenge, relationship);
  await Future<void>.delayed(const Duration(milliseconds: 50));

  // 5. Client requests playback ticket & signs container
  final issueRequest = AiroPlaybackTicketIssueRequest(
    requestId: 'req-ticket-v12',
    ticketId: 'ticket-play-v12',
    receiverDeviceId: challenge.receiverDeviceId,
    sessionId: 'session-stream-v12',
    sourceHandle: AiroPlaybackSourceHandle.redacted(
      'encrypted-asset-token-v12',
    ),
    scopes: {AiroPairingScope.playbackControl},
    issuerDeviceId: relationship.controllerDeviceId,
    issuedAt: now,
    notBefore: now,
    expiresAt: now.add(const Duration(minutes: 3)),
  );

  final issueDecision = await clientEngine.requestTicket(
    issueRequest,
    relationship,
    now: now,
  );
  print('\n3. Ticket Issued via Engine: ID ${issueDecision.ticket?.ticketId}');

  final secretKeyBytes = utf8.encode('shared-session-secret-key-32bytes');
  final signedPayload = AiroSignedPayload.createHmac(
    payload: jsonEncode(issueDecision.ticket!.toJson()),
    keyId: keyDescriptor.keyId,
    secretKeyBytes: secretKeyBytes,
    timestamp: now,
  );

  print('4. Signed Ticket Payload Container:');
  print('   Signature Valid: ${signedPayload.verifyHmac(secretKeyBytes)}');

  // 6. TV Receiver redeems playback ticket via Engine
  final redeemRequest = AiroPlaybackTicketRedeemRequest(
    requestId: 'req-redeem-v12',
    ticketId: issueDecision.ticket!.ticketId,
    receiverDeviceId: challenge.receiverDeviceId,
    sessionId: 'session-stream-v12',
    requiredScope: AiroPairingScope.playbackControl,
    redeemedAt: now.add(const Duration(seconds: 10)),
  );

  print('\n5. TV Receiver redeeming ticket via Engine...');
  await clientEngine.redeemTicket(redeemRequest);
  await Future<void>.delayed(const Duration(milliseconds: 50));

  // Clean up
  await clientEngine.close();
  await serverEngine.close();
  await clientStorage.close();
  await serverStorage.close();

  print('\n=== Orchestration Workflow Complete ===');
}
