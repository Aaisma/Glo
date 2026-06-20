import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/insight_view_model.dart';

class CreateInsightDetailsView extends StatelessWidget {
  final Color activeColor;
  const CreateInsightDetailsView({super.key, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateInsightViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Publishing Options
          const Text("Publishing Options", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: RadioGroup<String>(
              groupValue: viewModel.publishType,
              onChanged: (val) async {
                if (val == null) return;
                viewModel.setPublishType(val);
                if (val == "Schedule") {
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
                }
              },
              child: Column(
                children: [
                  const RadioListTile<String>(
                    title: Text("Publish Now", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Make it live immediately"),
                    value: "Publish Now",
                    activeColor: Color(0xFFFF3E63),
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
                    activeColor: const Color(0xFFFF3E63),
                  ),
                  const Divider(),
                  const RadioListTile<String>(
                    title: Text("Save as Draft", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Continue editing later"),
                    value: "Save as Draft",
                    activeColor: Color(0xFFFF3E63),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Placement Options
          const Text("Placement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text("Featured Insight", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Show in featured header section"),
                  value: viewModel.isFeatured,
                  activeColor: const Color(0xFFFF3E63),
                  onChanged: (val) => viewModel.setFeatured(val!),
                ),
                const Divider(),
                CheckboxListTile(
                  title: const Text("Trending", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Show in trending section"),
                  value: viewModel.isTrending,
                  activeColor: const Color(0xFFFF3E63),
                  onChanged: (val) => viewModel.setTrending(val!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Bottom Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: activeColor),
                  foregroundColor: activeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => viewModel.setStep(0),
                child: const Text("<- Back"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => viewModel.setStep(2),
                child: const Text("Next: Preview ->"),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
