import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../widgets/inventory_widgets.dart';
import '../widgets/add_brand_dialog.dart';
import '../domain/models/brand_model.dart';
import '../../../shared/widgets/fancy_image.dart';

class BrandsView extends StatelessWidget {
  final bool isDark;
  const BrandsView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InventoryLoaded) {
          if (state.brands.isEmpty) {
            return InventoryEmptyState(
              title: 'No brands found',
              icon: Icons.branding_watermark_outlined,
              isDark: isDark,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(28),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 0.8,
            ),
            itemCount: state.brands.length,
            itemBuilder: (context, index) {
              final brand = state.brands[index];
              return _BrandCard(brand: brand, isDark: isDark);
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandModel brand;
  final bool isDark;

  const _BrandCard({required this.brand, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Image Section (3 parts)
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors
                        .white, // Brands often have transparent/white logos
                    child: FancyImage(
                      imageUrl: brand.logoUrl,
                      borderRadius: 0,
                      placeholderIcon: Icons.business_rounded,
                      iconSize: 40,
                    ),
                  ),
                  // Action Buttons Overlay (Edit & Delete)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButtonOverlay(
                          icon: Icons.edit_rounded,
                          color: AppColors.primary,
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => AddBrandDialog(brand: brand),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButtonOverlay(
                          icon: Icons.close_rounded,
                          color: AppColors.error,
                          onTap: () => confirmInventoryDelete(
                            context: context,
                            title: 'Delete Brand',
                            message:
                                'Are you sure you want to delete "${brand.name}"?',
                            onConfirm: () => context.read<InventoryBloc>().add(
                              DeleteBrand(brand),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Name Section (1 part)
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Official Partner',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
