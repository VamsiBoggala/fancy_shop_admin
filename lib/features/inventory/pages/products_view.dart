import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../widgets/inventory_widgets.dart';
import '../widgets/add_product_dialog.dart';
import '../domain/models/product_model.dart';
import '../../../shared/widgets/fancy_image.dart';

class ProductsView extends StatefulWidget {
  final bool isDark;
  final String searchQuery;
  const ProductsView({super.key, required this.isDark, this.searchQuery = ''});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String _sortBy = 'name';
  bool _sortAsc = true;

  List<ProductModel> _sort(List<ProductModel> list) {
    final sorted = List<ProductModel>.from(list);
    sorted.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'price':
          cmp = a.price.compareTo(b.price);
          break;
        case 'stock':
          cmp = a.stockQuantity.compareTo(b.stockQuantity);
          break;
        case 'brand':
          cmp = a.brandName.compareTo(b.brandName);
          break;
        default:
          cmp = a.name.compareTo(b.name);
      }
      return _sortAsc ? cmp : -cmp;
    });
    return sorted;
  }

  void _onSort(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAsc = !_sortAsc;
      } else {
        _sortBy = column;
        _sortAsc = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is InventoryError) {
          return Center(child: Text(state.message));
        }
        if (state is InventoryLoaded) {
          final filtered = widget.searchQuery.isEmpty
              ? state.products
              : state.products.where((p) {
                  return p.name.toLowerCase().contains(widget.searchQuery) ||
                      p.brandName.toLowerCase().contains(widget.searchQuery) ||
                      p.categoryName.toLowerCase().contains(widget.searchQuery);
                }).toList();

          final sorted = _sort(filtered);

          if (sorted.isEmpty) {
            return InventoryEmptyState(
              title: widget.searchQuery.isEmpty
                  ? 'No products yet'
                  : 'No results for "${widget.searchQuery}"',
              icon: Icons.inventory_2_outlined,
              isDark: widget.isDark,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary bar
              _SummaryBar(
                isDark: widget.isDark,
                count: sorted.length,
                total: state.products.length,
                label: 'products',
              ),
              // Table
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: _ProductTable(
                    products: sorted,
                    isDark: widget.isDark,
                    sortBy: _sortBy,
                    sortAsc: _sortAsc,
                    onSort: _onSort,
                  ),
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

// ── Summary Bar ───────────────────────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  final bool isDark;
  final int count;
  final int total;
  final String label;

  const _SummaryBar({
    required this.isDark,
    required this.count,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFiltered = count != total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          Text(
            isFiltered ? 'Showing $count of $total $label' : '$total $label',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (isFiltered) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Filtered',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Product Table ─────────────────────────────────────────────────────────────
class _ProductTable extends StatelessWidget {
  final List<ProductModel> products;
  final bool isDark;
  final String sortBy;
  final bool sortAsc;
  final ValueChanged<String> onSort;

  const _ProductTable({
    required this.products,
    required this.isDark,
    required this.sortBy,
    required this.sortAsc,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final headerBg = isDark
        ? AppColors.darkSurfaceVariant
        : const Color(0xFFF9FAFB);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          Container(
            color: headerBg,
            child: Row(
              children: [
                _ColHeader(
                  label: 'Product',
                  flex: 4,
                  sortKey: 'name',
                  sortBy: sortBy,
                  sortAsc: sortAsc,
                  onSort: onSort,
                ),
                _ColHeader(
                  label: 'Category',
                  flex: 2,
                  sortKey: null,
                  sortBy: sortBy,
                  sortAsc: sortAsc,
                  onSort: onSort,
                ),
                _ColHeader(
                  label: 'Brand',
                  flex: 2,
                  sortKey: 'brand',
                  sortBy: sortBy,
                  sortAsc: sortAsc,
                  onSort: onSort,
                ),
                _ColHeader(
                  label: 'Price',
                  flex: 2,
                  sortKey: 'price',
                  sortBy: sortBy,
                  sortAsc: sortAsc,
                  onSort: onSort,
                ),
                _ColHeader(
                  label: 'Discount',
                  flex: 2,
                  sortKey: null,
                  sortBy: sortBy,
                  sortAsc: sortAsc,
                  onSort: onSort,
                ),
                _ColHeader(
                  label: 'Stock',
                  flex: 2,
                  sortKey: 'stock',
                  sortBy: sortBy,
                  sortAsc: sortAsc,
                  onSort: onSort,
                ),
                const SizedBox(width: 80), // actions
              ],
            ),
          ),
          const Divider(height: 1),
          // Rows
          ...products.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final isEven = i.isEven;
            return Column(
              children: [
                _ProductRow(product: p, isDark: isDark, isEven: isEven),
                if (i < products.length - 1)
                  Divider(height: 1, color: border.withOpacity(0.5)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Column Header ─────────────────────────────────────────────────────────────
class _ColHeader extends StatelessWidget {
  final String label;
  final int flex;
  final String? sortKey;
  final String sortBy;
  final bool sortAsc;
  final ValueChanged<String> onSort;

  const _ColHeader({
    required this.label,
    required this.flex,
    required this.sortKey,
    required this.sortBy,
    required this.sortAsc,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = sortKey != null && sortBy == sortKey;

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: sortKey != null ? () => onSort(sortKey!) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isActive
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                ),
              ),
              if (sortKey != null) ...[
                const SizedBox(width: 4),
                Icon(
                  isActive
                      ? (sortAsc
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded)
                      : Icons.unfold_more_rounded,
                  size: 13,
                  color: isActive
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkTextHint
                            : AppColors.lightTextHint),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Product Row ───────────────────────────────────────────────────────────────
class _ProductRow extends StatefulWidget {
  final ProductModel product;
  final bool isDark;
  final bool isEven;

  const _ProductRow({
    required this.product,
    required this.isDark,
    required this.isEven,
  });

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isDark = widget.isDark;

    final rowBg = _hovering
        ? (isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.primary.withOpacity(0.03))
        : (widget.isEven
              ? Colors.transparent
              : (isDark
                    ? Colors.white.withOpacity(0.01)
                    : Colors.black.withOpacity(0.01)));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: rowBg,
        child: Row(
          children: [
            // Product column: image + name
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: FancyImage(
                          imageUrl: p.imageUrl,
                          borderRadius: 8,
                          placeholderIcon: Icons.inventory_2_rounded,
                          iconSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${p.id.length > 8 ? p.id.substring(0, 8) : p.id}…',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextHint
                                  : AppColors.lightTextHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Category
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  p.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ),
            // Brand
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Price
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '₹${p.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ),
            // Discount
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: p.discount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${p.discount.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      )
                    : Text(
                        '—',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.lightTextHint,
                        ),
                      ),
              ),
            ),
            // Stock — quick +/- stepper
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _StockStepper(product: p, isDark: isDark),
              ),
            ),
            // Actions
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RowAction(
                    icon: Icons.edit_rounded,
                    color: AppColors.primary,
                    tooltip: 'Edit',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AddProductDialog(product: p),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _RowAction(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    tooltip: 'Delete',
                    onTap: () => confirmInventoryDelete(
                      context: context,
                      title: 'Delete Product',
                      message: 'Are you sure you want to delete "${p.name}"?',
                      onConfirm: () =>
                          context.read<InventoryBloc>().add(DeleteProduct(p)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Row Action Button ─────────────────────────────────────────────────────────
class _RowAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _RowAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_RowAction> createState() => _RowActionState();
}

class _RowActionState extends State<_RowAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _hover
                  ? widget.color.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}

// ── Stock Stepper ─────────────────────────────────────────────────────────────
class _StockStepper extends StatelessWidget {
  final ProductModel product;
  final bool isDark;

  const _StockStepper({required this.product, required this.isDark});

  Color get _stockColor {
    if (product.stockQuantity == 0) return AppColors.error;
    if (product.stockQuantity < 10) return AppColors.warning;
    return AppColors.success;
  }

  Color get _stockBg {
    if (product.stockQuantity == 0) return AppColors.error.withOpacity(0.1);
    if (product.stockQuantity < 10) return AppColors.warning.withOpacity(0.1);
    return AppColors.success.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    final stock = product.stockQuantity;
    final canDecrement = stock > 0;

    // Read pending status from BLoC state
    final state = context.watch<InventoryBloc>().state;
    final isPending =
        state is InventoryLoaded && state.pendingStockIds.contains(product.id);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrease button — replaced by mini loader when syncing
        isPending
            ? _SyncingPlaceholder(isDark: isDark)
            : _StepButton(
                icon: Icons.remove_rounded,
                enabled: canDecrement,
                isDark: isDark,
                onTap: canDecrement
                    ? () => context.read<InventoryBloc>().add(
                        AdjustProductStock(product.id, -1),
                      )
                    : null,
              ),
        const SizedBox(width: 6),
        // Stock badge — slightly dimmed while syncing
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isPending ? 0.6 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _stockBg,
              borderRadius: BorderRadius.circular(6),
              border: isPending
                  ? Border.all(color: AppColors.primary.withOpacity(0.4))
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                key: ValueKey(stock),
                stock == 0 ? 'Out' : '$stock',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _stockColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Increase button — replaced by mini loader when syncing
        isPending
            ? const SizedBox(width: 26)
            : _StepButton(
                icon: Icons.add_rounded,
                enabled: true,
                isDark: isDark,
                onTap: () => context.read<InventoryBloc>().add(
                  AdjustProductStock(product.id, 1),
                ),
              ),
      ],
    );
  }
}

class _StepButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback? onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _press;
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.enabled) _press.reverse();
  }

  void _onTapUp(_) {
    if (widget.enabled) _press.forward();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled
        ? AppColors.primary
        : (widget.isDark ? AppColors.darkTextHint : AppColors.lightTextHint);

    return ScaleTransition(
      scale: _scale,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) {
          setState(() => _hover = false);
          _press.forward();
        },
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: () => _press.forward(),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _hover && widget.enabled
                  ? color.withOpacity(0.12)
                  : (widget.isDark
                        ? AppColors.darkSurfaceVariant
                        : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _hover && widget.enabled
                    ? color.withOpacity(0.4)
                    : (widget.isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
              ),
            ),
            child: Icon(widget.icon, size: 14, color: color),
          ),
        ),
      ),
    );
  }
}

// ── Syncing Placeholder ───────────────────────────────────────────────────────
/// A 26×26 placeholder matching the step-button size, showing a mini spinner
/// while the stock delta is being written to Firestore.
class _SyncingPlaceholder extends StatelessWidget {
  final bool isDark;
  const _SyncingPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: CircularProgressIndicator(
          strokeWidth: 1.8,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
