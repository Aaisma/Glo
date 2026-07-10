import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/model/feedback_model.dart';
import 'package:glo/viewmodel/feedback_view_model.dart';
import '../../../repo/feedback_repo.dart';
import 'feedback_success_screen.dart';

class FeedbackHistoryScreen extends StatelessWidget {
  const FeedbackHistoryScreen({Key? key}) : super(key: key);

  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloBabyPinkBg = const Color(0xFFFFF0F3);

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
          "Feedback History",
          style: TextStyle(
            color: gloDarkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<FeedbackModel>>(
                  stream: context.read<FeedbackRepo>().getFeedbackStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    final historyItems = snapshot.data ?? [];
                    if (historyItems.isEmpty) {
                      return const Center(child: Text("No feedback yet."));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: historyItems.length,
                      itemBuilder: (context, index) {
                        final item = historyItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.category,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: gloDarkText,
                                        fontSize: 14,
                                      )),
                                  Text(
                                    item.timestamp.toLocal().toString().split(' ')[0],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: gloDarkText.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, thickness: 0.8),
                              Text(
                                item.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: gloDarkText.withOpacity(0.7),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: gloBabyPinkBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.type,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: gloPrimaryPink,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "⭐ ${item.ratingIndex}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: gloDarkText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: gloPrimaryPink.withOpacity(0.3),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackSuccessScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Finish",
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
