import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../constants/ayd_colour.dart';

/// Fixed category options for Insights polls (kept identical to the
/// article create flow so both use the same category strings).
const List<String> kInsightCategories = [
  'Health & Wellness',
  'Lifestyle',
  'Community',
  'Expert Insights',
];

class CreatePollView extends StatefulWidget {
  const CreatePollView({super.key});

  @override
  State<CreatePollView> createState() => _CreatePollViewState();
}

class _CreatePollViewState extends State<CreatePollView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateInsightPollViewModel>().checkForUnfinishedDraft();
    });
  }

  void _showDraftRecoveryDialog(CreateInsightPollViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Unfinished Draft Found 🌸"),
          content: const Text(
            "Would you like to restore your previous draft or start fresh?",
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await viewModel.discardDraft();
                if (mounted) Navigator.of(ctx).pop();
              },
              child: const Text("Discard Draft", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AydColors.adminInsightButton,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                await viewModel.restoreDraft();
                if (mounted) Navigator.of(ctx).pop();
              },
              child: const Text("Continue Editing", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateInsightPollViewModel>();
    final activeColor = AydColors.adminInsightButton;

    if (viewModel.showDraftRecovery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showDraftRecoveryDialog(viewModel);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Create Poll",
          style: TextStyle(color: Color(0xFF332B2C), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B2C)),
          onPressed: () {
            viewModel.clearForm();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: viewModel.categoryController.text.isEmpty
                    ? null
                    : viewModel.categoryController.text,
                decoration: InputDecoration(
                  hintText: "Select a category",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border, width: 2)),
                ),
                items: kInsightCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  viewModel.categoryController.text = val;
                  viewModel.setCategory(val);
                },
              ),

              const SizedBox(height: 20),

              // Question Input
              const Text(
                "Question",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: viewModel.questionController,
                decoration: InputDecoration(
                  hintText: "If eligible for a work-from-home position, what do you prefer most?",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border, width: 2)),
                ),
              ),

              const SizedBox(height: 24),

              // Options list
              const Text(
                "Options (2 to 6)",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.optionControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: viewModel.optionControllers[index],
                            decoration: InputDecoration(
                              hintText: "Option ${index + 1}",
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border, width: 2)),
                            ),
                          ),
                        ),
                        if (viewModel.canRemoveOption) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => viewModel.removeOptionField(index),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              // Add Option Button
              if (viewModel.canAddOption)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: activeColor,
                      side: BorderSide(color: AydColors.border),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: viewModel.addOptionField,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text("Add Option Field"),
                  ),
                ),

              const SizedBox(height: 24),

              // Publishing Options — same pattern as CreateInsightDetailsView
              const Text(
                "Publishing Options",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("Publish Now", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Make it live immediately"),
                      value: "Publish Now",
                      groupValue: viewModel.publishType,
                      onChanged: (val) {
                        if (val != null) viewModel.setPublishType(val);
                      },
                      activeColor: activeColor,
                    ),
                    const Divider(),
                    RadioListTile<String>(
                      title: const Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        viewModel.scheduleDate == null
                            ? "Choose date & time"
                            : DateFormat('yyyy-MM-dd HH:mm').format(viewModel.scheduleDate!),
                      ),
                      value: "Schedule",
                      groupValue: viewModel.publishType,
                      onChanged: (val) async {
                        if (val == null) return;
                        viewModel.setPublishType(val);
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null && context.mounted) {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            viewModel.setScheduleDate(
                              DateTime(date.year, date.month, date.day, time.hour, time.minute),
                            );
                          }
                        }
                      },
                      activeColor: activeColor,
                    ),
                    const Divider(),
                    RadioListTile<String>(
                      title: const Text("Save as Draft", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Continue editing later"),
                      value: "Save as Draft",
                      groupValue: viewModel.publishType,
                      onChanged: (val) {
                        if (val != null) viewModel.setPublishType(val);
                      },
                      activeColor: activeColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Save / Publish Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    if (viewModel.questionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a question! 🌸")),
                      );
                      return;
                    }

                    if (viewModel.categoryController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a category! 🌸")),
                      );
                      return;
                    }

                    int nonEmptyCount = 0;
                    for (var controller in viewModel.optionControllers) {
                      if (controller.text.trim().isNotEmpty) nonEmptyCount++;
                    }

                    if (nonEmptyCount < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter at least 2 options! 🌸")),
                      );
                      return;
                    }

                    if (viewModel.publishType == 'Schedule' && viewModel.scheduleDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please choose a schedule date & time! 🌸")),
                      );
                      return;
                    }

                    if (viewModel.publishType == 'Save as Draft') {
                      await viewModel.autoSaveDraft();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Draft saved successfully! 🌸")),
                        );
                      }
                    } else {
                      await viewModel.publish();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              viewModel.publishType == 'Schedule'
                                  ? "Poll scheduled successfully! 🌸"
                                  : "Poll published successfully! 🌸",
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    viewModel.publishType == 'Save as Draft'
                        ? "Save Draft"
                        : (viewModel.publishType == 'Schedule' ? "Schedule Now" : "Publish Now"),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}