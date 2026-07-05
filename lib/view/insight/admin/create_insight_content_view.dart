import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/insight_view_model.dart';
import 'create_poll_view.dart';
import 'create_insight_details_view.dart';
import 'create_insight_preview_view.dart';
import '../../../constants/ayd_colour.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../viewmodel/image_viewmodel.dart';
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
    final themeColor = AydColors.adminInsightButton;

    // Trigger draft dialog after frame paint if flag set
    if (viewModel.showDraftRecovery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showDraftRecoveryDialog(viewModel);
      });
    }

    return Container(
      decoration: const BoxDecoration(
        color: AydColors.admin,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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

      ),
      body: SafeArea(
        child: Column(
          children: [
            // ProgressBar
            _buildProgressBar(viewModel.currentStep, themeColor),

            const SizedBox(height: 16),

            // Main Body Switcher
            Expanded(
              child: IndexedStack(
                index: viewModel.currentStep,
                children: [
                  _buildStep1Content(viewModel, themeColor),
                  CreateInsightDetailsView(activeColor: themeColor),
                  CreateInsightPreviewView(activeColor: themeColor),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildProgressBar(int step, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressCircle(0, "Content", step > 0, step >= 0, activeColor),
          Expanded(child: Divider(color: step > 0 ? activeColor : Colors.grey.shade300, thickness: 2)),
          _buildProgressCircle(1, "Details", step > 1, step >= 1, activeColor),
          Expanded(child: Divider(color: step > 1 ? activeColor : Colors.grey.shade300, thickness: 2)),
          _buildProgressCircle(2, "Preview", step > 2, step >= 2, activeColor),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border, width: 2)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border, width: 2)),
            ),
          ),
          const SizedBox(height: 16),

          // Cover Image Loader
          const Text("Cover Image", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C))),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final source = await showModalBottomSheet<ImageSource>(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Camera'),
                        onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Gallery'),
                        onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
              );
              
              if (source != null && context.mounted) {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: source);
                if (pickedFile != null && context.mounted) {
                  viewModel.setCoverImage(pickedFile.path);
                }
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                child: _buildCoverImage(viewModel.coverImage),
              ),
            ),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AydColors.border, width: 2)),
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AydColors.adminInsightButton,
                  side: const BorderSide(color: Color(0xFFE4DAF9)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePollView()),
                  );
                },
                child: const Text("Create Poll"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => viewModel.setStep(1),
                child: const Text("Next: Details"),
              ),
            ],
          ),
          const SizedBox(height: 100), // padding for keyboard
      ],
    ));
  }

  Widget _buildCoverImage(String coverImage) {
    if (coverImage.isEmpty) {
      return Image.asset('assets/images/image.png', height: 100, fit: BoxFit.cover);
    } else if (coverImage.startsWith('http')) {
      return Image.network(coverImage, height: 100, fit: BoxFit.cover);
    } else if (coverImage.startsWith('assets/')) {
      return Image.asset(coverImage, height: 100, fit: BoxFit.cover);
    } else {
      return Image.file(File(coverImage), height: 100, fit: BoxFit.cover);
    }
  }
}
