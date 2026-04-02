// DEPRECATED: This screen is superseded by GoogleSignInScreen.
// Kept as a compile-safe stub; it is no longer reachable via the nav stack.
import 'package:flutter/material.dart';
import 'package:pet/screens/auth/google_sign_in_screen.dart';

/// Redirect stub — navigates immediately to [GoogleSignInScreen].
class EmailAuthScreen extends StatelessWidget {
  const EmailAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoogleSignInScreen();
  }
}
