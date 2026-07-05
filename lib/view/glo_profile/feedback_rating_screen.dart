import 'package:flutter/material.dart';

class FeedbackRatingScreen extends StatefulWidget {
  const FeedbackRatingScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackRatingScreen> createState() => _FeedbackRatingScreenState();
}

class _FeedbackRatingScreenState extends State<FeedbackRatingScreen> {
  // Theme Colors matching your design theme from image_37b545.png
  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloLightBg = const Color(0xFFFFF5F7);

  // Track selected star rating state
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gloLightBg,
      resizeToAvoidBottomInset: false, // Prevents screen squishing
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: gloDarkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Step 1 of 4", // Progress indicator tracker text
          style: TextStyle(
            color: gloDarkText.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w600,
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

              // --- SCREEN HEADING ---
              Text(
                "How would you rate your\noverall experience? ✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gloDarkText,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your feedback is highly appreciated and will help us improve your wellness experience.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: gloDarkText.withOpacity(0.6),
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // --- INTERACTIVE STAR RATING ROW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  int starValue = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = starValue;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(
                        starValue <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 54,
                        color: starValue <= _selectedRating ? gloPrimaryPink : gloDarkText.withOpacity(0.2),
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // --- ACTION BUTTONS (Back & Next) ---
              Row(
                children: [
                  // Back Button Outline
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        side: BorderSide(color: gloPrimaryPink, width: 1.5),
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
                  // Next Button Filled
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gloPrimaryPink,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _selectedRating == 0
                          ? null // Disables button until a star rating is picked
                          : () {
                        // This will navigate to Screen 4 (Category Grid selection) next!
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