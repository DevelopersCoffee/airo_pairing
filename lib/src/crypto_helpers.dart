import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

import 'enums.dart';

abstract class AiroCryptoUtils {
  /// Computes a hex SHA-256 fingerprint for a raw public key or certificate byte array.
  static String computePublicKeyFingerprint(List<int> publicKeyBytes) {
    final digest = sha256.convert(publicKeyBytes);
    return digest.toString();
  }

  /// Computes an HMAC-SHA256 signature for a UTF-8 message string using a secret key.
  static String signHmacSha256(String message, List<int> secretKeyBytes) {
    final hmac = Hmac(sha256, secretKeyBytes);
    final digest = hmac.convert(utf8.encode(message));
    return base64.encode(digest.bytes);
  }

  /// Verifies an HMAC-SHA256 base64 signature against a UTF-8 message string.
  static bool verifyHmacSha256(
    String message,
    String signatureBase64,
    List<int> secretKeyBytes,
  ) {
    final computedSignature = signHmacSha256(message, secretKeyBytes);
    return computedSignature == signatureBase64;
  }
}

class AiroSignedPayload extends Equatable {
  const AiroSignedPayload({
    required this.payload,
    required this.signatureBase64,
    required this.keyId,
    required this.algorithm,
    required this.timestamp,
    this.schemaVersion = kAiroPairingSchemaVersion,
  });

  final String schemaVersion;
  final String payload;
  final String signatureBase64;
  final String keyId;
  final AiroTrustedDeviceKeyAlgorithm algorithm;
  final DateTime timestamp;

  /// Creates a signed payload container using HMAC-SHA256 signature algorithm over [payload].
  factory AiroSignedPayload.createHmac({
    required String payload,
    required String keyId,
    required List<int> secretKeyBytes,
    required DateTime timestamp,
  }) {
    final signature = AiroCryptoUtils.signHmacSha256(
      '$keyId:$timestamp:${payload.trim()}',
      secretKeyBytes,
    );
    return AiroSignedPayload(
      payload: payload,
      signatureBase64: signature,
      keyId: keyId,
      algorithm: AiroTrustedDeviceKeyAlgorithm.ed25519,
      timestamp: timestamp,
    );
  }

  /// Verifies the payload signature using the given secret/public key.
  bool verifyHmac(List<int> secretKeyBytes) {
    final expectedMessage = '$keyId:$timestamp:${payload.trim()}';
    return AiroCryptoUtils.verifyHmacSha256(
      expectedMessage,
      signatureBase64,
      secretKeyBytes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'payload': payload,
      'signatureBase64': signatureBase64,
      'keyId': keyId,
      'algorithm': algorithm.stableId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AiroSignedPayload.fromJson(Map<String, dynamic> json) {
    return AiroSignedPayload(
      schemaVersion:
          (json['schemaVersion'] as String?) ?? kAiroPairingSchemaVersion,
      payload: json['payload'] as String,
      signatureBase64: json['signatureBase64'] as String,
      keyId: json['keyId'] as String,
      algorithm: AiroTrustedDeviceKeyAlgorithm.fromStableId(
        json['algorithm'] as String,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    payload,
    signatureBase64,
    keyId,
    algorithm,
    timestamp,
  ];
}
