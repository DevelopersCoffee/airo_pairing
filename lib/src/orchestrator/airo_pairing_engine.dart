import 'dart:async';

import '../contracts/airo_storage_adapter.dart';
import '../contracts/airo_transport_layer.dart';
import '../enums.dart';
import '../pairing_challenge.dart';
import '../playback_ticket_service.dart';
import '../trusted_device.dart';

class AiroPairingEngine {
  AiroPairingEngine({
    required this.transport,
    required this.storage,
    AiroPlaybackTicketService? ticketService,
  }) : ticketService = ticketService ?? AiroFakePlaybackTicketService() {
    _subscription = transport.incomingMessages.listen(_processIncomingMessage);
  }

  final AiroTransportLayer transport;
  final AiroStorageAdapter storage;
  final AiroPlaybackTicketService ticketService;

  StreamSubscription<AiroNetworkMessage>? _subscription;

  final StreamController<AiroPairingChallenge> _challengeController =
      StreamController<AiroPairingChallenge>.broadcast();
  final StreamController<AiroTrustedDeviceRecord> _pairingSuccessController =
      StreamController<AiroTrustedDeviceRecord>.broadcast();
  final StreamController<AiroPlaybackTicketServiceDecision>
  _ticketRedeemedController =
      StreamController<AiroPlaybackTicketServiceDecision>.broadcast();

  Stream<AiroPairingChallenge> get onChallengeReceived =>
      _challengeController.stream;
  Stream<AiroTrustedDeviceRecord> get onPairingSuccess =>
      _pairingSuccessController.stream;
  Stream<AiroPlaybackTicketServiceDecision> get onTicketRedeemed =>
      _ticketRedeemedController.stream;

  Future<void> sendChallenge(AiroPairingChallenge challenge) async {
    final msg = AiroNetworkMessage(
      action: 'CHALLENGE_INIT',
      payload: challenge.toJson(),
      timestamp: DateTime.now().toUtc(),
    );
    await transport.send(msg);
  }

  Future<void> approveChallenge(
    AiroPairingChallenge challenge,
    AiroTrustedDeviceRecord relationshipRecord,
  ) async {
    final updatedChallenge = challenge.copyWith(
      status: AiroPairingChallengeStatus.approved,
    );
    await storage.saveDeviceRecord(relationshipRecord);

    final msg = AiroNetworkMessage(
      action: 'CHALLENGE_APPROVE',
      payload: {
        'challenge': updatedChallenge.toJson(),
        'relationship': relationshipRecord.toJson(),
      },
      timestamp: DateTime.now().toUtc(),
    );
    await transport.send(msg);
    _pairingSuccessController.add(relationshipRecord);
  }

  Future<AiroPlaybackTicketServiceDecision> requestTicket(
    AiroPlaybackTicketIssueRequest request,
    AiroTrustedDeviceRecord issuer, {
    DateTime? now,
  }) async {
    final evalTime = now ?? DateTime.now().toUtc();
    final decision = await ticketService.issue(
      request: request,
      issuer: issuer,
      now: evalTime,
    );

    final msg = AiroNetworkMessage(
      action: 'TICKET_ISSUE_RESPONSE',
      payload: decision.toJson(),
      timestamp: evalTime,
    );
    await transport.send(msg);
    return decision;
  }

  Future<AiroPlaybackTicketServiceDecision> redeemTicket(
    AiroPlaybackTicketRedeemRequest request, {
    DateTime? now,
  }) async {
    final evalTime = now ?? DateTime.now().toUtc();
    final decision = await ticketService.redeem(request: request);
    if (decision.accepted) {
      _ticketRedeemedController.add(decision);
    }
    final msg = AiroNetworkMessage(
      action: 'TICKET_REDEEM_RESPONSE',
      payload: decision.toJson(),
      timestamp: evalTime,
    );
    await transport.send(msg);
    return decision;
  }

  void _processIncomingMessage(AiroNetworkMessage msg) async {
    switch (msg.action) {
      case 'CHALLENGE_INIT':
        final challenge = AiroPairingChallenge.fromJson(msg.payload);
        _challengeController.add(challenge);

      case 'CHALLENGE_APPROVE':
        final relMap = msg.payload['relationship'] as Map<String, dynamic>;
        final relationship = AiroTrustedDeviceRecord.fromJson(relMap);
        await storage.saveDeviceRecord(relationship);
        _pairingSuccessController.add(relationship);

      case 'TICKET_REDEEM_RESPONSE':
        final decision = AiroPlaybackTicketServiceDecision.fromJson(
          msg.payload,
        );
        if (decision.accepted) {
          _ticketRedeemedController.add(decision);
        }
    }
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await _challengeController.close();
    await _pairingSuccessController.close();
    await _ticketRedeemedController.close();
  }
}
