import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/user_view_model.dart';

class SkinDermaPage extends StatelessWidget {
  const SkinDermaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dermatology Care"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<UserViewModel>(
          builder: (context, userVM, child) {
            // ONBOARDING INITIALIZATION
            final user = userVM.user;
            final visitsDerma = user?.visitsDerma ?? false;
            final lastVisit = user?.lastDermaVisit;
            final formattedDate = lastVisit != null
                ? "${lastVisit.year}-${lastVisit.month.toString().padLeft(2, '0')}-${lastVisit.day.toString().padLeft(2, '0')}"
                : "No visits logged";

            // EXISTING TRACKER FUNCTIONALITY
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.pink,
                            child: Icon(
                              Icons.local_hospital,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Dermatologist Status",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                visitsDerma ? Icons.check_circle : Icons.cancel,
                                color: visitsDerma ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                visitsDerma
                                    ? "Visits a Dermatologist"
                                    : "Does not visit a Dermatologist",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (visitsDerma) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            const Text(
                              "Last Appointment Date",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tips / Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                "Dermatology Care Tips",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            "• Regular check-ups help detect skin issues early.\n"
                            "• Always wear sunscreen with at least SPF 30 daily.\n"
                            "• Keep track of any changes in moles or skin spots.",
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  ElevatedButton(
                    onPressed: () {
                      // Schedule appointment logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Book Consultation",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
