import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';

import 'app/app.dart';
import 'core/services/device_token_service.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/local_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache.maximumSize = 200;

  PaintingBinding.instance.imageCache.maximumSizeBytes =
      100 * 1024 * 1024;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  Env.validate();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );

  await LocalNotificationService.instance.initialize();

  await LocalNotificationService.instance.requestPermission();
  LocalNotificationService.instance.listenToForegroundMessages();
  await DeviceTokenService.instance.initialize();

  runApp(const ProviderScope(child: TechShopApp()));
}
