import 'package:flutter/material.dart';

class SymptomCategoryWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Set<String> selectedSymptoms;
  final Function(String) onSymptomToggled;

  const SymptomCategoryWidget({
    super.key,
    required this.title,
    required this.items,
    required this.selectedSymptoms,
    required this.onSymptomToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: items.map((item) {
              final isSelected = selectedSymptoms.contains(item['name']);
              return SymptomItemWidget(
                name: item['name'],
                icon: item['icon'],
                isSelected: isSelected,
                onTap: () => onSymptomToggled(item['name']),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class SymptomItemWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SymptomItemWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.pinkAccent, width: 2)
                  : Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
            ),
            child: Center(
              child: Icon(
                icon,
                color: isSelected ? Colors.pinkAccent : Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 75,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
