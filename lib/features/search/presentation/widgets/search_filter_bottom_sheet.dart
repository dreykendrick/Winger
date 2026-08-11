import 'package:flutter/material.dart';
import 'package:winger/features/search/domain/entities/search_filter.dart';
import 'package:winger/features/search/domain/entities/search_sort.dart';
import 'package:winger/shared/components/winger_button.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final SearchFilter initialFilter;
  final ValueChanged<SearchFilter> onApply;

  const SearchFilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late SearchSort _selectedSort;
  late bool _inStockOnly;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialFilter.sort;
    _inStockOnly = widget.initialFilter.inStockOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter & Sort Products',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Sort By',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SearchSort.values.map((sort) {
              final isSelected = _selectedSort == sort;
              return ChoiceChip(
                label: Text(sort.label),
                selected: isSelected,
                selectedColor:
                    WingerTokens.primaryEmerald.withValues(alpha: 0.2),
                onSelected: (_) {
                  setState(() => _selectedSort = sort);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('In-Stock Only',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            value: _inStockOnly,
            // ignore: deprecated_member_use
            activeColor: WingerTokens.primaryEmerald,
            onChanged: (val) => setState(() => _inStockOnly = val),
          ),
          const SizedBox(height: 24),
          WingerButton(
            label: 'Apply Filters',
            onPressed: () {
              widget.onApply(
                widget.initialFilter.copyWith(
                  sort: _selectedSort,
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
