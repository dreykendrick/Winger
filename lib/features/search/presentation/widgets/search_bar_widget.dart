import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search products, categories, stores...',
        prefixIcon:
            const Icon(Icons.search, color: WingerTokens.primaryEmerald),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
            IconButton(
              icon: const Icon(Icons.tune, color: WingerTokens.primaryEmerald),
              onPressed: onFilterTap,
            ),
          ],
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WingerTokens.radiusLarge),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
