import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Initialize GoogleSignIn with platform-specific configuration
    _googleSignIn = GoogleSignIn(
      // The OAuth client ID of your app. This is required for web.
      clientId:
          kIsWeb
              ? '99002182038-4jhj6bltaim4vp1jk06lgpth4no5ltfk.apps.googleusercontent.com'
              : null,
      scopes: ['email', 'profile'],
    );
  }
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print("Starting Google Sign In process...");
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      print(
        "Current user before sign-in: ${currentUser?.displayName ?? 'Not signed in'}",
      );
      if (kIsWeb) {
        // Web implementation
        print("Using web implementation for Google Sign-In");

        // Configure Google Sign-in for web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        // We'll use popup approach instead of redirect to avoid the Future completion error
        try {
          print("Using popup for Google Sign-In on web");
          final userCredential = await _auth.signInWithPopup(googleProvider);
          print(
            "Firebase web sign in with popup successful: ${userCredential.user?.uid ?? 'null'}",
          );
          return userCredential;
        } catch (e) {
          print("Popup method failed: $e");
          // Check if the error is related to popup being blocked
          if (e.toString().contains('popup')) {
            print("Popup may have been blocked, trying redirect as fallback");
            try {
              // Use redirect as fallback - won't return immediately
              await _auth.signInWithRedirect(googleProvider);
              // The code below won't execute immediately due to page redirect
              return null;
            } catch (redirectError) {
              print("Redirect method also failed: $redirectError");
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      } else {
        // Mobile implementation
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        print("Google Sign In account: ${googleUser?.email ?? 'null'}");
        print(
          "Google Sign In display name: ${googleUser?.displayName ?? 'null'}",
        );

        if (googleUser == null) {
          // User canceled the sign-in flow
          print("User canceled Google Sign In");
          return null;
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        print("Got authentication tokens");
        print("ID Token available: ${googleAuth.idToken != null}");
        print("Access Token available: ${googleAuth.accessToken != null}");

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        print("Created credential for Firebase");

        // Sign in to Firebase with the credential
        final userCredential = await _auth.signInWithCredential(credential);
        print(
          "Firebase sign in successful: ${userCredential.user?.uid ?? 'null'}",
        );
        print("User email: ${userCredential.user?.email}");
        print("User display name: ${userCredential.user?.displayName}");
        print("User phone: ${userCredential.user?.phoneNumber}");

        return userCredential;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      // Rethrow to handle in the UI
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        // Only call Google sign out on mobile platforms
        await _googleSignIn.signOut();
      }
      // Sign out from Firebase Auth on all platforms
      await _auth.signOut();
      print("Successfully signed out");
    } catch (e) {
      print("Error signing out: $e");
      rethrow;
    }
  }
}
