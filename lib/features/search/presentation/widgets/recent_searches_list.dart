import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class RecentSearchesList extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;
  final VoidCallback onClearAll;

  const RecentSearchesList({
    super.key,
    required this.searches,
    required this.onSelect,
    required this.onDelete,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Searches',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            TextButton(
              onPressed: onClearAll,
              child: const Text('Clear All',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searches.map((query) {
            return InputChip(
              label: Text(query, style: const TextStyle(fontSize: 12)),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => onDelete(query),
              onPressed: () => onSelect(query),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(WingerTokens.radiusLarge)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
