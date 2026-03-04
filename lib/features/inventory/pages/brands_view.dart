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
  final String searchQuery;
  const BrandsView({super.key, required this.isDark, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is InventoryLoaded) {
          final filtered = searchQuery.isEmpty
              ? state.brands
              : state.brands
                    .where((b) => b.name.toLowerCase().contains(searchQuery))
                    .toList();

          if (filtered.isEmpty) {
            return InventoryEmptyState(
              title: searchQuery.isEmpty
                  ? 'No brands yet'
                  : 'No results for "$searchQuery"',
              icon: Icons.branding_watermark_outlined,
              isDark: isDark,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Text(
                  filtered.length == state.brands.length
                      ? '${state.brands.length} brands'
                      : 'Showing ${filtered.length} of ${state.brands.length} brands',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _BrandCard(brand: filtered[index], isDark: isDark);
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _BrandCard extends StatefulWidget {
  final BrandModel brand;
  final bool isDark;

  const _BrandCard({required this.brand, required this.isDark});

  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.brand;
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovering
                ? AppColors.accent.withOpacity(0.5)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? AppColors.accent.withOpacity(0.1)
                  : Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: _hovering ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Image / logo section — white bg for logos
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.white,
                      child: FancyImage(
                        imageUrl: b.logoUrl.isNotEmpty ? b.logoUrl : null,
                        borderRadius: 0,
                        placeholderIcon: Icons.business_rounded,
                        iconSize: 36,
                      ),
                    ),
                    // Hover actions overlay
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: _hovering ? 1.0 : 0.0,
                      child: Container(
                        color: Colors.black.withOpacity(0.25),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CardAction(
                                icon: Icons.edit_rounded,
                                label: 'Edit',
                                color: AppColors.primary,
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => AddBrandDialog(brand: b),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _CardAction(
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete',
                                color: AppColors.error,
                                onTap: () => confirmInventoryDelete(
                                  context: context,
                                  title: 'Delete Brand',
                                  message:
                                      'Delete "${b.name}"? This cannot be undone.',
                                  onConfirm: () => context
                                      .read<InventoryBloc>()
                                      .add(DeleteBrand(b)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info section
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
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
                        b.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Official Partner',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card Action Button ────────────────────────────────────────────────────────
class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
