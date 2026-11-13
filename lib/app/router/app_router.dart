import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/addresses/presentation/screens/addresses_screen.dart';
import '../../features/admin/presentation/screens/add_product_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/providers/admin_providers.dart';
import '../../features/admin/presentation/screens/admin_inventory_screen.dart';
import '../../features/admin/presentation/screens/admin_order_details_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/admin/presentation/screens/admin_reviews_screen.dart';
import '../../features/admin/presentation/screens/admin_stock_history_screen.dart';
import '../../features/admin/presentation/screens/edit_product_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/update_password_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/comparison/presentation/screens/comparison_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/products/domain/entities/product_entity.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/recently_viewed/presentation/screens/recently_viewed_screen.dart';
import '../../features/support/presentation/screens/admin_support_ticket_details_screen.dart';
import '../../features/support/presentation/screens/admin_support_tickets_screen.dart';
import '../../features/support/presentation/screens/create_support_ticket_screen.dart';
import '../../features/support/presentation/screens/my_support_tickets_screen.dart';
import '../../features/support/presentation/screens/support_ticket_details_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import 'auth_refresh_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefreshNotifier = ref.watch(authRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: authRefreshNotifier,

    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final location = state.matchedLocation;

      // Always direct a recovery session to the new-password screen.
      if (authRefreshNotifier.isPasswordRecovery &&
          location != '/update-password') {
        return '/update-password';
      }

      final isPublicRoute =
          location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';

      // Prevent unauthenticated users from accessing private routes.
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Redirect logged-in users away from login and registration.
      if (isLoggedIn && (location == '/login' || location == '/register')) {
        return '/home';
      }

      // Admin-only route protection.
      final isAdminRoute =
          location == '/admin' || location.startsWith('/admin/');

      if (isLoggedIn && isAdminRoute) {
        try {
          final isAdmin = await ref.read(checkAdminRoleProvider).call();

          if (!isAdmin) {
            return '/home';
          }
        } catch (error) {
          // Deny access if the admin check fails.
          return '/home';
        }
      }

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/update-password',
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/product/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;

          return ProductDetailsScreen(productId: productId);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/order/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;

          return OrderDetailsScreen(orderId: orderId);
        },
      ),

      // Admin-only route.
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/products/add',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/admin/products/edit',
        builder: (context, state) {
          final product = state.extra as ProductEntity;

          return EditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/admin/reviews',
        builder: (context, state) => const AdminReviewsScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/admin/orders/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;

          return AdminOrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/support/create',
        builder: (context, state) {
          return const CreateSupportTicketScreen();
        },
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) {
          return const MySupportTicketsScreen();
        },
      ),
      GoRoute(
        path: '/support/:ticketId',
        builder: (context, state) {
          final ticketId = state.pathParameters['ticketId']!;

          return SupportTicketDetailsScreen(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: '/admin/support',
        builder: (context, state) => const AdminSupportTicketsScreen(),
      ),

      GoRoute(
        path: '/admin/support/:ticketId',
        builder: (context, state) {
          final ticketId = state.pathParameters['ticketId']!;

          return AdminSupportTicketDetailsScreen(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: '/compare',
        builder: (context, state) => const ComparisonScreen(),
      ),
      GoRoute(
        path: '/recently-viewed',
        builder: (context, state) => const RecentlyViewedScreen(),
      ),
      GoRoute(
        path: '/admin/inventory',
        builder: (context, state) => const AdminInventoryScreen(),
      ),
      GoRoute(
        path: '/admin/inventory/history/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          final productName = state.extra as String? ?? 'Product';

          return AdminStockHistoryScreen(
            productId: productId,
            productName: productName,
          );
        },
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
});
