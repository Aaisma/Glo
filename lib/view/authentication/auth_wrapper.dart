import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/user_view_model.dart';
import 'authentication_page.dart';
import '../survey_page.dart';
import '../navigation_icon/glo_profile.dart';
import '../../view/dashboard_page.dart';
import '../../view/admin/admin_dashboard_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final user = snapshot.data;
        if (user == null) {
          return const AuthenticationPage();
        }

        return Consumer<UserViewModel>(
          builder: (context, userVM, child) {
            // Need to set userId and fetch user if not already done for this user
            if (userVM.userId != user.uid) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                userVM.setUserId(user.uid);
                userVM.fetchCurrentUser();
              });
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (userVM.loading || userVM.user == null) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final userModel = userVM.user!;
            
            if (userModel.role == 'admin') {
              return const AdminDashboardPage();
            }
            
            if (!userModel.surveyCompleted) {
              return const SurveyPage();
            }
            
            if (!userModel.profileCompleted) {
              return const GloProfileScreen(); // Assuming this is defined
            }

            // User is fully onboarded
            return const DashboardScreen();
          },
        );
      },
    );
  }
}
