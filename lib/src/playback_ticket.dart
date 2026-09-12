import 'package:equatable/equatable.dart';

import 'enums.dart';

class AiroPlaybackSourceHandle extends Equatable {
  const AiroPlaybackSourceHandle._(this.value);

  factory AiroPlaybackSourceHandle.redacted(String value) {
    final rejection = validate(value);
    if (rejection != null) {
      throw ArgumentError.value(value, 'value', rejection.stableId);
    }
    return AiroPlaybackSourceHandle._(value.trim());
  }

  final String value;

  static AiroPlaybackSourceHandleRejectionCode? validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return AiroPlaybackSourceHandleRejectionCode.empty;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return AiroPlaybackSourceHandleRejectionCode.urlValue;
    }
    if (trimmed.startsWith('file://') ||
        trimmed.startsWith('/') ||
        RegExp(r'^[A-Za-z]:\\').hasMatch(trimmed)) {
      return AiroPlaybackSourceHandleRejectionCode.localPathValue;
    }
    if (RegExp(
      r'\b(?:10|127|172\.(?:1[6-9]|2\d|3[0-1])|192\.168)\.',
    ).hasMatch(trimmed)) {
      return AiroPlaybackSourceHandleRejectionCode.localIpValue;
    }
    if (RegExp(
      r'\b(?:bearer|basic)\s+[A-Za-z0-9._~+/=-]+',
      caseSensitive: false,
    ).hasMatch(trimmed)) {
      return AiroPlaybackSourceHandleRejectionCode.credentialLikeValue;
    }

    return null;
  }

  Map<String, dynamic> toJson() => {'value': value};

  factory AiroPlaybackSourceHandle.fromJson(Map<String, dynamic> json) {
    return AiroPlaybackSourceHandle.redacted(json['value'] as String);
  }

  @override
  String toString() => 'AiroPlaybackSourceHandle(redacted)';

  @override
  List<Object?> get props => [value];
}

class AiroPlaybackTicket extends Equatable {
  AiroPlaybackTicket({
    required this.ticketId,
    required this.receiverDeviceId,
    required this.sessionId,
    required this.sourceHandle,
    required Set<AiroPairingScope> scopes,
    required this.issuedAt,
    required this.notBefore,
    required this.expiresAt,
    this.revokedAt,
    this.usedAt,
    this.schemaVersion = kAiroPairingSchemaVersion,
  }) : scopes = Set.unmodifiable(scopes);

  final String schemaVersion;
  final String ticketId;
  final String receiverDeviceId;
  final String sessionId;
  final AiroPlaybackSourceHandle sourceHandle;
  final Set<AiroPairingScope> scopes;
  final DateTime issuedAt;
  final DateTime notBefore;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  final DateTime? usedAt;

  AiroPlaybackTicketValidationResult validate({
    required String receiverDeviceId,
    required String sessionId,
    required AiroPairingScope requiredScope,
    required DateTime now,
  }) {
    if (this.receiverDeviceId != receiverDeviceId) {
      return const AiroPlaybackTicketValidationResult(
        code: AiroPlaybackTicketValidationCode.receiverMismatch,
      );
    }
    if (this.sessionId != sessionId) {
      return const AiroPlaybackTicketValidationResult(
        code: AiroPlaybackTicketValidationCode.sessionMismatch,
      );
    }
    if (revokedAt != null && !now.isBefore(revokedAt!)) {
      return const AiroPlaybackTicketValidationResult(
        code: AiroPlaybackTicketValidationCode.revoked,
      );
    }
    if (usedAt != null && !now.isBefore(usedAt!)) {
      return const AiroPlaybackTicketValidationResult(
        code: AiroPlaybackTicketValidationCode.alreadyUsed,
      );
    }
    if (!scopes.contains(requiredScope)) {
      return const AiroPlaybackTicketValidationResult(
        code: AiroPlaybackTicketValidationCode.scopeMissing,
      );
    }
    if (now.isBefore(notBefore)) {
      return const AiroPlaybackTicketValidationResult(
        code: AiroPlaybackTicketValidationCode.notYetValid,
      );
    }
    if (!now.isBefore(expiresAt)) {
      return const AiroPlaybackTicketValidationResult(
        code: AiroPlaybackTicketValidationCode.expired,
      );
    }
    return const AiroPlaybackTicketValidationResult(
      code: AiroPlaybackTicketValidationCode.accepted,
    );
  }

  bool allows({
    required String receiverDeviceId,
    required String sessionId,
    required AiroPairingScope requiredScope,
    required DateTime now,
  }) {
    return validate(
      receiverDeviceId: receiverDeviceId,
      sessionId: sessionId,
      requiredScope: requiredScope,
      now: now,
    ).accepted;
  }

  AiroPlaybackTicket copyWith({DateTime? revokedAt, DateTime? usedAt}) {
    return AiroPlaybackTicket(
      schemaVersion: schemaVersion,
      ticketId: ticketId,
      receiverDeviceId: receiverDeviceId,
      sessionId: sessionId,
      sourceHandle: sourceHandle,
      scopes: scopes,
      issuedAt: issuedAt,
      notBefore: notBefore,
      expiresAt: expiresAt,
      revokedAt: revokedAt ?? this.revokedAt,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'ticketId': ticketId,
      'receiverDeviceId': receiverDeviceId,
      'sessionId': sessionId,
      'sourceHandle': sourceHandle.toJson(),
      'scopes': scopes.map((s) => s.stableId).toList(),
      'issuedAt': issuedAt.toIso8601String(),
      'notBefore': notBefore.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      if (revokedAt != null) 'revokedAt': revokedAt!.toIso8601String(),
      if (usedAt != null) 'usedAt': usedAt!.toIso8601String(),
    };
  }

  factory AiroPlaybackTicket.fromJson(Map<String, dynamic> json) {
    final scopesList = (json['scopes'] as List<dynamic>)
        .map((s) => AiroPairingScope.fromStableId(s as String))
        .toSet();

    return AiroPlaybackTicket(
      schemaVersion: (json['schemaVersion'] as String?) ?? kAiroPairingSchemaVersion,
      ticketId: json['ticketId'] as String,
      receiverDeviceId: json['receiverDeviceId'] as String,
      sessionId: json['sessionId'] as String,
      sourceHandle: AiroPlaybackSourceHandle.fromJson(json['sourceHandle'] as Map<String, dynamic>),
      scopes: scopesList,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      notBefore: DateTime.parse(json['notBefore'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      revokedAt: json['revokedAt'] != null ? DateTime.parse(json['revokedAt'] as String) : null,
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt'] as String) : null,
    );
  }

  @override
  String toString() {
    return 'AiroPlaybackTicket('
        'ticketId: $ticketId, '
        'receiverDeviceId: $receiverDeviceId, '
        'sessionId: $sessionId, '
        'sourceHandle: redacted, '
        'scopes: ${scopes.map((scope) => scope.stableId).join(',')}, '
        'issuedAt: $issuedAt, '
        'notBefore: $notBefore, '
        'expiresAt: $expiresAt, '
        'revokedAt: $revokedAt, '
        'usedAt: $usedAt'
        ')';
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    ticketId,
    receiverDeviceId,
    sessionId,
    sourceHandle,
    scopes,
    issuedAt,
    notBefore,
    expiresAt,
    revokedAt,
    usedAt,
  ];
}

class AiroPlaybackTicketValidationResult extends Equatable {
  const AiroPlaybackTicketValidationResult({required this.code});

  final AiroPlaybackTicketValidationCode code;

  bool get accepted => code == AiroPlaybackTicketValidationCode.accepted;

  Map<String, dynamic> toJson() => {'code': code.stableId};

  factory AiroPlaybackTicketValidationResult.fromJson(Map<String, dynamic> json) {
    return AiroPlaybackTicketValidationResult(
      code: AiroPlaybackTicketValidationCode.fromStableId(json['code'] as String),
    );
  }

  @override
  List<Object?> get props => [code];
}
