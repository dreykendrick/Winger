import 'package:flutter/material.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../../marketplace/domain/entities/category.dart';

class DiscoveryFeedWidget extends StatelessWidget {
  final List<Category> categories;
  final List<String> popularTags;
  final ValueChanged<String> onTagTap;
  final ValueChanged<Category> onCategoryTap;

  const DiscoveryFeedWidget({
    super.key,
    required this.categories,
    required this.popularTags,
    required this.onTagTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (popularTags.isNotEmpty) ...[
          const Text('Popular Tags',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: popularTags.map((tag) {
              return ActionChip(
                label: Text('# $tag',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: WingerTokens.primaryEmerald)),
                backgroundColor:
                    WingerTokens.primaryEmerald.withValues(alpha: 0.1),
                onPressed: () => onTagTap(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (categories.isNotEmpty) ...[
          const Text('Browse Top Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 70,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () => onCategoryTap(cat),
                borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
                child: WingerCard(
                  child: Row(
                    children: [
                      const Icon(Icons.grid_view_outlined,
                          color: WingerTokens.primaryEmerald),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
