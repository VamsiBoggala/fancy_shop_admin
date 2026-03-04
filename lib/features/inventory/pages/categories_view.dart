import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../widgets/inventory_widgets.dart';
import '../widgets/add_category_dialog.dart';
import '../domain/models/category_model.dart';
import '../../../shared/widgets/fancy_image.dart';

class CategoriesView extends StatelessWidget {
  final bool isDark;
  final String searchQuery;
  const CategoriesView({
    super.key,
    required this.isDark,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is InventoryLoaded) {
          final filtered = searchQuery.isEmpty
              ? state.categories
              : state.categories
                    .where((c) => c.name.toLowerCase().contains(searchQuery))
                    .toList();

          if (filtered.isEmpty) {
            return InventoryEmptyState(
              title: searchQuery.isEmpty
                  ? 'No categories yet'
                  : 'No results for "$searchQuery"',
              icon: Icons.category_outlined,
              isDark: isDark,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Text(
                  filtered.length == state.categories.length
                      ? '${state.categories.length} categories'
                      : 'Showing ${filtered.length} of ${state.categories.length} categories',
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
                    return _CategoryCard(
                      category: filtered[index],
                      isDark: isDark,
                    );
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

class _CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final bool isDark;

  const _CategoryCard({required this.category, required this.isDark});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
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
                ? AppColors.primary.withOpacity(0.4)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? AppColors.primary.withOpacity(0.08)
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
              // Image section
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FancyImage(
                      imageUrl: c.imageUrl,
                      borderRadius: 0,
                      placeholderIcon: Icons.category_rounded,
                      iconSize: 36,
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Actions overlay — shown on hover
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
                                  builder: (_) =>
                                      AddCategoryDialog(category: c),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _CardAction(
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete',
                                color: AppColors.error,
                                onTap: () => confirmInventoryDelete(
                                  context: context,
                                  title: 'Delete Category',
                                  message:
                                      'Delete "${c.name}"? This cannot be undone.',
                                  onConfirm: () => context
                                      .read<InventoryBloc>()
                                      .add(DeleteCategory(c)),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
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
                          Icon(
                            Icons.label_outline_rounded,
                            size: 11,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            c.iconName.isNotEmpty ? c.iconName : 'Category',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
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
