import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/insight_view_model.dart';

class CreateInsightPreviewView extends StatelessWidget {
  final Color activeColor;
  const CreateInsightPreviewView({super.key, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateInsightViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Preview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 12),

          // Compiled Article Card Preview
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    viewModel.coverImage,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 160, color: const Color(0xFFFFE5EC)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            viewModel.category.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFFF3E63),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          viewModel.titleController.text.isEmpty ? "Untitled Article" : viewModel.titleController.text,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          viewModel.summaryController.text.isEmpty
                              ? "No summary provided."
                              : viewModel.summaryController.text,
                          style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.contentController.text.isEmpty
                              ? "No content body written yet."
                              : viewModel.contentController.text,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Bottom buttons
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
                onPressed: () => viewModel.setStep(1),
                child: const Text("<- Back"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                onPressed: () async {
                  await viewModel.publish();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          viewModel.publishType == 'Schedule'
                              ? "Insight scheduled successfully! 🌸"
                              : "Insight published successfully! 🌸",
                        ),
                      ),
                    );
                  }
                },
                child: Text(viewModel.publishType == 'Schedule' ? "Schedule Now" : "Publish New"),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
