import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_empty_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/shimmer_product_card.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../models/product_model.dart';
import '../providers/product_list_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  final String? initialSearch;

  const ProductListScreen({
    super.key,
    this.initialCategoryId,
    this.initialSearch,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch ?? '';
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).applyFilter(
            ProductFilter(
              search: widget.initialSearch,
              categoryId: widget.initialCategoryId,
            ),
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListProvider.notifier).loadMore();
    }
  }

  void _showSortSheet() {
    final current = ref.read(productListProvider).filter.sort;
    showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sıralama',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            _SortTile(
              label: 'En Yeni',
              value: null,
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, '__newest__'),
            ),
            _SortTile(
              label: 'Fiyat: Düşükten Yükseğe',
              value: 'price_asc',
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            _SortTile(
              label: 'Fiyat: Yüksekten Düşüğe',
              value: 'price_desc',
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).then((value) {
      if (value == null) return;
      final filter = ref.read(productListProvider).filter;
      ref.read(productListProvider.notifier).applyFilter(
            value == '__newest__'
                ? filter.copyWith(clearSort: true)
                : filter.copyWith(sort: value),
          );
    });
  }

  void _onSearchSubmitted(String value) {
    final filter = ref.read(productListProvider).filter;
    ref.read(productListProvider.notifier).applyFilter(
          value.trim().isEmpty
              ? filter.copyWith(clearSearch: true)
              : filter.copyWith(search: value.trim()),
        );
  }

  void _selectCategory(String? id) {
    final filter = ref.read(productListProvider).filter;
    ref.read(productListProvider.notifier).applyFilter(
          id == null
              ? filter.copyWith(clearCategory: true)
              : filter.copyWith(categoryId: id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final categories = ref.watch(categoryTreeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ürünler')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'Ürün veya üretici ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchSubmitted('');
                        },
                      ),
              ),
            ),
          ),
          categories.maybeWhen(
            data: (list) => _CategoryFilterBar(
              categories: list.where((c) => c.isRoot).toList(),
              selectedId: state.filter.categoryId,
              onSelect: _selectCategory,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.isLoading
                        ? 'Yükleniyor...'
                        : '${state.total} ürün bulundu',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sıralama',
                  onPressed: _showSortSheet,
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(ProductListState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const ShimmerList();
    }
    if (state.errorMessage != null && state.items.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(productListProvider.notifier).refresh(),
      );
    }
    if (state.items.isEmpty) {
      final search = state.filter.search;
      final emptyMsg = (search?.isNotEmpty ?? false)
          ? '"$search" için sonuç bulunamadı'
          : 'Henüz ürün bulunmuyor';
      return AppEmptyWidget(message: emptyMsg);
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(productListProvider.notifier).refresh(),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 2 : 0),
        itemBuilder: (_, i) {
          if (i >= state.items.length) {
            return const ShimmerProductCard();
          }
          return ProductCard(product: state.items[i]);
        },
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  const _CategoryFilterBar({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return AppCategoryChip(
              label: 'Tümü',
              selected: selectedId == null,
              onTap: () => onSelect(null),
            );
          }
          final c = categories[i - 1];
          return AppCategoryChip(
            label: c.name,
            selected: c.id == selectedId,
            onTap: () => onSelect(c.id),
          );
        },
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final String? value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _SortTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String?>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
