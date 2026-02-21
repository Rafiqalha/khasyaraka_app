import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

/// Sorting Widget - Reorderable list for sorting questions
///
/// User drags items to reorder them in the correct sequence
class SortingWidget extends StatefulWidget {
  final List<String> items;
  final bool isChecked;
  final bool isCorrect;
  final Function(List<String>) onOrderChanged;

  const SortingWidget({
    super.key,
    required this.items,
    required this.isChecked,
    required this.isCorrect,
    required this.onOrderChanged,
  });

  @override
  State<SortingWidget> createState() => _SortingWidgetState();
}

class _SortingWidgetState extends State<SortingWidget> {
  late List<String> _currentOrder;

  @override
  void initState() {
    super.initState();
    // Shuffle items initially (optional - can be controlled by backend)
    _currentOrder = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.hasdukWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isChecked
                  ? (widget.isCorrect
                        ? AppColors.successGreen
                        : AppColors.alertRed)
                  : AppColors.scoutBrown.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    color: AppColors.scoutBrown.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Seret untuk mengurutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.scoutBrown.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: widget.isChecked
                    ? (oldIndex, newIndex) {}
                    : _onReorder,
                children: _currentOrder.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildSortableItem(
                    key: ValueKey(item),
                    index: index,
                    text: item,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (widget.isChecked && widget.isCorrect)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Urutan benar!',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        if (widget.isChecked && !widget.isCorrect)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.cancel, color: AppColors.alertRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Urutan kurang tepat, coba lagi!',
                  style: TextStyle(
                    color: AppColors.alertRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSortableItem({
    required Key key,
    required int index,
    required String text,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.scoutBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.scoutBrown.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.forestGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: AppColors.forestGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.scoutBrown,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: widget.isChecked
            ? null
            : Icon(
                Icons.drag_handle,
                color: AppColors.scoutBrown.withValues(alpha: 0.4),
              ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    setState(() {
      final item = _currentOrder.removeAt(oldIndex);
      _currentOrder.insert(newIndex, item);
    });
    widget.onOrderChanged(_currentOrder);
  }
}
