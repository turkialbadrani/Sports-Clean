import 'package:flutter/material.dart';

class FavoriteSelector {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required Map<int, String> items,
    required Set<int> selectedItems,
    required void Function(Set<int>) onConfirm,
  }) async {
    var tempSelected = Set<int>.from(selectedItems);
    final searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final filteredItems = items.entries
                .where((e) => e.value
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))
                .toList();

            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                height: 450, // ارتفاع مناسب
                child: Column(
                  children: [
                    // 🔍 مربع البحث
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "ابحث...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 10),

                    // ✅ أزرار اختيار/مسح الكل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              tempSelected = items.keys.toSet();
                            });
                          },
                          child: const Text("اختيار الكل"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              tempSelected.clear();
                            });
                          },
                          child: const Text("مسح الكل"),
                        ),
                      ],
                    ),

                    const Divider(),

                    // 📜 القائمة Scrollable
                    Expanded(
                      child: ListView(
                        children: filteredItems.map((entry) {
                          final id = entry.key;
                          final name = entry.value;
                          final isSelected = tempSelected.contains(id);

                          return CheckboxListTile(
                            title: Text(name),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  tempSelected.add(id);
                                } else {
                                  tempSelected.remove(id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("إلغاء"),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: const Text("تم"),
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
