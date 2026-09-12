const String kAiroPairingSchemaVersion = '1.0.0';

enum AiroDeviceRole {
  tvReceiver('tv_receiver'),
  mobileController('mobile_controller'),
  desktopCompanion('desktop_companion'),
  homeNode('home_node'),
  cloudRelay('cloud_relay');

  const AiroDeviceRole(this.stableId);

  final String stableId;

  static AiroDeviceRole fromStableId(String stableId) {
    return AiroDeviceRole.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError('Unknown AiroDeviceRole: $stableId'),
    );
  }
}

enum AiroPairingScope {
  playbackControl('playback_control'),
  textInput('text_input'),
  sourceSelection('source_selection'),
  diagnostics('diagnostics'),
  companionSearch('companion_search'),
  playbackTicketIssue('playback_ticket_issue');

  const AiroPairingScope(this.stableId);

  final String stableId;

  static AiroPairingScope fromStableId(String stableId) {
    return AiroPairingScope.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError('Unknown AiroPairingScope: $stableId'),
    );
  }
}

enum AiroPairingChallengeStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  expired('expired'),
  revoked('revoked');

  const AiroPairingChallengeStatus(this.stableId);

  final String stableId;

  static AiroPairingChallengeStatus fromStableId(String stableId) {
    return AiroPairingChallengeStatus.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () =>
          throw ArgumentError('Unknown AiroPairingChallengeStatus: $stableId'),
    );
  }
}

enum AiroTrustedDeviceAccessCode {
  accepted('accepted'),
  scopeMissing('scope_missing'),
  notYetValid('not_yet_valid'),
  expired('expired'),
  revoked('revoked');

  const AiroTrustedDeviceAccessCode(this.stableId);

  final String stableId;

  static AiroTrustedDeviceAccessCode fromStableId(String stableId) {
    return AiroTrustedDeviceAccessCode.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () =>
          throw ArgumentError('Unknown AiroTrustedDeviceAccessCode: $stableId'),
    );
  }
}

enum AiroTrustedDeviceTrustLevel {
  restricted('restricted', 0),
  paired('paired', 1),
  trusted('trusted', 2),
  owner('owner', 3);

  const AiroTrustedDeviceTrustLevel(this.stableId, this.rank);

  final String stableId;
  final int rank;

  bool satisfies(AiroTrustedDeviceTrustLevel minimum) => rank >= minimum.rank;

  static AiroTrustedDeviceTrustLevel fromStableId(String stableId) {
    return AiroTrustedDeviceTrustLevel.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () =>
          throw ArgumentError('Unknown AiroTrustedDeviceTrustLevel: $stableId'),
    );
  }
}

enum AiroTrustedDeviceKeyAlgorithm {
  ed25519('ed25519'),
  p256('p256');

  const AiroTrustedDeviceKeyAlgorithm(this.stableId);

  final String stableId;

  static AiroTrustedDeviceKeyAlgorithm fromStableId(String stableId) {
    return AiroTrustedDeviceKeyAlgorithm.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError(
        'Unknown AiroTrustedDeviceKeyAlgorithm: $stableId',
      ),
    );
  }
}

enum AiroTrustedDeviceKeyState {
  active('active'),
  rotationDue('rotation_due'),
  notYetValid('not_yet_valid'),
  expired('expired'),
  revoked('revoked');

  const AiroTrustedDeviceKeyState(this.stableId);

  final String stableId;

  static AiroTrustedDeviceKeyState fromStableId(String stableId) {
    return AiroTrustedDeviceKeyState.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () =>
          throw ArgumentError('Unknown AiroTrustedDeviceKeyState: $stableId'),
    );
  }
}

enum AiroTrustedDeviceSecurityCode {
  accepted('accepted'),
  accessDenied('access_denied'),
  trustLevelInsufficient('trust_level_insufficient'),
  keyMissing('key_missing'),
  keyUnsupported('key_unsupported'),
  keyNotYetValid('key_not_yet_valid'),
  keyExpired('key_expired'),
  keyRevoked('key_revoked'),
  keyRotationRequired('key_rotation_required');

  const AiroTrustedDeviceSecurityCode(this.stableId);

  final String stableId;

  static AiroTrustedDeviceSecurityCode fromStableId(String stableId) {
    return AiroTrustedDeviceSecurityCode.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError(
        'Unknown AiroTrustedDeviceSecurityCode: $stableId',
      ),
    );
  }
}

enum AiroRestrictedReceiverAction {
  redeemPlaybackTicket('redeem_playback_ticket'),
  reportPlaybackState('report_playback_state'),
  playbackControl('playback_control'),
  diagnosticsRead('diagnostics_read'),
  issuePlaybackTicket('issue_playback_ticket'),
  sourceCredentialRead('source_credential_read'),
  rawSourceHandleRead('raw_source_handle_read'),
  adminAction('admin_action'),
  billingAction('billing_action'),
  profileManagement('profile_management'),
  trustedDeviceManagement('trusted_device_management');

  const AiroRestrictedReceiverAction(this.stableId);

  final String stableId;

  static AiroRestrictedReceiverAction fromStableId(String stableId) {
    return AiroRestrictedReceiverAction.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError(
        'Unknown AiroRestrictedReceiverAction: $stableId',
      ),
    );
  }
}

enum AiroRestrictedReceiverTrustCode {
  accepted('accepted'),
  receiverMismatch('receiver_mismatch'),
  relationshipNotYetValid('relationship_not_yet_valid'),
  relationshipExpired('relationship_expired'),
  relationshipRevoked('relationship_revoked'),
  scopeMissing('scope_missing'),
  actionNotAllowed('action_not_allowed'),
  playbackTicketRequired('playback_ticket_required'),
  playbackTicketDenied('playback_ticket_denied'),
  ticketIssueDenied('ticket_issue_denied'),
  credentialAccessDenied('credential_access_denied'),
  rawSourceAccessDenied('raw_source_access_denied'),
  adminActionDenied('admin_action_denied'),
  billingActionDenied('billing_action_denied'),
  profileManagementDenied('profile_management_denied'),
  trustedDeviceManagementDenied('trusted_device_management_denied');

  const AiroRestrictedReceiverTrustCode(this.stableId);

  final String stableId;

  static AiroRestrictedReceiverTrustCode fromStableId(String stableId) {
    return AiroRestrictedReceiverTrustCode.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError(
        'Unknown AiroRestrictedReceiverTrustCode: $stableId',
      ),
    );
  }
}

enum AiroPlaybackTicketValidationCode {
  accepted('accepted'),
  receiverMismatch('receiver_mismatch'),
  sessionMismatch('session_mismatch'),
  scopeMissing('scope_missing'),
  notYetValid('not_yet_valid'),
  expired('expired'),
  revoked('revoked'),
  alreadyUsed('already_used');

  const AiroPlaybackTicketValidationCode(this.stableId);

  final String stableId;

  static AiroPlaybackTicketValidationCode fromStableId(String stableId) {
    return AiroPlaybackTicketValidationCode.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError(
        'Unknown AiroPlaybackTicketValidationCode: $stableId',
      ),
    );
  }
}

enum AiroPlaybackTicketServiceAction {
  issue('issue'),
  redeem('redeem'),
  deny('deny'),
  noOp('no_op');

  const AiroPlaybackTicketServiceAction(this.stableId);

  final String stableId;

  static AiroPlaybackTicketServiceAction fromStableId(String stableId) {
    return AiroPlaybackTicketServiceAction.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError(
        'Unknown AiroPlaybackTicketServiceAction: $stableId',
      ),
    );
  }
}

enum AiroPlaybackTicketServiceCode {
  accepted('accepted'),
  invalidLifetime('invalid_lifetime'),
  receiverMismatch('receiver_mismatch'),
  sessionMismatch('session_mismatch'),
  sourceUnsafe('source_unsafe'),
  issuerAccessDenied('issuer_access_denied'),
  issuerTrustInsufficient('issuer_trust_insufficient'),
  issuerKeyMissing('issuer_key_missing'),
  issuerKeyUnsupported('issuer_key_unsupported'),
  issuerKeyNotYetValid('issuer_key_not_yet_valid'),
  issuerKeyExpired('issuer_key_expired'),
  issuerKeyRevoked('issuer_key_revoked'),
  issuerKeyRotationRequired('issuer_key_rotation_required'),
  scopeMissing('scope_missing'),
  notYetValid('not_yet_valid'),
  expired('expired'),
  revoked('revoked'),
  alreadyUsed('already_used'),
  serviceUnavailable('service_unavailable');

  const AiroPlaybackTicketServiceCode(this.stableId);

  final String stableId;

  static AiroPlaybackTicketServiceCode fromStableId(String stableId) {
    return AiroPlaybackTicketServiceCode.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError(
        'Unknown AiroPlaybackTicketServiceCode: $stableId',
      ),
    );
  }
}

enum AiroPlaybackSourceHandleRejectionCode {
  empty('empty'),
  urlValue('url_value'),
  localPathValue('local_path_value'),
  localIpValue('local_ip_value'),
  credentialLikeValue('credential_like_value');

  const AiroPlaybackSourceHandleRejectionCode(this.stableId);

  final String stableId;

  static AiroPlaybackSourceHandleRejectionCode fromStableId(String stableId) {
    return AiroPlaybackSourceHandleRejectionCode.values.firstWhere(
      (e) => e.stableId == stableId,
      orElse: () => throw ArgumentError(
        'Unknown AiroPlaybackSourceHandleRejectionCode: $stableId',
      ),
    );
  }
}
