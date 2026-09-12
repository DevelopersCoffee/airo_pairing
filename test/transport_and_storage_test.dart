import 'package:airo_pairing/airo_pairing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transport Layer & Storage Adapter Contracts Tests', () {
    test('AiroNetworkMessage serializes and deserializes cleanly', () {
      final now = DateTime.utc(2026, 9, 12, 12, 0, 0);
      final msg = AiroNetworkMessage(
        action: 'CHALLENGE_INIT',
        payload: {'challengeId': 'ch-100', 'receiverDeviceId': 'tv-01'},
        timestamp: now,
      );

      final json = msg.toJson();
      final recovered = AiroNetworkMessage.fromJson(json);

      expect(recovered, equals(msg));
      expect(recovered.action, equals('CHALLENGE_INIT'));
    });

    test(
      'AiroInMemoryTransportLayer dispatches messages between paired endpoints',
      () async {
        final (clientTransport, serverTransport) =
            AiroInMemoryTransportLayer.createPair();

        final receivedByServer = <AiroNetworkMessage>[];
        final receivedByClient = <AiroNetworkMessage>[];

        serverTransport.incomingMessages.listen(receivedByServer.add);
        clientTransport.incomingMessages.listen(receivedByClient.add);

        final now = DateTime.utc(2026, 9, 12, 12, 0, 0);
        final clientMsg = AiroNetworkMessage(
          action: 'PING',
          payload: {'sender': 'client'},
          timestamp: now,
        );

        await clientTransport.send(clientMsg);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedByServer.length, equals(1));
        expect(receivedByServer.first, equals(clientMsg));

        final serverMsg = AiroNetworkMessage(
          action: 'PONG',
          payload: {'sender': 'server'},
          timestamp: now,
        );
        await serverTransport.send(serverMsg);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedByClient.length, equals(1));
        expect(receivedByClient.first, equals(serverMsg));

        await clientTransport.close();
        await serverTransport.close();
      },
    );

    test(
      'AiroInMemoryStorageAdapter persists and watches relationship records',
      () async {
        final storage = AiroInMemoryStorageAdapter();
        final now = DateTime.utc(2026, 9, 12, 12, 0, 0);

        final record = AiroTrustedDeviceRecord(
          relationshipId: 'rel-1',
          controllerDeviceId: 'ctrl-1',
          receiverDeviceId: 'tv-1',
          controllerRole: AiroDeviceRole.mobileController,
          receiverRole: AiroDeviceRole.tvReceiver,
          scopes: {AiroPairingScope.playbackControl},
          createdAt: now,
        );

        final watchedUpdates = <List<AiroTrustedDeviceRecord>>[];
        storage.watchRecords().listen(watchedUpdates.add);

        await storage.saveDeviceRecord(record);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final retrieved = await storage.getDeviceRecord('tv-1');
        expect(retrieved, equals(record));

        final all = await storage.getAllRecords();
        expect(all.length, equals(1));
        expect(watchedUpdates.length, equals(1));

        await storage.removeDeviceRecord('tv-1');
        final emptyCheck = await storage.getDeviceRecord('tv-1');
        expect(emptyCheck, isNull);

        await storage.close();
      },
    );
  });
}
