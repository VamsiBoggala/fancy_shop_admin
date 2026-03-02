import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/orders/pages/orders_page.dart';
import '../../features/inventory/pages/inventory_page.dart';
import '../../features/support/pages/support_page.dart';
import '../../features/chat/pages/chat_support_page.dart';
import '../../features/coupons/pages/coupons_page.dart';
import '../../features/banners/pages/banners_page.dart';
import '../../features/offers/pages/offers_page.dart';
import '../../features/popular_items/pages/popular_items_page.dart';
import '../../shared/widgets/main_layout.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return GoRouter(
      initialLocation: AppConstants.routeLogin,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final isLoggedIn = authBloc.state is AuthAuthenticated;
        final isLoginRoute = state.matchedLocation == AppConstants.routeLogin;

        if (!isLoggedIn && !isLoginRoute) return AppConstants.routeLogin;
        if (isLoggedIn && isLoginRoute) return AppConstants.routeDashboard;
        return null;
      },
      routes: [
        GoRoute(
          path: AppConstants.routeLogin,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(
              path: AppConstants.routeDashboard,
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: AppConstants.routeOrders,
              name: 'orders',
              builder: (context, state) => const OrdersPage(),
            ),
            GoRoute(
              path: AppConstants.routeInventory,
              name: 'inventory',
              builder: (context, state) => const InventoryPage(),
            ),
            GoRoute(
              path: AppConstants.routeSupport,
              name: 'support',
              builder: (context, state) => const SupportPage(),
            ),
            GoRoute(
              path: AppConstants.routeChat,
              name: 'chat',
              builder: (context, state) => const ChatSupportPage(),
            ),
            GoRoute(
              path: AppConstants.routeCoupons,
              name: 'coupons',
              builder: (context, state) => const CouponsPage(),
            ),
            GoRoute(
              path: AppConstants.routeBanners,
              name: 'banners',
              builder: (context, state) => const BannersPage(),
            ),
            GoRoute(
              path: AppConstants.routeOffers,
              name: 'offers',
              builder: (context, state) => const OffersPage(),
            ),
            GoRoute(
              path: AppConstants.routePopularItems,
              name: 'popular-items',
              builder: (context, state) => const PopularItemsPage(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
    );
  }
}

/// A [ChangeNotifier] that triggers when a [Stream] emits a value.
/// Used to refresh [GoRouter] when [AuthBloc] state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
