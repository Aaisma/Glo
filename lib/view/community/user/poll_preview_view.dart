import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/community_models.dart';
import '../../../viewmodel/community_view_model.dart';

class PollPreviewView extends StatelessWidget {
  const PollPreviewView({super.key});

  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) {
        buffer.write('ff');
      }
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFFFD8CA1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreatePollViewModel>();
    final accentColor = const Color(0xFFFF3E63);
    final pinkTheme = const Color(0xFFFD8CA1);

    final selectedCategory = viewModel.categories.firstWhere(
      (c) => c.id == viewModel.categoryId,
      orElse: () => CommunityCategory(id: '', name: 'General', color: '#FFE5EC'),
    );

    final categoryColor = _hexToColor(selectedCategory.color);

    // Get non-empty options
    final optionTexts = viewModel.optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Preview Poll",
          style: TextStyle(color: Color(0xFF332B2C), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B2C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined, color: accentColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "This is a preview of your poll. Check all options before publishing! 🌸",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF332B2C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preview card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Author, Category Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: accentColor.withValues(alpha: 0.1),
                              radius: 16,
                              child: Icon(
                                viewModel.isAnonymous ? Icons.face : Icons.person,
                                size: 18,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              viewModel.isAnonymous ? "Anonymous User" : "Anu",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF554B4C),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: categoryColor),
                          ),
                          child: Text(
                            selectedCategory.name,
                            style: TextStyle(
                              color: _hexToColor(selectedCategory.color).withValues(alpha: 0.8) == Colors.white
                                  ? const Color(0xFF332B2C)
                                  : _hexToColor(selectedCategory.color),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question Text
                    Text(
                      viewModel.questionController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Options listing with mock results / checkboxes
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: optionTexts.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: pinkTheme.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFFFDFE),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: pinkTheme, width: 2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionTexts[index],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF332B2C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Meta Row
                    Row(
                      children: [
                        Icon(Icons.poll_outlined, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          "0 votes",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          "0 views",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Actions Row
              Row(
                children: [
                  // Edit Button
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "Edit Poll",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Publish Button
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          await viewModel.publish();
                          if (context.mounted) {
                            // Pop twice to return to feed
                            Navigator.of(context).pop(); // pop preview
                            Navigator.of(context).pop(); // pop create poll form
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Poll created successfully! 🌸"),
                                backgroundColor: Color(0xFFFF3E63),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Publish Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
