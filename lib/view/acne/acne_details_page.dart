import 'package:flutter/material.dart';
import 'package:glo/constants/app_colors.dart';

class AcneDetailsPage extends StatelessWidget {
  final String acneType;
  final String description;
  final List<String> commonCauses;
  final List<String> treatmentTips;
  final Widget illustration;

  const AcneDetailsPage({
    super.key,
    required this.acneType,
    required this.description,
    required this.commonCauses,
    required this.treatmentTips,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(acneType, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.pink,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: AppColors.pink,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'acne_$acneType',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: illustration,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("What is it?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.pink)),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 15, color: AppColors.text, height: 1.6),
                  ),
                  const SizedBox(height: 30),

                  const Text("Common Causes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 12),
                  ...commonCauses.map((cause) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 8, color: AppColors.pink),
                        const SizedBox(width: 10),
                        Expanded(child: Text(cause, style: const TextStyle(fontSize: 14, color: AppColors.grey))),
                      ],
                    ),
                  )),

                  const SizedBox(height: 30),

                  const Text("How to Treat It", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightPink,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderPink),
                    ),
                    child: Column(
                      children: treatmentTips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome, size: 18, color: AppColors.pink),
                            const SizedBox(width: 12),
                            Expanded(child: Text(tip, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
