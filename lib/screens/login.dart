// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_application/services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      print("Attempting to sign in with Google");
      final UserCredential? userCredential =
          await _authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        print("Sign in successful, user ID: ${userCredential.user?.uid}");
        print(
          "Current state of auth: User signed in: ${FirebaseAuth.instance.currentUser != null}",
        );
        print("User email: ${userCredential.user?.email}");

        // Force a redirect by navigating to the current page
        // This will trigger the router redirect to send the user to the catalog
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          context.go('/catalog');
          print(
            "Explicitly navigated to catalog after successful authentication",
          );
        }
      } else if (mounted) {
        print("Sign in was canceled by user");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign in was canceled')));
      }
    } catch (e) {
      print("Error during sign in: $e");

      // Handle "Future already completed" error gracefully
      if (e.toString().contains('Future already completed')) {
        print(
          "Ignoring Future already completed error - this is expected in some flows",
        );

        // Check if auth was actually successful despite the error
        if (FirebaseAuth.instance.currentUser != null && mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          context.go('/catalog');
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 50),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: SvgPicture.asset(
                      'assets/images/google_g_logo.svg',
                      height: 24,
                    ),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
