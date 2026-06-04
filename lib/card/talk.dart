import 'package:flutter/material.dart';
import '../app_colors.dart';

class TalkCard extends StatelessWidget {
  const TalkCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Talk about your day",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.edit_note,
                color: AppColors.pink,
              ),
            ],
          ),

          const SizedBox(height: 18),

          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
              "Write your thoughts, feelings or anything you want...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text("Add Note"),
          )
        ],
      ),
    );
  }
}