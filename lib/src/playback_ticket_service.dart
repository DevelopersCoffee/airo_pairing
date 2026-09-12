import 'package:equatable/equatable.dart';

import 'enums.dart';

import 'key_descriptor.dart';
import 'playback_ticket.dart';
import 'trusted_device.dart';

class AiroPlaybackTicketIssueRequest extends Equatable {
  AiroPlaybackTicketIssueRequest({
    required this.requestId,
    required this.ticketId,
    required this.receiverDeviceId,
    required this.sessionId,
    required this.sourceHandle,
    required Set<AiroPairingScope> scopes,
    required this.issuerDeviceId,
    required this.issuedAt,
    required this.notBefore,
    required this.expiresAt,
    this.schemaVersion = kAiroPairingSchemaVersion,
  }) : scopes = Set.unmodifiable(scopes);

  final String schemaVersion;
  final String requestId;
  final String ticketId;
  final String receiverDeviceId;
  final String sessionId;
  final AiroPlaybackSourceHandle sourceHandle;
  final Set<AiroPairingScope> scopes;
  final String issuerDeviceId;
  final DateTime issuedAt;
  final DateTime notBefore;
  final DateTime expiresAt;

  Duration get lifetime => expiresAt.difference(notBefore);

  AiroPlaybackTicket toTicket() {
    return AiroPlaybackTicket(
      ticketId: ticketId,
      receiverDeviceId: receiverDeviceId,
      sessionId: sessionId,
      sourceHandle: sourceHandle,
      scopes: scopes,
      issuedAt: issuedAt,
      notBefore: notBefore,
      expiresAt: expiresAt,
      schemaVersion: schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'requestId': requestId,
      'ticketId': ticketId,
      'receiverDeviceId': receiverDeviceId,
      'sessionId': sessionId,
      'sourceHandle': sourceHandle.toJson(),
      'scopes': scopes.map((s) => s.stableId).toList(),
      'issuerDeviceId': issuerDeviceId,
      'issuedAt': issuedAt.toIso8601String(),
      'notBefore': notBefore.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory AiroPlaybackTicketIssueRequest.fromJson(Map<String, dynamic> json) {
    final scopesList = (json['scopes'] as List<dynamic>)
        .map((s) => AiroPairingScope.fromStableId(s as String))
        .toSet();

    return AiroPlaybackTicketIssueRequest(
      schemaVersion:
          (json['schemaVersion'] as String?) ?? kAiroPairingSchemaVersion,
      requestId: json['requestId'] as String,
      ticketId: json['ticketId'] as String,
      receiverDeviceId: json['receiverDeviceId'] as String,
      sessionId: json['sessionId'] as String,
      sourceHandle: AiroPlaybackSourceHandle.fromJson(
        json['sourceHandle'] as Map<String, dynamic>,
      ),
      scopes: scopesList,
      issuerDeviceId: json['issuerDeviceId'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      notBefore: DateTime.parse(json['notBefore'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  @override
  String toString() {
    return 'AiroPlaybackTicketIssueRequest('
        'requestId: $requestId, '
        'ticketId: $ticketId, '
        'receiverDeviceId: $receiverDeviceId, '
        'sessionId: $sessionId, '
        'sourceHandle: redacted, '
        'scopes: ${scopes.map((scope) => scope.stableId).join(',')}, '
        'issuerDeviceId: $issuerDeviceId, '
        'notBefore: $notBefore, '
        'expiresAt: $expiresAt'
        ')';
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    requestId,
    ticketId,
    receiverDeviceId,
    sessionId,
    sourceHandle,
    scopes,
    issuerDeviceId,
    issuedAt,
    notBefore,
    expiresAt,
  ];
}

class AiroPlaybackTicketRedeemRequest extends Equatable {
  const AiroPlaybackTicketRedeemRequest({
    required this.requestId,
    required this.ticketId,
    required this.receiverDeviceId,
    required this.sessionId,
    required this.requiredScope,
    required this.redeemedAt,
    this.schemaVersion = kAiroPairingSchemaVersion,
  });

  final String schemaVersion;
  final String requestId;
  final String ticketId;
  final String receiverDeviceId;
  final String sessionId;
  final AiroPairingScope requiredScope;
  final DateTime redeemedAt;

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'requestId': requestId,
      'ticketId': ticketId,
      'receiverDeviceId': receiverDeviceId,
      'sessionId': sessionId,
      'requiredScope': requiredScope.stableId,
      'redeemedAt': redeemedAt.toIso8601String(),
    };
  }

  factory AiroPlaybackTicketRedeemRequest.fromJson(Map<String, dynamic> json) {
    return AiroPlaybackTicketRedeemRequest(
      schemaVersion:
          (json['schemaVersion'] as String?) ?? kAiroPairingSchemaVersion,
      requestId: json['requestId'] as String,
      ticketId: json['ticketId'] as String,
      receiverDeviceId: json['receiverDeviceId'] as String,
      sessionId: json['sessionId'] as String,
      requiredScope: AiroPairingScope.fromStableId(
        json['requiredScope'] as String,
      ),
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    requestId,
    ticketId,
    receiverDeviceId,
    sessionId,
    requiredScope,
    redeemedAt,
  ];
}

class AiroPlaybackTicketServiceDecision extends Equatable {
  AiroPlaybackTicketServiceDecision({
    required this.action,
    required Iterable<AiroPlaybackTicketServiceCode> codes,
    this.ticket,
  }) : codes = List.unmodifiable(codes);

  final AiroPlaybackTicketServiceAction action;
  final List<AiroPlaybackTicketServiceCode> codes;
  final AiroPlaybackTicket? ticket;

  bool get accepted =>
      (action == AiroPlaybackTicketServiceAction.issue ||
          action == AiroPlaybackTicketServiceAction.redeem) &&
      codes.length == 1 &&
      codes.single == AiroPlaybackTicketServiceCode.accepted;

  Map<String, Object?> toDiagnosticMap() {
    return {
      'action': action.stableId,
      'codes': codes.map((code) => code.stableId).toList(growable: false),
      'ticketId': ticket?.ticketId,
      'receiverDeviceId': ticket?.receiverDeviceId,
      'sessionId': ticket?.sessionId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action.stableId,
      'codes': codes.map((c) => c.stableId).toList(),
      if (ticket != null) 'ticket': ticket!.toJson(),
    };
  }

  factory AiroPlaybackTicketServiceDecision.fromJson(
    Map<String, dynamic> json,
  ) {
    final codesList = (json['codes'] as List<dynamic>)
        .map((c) => AiroPlaybackTicketServiceCode.fromStableId(c as String))
        .toList();

    return AiroPlaybackTicketServiceDecision(
      action: AiroPlaybackTicketServiceAction.fromStableId(
        json['action'] as String,
      ),
      codes: codesList,
      ticket: json['ticket'] != null
          ? AiroPlaybackTicket.fromJson(json['ticket'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [action, codes, ticket];
}

class AiroPlaybackTicketServicePolicy extends Equatable {
  AiroPlaybackTicketServicePolicy({
    this.requiredIssueScope = AiroPairingScope.playbackTicketIssue,
    this.minimumTrustLevel = AiroTrustedDeviceTrustLevel.paired,
    this.minLifetime = const Duration(seconds: 5),
    this.maxLifetime = const Duration(minutes: 5),
    Set<AiroTrustedDeviceKeyAlgorithm> allowedKeyAlgorithms = const {
      AiroTrustedDeviceKeyAlgorithm.ed25519,
      AiroTrustedDeviceKeyAlgorithm.p256,
    },
    this.keyRotationInterval,
  }) : allowedKeyAlgorithms = Set.unmodifiable(allowedKeyAlgorithms);

  final AiroPairingScope requiredIssueScope;
  final AiroTrustedDeviceTrustLevel minimumTrustLevel;
  final Duration minLifetime;
  final Duration maxLifetime;
  final Set<AiroTrustedDeviceKeyAlgorithm> allowedKeyAlgorithms;
  final Duration? keyRotationInterval;

  AiroPlaybackTicketServiceDecision evaluateIssue({
    required AiroPlaybackTicketIssueRequest request,
    required AiroTrustedDeviceRecord issuer,
    required DateTime now,
  }) {
    final codes = <AiroPlaybackTicketServiceCode>[];
    final access = issuer.evaluateAccess(
      requiredScope: requiredIssueScope,
      now: now,
    );
    if (!access.accepted) {
      codes.add(AiroPlaybackTicketServiceCode.issuerAccessDenied);
    }
    if (!issuer.trustLevel.satisfies(minimumTrustLevel)) {
      codes.add(AiroPlaybackTicketServiceCode.issuerTrustInsufficient);
    }
    if (issuer.controllerDeviceId != request.issuerDeviceId) {
      codes.add(AiroPlaybackTicketServiceCode.issuerAccessDenied);
    }
    if (issuer.receiverDeviceId != request.receiverDeviceId) {
      codes.add(AiroPlaybackTicketServiceCode.receiverMismatch);
    }
    if (!request.scopes.contains(AiroPairingScope.playbackControl)) {
      codes.add(AiroPlaybackTicketServiceCode.scopeMissing);
    }
    final lifetime = request.lifetime;
    if (lifetime < minLifetime ||
        lifetime > maxLifetime ||
        !request.notBefore.isBefore(request.expiresAt)) {
      codes.add(AiroPlaybackTicketServiceCode.invalidLifetime);
    }
    if (AiroPlaybackSourceHandle.validate(request.sourceHandle.value) != null) {
      codes.add(AiroPlaybackTicketServiceCode.sourceUnsafe);
    }
    _addKeyCodes(issuer.keyDescriptor, now, codes);

    return AiroPlaybackTicketServiceDecision(
      action: codes.isEmpty
          ? AiroPlaybackTicketServiceAction.issue
          : AiroPlaybackTicketServiceAction.deny,
      codes: codes.isEmpty
          ? const [AiroPlaybackTicketServiceCode.accepted]
          : codes,
      ticket: codes.isEmpty ? request.toTicket() : null,
    );
  }

  AiroPlaybackTicketServiceDecision evaluateRedeem({
    required AiroPlaybackTicket ticket,
    required AiroPlaybackTicketRedeemRequest request,
  }) {
    final result = ticket.validate(
      receiverDeviceId: request.receiverDeviceId,
      sessionId: request.sessionId,
      requiredScope: request.requiredScope,
      now: request.redeemedAt,
    );
    final code = switch (result.code) {
      AiroPlaybackTicketValidationCode.accepted =>
        AiroPlaybackTicketServiceCode.accepted,
      AiroPlaybackTicketValidationCode.receiverMismatch =>
        AiroPlaybackTicketServiceCode.receiverMismatch,
      AiroPlaybackTicketValidationCode.sessionMismatch =>
        AiroPlaybackTicketServiceCode.sessionMismatch,
      AiroPlaybackTicketValidationCode.scopeMissing =>
        AiroPlaybackTicketServiceCode.scopeMissing,
      AiroPlaybackTicketValidationCode.notYetValid =>
        AiroPlaybackTicketServiceCode.notYetValid,
      AiroPlaybackTicketValidationCode.expired =>
        AiroPlaybackTicketServiceCode.expired,
      AiroPlaybackTicketValidationCode.revoked =>
        AiroPlaybackTicketServiceCode.revoked,
      AiroPlaybackTicketValidationCode.alreadyUsed =>
        AiroPlaybackTicketServiceCode.alreadyUsed,
    };

    return AiroPlaybackTicketServiceDecision(
      action: result.accepted
          ? AiroPlaybackTicketServiceAction.redeem
          : AiroPlaybackTicketServiceAction.deny,
      codes: [code],
      ticket: result.accepted
          ? ticket.copyWith(usedAt: request.redeemedAt)
          : ticket,
    );
  }

  void _addKeyCodes(
    AiroTrustedDeviceKeyDescriptor? key,
    DateTime now,
    List<AiroPlaybackTicketServiceCode> codes,
  ) {
    if (key == null) {
      codes.add(AiroPlaybackTicketServiceCode.issuerKeyMissing);
      return;
    }
    if (!allowedKeyAlgorithms.contains(key.algorithm)) {
      codes.add(AiroPlaybackTicketServiceCode.issuerKeyUnsupported);
    }
    switch (key.stateAt(now: now, rotationInterval: keyRotationInterval)) {
      case AiroTrustedDeviceKeyState.active:
        break;
      case AiroTrustedDeviceKeyState.notYetValid:
        codes.add(AiroPlaybackTicketServiceCode.issuerKeyNotYetValid);
      case AiroTrustedDeviceKeyState.expired:
        codes.add(AiroPlaybackTicketServiceCode.issuerKeyExpired);
      case AiroTrustedDeviceKeyState.revoked:
        codes.add(AiroPlaybackTicketServiceCode.issuerKeyRevoked);
      case AiroTrustedDeviceKeyState.rotationDue:
        codes.add(AiroPlaybackTicketServiceCode.issuerKeyRotationRequired);
    }
  }

  @override
  List<Object?> get props => [
    requiredIssueScope,
    minimumTrustLevel,
    minLifetime,
    maxLifetime,
    allowedKeyAlgorithms,
    keyRotationInterval,
  ];
}

abstract interface class AiroPlaybackTicketService {
  Future<AiroPlaybackTicketServiceDecision> issue({
    required AiroPlaybackTicketIssueRequest request,
    required AiroTrustedDeviceRecord issuer,
    required DateTime now,
  });

  Future<AiroPlaybackTicketServiceDecision> redeem({
    required AiroPlaybackTicketRedeemRequest request,
  });

  Future<AiroPlaybackTicket?> revoke({
    required String ticketId,
    required DateTime revokedAt,
  });
}

class AiroNoOpPlaybackTicketService implements AiroPlaybackTicketService {
  const AiroNoOpPlaybackTicketService();

  @override
  Future<AiroPlaybackTicketServiceDecision> issue({
    required AiroPlaybackTicketIssueRequest request,
    required AiroTrustedDeviceRecord issuer,
    required DateTime now,
  }) async {
    return AiroPlaybackTicketServiceDecision(
      action: AiroPlaybackTicketServiceAction.noOp,
      codes: const [AiroPlaybackTicketServiceCode.serviceUnavailable],
    );
  }

  @override
  Future<AiroPlaybackTicketServiceDecision> redeem({
    required AiroPlaybackTicketRedeemRequest request,
  }) async {
    return AiroPlaybackTicketServiceDecision(
      action: AiroPlaybackTicketServiceAction.noOp,
      codes: const [AiroPlaybackTicketServiceCode.serviceUnavailable],
    );
  }

  @override
  Future<AiroPlaybackTicket?> revoke({
    required String ticketId,
    required DateTime revokedAt,
  }) async {
    return null;
  }
}

class AiroFakePlaybackTicketService implements AiroPlaybackTicketService {
  AiroFakePlaybackTicketService({
    AiroPlaybackTicketServicePolicy? policy,
    Iterable<AiroPlaybackTicket> tickets = const [],
  }) : policy = policy ?? AiroPlaybackTicketServicePolicy(),
       _tickets = {for (final ticket in tickets) ticket.ticketId: ticket};

  final AiroPlaybackTicketServicePolicy policy;
  final Map<String, AiroPlaybackTicket> _tickets;

  @override
  Future<AiroPlaybackTicketServiceDecision> issue({
    required AiroPlaybackTicketIssueRequest request,
    required AiroTrustedDeviceRecord issuer,
    required DateTime now,
  }) async {
    final decision = policy.evaluateIssue(
      request: request,
      issuer: issuer,
      now: now,
    );
    final ticket = decision.ticket;
    if (decision.accepted && ticket != null) {
      _tickets[ticket.ticketId] = ticket;
    }
    return decision;
  }

  @override
  Future<AiroPlaybackTicketServiceDecision> redeem({
    required AiroPlaybackTicketRedeemRequest request,
  }) async {
    final ticket = _tickets[request.ticketId];
    if (ticket == null) {
      return AiroPlaybackTicketServiceDecision(
        action: AiroPlaybackTicketServiceAction.deny,
        codes: const [AiroPlaybackTicketServiceCode.revoked],
      );
    }
    final decision = policy.evaluateRedeem(ticket: ticket, request: request);
    final redeemed = decision.ticket;
    if (decision.accepted && redeemed != null) {
      _tickets[redeemed.ticketId] = redeemed;
    }
    return decision;
  }

  @override
  Future<AiroPlaybackTicket?> revoke({
    required String ticketId,
    required DateTime revokedAt,
  }) async {
    final ticket = _tickets[ticketId];
    if (ticket == null) return null;
    final revoked = ticket.copyWith(revokedAt: revokedAt);
    _tickets[ticketId] = revoked;
    return revoked;
  }
}
