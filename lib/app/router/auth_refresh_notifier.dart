import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthRefreshNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}