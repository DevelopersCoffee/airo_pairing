// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:airo_pairing/airo_pairing.dart';

void main() async {
  print('=== Airo Pairing End-to-End Workflow ===\n');

  final now = DateTime.utc(2026, 9, 12, 12, 0, 0);

  // 1. Controller creates pairing challenge to pair with TV Receiver
  final challenge = AiroPairingChallenge(
    challengeId: 'ch-9001',
    receiverDeviceId: 'airo-tv-livingroom-01',
    receiverRole: AiroDeviceRole.tvReceiver,
    requestedScopes: {
      AiroPairingScope.playbackControl,
      AiroPairingScope.playbackTicketIssue,
      AiroPairingScope.diagnostics,
    },
    issuedAt: now,
    expiresAt: now.add(const Duration(minutes: 5)),
  );

  print('1. Pairing Challenge Issued:');
  print('   Challenge ID: ${challenge.challengeId}');
  print('   Receiver: ${challenge.receiverDeviceId}');
  print('   Can Approve: ${challenge.canApproveAt(now)}\n');

  // 2. Compute key fingerprint and build trusted relationship record
  final rawPublicKey = utf8.encode('controller-ed25519-public-key-bytes');
  final keyFingerprint = AiroCryptoUtils.computePublicKeyFingerprint(
    rawPublicKey,
  );

  final keyDescriptor = AiroTrustedDeviceKeyDescriptor(
    keyId: 'key-ctrl-01',
    algorithm: AiroTrustedDeviceKeyAlgorithm.ed25519,
    publicKeyFingerprint: keyFingerprint,
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
    trustLevel: AiroTrustedDeviceTrustLevel.trusted,
    keyDescriptor: keyDescriptor,
    pairingChallengeId: challenge.challengeId,
  );

  print('2. Trusted Device Relationship Established:');
  print('   Relationship ID: ${relationship.relationshipId}');
  print('   Key Fingerprint: ${keyDescriptor.publicKeyFingerprint}');
  print('   Trust Level: ${relationship.trustLevel.name}\n');

  // 3. Controller requests a playback ticket for an asset
  final ticketService = AiroFakePlaybackTicketService();
  final sourceHandle = AiroPlaybackSourceHandle.redacted(
    'encrypted-asset-token-7734',
  );

  final issueRequest = AiroPlaybackTicketIssueRequest(
    requestId: 'req-ticket-01',
    ticketId: 'ticket-play-01',
    receiverDeviceId: challenge.receiverDeviceId,
    sessionId: 'session-stream-99',
    sourceHandle: sourceHandle,
    scopes: {AiroPairingScope.playbackControl},
    issuerDeviceId: relationship.controllerDeviceId,
    issuedAt: now,
    notBefore: now,
    expiresAt: now.add(const Duration(minutes: 3)),
  );

  final issueDecision = await ticketService.issue(
    request: issueRequest,
    issuer: relationship,
    now: now,
  );

  print('3. Playback Ticket Issuance:');
  print('   Issued Accepted: ${issueDecision.accepted}');
  print('   Ticket ID: ${issueDecision.ticket?.ticketId}\n');

  // 4. Sign ticket payload using HMAC
  final secretKeyBytes = utf8.encode('shared-session-secret-key-32bytes');
  final signedPayload = AiroSignedPayload.createHmac(
    payload: jsonEncode(issueDecision.ticket!.toJson()),
    keyId: keyDescriptor.keyId,
    secretKeyBytes: secretKeyBytes,
    timestamp: now,
  );

  print('4. Ticket Payload Signed & Transmitted:');
  print('   Signature Base64: ${signedPayload.signatureBase64}');
  print('   Signature Valid: ${signedPayload.verifyHmac(secretKeyBytes)}\n');

  // 5. TV Receiver redeems the playback ticket
  final redeemRequest = AiroPlaybackTicketRedeemRequest(
    requestId: 'req-redeem-01',
    ticketId: issueDecision.ticket!.ticketId,
    receiverDeviceId: challenge.receiverDeviceId,
    sessionId: 'session-stream-99',
    requiredScope: AiroPairingScope.playbackControl,
    redeemedAt: now.add(const Duration(seconds: 10)),
  );

  final redeemDecision = await ticketService.redeem(request: redeemRequest);

  print('5. TV Receiver Redemption:');
  print('   Redeem Accepted: ${redeemDecision.accepted}');
  print(
    '   Redeem Codes: ${redeemDecision.codes.map((c) => c.stableId).join(', ')}\n',
  );

  print('=== Workflow Complete ===');
}
