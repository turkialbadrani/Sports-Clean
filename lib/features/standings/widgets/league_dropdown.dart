import 'package:flutter/material.dart';
import 'package:today_smart/features/localization/ar_names.dart';
import 'package:today_smart/features/localization/localization_ar.dart';

class LeagueDropdown extends StatelessWidget {
  final int selectedLeague;
  final List<int> activeLeagues;
  final ValueChanged<int> onChanged;

  const LeagueDropdown({
    super.key,
    required this.selectedLeague,
    required this.activeLeagues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Text(
            'الدوري:',
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
                  value: selectedLeague,
                  underline: const SizedBox.shrink(),
                  iconEnabledColor: cs.primary,
                  dropdownColor: cs.surface,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (val) {
                    if (val != null) onChanged(val);
                  },
                  items: activeLeagues.map((id) {
                    final name = arName(
                      kind: ArNameKind.league,
                      id: id,
                      name: LocalizationAr.leagueName(id),
                    );
                    return DropdownMenuItem(
                      value: id,
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
