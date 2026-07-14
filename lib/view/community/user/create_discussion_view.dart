import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/community_view_model.dart';
import '../../../constants/ayd_colour.dart';
import 'discussion_preview_view.dart';

class CreateDiscussionView extends StatefulWidget {
  const CreateDiscussionView({super.key});

  @override
  State<CreateDiscussionView> createState() => _CreateDiscussionViewState();
}

class _CreateDiscussionViewState extends State<CreateDiscussionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateDiscussionViewModel>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateDiscussionViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Start a Discussion",
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
              // Category Dropdown
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AydColors.communityCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AydColors.communityButton.withValues(alpha: 0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: viewModel.categoryId,
                    isExpanded: true,
                    hint: const Text(
                      "Select Category",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    items: viewModel.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Text(
                          cat.name,
                          style: const TextStyle(color: Color(0xFF332B2C)),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        viewModel.setCategory(val);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Title",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: viewModel.titleController,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: "Enter discussion title...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: AydColors.communityCardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AydColors.communityButton.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AydColors.communityButton.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AydColors.communityButton, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Content Body
              const Text(
                "Content",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: viewModel.contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: "What would you like to talk about?",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: AydColors.communityCardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AydColors.communityButton.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AydColors.communityButton.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AydColors.communityButton, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Post Anonymously Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AydColors.communityCardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AydColors.communityButton.withValues(alpha: 0.1)),
                ),
                child: SwitchListTile(
                  title: const Text(
                    "Post Anonymously",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                  ),
                  subtitle: const Text("Your username won't be shown publicly"),
                  value: viewModel.isAnonymous,
                  activeThumbColor: AydColors.communityButton,
                  activeTrackColor: AydColors.communityButton.withValues(alpha: 0.3),
                  onChanged: viewModel.toggleAnonymous,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 40),

              // Preview/Publish Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AydColors.communityButton,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (viewModel.titleController.text.trim().isEmpty ||
                        viewModel.contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill in all fields! 💙")),
                      );
                      return;
                    }

                    if (viewModel.categoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a category! 💙")),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DiscussionPreviewView(),
                      ),
                    );
                  },
                  child: const Text(
                    "Preview Post",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
