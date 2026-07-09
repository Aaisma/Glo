import 'package:flutter/material.dart';

class FeedbackSuccessScreen extends StatelessWidget {
  const FeedbackSuccessScreen({Key? key}) : super(key: key);

  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloBabyPinkBg = const Color(0xFFFFF0F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gloBabyPinkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // --- PURPLE CHECKMARK BADGE WITH CONFETTI DECORATIONS ---
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      child: Text(
                        "✨ 🎉 🌟",
                        style: TextStyle(fontSize: 24, color: Colors.amber.withValues(alpha: 0.6)),
                      ),
                    ),
                    Container(
                      width: 110,
                      height: 110,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C4FFF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C4FFF).withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- HEADING TEXT ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Thank You!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900, // Fixed: Changed from .black to .w900
                      color: gloDarkText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("🌸", style: TextStyle(fontSize: 26)),
                ],
              ),
              const SizedBox(height: 24),

              // --- DESCRIPTION BODY ---
              Text(
                "Your feedback has been\nsubmitted successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: gloDarkText.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "You're helping us make GLO\nbetter for every woman ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: gloDarkText.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  const Text("💜", style: TextStyle(fontSize: 16)),
                ],
              ),

              const Spacer(),

              // --- ACTION BUTTON (Done) ---
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: gloPrimaryPink.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gloPrimaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}