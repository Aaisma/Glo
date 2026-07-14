import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/user_viewmodel.dart';
import 'package:glo/repo/user_repo.dart';
import 'package:glo/view/dashboard_page.dart';
import 'package:glo/view/authentication/authentication_page.dart';
import 'package:glo/view/survey_page.dart';
import 'package:glo/view/glo_profile/glo_profile.dart';
import 'package:glo/view/admin_dashboard_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _initializingUid;
  final Set<String> _initializedUid = {};
  String? _profileCreationError;

  Future<void> _initializeForUser(BuildContext context, UserViewModel userVM, User user) async {
    if (_initializingUid == user.uid || _initializedUid.contains(user.uid)) return;
    _initializingUid = user.uid;

    userVM.setUserId(user.uid);
    await userVM.fetchCurrentUser();

    if (userVM.user == null) {
      try {
        final userRepo = Provider.of<UserRepo>(context, listen: false);
        await userRepo.createDefaultProfile(user);
        await userVM.fetchCurrentUser();
      } catch (e, stackTrace) {
        debugPrint('createDefaultProfile failed for ${user.uid}: $e');
        debugPrintStack(stackTrace: stackTrace);
        if (mounted) _profileCreationError = e.toString();
      }
    }

    _initializedUid.add(user.uid);
    if (mounted) {
      setState(() => _initializingUid = null); // triggers the one rebuild that's now safe to judge
    } else {
      _initializingUid = null;
    }
  }

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
          _initializingUid = null;
          _initializedUid.clear();
          _profileCreationError = null;
          final userVM = Provider.of<UserViewModel>(context, listen: false);
          if (userVM.userId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userVM.clearUser();
            });
          }
          return const AuthenticationPage();
        }

        return Consumer<UserViewModel>(
          builder: (context, userVM, child) {
            if (_initializingUid != user.uid && !_initializedUid.contains(user.uid)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeForUser(context, userVM, user);
              });
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (_initializingUid == user.uid) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (userVM.loading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (userVM.user == null) {
              final creationFailed = _profileCreationError != null;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      creationFailed
                          ? "Couldn't set up your profile: $_profileCreationError"
                          : "Account has been removed by admin",
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                _initializedUid.remove(user.uid);
                _profileCreationError = null;
              });
              return const AuthenticationPage();
            }

            final userModel = userVM.user!;

            if (userModel.role == 'admin') {
              return const AdminDashboardScreen();
            }

            if (userModel.role == 'user') {
              if (!userModel.surveyCompleted) {
                return const SurveyPage();
              }
              if (!userModel.profileCompleted) {
                return const GloProfileScreen();
              }
              return const DashboardScreen();
            }

            // Fallback for empty or other roles
            if (!userModel.surveyCompleted) {
              return const SurveyPage();
            }
            if (!userModel.profileCompleted) {
              return const DashboardScreen(initialIndex: 4);
            }
            return const DashboardScreen();
          },
        );
      },
    );
  }
}