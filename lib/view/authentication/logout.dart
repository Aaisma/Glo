import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/auth_viewmodel.dart';
import 'package:glo/viewmodel/user_viewmodel.dart';
import '../authentication/login_screen.dart';

class LogoutDialog {
  static void show(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Capture Navigators and Providers before async work
              final navigator = Navigator.of(parentContext);
              final dialogNavigator = Navigator.of(dialogContext);
              final authVm = parentContext.read<AuthViewModel>();
              
              // We use read to avoid ProviderNotFoundException if UserViewModel isn't at the top of Admin tree
              // Wait, does Admin have UserViewModel? Yes, it's typically injected at the app root.
              
              await authVm.signOut();
              
              if (!parentContext.mounted || !dialogContext.mounted) return;
              
              // Attempt to clear UserViewModel if it exists in the widget tree
              try {
                final userVM = parentContext.read<UserViewModel>();
                userVM.clearUser();
              } catch (_) {
                // If UserViewModel is not provided to the admin tree, ignore
              }

              dialogNavigator.pop(); // Close dialog safely
              navigator.pushNamedAndRemoveUntil(
                '/authWrapper',
                (_) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}