import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/community_view_model.dart';
import '../../community/user/poll_preview_view.dart';

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
      context.read<CreatePollViewModel>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreatePollViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);
    final accentColor = const Color(0xFFFF3E63);

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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
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
                      foregroundColor: accentColor,
                      side: BorderSide(color: pinkTheme),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: viewModel.addOptionField,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text("Add Option Field"),
                  ),
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
                  activeColor: accentColor,
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
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (viewModel.questionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a question! 🌸")),
                      );
                      return;
                    }
                    
                    if (viewModel.categoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a category! 🌸")),
                      );
                      return;
                    }

                    // Filter non-empty fields
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
