import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tech_shop/app/router/app_router.dart';
import 'package:tech_shop/app/theme/app_theme.dart';
import 'package:tech_shop/app/theme/theme_provider.dart';
import 'package:tech_shop/core/services/local_notification_service.dart';

class TechShopApp extends ConsumerStatefulWidget {
  const TechShopApp({super.key});

  @override
  ConsumerState<TechShopApp> createState() => _TechShopAppState();
}

class _TechShopAppState extends ConsumerState<TechShopApp> {
  StreamSubscription<String>? _orderTapSubscription;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = ref.read(appRouterProvider);

    final notificationService = LocalNotificationService.instance;

    _orderTapSubscription = notificationService.orderTapStream.listen((
      orderId,
    ) {
      _router.push('/order/$orderId');
    });

    notificationService.listenToNotificationTaps();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationService.handleInitialMessage();
    });
  }

  @override
  void dispose() {
    _orderTapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'TechShop',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}
