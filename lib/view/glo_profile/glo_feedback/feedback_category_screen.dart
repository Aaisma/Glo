import 'package:flutter/material.dart';
import 'feedback_type_screen.dart';

class FeedbackCategoryScreen extends StatefulWidget {
  const FeedbackCategoryScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackCategoryScreen> createState() => _FeedbackCategoryScreenState();
}

class _FeedbackCategoryScreenState extends State<FeedbackCategoryScreen> {
  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloBabyPinkBg = const Color(0xFFFFF0F3);

  int _selectedCategoryIndex = -1;

  final List<Map<String, String>> _categories = [
    {"icon": "📅", "title": "Period Tracker"},
    {"icon": "🥚", "title": "Ovulation"},
    {"icon": "🌸", "title": "Mood Tracker"},
    {"icon": "✨", "title": "Acne Tracker"},
    {"icon": "💧", "title": "Drink Water"},
    {"icon": "💊", "title": "Medication"},
    {"icon": "👩‍⚕️", "title": "Derma Visit"},
    {"icon": "📖", "title": "Journal"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gloBabyPinkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: gloDarkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Step 2 of 4",
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
              const SizedBox(height: 12),
              Text(
                "Which category does your\nfeedback belong to? 🛠️",
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
                  "Select the feature area that you would like to help us improve today.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: gloDarkText.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      child: AnimatedScale(
                        scale: isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected ? gloBabyPinkBg : gloBabyPinkBg.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  _categories[index]["icon"]!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _categories[index]["title"]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? gloPrimaryPink : gloDarkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
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
                        boxShadow: _selectedCategoryIndex != -1
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
                        onPressed: _selectedCategoryIndex == -1
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FeedbackTypeScreen()),
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