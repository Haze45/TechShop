import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/design_system_preview.dart';

final appRouterProvider = Provider<GoRouter>((ref){
  final router = GoRouter(
    initialLocation: '/',

    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state){
          return const DesignSystemPreview();
        },
      )
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'TechShop Architecture Ready',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
