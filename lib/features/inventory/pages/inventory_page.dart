import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';

import '../widgets/add_brand_dialog.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/add_product_dialog.dart';

import '../../../shared/utils/fancy_snackbar.dart';

import 'products_view.dart';
import 'categories_view.dart';
import 'brands_view.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const _tabs = [
    (label: 'Products', icon: Icons.inventory_2_rounded),
    (label: 'Categories', icon: Icons.category_rounded),
    (label: 'Brands', icon: Icons.branding_watermark_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // Use animation value check to only fire when a tab is fully selected,
      // not during the animation frames (avoids mid-flight setState calls).
      if (!_tabController.indexIsChanging &&
          _tabController.index != _activeIndex) {
        setState(() {
          _activeIndex = _tabController.index;
          _searchController.clear();
          _searchQuery = '';
        });
      }
    });
    context.read<InventoryBloc>().add(LoadInventory());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is InventoryError) {
          FancySnackBar.show(
            context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            isDark: isDark,
            tabController: _tabController,
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: (v) =>
                setState(() => _searchQuery = v.toLowerCase().trim()),
            onAddPressed: _showAddDialog,
            tabs: _tabs,
          ),
          Expanded(
            // IndexedStack keeps all children alive → zero rebuild on switch,
            // zero slide animation → perfectly smooth instant tab switching.
            child: IndexedStack(
              index: _activeIndex,
              children: [
                ProductsView(isDark: isDark, searchQuery: _searchQuery),
                CategoriesView(isDark: isDark, searchQuery: _searchQuery),
                BrandsView(isDark: isDark, searchQuery: _searchQuery),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    Widget dialog;
    switch (_tabController.index) {
      case 0:
        dialog = const AddProductDialog();
        break;
      case 1:
        dialog = const AddCategoryDialog();
        break;
      case 2:
        dialog = const AddBrandDialog();
        break;
      default:
        return;
    }
    showDialog(context: context, builder: (_) => dialog);
  }
}

// ── Page Header ───────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final bool isDark;
  final TabController tabController;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;
  final List<({String label, IconData icon})> tabs;

  const _PageHeader({
    required this.isDark,
    required this.tabController,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddPressed,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: title + count chips + add button
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.chartGradient1,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store_mall_directory_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Manage products, categories & brands',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Stats chips
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is! InventoryLoaded) return const SizedBox();
                    return Row(
                      children: [
                        _StatChip(
                          label: 'Products',
                          count: state.products.length,
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Categories',
                          count: state.categories.length,
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Brands',
                          count: state.brands.length,
                          color: AppColors.accent,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 20),
                      ],
                    );
                  },
                ),
                // Add button
                _AddButton(onPressed: onAddPressed),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Search + tabs row
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
            child: Row(
              children: [
                // Tab bar (left)
                Expanded(
                  child: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    splashBorderRadius: BorderRadius.circular(10),
                    indicator: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    labelColor: AppColors.primary,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    padding: EdgeInsets.zero,
                    tabs: [
                      for (final t in tabs)
                        Tab(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(t.icon, size: 16),
                                const SizedBox(width: 6),
                                Text(t.label),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Search bar (right, fixed width)
                _SearchBar(
                  controller: searchController,
                  isDark: isDark,
                  onChanged: onSearchChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
        ],
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Button ────────────────────────────────────────────────────────────────
class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'Add New',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search…',
            hintStyle: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, val, __) => val.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }
}
