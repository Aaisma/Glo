import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/insight_view_model.dart';
import 'create_poll_view.dart';
import 'create_insight_details_view.dart';
import 'create_insight_preview_view.dart';

class CreateInsightViews extends StatefulWidget {
  const CreateInsightViews({super.key});

  @override
  State<CreateInsightViews> createState() => _CreateInsightViewsState();
}

class _CreateInsightViewsState extends State<CreateInsightViews> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CreateInsightViewModel>();
      viewModel.checkForUnfinishedDraft();
    });
  }

  void _showDraftRecoveryDialog(CreateInsightViewModel viewModel) {
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
                backgroundColor: const Color(0xFFFD8CA1),
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
    final viewModel = context.watch<CreateInsightViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);

    // Trigger draft dialog after frame paint if flag set
    if (viewModel.showDraftRecovery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showDraftRecoveryDialog(viewModel);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Create Insight",
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
        actions: [
          TextButton(
            onPressed: () async {
              await viewModel.autoSaveDraft();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Draft saved successfully! 🌸")),
                );
              }
            },
            child: const Text(
              "Save Draft",
              style: TextStyle(color: Color(0xFFFF3E63), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ProgressBar
            _buildProgressBar(viewModel.currentStep, pinkTheme),

            const SizedBox(height: 16),

            // Main Body Switcher
            Expanded(
              child: IndexedStack(
                index: viewModel.currentStep,
                children: [
                  _buildStep1Content(viewModel, pinkTheme),
                  CreateInsightDetailsView(activeColor: pinkTheme),
                  CreateInsightPreviewView(activeColor: pinkTheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int step, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Row(
        children: [
          _buildProgressCircle(0, "Content", step >= 0, step == 0, activeColor),
          _buildProgressLine(step >= 1, activeColor),
          _buildProgressCircle(1, "Details", step >= 1, step == 1, activeColor),
          _buildProgressLine(step >= 2, activeColor),
          _buildProgressCircle(2, "Preview", step >= 2, step == 2, activeColor),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(int num, String label, bool isDone, bool isActive, Color activeColor) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone ? activeColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? activeColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    "${num + 1}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? activeColor : Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF332B2C) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isDone, Color activeColor) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? activeColor : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  Widget _buildStep1Content(CreateInsightViewModel viewModel, Color activeColor) {
    final categories = ["Health & Wellness", "Lifestyle", "Community", "Expert Insights", "Trending"];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.titleController,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: "Morning Rituals That Set a Positive Tone",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // Category
          const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: viewModel.category,
                isExpanded: true,
                onChanged: (val) {
                  if (val != null) viewModel.setCategory(val);
                },
                items: categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          const Text("Summary", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.summaryController,
            maxLength: 160,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Simple morning habits that boost your mood, energy, and focus all day long.",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // Cover Image Loader
          const Text("Cover Image", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 8),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  viewModel.coverImage,
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 100, height: 60, color: const Color(0xFFFFE5EC)),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE5EC),
                  foregroundColor: const Color(0xFFFF3E63),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Simulate image select by picking mock images
                  final images = [
                    'assets/images/stressandsleep.png',
                    'assets/images/aboutus.png',
                    'assets/images/logo.png',
                    'assets/images/journal.png',
                  ];
                  final currentIdx = images.indexOf(viewModel.coverImage);
                  final nextIdx = (currentIdx + 1) % images.length;
                  viewModel.setCoverImage(images[nextIdx]);
                },
                child: const Text("Edit Image"),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content body
          const Text("Article Content", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.contentController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: "Write your article content here...",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0E6FF),
                  foregroundColor: Colors.deepPurple,
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFF3E63)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePollView()),
                  );
                },
                icon: const Icon(Icons.poll_outlined, size: 20),
                label: const Text("Create Poll"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => viewModel.setStep(1),
                child: const Text("Next: Details ->"),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
