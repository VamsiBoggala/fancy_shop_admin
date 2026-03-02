import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';

import '../widgets/add_brand_dialog.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/add_product_dialog.dart';

import '../../../shared/widgets/fancy_button.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<InventoryBloc>().add(LoadInventory());
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          _buildIntegratedHeader(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ProductsView(isDark: isDark),
                CategoriesView(isDark: isDark),
                BrandsView(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegratedHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inventory',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              FancyButton(
                label: 'Add New',
                onPressed: () => _showAddDialog(),
                isFullWidth: false,
                height: 44,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            splashBorderRadius: BorderRadius.circular(12),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: AppColors.primary),
              borderRadius: BorderRadius.circular(3),
            ),
            labelColor: AppColors.primary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            padding: const EdgeInsets.only(bottom: 8),
            tabs: const [
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Products'),
                    ],
                  ),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Icon(Icons.category_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Categories'),
                    ],
                  ),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Icon(Icons.branding_watermark_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Brands'),
                    ],
                  ),
                ),
              ),
            ],
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
    showDialog(context: context, builder: (context) => dialog);
  }
}
