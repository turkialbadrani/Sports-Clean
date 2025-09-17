import 'package:flutter/material.dart';
import "package:today_smart/features/fixtures/widgets/fixtures_list.dart";

class FixturesListSortButtons extends StatelessWidget {
  final SortType sortType;
  final ValueChanged<SortType> onChanged;

  const FixturesListSortButtons({
    super.key,
    required this.sortType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ToggleButtons(
        isSelected: [
          sortType == SortType.byLeague,
          sortType == SortType.byTime,   // ✅ عدلنا من byDate → byTime
        ],
        onPressed: (index) {
          if (index == 0) {
            onChanged(SortType.byLeague);
          } else {
            onChanged(SortType.byTime);  // ✅ عدلنا هنا بعد
          }
        },
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],              // لون النص الافتراضي
        selectedColor: Colors.white,          // لون النص إذا مختار
        fillColor: const Color(0xFF9C27B0),   // 💜 بنفسجي إذا مختار
        selectedBorderColor: const Color(0xFF9C27B0),
        borderColor: Colors.grey[700]!,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events, size: 18),
                SizedBox(width: 6),
                Text("حسب البطولات"),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 18), // ⏰ أيقونة الوقت
                SizedBox(width: 6),
                Text("حسب الوقت"), // ✅ عدلنا النص
              ],
            ),
          ),
        ],
      ),
    );
  }
}
