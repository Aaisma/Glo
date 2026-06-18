import 'package:flutter/material.dart';
import '../../../constants/ayd_colour.dart';

class SymptomOption {
  final String label;
  final IconData icon;
  final String? imagePath;

  const SymptomOption(this.label, this.icon, {this.imagePath});
}

class SymptomCard extends StatefulWidget {
  final String title;
  final IconData categoryIcon;
  final Color categoryColor;
  final List<SymptomOption> options;
  final Set<String> selectedOptions;
  final bool isSingleChoice;
  final Function(String) onOptionSelected;

  final bool initiallyExpanded;

  const SymptomCard({
    super.key,
    required this.title,
    required this.categoryIcon,
    required this.categoryColor,
    required this.options,
    required this.selectedOptions,
    required this.isSingleChoice,
    required this.onOptionSelected,
    this.initiallyExpanded = false,
  });

  @override
  State<SymptomCard> createState() => _SymptomCardState();
}

class _SymptomCardState extends State<SymptomCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final hasSelections = widget.selectedOptions.isNotEmpty;
    final selectedText = hasSelections 
        ? widget.selectedOptions.join(", ") 
        : "None selected";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AydColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AydColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.categoryIcon, color: widget.categoryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AydColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AydColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSelections && !widget.isSingleChoice)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.selectedOptions.length}',
                    style: TextStyle(
                      color: widget.categoryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
                color: AydColors.textSecondary,
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 12,
                children: widget.options.map((option) {
                  final isSelected = widget.selectedOptions.contains(option.label);
                  return GestureDetector(
                    onTap: () => widget.onOptionSelected(option.label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? widget.categoryColor.withValues(alpha: 0.1) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                              ? widget.categoryColor 
                              : AydColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.label,
                            style: TextStyle(
                              color: isSelected ? widget.categoryColor : AydColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.check_circle, size: 14, color: widget.categoryColor),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
