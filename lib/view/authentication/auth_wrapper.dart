import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';
import '../dashboard_page.dart';
import 'authentication_page.dart';
import '../survey_page.dart';
import '../glo_profile/glo_profile.dart';
import 'package:glo/view/glo_admin/admin_dashboard_screen.dart';

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
                // Update other ViewModels with the user ID
                Provider.of<PeriodViewModel>(context, listen: false).setUserId(user.uid);
                Provider.of<OvulationViewModel>(context, listen: false).setUserId(user.uid);
              });
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (userVM.loading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (userVM.user == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                userVM.createDefaultProfile();
              });
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final userModel = userVM.user!;
            
            if (userModel.role == 'admin') {
              return const AdminDashboardScreen();
            }
            
            if (!userModel.surveyCompleted) {
              return const SurveyPage();
            }
            
            if (!userModel.profileCompleted) {
              return const DashboardScreen(initialIndex: 4);
            }

            // User is fully onboarded
            return const DashboardScreen();
          },
        );
      },
    );
  }
}
