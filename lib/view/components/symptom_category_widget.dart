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
                imagePath: item['imagePath'],
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
  final String? imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final double itemWidth;

  const SymptomItemWidget({
    super.key,
    required this.name,
    required this.icon,
    this.imagePath,
    required this.isSelected,
    required this.onTap,
    this.itemWidth = 85.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: itemWidth - 10,
              height: itemWidth - 10,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF6ECE4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isSelected ? Colors.pinkAccent.withValues(alpha: 0.1) : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.pinkAccent : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                ],
              ),
              child: imagePath != null
                  ? Image.asset(imagePath!, fit: BoxFit.contain)
                  : Icon(
                      icon,
                      color: isSelected ? Colors.pinkAccent : const Color(0xFF8C7D73),
                      size: (itemWidth - 10) / 2,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.pinkAccent : const Color(0xFF8C7D73),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
