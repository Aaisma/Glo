import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/feedback_view_model.dart';
import 'feedback_form_screen.dart';

class FeedbackTypeScreen extends StatefulWidget {
  const FeedbackTypeScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackTypeScreen> createState() => _FeedbackTypeScreenState();
}

class _FeedbackTypeScreenState extends State<FeedbackTypeScreen> {
  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloBabyPinkBg = const Color(0xFFFFF0F3);

  int _selectedTypeIndex = -1;

  final List<Map<String, String>> _feedbackTypes = [
    {"icon": "💡", "title": "Suggestion", "desc": "Recommend a new feature or improvement"},
    {"icon": "🪲", "title": "Bug Report", "desc": "Report an error, crash, or unexpected issue"},
    {"icon": "💖", "title": "Compliment", "desc": "Share what you love about this feature"},
    {"icon": "✨", "title": "Other", "desc": "Anything else you would like to tell us"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gloBabyPinkBg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: gloDarkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Step 3 of 4",
          style: TextStyle(
            color: gloDarkText.withOpacity(0.4),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "What kind of feedback\nis this? 📝",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: gloDarkText,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "Select a category below to help our development team process your input effectively.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: gloDarkText.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _feedbackTypes.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedTypeIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTypeIndex = index;
                        });
                      },
                      child: AnimatedScale(
                        scale: isSelected ? 1.02 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? gloPrimaryPink : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? gloPrimaryPink.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? gloBabyPinkBg : gloBabyPinkBg.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  _feedbackTypes[index]["icon"]!,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _feedbackTypes[index]["title"]!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? gloPrimaryPink : gloDarkText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _feedbackTypes[index]["desc"]!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: gloDarkText.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? gloPrimaryPink : gloDarkText.withOpacity(0.15),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: BorderSide(color: gloPrimaryPink, width: 1.5),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: gloPrimaryPink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: _selectedTypeIndex != -1
                            ? [
                          BoxShadow(
                            color: gloPrimaryPink.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                            : null,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gloPrimaryPink,
                          disabledBackgroundColor: gloPrimaryPink.withOpacity(0.4),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _selectedTypeIndex == -1
                            ? null
                            : () {
                          context.read<FeedbackViewModel>().updateType(_feedbackTypes[_selectedTypeIndex]["title"]!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedbackFormScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Next",
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}