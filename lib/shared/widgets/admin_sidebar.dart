import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;

  const AdminSidebar({super.key, required this.currentRoute});

  static final List<_NavItem> _items = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppConstants.routeDashboard,
    ),
    _NavItem(
      label: 'Orders',
      icon: Icons.receipt_long_rounded,
      route: AppConstants.routeOrders,
    ),
    _NavItem(
      label: 'Inventory',
      icon: Icons.inventory_2_rounded,
      route: AppConstants.routeInventory,
    ),
    _NavItem(
      label: 'Support Tickets',
      icon: Icons.support_agent_rounded,
      route: AppConstants.routeSupport,
    ),
    _NavItem(
      label: 'Live Chat',
      icon: Icons.chat_bubble_rounded,
      route: AppConstants.routeChat,
    ),
    _NavItem(
      label: 'Coupons',
      icon: Icons.local_offer_rounded,
      route: AppConstants.routeCoupons,
    ),
    _NavItem(
      label: 'Banners',
      icon: Icons.image_rounded,
      route: AppConstants.routeBanners,
    ),
    _NavItem(
      label: 'Top Offers',
      icon: Icons.bolt_rounded,
      route: AppConstants.routeOffers,
    ),
    _NavItem(
      label: 'Popular Items',
      icon: Icons.trending_up_rounded,
      route: AppConstants.routePopularItems,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark ? AppColors.darkSidebar : AppColors.lightSidebar;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.40 : 0.20),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KLV Enterprises',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSidebarText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Divider ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white.withOpacity(0.10), height: 1),
          ),
          const SizedBox(height: 12),

          // ── Section label ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ),

          // ── Nav Items ──────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isActive = currentRoute == item.route;
                return _NavTile(
                  item: item,
                  isActive: isActive,
                  onTap: () => context.go(item.route),
                );
              },
            ),
          ),

          // ── Bottom: Logout ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(color: Colors.white.withOpacity(0.10), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            child: _NavTile(
              item: _NavItem(
                label: 'Sign Out',
                icon: Icons.logout_rounded,
                route: AppConstants.routeLogin,
              ),
              isActive: false,
              isLogout: true,
              onTap: () {
                context.read<AuthBloc>().add(const AuthSignedOut());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool isLogout;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.isActive
              ? AppColors.primary.withOpacity(0.25)
              : _hovering
              ? Colors.white.withOpacity(0.07)
              : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  // Active indicator bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: widget.isActive
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    widget.item.icon,
                    size: 20,
                    color: widget.isLogout
                        ? AppColors.error.withOpacity(0.80)
                        : widget.isActive
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.55),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: widget.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: widget.isLogout
                          ? AppColors.error.withOpacity(0.80)
                          : widget.isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}
