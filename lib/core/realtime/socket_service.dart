import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../auth/token_storage.dart';
import '../config/app_config.dart';

class SocketEvent {
  const SocketEvent(this.name, this.data);
  final String name;
  final dynamic data;
}

class SocketService {
  SocketService(this._storage);
  final TokenStorage _storage;
  io.Socket? _socket;
  final _events = StreamController<SocketEvent>.broadcast();
  Stream<SocketEvent> get events => _events.stream;
  bool get connected => _socket?.connected == true;

  static const _eventNames = [
    'notification.created',
    'attendance.checked_in',
    'attendance.checked_out',
    'attendance.corrected',
    'worksheet.reviewed',
    'leave.approved',
    'leave.rejected',
    'checkout.reminder',
    'evaluation.opened',
    'evaluation.scored',
    'evaluation.finalized',
    'meeting.changed',
    'meeting.cancelled',
    'meeting.rescheduled',
    'chat.message.created',
  ];

  Future<void> connect() async {
    final token = await _storage.readAccessToken();
    if (token == null || token.isEmpty) return;
    disconnect();
    final socket = io.io(
      AppConfig.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(kIsWeb ? ['polling', 'websocket'] : ['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );
    _socket = socket;
    for (final name in _eventNames) {
      socket.on(name, (data) => _events.add(SocketEvent(name, data)));
    }
    socket.connect();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _events.close();
  }
}
