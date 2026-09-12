import 'package:equatable/equatable.dart';

import 'enums.dart';

class AiroPairingChallenge extends Equatable {
  AiroPairingChallenge({
    required this.challengeId,
    required this.receiverDeviceId,
    required this.receiverRole,
    required Set<AiroPairingScope> requestedScopes,
    required this.issuedAt,
    required this.expiresAt,
    this.status = AiroPairingChallengeStatus.pending,
    this.schemaVersion = kAiroPairingSchemaVersion,
  }) : requestedScopes = Set.unmodifiable(requestedScopes);

  final String schemaVersion;
  final String challengeId;
  final String receiverDeviceId;
  final AiroDeviceRole receiverRole;
  final Set<AiroPairingScope> requestedScopes;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final AiroPairingChallengeStatus status;

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  AiroPairingChallengeStatus statusAt(DateTime now) {
    if (status == AiroPairingChallengeStatus.pending && isExpired(now)) {
      return AiroPairingChallengeStatus.expired;
    }
    return status;
  }

  bool canApproveAt(DateTime now) =>
      statusAt(now) == AiroPairingChallengeStatus.pending;

  AiroPairingChallenge copyWith({
    String? challengeId,
    String? receiverDeviceId,
    AiroDeviceRole? receiverRole,
    Set<AiroPairingScope>? requestedScopes,
    DateTime? issuedAt,
    DateTime? expiresAt,
    AiroPairingChallengeStatus? status,
    String? schemaVersion,
  }) {
    return AiroPairingChallenge(
      challengeId: challengeId ?? this.challengeId,
      receiverDeviceId: receiverDeviceId ?? this.receiverDeviceId,
      receiverRole: receiverRole ?? this.receiverRole,
      requestedScopes: requestedScopes ?? this.requestedScopes,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'challengeId': challengeId,
      'receiverDeviceId': receiverDeviceId,
      'receiverRole': receiverRole.stableId,
      'requestedScopes': requestedScopes.map((s) => s.stableId).toList(),
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status': status.stableId,
    };
  }

  factory AiroPairingChallenge.fromJson(Map<String, dynamic> json) {
    final scopesList = (json['requestedScopes'] as List<dynamic>)
        .map((s) => AiroPairingScope.fromStableId(s as String))
        .toSet();

    return AiroPairingChallenge(
      schemaVersion:
          (json['schemaVersion'] as String?) ?? kAiroPairingSchemaVersion,
      challengeId: json['challengeId'] as String,
      receiverDeviceId: json['receiverDeviceId'] as String,
      receiverRole: AiroDeviceRole.fromStableId(json['receiverRole'] as String),
      requestedScopes: scopesList,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: AiroPairingChallengeStatus.fromStableId(json['status'] as String),
    );
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    challengeId,
    receiverDeviceId,
    receiverRole,
    requestedScopes,
    issuedAt,
    expiresAt,
    status,
  ];
}
