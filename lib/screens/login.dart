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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to Shop App',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sign in to continue shopping',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : _buildGoogleSignInButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _signInWithGoogle,
        icon: SvgPicture.asset(
          'assets/images/google_g_logo.svg',
          height: 24,
          width: 24,
        ),
        label: const Text('Sign in with Google'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
