import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceTokenService {
  DeviceTokenService._();

  static final DeviceTokenService instance = DeviceTokenService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  String? _currentUserId;
  bool _started = false;

  Future<void> initialize() async {
    if (_started) return;
    _started = true;

    _currentUserId = _supabase.auth.currentUser?.id;

    // Register the token if the user is already logged in.
    if (_currentUserId != null) {
      await registerCurrentDevice();
    }

    // Register again whenever Firebase refreshes the FCM token.
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
      _saveToken(token);
    });

    // Register a token whenever a user signs in.
    _authSubscription = _supabase.auth.onAuthStateChange.listen((authState) {
      final session = authState.session;

      _currentUserId = session?.user.id;

      if (_currentUserId != null) {
        registerCurrentDevice();
      }
    });
  }

  Future<void> registerCurrentDevice() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) return;

    _currentUserId = userId;

    final token = await _messaging.getToken();

    if (token == null || token.isEmpty) {
      debugPrint('FCM token is not available yet.');
      return;
    }

    await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final userId = _currentUserId;

    if (userId == null) return;

    try {
      await _supabase.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': 'android',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'token');

      debugPrint('FCM device token saved successfully.');
    } catch (error) {
      debugPrint('Unable to save FCM device token: $error');
    }
  }

  /// Remove this device's token before signing out.
  Future<void> removeCurrentDeviceToken() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) return;

    final token = await _messaging.getToken();

    if (token == null || token.isEmpty) return;

    await _supabase
        .from('device_tokens')
        .delete()
        .eq('user_id', userId)
        .eq('token', token);

    _currentUserId = null;

    debugPrint('FCM device token removed.');
  }
}
