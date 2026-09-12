import 'dart:async';
import 'package:equatable/equatable.dart';

import '../enums.dart';

class AiroNetworkMessage extends Equatable {
  const AiroNetworkMessage({
    required this.action,
    required this.payload,
    required this.timestamp,
    this.schemaVersion = kAiroPairingSchemaVersion,
  });

  final String schemaVersion;
  final String action;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'action': action,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AiroNetworkMessage.fromJson(Map<String, dynamic> json) {
    return AiroNetworkMessage(
      schemaVersion:
          (json['schemaVersion'] as String?) ?? kAiroPairingSchemaVersion,
      action: json['action'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [schemaVersion, action, payload, timestamp];
}

abstract interface class AiroTransportLayer {
  Stream<AiroNetworkMessage> get incomingMessages;
  Future<void> send(AiroNetworkMessage message);
  Future<void> initialize();
  Future<void> close();
}

class AiroInMemoryTransportLayer implements AiroTransportLayer {
  AiroInMemoryTransportLayer()
    : _incomingController = StreamController<AiroNetworkMessage>.broadcast();

  AiroInMemoryTransportLayer? _peer;
  final StreamController<AiroNetworkMessage> _incomingController;

  static (AiroInMemoryTransportLayer, AiroInMemoryTransportLayer) createPair() {
    final a = AiroInMemoryTransportLayer();
    final b = AiroInMemoryTransportLayer();
    a._peer = b;
    b._peer = a;
    return (a, b);
  }

  @override
  Stream<AiroNetworkMessage> get incomingMessages => _incomingController.stream;

  @override
  Future<void> send(AiroNetworkMessage message) async {
    final peer = _peer;
    if (peer != null && !peer._incomingController.isClosed) {
      peer._incomingController.add(message);
    }
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {
    await _incomingController.close();
  }
}
