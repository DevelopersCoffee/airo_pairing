import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'playback_ticket.dart';
import 'trusted_device.dart';

class AiroRestrictedReceiverTrustDecision extends Equatable {
  AiroRestrictedReceiverTrustDecision({
    required this.relationshipId,
    required this.receiverDeviceId,
    required this.action,
    required List<AiroRestrictedReceiverTrustCode> codes,
    this.accessCode,
    this.playbackTicketCode,
  }) : codes = List.unmodifiable(codes);

  final String relationshipId;
  final String receiverDeviceId;
  final AiroRestrictedReceiverAction action;
  final List<AiroRestrictedReceiverTrustCode> codes;
  final AiroTrustedDeviceAccessCode? accessCode;
  final AiroPlaybackTicketValidationCode? playbackTicketCode;

  bool get accepted =>
      codes.length == 1 &&
      codes.single == AiroRestrictedReceiverTrustCode.accepted;

  Map<String, Object?> toPublicMap() {
    return {
      'relationshipId': relationshipId,
      'receiverDeviceId': receiverDeviceId,
      'action': action.stableId,
      'codes': _restrictedReceiverTrustCodeStableIds(codes),
      'accessCode': accessCode?.stableId,
      'playbackTicketCode': playbackTicketCode?.stableId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'relationshipId': relationshipId,
      'receiverDeviceId': receiverDeviceId,
      'action': action.stableId,
      'codes': codes.map((c) => c.stableId).toList(),
      if (accessCode != null) 'accessCode': accessCode!.stableId,
      if (playbackTicketCode != null)
        'playbackTicketCode': playbackTicketCode!.stableId,
    };
  }

  factory AiroRestrictedReceiverTrustDecision.fromJson(
    Map<String, dynamic> json,
  ) {
    final codesList = (json['codes'] as List<dynamic>)
        .map((c) => AiroRestrictedReceiverTrustCode.fromStableId(c as String))
        .toList();

    return AiroRestrictedReceiverTrustDecision(
      relationshipId: json['relationshipId'] as String,
      receiverDeviceId: json['receiverDeviceId'] as String,
      action: AiroRestrictedReceiverAction.fromStableId(
        json['action'] as String,
      ),
      codes: codesList,
      accessCode: json['accessCode'] != null
          ? AiroTrustedDeviceAccessCode.fromStableId(
              json['accessCode'] as String,
            )
          : null,
      playbackTicketCode: json['playbackTicketCode'] != null
          ? AiroPlaybackTicketValidationCode.fromStableId(
              json['playbackTicketCode'] as String,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [
    relationshipId,
    receiverDeviceId,
    action,
    codes,
    accessCode,
    playbackTicketCode,
  ];
}

class AiroRestrictedReceiverTrustPolicy extends Equatable {
  AiroRestrictedReceiverTrustPolicy({
    Set<AiroRestrictedReceiverAction> allowedActions = const {
      AiroRestrictedReceiverAction.redeemPlaybackTicket,
      AiroRestrictedReceiverAction.reportPlaybackState,
      AiroRestrictedReceiverAction.playbackControl,
      AiroRestrictedReceiverAction.diagnosticsRead,
    },
  }) : allowedActions = Set.unmodifiable(allowedActions);

  final Set<AiroRestrictedReceiverAction> allowedActions;

  AiroRestrictedReceiverTrustDecision evaluate({
    required AiroTrustedDeviceRecord relationship,
    required AiroRestrictedReceiverAction action,
    required String receiverDeviceId,
    required DateTime now,
    String? sessionId,
    AiroPlaybackTicket? playbackTicket,
    AiroPairingScope requiredPlaybackTicketScope =
        AiroPairingScope.playbackControl,
  }) {
    final codes = <AiroRestrictedReceiverTrustCode>[];

    if (relationship.receiverDeviceId != receiverDeviceId) {
      codes.add(AiroRestrictedReceiverTrustCode.receiverMismatch);
    }

    final access = relationship.evaluateAccess(
      requiredScope: _requiredRelationshipScope(action),
      now: now,
    );
    if (!access.accepted) {
      codes.add(_restrictedCodeForAccess(access.code));
    }

    if (!allowedActions.contains(action)) {
      codes.add(AiroRestrictedReceiverTrustCode.actionNotAllowed);
      final specific = _restrictedCodeForDeniedAction(action);
      if (specific != null) {
        codes.add(specific);
      }
    }

    AiroPlaybackTicketValidationCode? playbackTicketCode;
    if (action == AiroRestrictedReceiverAction.redeemPlaybackTicket) {
      if (playbackTicket == null || sessionId == null) {
        codes.add(AiroRestrictedReceiverTrustCode.playbackTicketRequired);
      } else {
        final ticketValidation = playbackTicket.validate(
          receiverDeviceId: receiverDeviceId,
          sessionId: sessionId,
          requiredScope: requiredPlaybackTicketScope,
          now: now,
        );
        playbackTicketCode = ticketValidation.code;
        if (!ticketValidation.accepted) {
          codes.add(AiroRestrictedReceiverTrustCode.playbackTicketDenied);
        }
      }
    }

    return AiroRestrictedReceiverTrustDecision(
      relationshipId: relationship.relationshipId,
      receiverDeviceId: receiverDeviceId,
      action: action,
      codes: codes.isEmpty
          ? const [AiroRestrictedReceiverTrustCode.accepted]
          : codes,
      accessCode: access.code,
      playbackTicketCode: playbackTicketCode,
    );
  }

  AiroPairingScope _requiredRelationshipScope(
    AiroRestrictedReceiverAction action,
  ) {
    return switch (action) {
      AiroRestrictedReceiverAction.diagnosticsRead ||
      AiroRestrictedReceiverAction.reportPlaybackState =>
        AiroPairingScope.diagnostics,
      AiroRestrictedReceiverAction.redeemPlaybackTicket ||
      AiroRestrictedReceiverAction.playbackControl =>
        AiroPairingScope.playbackControl,
      AiroRestrictedReceiverAction.issuePlaybackTicket =>
        AiroPairingScope.playbackTicketIssue,
      AiroRestrictedReceiverAction.sourceCredentialRead ||
      AiroRestrictedReceiverAction.rawSourceHandleRead ||
      AiroRestrictedReceiverAction.adminAction ||
      AiroRestrictedReceiverAction.billingAction ||
      AiroRestrictedReceiverAction.profileManagement ||
      AiroRestrictedReceiverAction.trustedDeviceManagement =>
        AiroPairingScope.playbackControl,
    };
  }

  AiroRestrictedReceiverTrustCode _restrictedCodeForAccess(
    AiroTrustedDeviceAccessCode code,
  ) {
    return switch (code) {
      AiroTrustedDeviceAccessCode.accepted =>
        AiroRestrictedReceiverTrustCode.accepted,
      AiroTrustedDeviceAccessCode.scopeMissing =>
        AiroRestrictedReceiverTrustCode.scopeMissing,
      AiroTrustedDeviceAccessCode.notYetValid =>
        AiroRestrictedReceiverTrustCode.relationshipNotYetValid,
      AiroTrustedDeviceAccessCode.expired =>
        AiroRestrictedReceiverTrustCode.relationshipExpired,
      AiroTrustedDeviceAccessCode.revoked =>
        AiroRestrictedReceiverTrustCode.relationshipRevoked,
    };
  }

  AiroRestrictedReceiverTrustCode? _restrictedCodeForDeniedAction(
    AiroRestrictedReceiverAction action,
  ) {
    return switch (action) {
      AiroRestrictedReceiverAction.issuePlaybackTicket =>
        AiroRestrictedReceiverTrustCode.ticketIssueDenied,
      AiroRestrictedReceiverAction.sourceCredentialRead =>
        AiroRestrictedReceiverTrustCode.credentialAccessDenied,
      AiroRestrictedReceiverAction.rawSourceHandleRead =>
        AiroRestrictedReceiverTrustCode.rawSourceAccessDenied,
      AiroRestrictedReceiverAction.adminAction =>
        AiroRestrictedReceiverTrustCode.adminActionDenied,
      AiroRestrictedReceiverAction.billingAction =>
        AiroRestrictedReceiverTrustCode.billingActionDenied,
      AiroRestrictedReceiverAction.profileManagement =>
        AiroRestrictedReceiverTrustCode.profileManagementDenied,
      AiroRestrictedReceiverAction.trustedDeviceManagement =>
        AiroRestrictedReceiverTrustCode.trustedDeviceManagementDenied,
      AiroRestrictedReceiverAction.redeemPlaybackTicket ||
      AiroRestrictedReceiverAction.reportPlaybackState ||
      AiroRestrictedReceiverAction.playbackControl ||
      AiroRestrictedReceiverAction.diagnosticsRead => null,
    };
  }

  @override
  List<Object?> get props => [allowedActions];
}

List<String> _restrictedReceiverTrustCodeStableIds(
  Iterable<AiroRestrictedReceiverTrustCode> values,
) {
  return values.map((value) => value.stableId).toList(growable: false)..sort();
}
