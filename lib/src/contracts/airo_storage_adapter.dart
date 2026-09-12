import 'dart:async';

import '../key_descriptor.dart';
import '../trusted_device.dart';

abstract interface class AiroStorageAdapter {
  Future<void> saveDeviceRecord(AiroTrustedDeviceRecord record);
  Future<AiroTrustedDeviceRecord?> getDeviceRecord(String deviceId);
  Future<List<AiroTrustedDeviceRecord>> getAllRecords();
  Future<void> removeDeviceRecord(String deviceId);
  Future<void> saveKeyDescriptor(AiroTrustedDeviceKeyDescriptor key);
  Future<AiroTrustedDeviceKeyDescriptor?> getKeyDescriptor(String keyId);
}

class AiroInMemoryStorageAdapter implements AiroStorageAdapter {
  AiroInMemoryStorageAdapter({
    Iterable<AiroTrustedDeviceRecord> initialRecords = const [],
    Iterable<AiroTrustedDeviceKeyDescriptor> initialKeys = const [],
  }) : _records = {for (final r in initialRecords) r.receiverDeviceId: r},
       _keys = {for (final k in initialKeys) k.keyId: k},
       _recordsController =
           StreamController<List<AiroTrustedDeviceRecord>>.broadcast();

  final Map<String, AiroTrustedDeviceRecord> _records;
  final Map<String, AiroTrustedDeviceKeyDescriptor> _keys;
  final StreamController<List<AiroTrustedDeviceRecord>> _recordsController;

  Stream<List<AiroTrustedDeviceRecord>> watchRecords() =>
      _recordsController.stream;

  @override
  Future<void> saveDeviceRecord(AiroTrustedDeviceRecord record) async {
    _records[record.receiverDeviceId] = record;
    _notify();
  }

  @override
  Future<AiroTrustedDeviceRecord?> getDeviceRecord(String deviceId) async {
    return _records[deviceId];
  }

  @override
  Future<List<AiroTrustedDeviceRecord>> getAllRecords() async {
    return _records.values.toList();
  }

  @override
  Future<void> removeDeviceRecord(String deviceId) async {
    _records.remove(deviceId);
    _notify();
  }

  @override
  Future<void> saveKeyDescriptor(AiroTrustedDeviceKeyDescriptor key) async {
    _keys[key.keyId] = key;
  }

  @override
  Future<AiroTrustedDeviceKeyDescriptor?> getKeyDescriptor(String keyId) async {
    return _keys[keyId];
  }

  void _notify() {
    if (!_recordsController.isClosed) {
      _recordsController.add(_records.values.toList());
    }
  }

  Future<void> close() async {
    await _recordsController.close();
  }
}
