import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/community_view_model.dart';
import 'poll_preview_view.dart';

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
      final viewModel = context.read<CreatePollViewModel>();
      viewModel.loadCategories();
      viewModel.checkForUnfinishedDraft();
    });
  }

  void _showDraftRecoveryDialog(CreatePollViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Recover Draft?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("You have an unsaved poll draft. Would you like to restore it?"),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.discardDraft();
              Navigator.of(ctx).pop();
            },
            child: const Text("Discard", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3E63),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              viewModel.restoreDraft();
              Navigator.of(ctx).pop();
            },
            child: const Text("Restore", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreatePollViewModel>();
    const accentColor = Color(0xFFFF3E63);

    // Show draft recovery dialog if needed
    if (viewModel.showDraftRecovery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDraftRecoveryDialog(viewModel);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Create a Poll",
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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

              // Question
              const Text(
                "Question",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: viewModel.questionController,
                maxLength: 120,
                decoration: InputDecoration(
                  hintText: "What do you want to ask?",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Options",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
                  ),
                  Text(
                    "${viewModel.optionControllers.length}/6",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
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
                            maxLength: 40,
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: "Option ${index + 1}",
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        if (viewModel.canRemoveOption)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => viewModel.removeOptionField(index),
                          ),
                      ],
                    ),
                  );
                },
              ),

              if (viewModel.canAddOption)
                TextButton.icon(
                  onPressed: viewModel.addOptionField,
                  icon: const Icon(Icons.add, color: accentColor),
                  label: const Text("Add Option", style: TextStyle(color: accentColor)),
                ),

              const SizedBox(height: 24),

              // Post Anonymously Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  title: const Text(
                    "Post Anonymously",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                  ),
                  subtitle: const Text("Your username won't be shown publicly"),
                  value: viewModel.isAnonymous,
                  activeThumbColor: accentColor,
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
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (viewModel.questionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a question! 🌸")),
                      );
                      return;
                    }

                    int filledOptions = viewModel.optionControllers.where((c) => c.text.trim().isNotEmpty).length;
                    if (filledOptions < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please provide at least two options! 🌸")),
                      );
                      return;
                    }

                    if (viewModel.categoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a category! 🌸")),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PollPreviewView(),
                      ),
                    );
                  },
                  child: const Text(
                    "Preview Poll",
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
