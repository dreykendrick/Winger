import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/category.dart';

class CategoryCarousel extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const CategoryCarousel({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: WingerTokens.space16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return FilterChip(
              label: const Text('All Products'),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(null),
              selectedColor: WingerTokens.primaryEmerald.withValues(alpha: 0.2),
              checkmarkColor: WingerTokens.primaryEmerald,
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;

          return FilterChip(
            label: Text(category.name),
            selected: isSelected,
            onSelected: (_) =>
                onCategorySelected(isSelected ? null : category.id),
            selectedColor: WingerTokens.primaryEmerald.withValues(alpha: 0.2),
            checkmarkColor: WingerTokens.primaryEmerald,
          );
        },
      ),
    );
  }
}
