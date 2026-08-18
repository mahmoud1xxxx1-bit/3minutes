import 'dart:async';

import 'package:flutter/services.dart';

class RoomInviteService {
  RoomInviteService._();

  static const MethodChannel _channel = MethodChannel(
    'com.threeminutes.game/invites',
  );
  static final StreamController<String> _controller =
      StreamController<String>.broadcast();
  static bool _initialized = false;

  static Stream<String> get roomCodes {
    _ensureInitialized();
    return _controller.stream;
  }

  static Future<String?> takeInitialRoomCode() async {
    _ensureInitialized();
    try {
      final value = await _channel.invokeMethod<String>('getInitialRoomCode');
      return _normalize(value);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'roomInvite') return;
      final code = _normalize(call.arguments as String?);
      if (code != null) _controller.add(code);
    });
  }

  static String? _normalize(String? value) {
    final code = value?.trim().toUpperCase();
    if (code == null || !RegExp(r'^[A-Z0-9]{5}$').hasMatch(code)) {
      return null;
    }
    return code;
  }
}
