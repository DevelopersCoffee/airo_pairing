import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'key_descriptor.dart';

class AiroTrustedDeviceRecord extends Equatable {
  AiroTrustedDeviceRecord({
    required this.relationshipId,
    required this.controllerDeviceId,
    required this.receiverDeviceId,
    required this.controllerRole,
    required this.receiverRole,
    required Set<AiroPairingScope> scopes,
    required this.createdAt,
    this.notBefore,
    this.expiresAt,
    this.revokedAt,
    this.pairingChallengeId,
    this.trustLevel = AiroTrustedDeviceTrustLevel.paired,
    this.keyDescriptor,
    this.revokedByDeviceId,
    this.revocationReason,
    this.schemaVersion = kAiroPairingSchemaVersion,
  }) : scopes = Set.unmodifiable(scopes);

  final String schemaVersion;
  final String relationshipId;
  final String controllerDeviceId;
  final String receiverDeviceId;
  final AiroDeviceRole controllerRole;
  final AiroDeviceRole receiverRole;
  final Set<AiroPairingScope> scopes;
  final DateTime createdAt;
  final DateTime? notBefore;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final String? pairingChallengeId;
  final AiroTrustedDeviceTrustLevel trustLevel;
  final AiroTrustedDeviceKeyDescriptor? keyDescriptor;
  final String? revokedByDeviceId;
  final String? revocationReason;

  AiroTrustedDeviceAccessResult evaluateAccess({
    required AiroPairingScope requiredScope,
    required DateTime now,
  }) {
    if (revokedAt != null && !now.isBefore(revokedAt!)) {
      return const AiroTrustedDeviceAccessResult(
        code: AiroTrustedDeviceAccessCode.revoked,
      );
    }
    final startsAt = notBefore ?? createdAt;
    if (now.isBefore(startsAt)) {
      return const AiroTrustedDeviceAccessResult(
        code: AiroTrustedDeviceAccessCode.notYetValid,
      );
    }
    if (expiresAt != null && !now.isBefore(expiresAt!)) {
      return const AiroTrustedDeviceAccessResult(
        code: AiroTrustedDeviceAccessCode.expired,
      );
    }
    if (!scopes.contains(requiredScope)) {
      return const AiroTrustedDeviceAccessResult(
        code: AiroTrustedDeviceAccessCode.scopeMissing,
      );
    }
    return const AiroTrustedDeviceAccessResult(
      code: AiroTrustedDeviceAccessCode.accepted,
    );
  }

  bool allows({
    required AiroPairingScope requiredScope,
    required DateTime now,
  }) {
    return evaluateAccess(requiredScope: requiredScope, now: now).accepted;
  }

  AiroTrustedDeviceRecord copyWith({
    String? relationshipId,
    String? controllerDeviceId,
    String? receiverDeviceId,
    AiroDeviceRole? controllerRole,
    AiroDeviceRole? receiverRole,
    Set<AiroPairingScope>? scopes,
    DateTime? createdAt,
    DateTime? notBefore,
    DateTime? expiresAt,
    DateTime? revokedAt,
    String? pairingChallengeId,
    AiroTrustedDeviceTrustLevel? trustLevel,
    AiroTrustedDeviceKeyDescriptor? keyDescriptor,
    String? revokedByDeviceId,
    String? revocationReason,
    String? schemaVersion,
  }) {
    return AiroTrustedDeviceRecord(
      relationshipId: relationshipId ?? this.relationshipId,
      controllerDeviceId: controllerDeviceId ?? this.controllerDeviceId,
      receiverDeviceId: receiverDeviceId ?? this.receiverDeviceId,
      controllerRole: controllerRole ?? this.controllerRole,
      receiverRole: receiverRole ?? this.receiverRole,
      scopes: scopes ?? this.scopes,
      createdAt: createdAt ?? this.createdAt,
      notBefore: notBefore ?? this.notBefore,
      expiresAt: expiresAt ?? this.expiresAt,
      revokedAt: revokedAt ?? this.revokedAt,
      pairingChallengeId: pairingChallengeId ?? this.pairingChallengeId,
      trustLevel: trustLevel ?? this.trustLevel,
      keyDescriptor: keyDescriptor ?? this.keyDescriptor,
      revokedByDeviceId: revokedByDeviceId ?? this.revokedByDeviceId,
      revocationReason: revocationReason ?? this.revocationReason,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'relationshipId': relationshipId,
      'controllerDeviceId': controllerDeviceId,
      'receiverDeviceId': receiverDeviceId,
      'controllerRole': controllerRole.stableId,
      'receiverRole': receiverRole.stableId,
      'scopes': scopes.map((s) => s.stableId).toList(),
      'createdAt': createdAt.toIso8601String(),
      if (notBefore != null) 'notBefore': notBefore!.toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      if (revokedAt != null) 'revokedAt': revokedAt!.toIso8601String(),
      if (pairingChallengeId != null) 'pairingChallengeId': pairingChallengeId,
      'trustLevel': trustLevel.stableId,
      if (keyDescriptor != null) 'keyDescriptor': keyDescriptor!.toJson(),
      if (revokedByDeviceId != null) 'revokedByDeviceId': revokedByDeviceId,
      if (revocationReason != null) 'revocationReason': revocationReason,
    };
  }

  factory AiroTrustedDeviceRecord.fromJson(Map<String, dynamic> json) {
    final scopesList = (json['scopes'] as List<dynamic>)
        .map((s) => AiroPairingScope.fromStableId(s as String))
        .toSet();

    return AiroTrustedDeviceRecord(
      schemaVersion: (json['schemaVersion'] as String?) ?? kAiroPairingSchemaVersion,
      relationshipId: json['relationshipId'] as String,
      controllerDeviceId: json['controllerDeviceId'] as String,
      receiverDeviceId: json['receiverDeviceId'] as String,
      controllerRole: AiroDeviceRole.fromStableId(json['controllerRole'] as String),
      receiverRole: AiroDeviceRole.fromStableId(json['receiverRole'] as String),
      scopes: scopesList,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notBefore: json['notBefore'] != null ? DateTime.parse(json['notBefore'] as String) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      revokedAt: json['revokedAt'] != null ? DateTime.parse(json['revokedAt'] as String) : null,
      pairingChallengeId: json['pairingChallengeId'] as String?,
      trustLevel: json['trustLevel'] != null
          ? AiroTrustedDeviceTrustLevel.fromStableId(json['trustLevel'] as String)
          : AiroTrustedDeviceTrustLevel.paired,
      keyDescriptor: json['keyDescriptor'] != null
          ? AiroTrustedDeviceKeyDescriptor.fromJson(json['keyDescriptor'] as Map<String, dynamic>)
          : null,
      revokedByDeviceId: json['revokedByDeviceId'] as String?,
      revocationReason: json['revocationReason'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    relationshipId,
    controllerDeviceId,
    receiverDeviceId,
    controllerRole,
    receiverRole,
    scopes,
    createdAt,
    notBefore,
    expiresAt,
    revokedAt,
    pairingChallengeId,
    trustLevel,
    keyDescriptor,
    revokedByDeviceId,
    revocationReason,
  ];
}

class AiroTrustedDeviceAccessResult extends Equatable {
  const AiroTrustedDeviceAccessResult({required this.code});

  final AiroTrustedDeviceAccessCode code;

  bool get accepted => code == AiroTrustedDeviceAccessCode.accepted;

  Map<String, dynamic> toJson() => {'code': code.stableId};

  factory AiroTrustedDeviceAccessResult.fromJson(Map<String, dynamic> json) {
    return AiroTrustedDeviceAccessResult(
      code: AiroTrustedDeviceAccessCode.fromStableId(json['code'] as String),
    );
  }

  @override
  List<Object?> get props => [code];
}

class AiroTrustedDeviceSecurityPolicy extends Equatable {
  AiroTrustedDeviceSecurityPolicy({
    required this.requiredScope,
    this.minimumTrustLevel = AiroTrustedDeviceTrustLevel.paired,
    Set<AiroTrustedDeviceKeyAlgorithm> allowedKeyAlgorithms = const {
      AiroTrustedDeviceKeyAlgorithm.ed25519,
      AiroTrustedDeviceKeyAlgorithm.p256,
    },
    this.keyRotationInterval,
    this.requiresKeyDescriptor = true,
  }) : allowedKeyAlgorithms = Set.unmodifiable(allowedKeyAlgorithms);

  final AiroPairingScope requiredScope;
  final AiroTrustedDeviceTrustLevel minimumTrustLevel;
  final Set<AiroTrustedDeviceKeyAlgorithm> allowedKeyAlgorithms;
  final Duration? keyRotationInterval;
  final bool requiresKeyDescriptor;

  AiroTrustedDeviceSecurityResult evaluate({
    required AiroTrustedDeviceRecord record,
    required DateTime now,
  }) {
    final blockers = <AiroTrustedDeviceSecurityBlocker>[];
    final access = record.evaluateAccess(
      requiredScope: requiredScope,
      now: now,
    );
    if (!access.accepted) {
      blockers.add(
        AiroTrustedDeviceSecurityBlocker(
          code: AiroTrustedDeviceSecurityCode.accessDenied,
          accessCode: access.code,
        ),
      );
    }
    if (!record.trustLevel.satisfies(minimumTrustLevel)) {
      blockers.add(
        AiroTrustedDeviceSecurityBlocker(
          code: AiroTrustedDeviceSecurityCode.trustLevelInsufficient,
          field: 'trustLevel',
        ),
      );
    }

    final keyDescriptor = record.keyDescriptor;
    if (keyDescriptor == null) {
      if (requiresKeyDescriptor) {
        blockers.add(
          const AiroTrustedDeviceSecurityBlocker(
            code: AiroTrustedDeviceSecurityCode.keyMissing,
            field: 'keyDescriptor',
          ),
        );
      }
    } else {
      if (!allowedKeyAlgorithms.contains(keyDescriptor.algorithm)) {
        blockers.add(
          AiroTrustedDeviceSecurityBlocker(
            code: AiroTrustedDeviceSecurityCode.keyUnsupported,
            field: keyDescriptor.algorithm.stableId,
          ),
        );
      }
      switch (keyDescriptor.stateAt(
        now: now,
        rotationInterval: keyRotationInterval,
      )) {
        case AiroTrustedDeviceKeyState.active:
          break;
        case AiroTrustedDeviceKeyState.rotationDue:
          blockers.add(
            const AiroTrustedDeviceSecurityBlocker(
              code: AiroTrustedDeviceSecurityCode.keyRotationRequired,
              field: 'keyDescriptor',
            ),
          );
        case AiroTrustedDeviceKeyState.notYetValid:
          blockers.add(
            const AiroTrustedDeviceSecurityBlocker(
              code: AiroTrustedDeviceSecurityCode.keyNotYetValid,
              field: 'keyDescriptor',
            ),
          );
        case AiroTrustedDeviceKeyState.expired:
          blockers.add(
            const AiroTrustedDeviceSecurityBlocker(
              code: AiroTrustedDeviceSecurityCode.keyExpired,
              field: 'keyDescriptor',
            ),
          );
        case AiroTrustedDeviceKeyState.revoked:
          blockers.add(
            const AiroTrustedDeviceSecurityBlocker(
              code: AiroTrustedDeviceSecurityCode.keyRevoked,
              field: 'keyDescriptor',
            ),
          );
      }
    }

    return AiroTrustedDeviceSecurityResult(blockers: blockers);
  }

  @override
  List<Object?> get props => [
    requiredScope,
    minimumTrustLevel,
    allowedKeyAlgorithms,
    keyRotationInterval,
    requiresKeyDescriptor,
  ];
}

class AiroTrustedDeviceSecurityBlocker extends Equatable {
  const AiroTrustedDeviceSecurityBlocker({
    required this.code,
    this.accessCode,
    this.field,
  });

  final AiroTrustedDeviceSecurityCode code;
  final AiroTrustedDeviceAccessCode? accessCode;
  final String? field;

  Map<String, dynamic> toJson() {
    return {
      'code': code.stableId,
      if (accessCode != null) 'accessCode': accessCode!.stableId,
      if (field != null) 'field': field,
    };
  }

  factory AiroTrustedDeviceSecurityBlocker.fromJson(Map<String, dynamic> json) {
    return AiroTrustedDeviceSecurityBlocker(
      code: AiroTrustedDeviceSecurityCode.fromStableId(json['code'] as String),
      accessCode: json['accessCode'] != null
          ? AiroTrustedDeviceAccessCode.fromStableId(json['accessCode'] as String)
          : null,
      field: json['field'] as String?,
    );
  }

  @override
  List<Object?> get props => [code, accessCode, field];
}

class AiroTrustedDeviceSecurityResult extends Equatable {
  AiroTrustedDeviceSecurityResult({
    required List<AiroTrustedDeviceSecurityBlocker> blockers,
  }) : blockers = List.unmodifiable(blockers);

  final List<AiroTrustedDeviceSecurityBlocker> blockers;

  bool get accepted => blockers.isEmpty;

  bool has(AiroTrustedDeviceSecurityCode code) {
    return blockers.any((blocker) => blocker.code == code);
  }

  Map<String, dynamic> toJson() {
    return {'blockers': blockers.map((b) => b.toJson()).toList()};
  }

  factory AiroTrustedDeviceSecurityResult.fromJson(Map<String, dynamic> json) {
    final list = (json['blockers'] as List<dynamic>)
        .map((b) => AiroTrustedDeviceSecurityBlocker.fromJson(b as Map<String, dynamic>))
        .toList();
    return AiroTrustedDeviceSecurityResult(blockers: list);
  }

  @override
  List<Object?> get props => [blockers];
}
