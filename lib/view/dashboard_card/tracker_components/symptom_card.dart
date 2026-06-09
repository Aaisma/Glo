import 'package:flutter/material.dart';
import '../../../model/tracker_theme.dart';

class SymptomOption {
  final String label;
  final IconData icon;

  const SymptomOption(this.label, this.icon);
}

class SymptomCard extends StatelessWidget {
  final String title;
  final List<SymptomOption> options;
  final Set<String> selectedOptions;
  final Function(String) onOptionSelected;
  final bool isSingleChoice;
  final ThemeColors theme;

  const SymptomCard({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onOptionSelected,
    this.isSingleChoice = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option.label);
              return GestureDetector(
                onTap: () => onOptionSelected(option.label),
                child: SizedBox(
                  width: 70, // Fixed width for alignment
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? theme.headerText : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? theme.headerText : const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          option.icon,
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.headerText : const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
