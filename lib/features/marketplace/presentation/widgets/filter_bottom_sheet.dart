import 'package:flutter/material.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/marketplace_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  final MarketplaceFilter initialFilter;
  final ValueChanged<MarketplaceFilter> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late MarketplaceSortOption _selectedSort;
  late bool _inStockOnly;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialFilter.sortOption;
    _inStockOnly = widget.initialFilter.inStockOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(WingerTokens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sort & Filter',
                  style: WingerTokens.headlineLarge(
                      Theme.of(context).colorScheme.onSurface)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: WingerTokens.space16),
          const Text('Sort By:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...MarketplaceSortOption.values.map(
            (option) => RadioListTile<MarketplaceSortOption>(
              title: Text(option.label),
              value: option,
              // ignore: deprecated_member_use
              groupValue: _selectedSort,
              // ignore: deprecated_member_use
              onChanged: (val) {
                if (val != null) setState(() => _selectedSort = val);
              },
            ),
          ),
          const SizedBox(height: WingerTokens.space16),
          SwitchListTile(
            title: const Text('In-Stock Products Only'),
            value: _inStockOnly,
            onChanged: (val) => setState(() => _inStockOnly = val),
          ),
          const SizedBox(height: WingerTokens.space24),
          WingerButton(
            label: 'Apply Filters',
            onPressed: () {
              widget.onApply(
                widget.initialFilter.copyWith(
                  sortOption: _selectedSort,
                  inStockOnly: _inStockOnly,
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
