import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_refresh_notifier.dart';

final authRefreshNotifierProvider =
Provider<AuthRefreshNotifier>((ref) {
  final notifier = AuthRefreshNotifier();

  ref.onDispose(notifier.dispose);

  return notifier;
});