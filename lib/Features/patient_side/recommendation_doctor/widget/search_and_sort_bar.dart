import 'package:flutter/material.dart';

class SearchAndSortBar extends StatelessWidget {
  const SearchAndSortBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.onSortPressed,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search by name or specialist',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSortPressed,
            icon: const Icon(Icons.sort_sharp),
          ),
        ],
      ),
    );
  }
}
