import 'package:equatable/equatable.dart';

import 'enums.dart';

class AiroTrustedDeviceKeyDescriptor extends Equatable {
  const AiroTrustedDeviceKeyDescriptor({
    required this.keyId,
    required this.algorithm,
    required this.publicKeyFingerprint,
    required this.createdAt,
    required this.notBefore,
    required this.expiresAt,
    this.revokedAt,
    this.schemaVersion = kAiroPairingSchemaVersion,
  });

  final String schemaVersion;
  final String keyId;
  final AiroTrustedDeviceKeyAlgorithm algorithm;
  final String publicKeyFingerprint;
  final DateTime createdAt;
  final DateTime notBefore;
  final DateTime expiresAt;
  final DateTime? revokedAt;

  AiroTrustedDeviceKeyState stateAt({
    required DateTime now,
    Duration? rotationInterval,
  }) {
    if (revokedAt != null && !now.isBefore(revokedAt!)) {
      return AiroTrustedDeviceKeyState.revoked;
    }
    if (now.isBefore(notBefore)) {
      return AiroTrustedDeviceKeyState.notYetValid;
    }
    if (!now.isBefore(expiresAt)) {
      return AiroTrustedDeviceKeyState.expired;
    }
    if (rotationInterval != null &&
        !now.isBefore(createdAt.add(rotationInterval))) {
      return AiroTrustedDeviceKeyState.rotationDue;
    }
    return AiroTrustedDeviceKeyState.active;
  }

  AiroTrustedDeviceKeyDescriptor copyWith({
    String? keyId,
    AiroTrustedDeviceKeyAlgorithm? algorithm,
    String? publicKeyFingerprint,
    DateTime? createdAt,
    DateTime? notBefore,
    DateTime? expiresAt,
    DateTime? revokedAt,
    String? schemaVersion,
  }) {
    return AiroTrustedDeviceKeyDescriptor(
      keyId: keyId ?? this.keyId,
      algorithm: algorithm ?? this.algorithm,
      publicKeyFingerprint: publicKeyFingerprint ?? this.publicKeyFingerprint,
      createdAt: createdAt ?? this.createdAt,
      notBefore: notBefore ?? this.notBefore,
      expiresAt: expiresAt ?? this.expiresAt,
      revokedAt: revokedAt ?? this.revokedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'keyId': keyId,
      'algorithm': algorithm.stableId,
      'publicKeyFingerprint': publicKeyFingerprint,
      'createdAt': createdAt.toIso8601String(),
      'notBefore': notBefore.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      if (revokedAt != null) 'revokedAt': revokedAt!.toIso8601String(),
    };
  }

  factory AiroTrustedDeviceKeyDescriptor.fromJson(Map<String, dynamic> json) {
    return AiroTrustedDeviceKeyDescriptor(
      schemaVersion: (json['schemaVersion'] as String?) ?? kAiroPairingSchemaVersion,
      keyId: json['keyId'] as String,
      algorithm: AiroTrustedDeviceKeyAlgorithm.fromStableId(json['algorithm'] as String),
      publicKeyFingerprint: json['publicKeyFingerprint'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notBefore: DateTime.parse(json['notBefore'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      revokedAt: json['revokedAt'] != null ? DateTime.parse(json['revokedAt'] as String) : null,
    );
  }

  @override
  String toString() {
    return 'AiroTrustedDeviceKeyDescriptor('
        'keyId: $keyId, '
        'algorithm: ${algorithm.stableId}, '
        'createdAt: $createdAt, '
        'notBefore: $notBefore, '
        'expiresAt: $expiresAt, '
        'revokedAt: $revokedAt'
        ')';
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    keyId,
    algorithm,
    publicKeyFingerprint,
    createdAt,
    notBefore,
    expiresAt,
    revokedAt,
  ];
}
