import 'package:flutter/material.dart';

class GroupDropdown extends StatelessWidget {
  final List<String> groupNames;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const GroupDropdown({
    super.key,
    required this.groupNames,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          Text(
            'المجموعة:',
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedIndex,
                  underline: const SizedBox.shrink(),
                  iconEnabledColor: cs.primary,
                  dropdownColor: cs.surface,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  items: List<DropdownMenuItem<int>>.generate(
                    groupNames.length,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(groupNames[i], overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  onChanged: (val) {
                    if (val != null) onChanged(val);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
