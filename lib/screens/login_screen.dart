import 'package:flutter/material.dart';
import 'package:cargoind/core/utils/responsive.dart';
import 'package:cargoind/core/services/auth_service.dart';
import 'package:cargoind/core/theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cargoind/screens/network_test_screen.dart';
import 'package:cargoind/screens/register_screen.dart';
import 'package:cargoind/screens/menu_screen.dart';
import 'package:cargoind/core/services/google_auth_service.dart';

// Extension to provide loginWithGoogle on AuthService if the method is not defined.
// Update the implementation to integrate with your backend (e.g., call an existing
// token-based login method or perform an HTTP request to exchange the Firebase token).
// extension AuthServiceGoogleExt on AuthService {
//   Future<void> loginWithGoogle(String firebaseIdToken) async {
//     // TODO: Replace with real implementation that sends firebaseIdToken to your backend.
//     // Example placeholder: if AuthService has a token-based login, call it here:
//     // await this.loginWithToken(firebaseIdToken);
//     return;
//   }
// }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final authService = AuthService();
    final success = await authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      // Check user role to determine which dashboard to show
      final isAdmin = await authService.isAdmin();

      if (isAdmin) {
        // Navigate to Admin Dashboard
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        // Navigate to Main Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenuRoute(
              username: _usernameController.text,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal. Periksa username dan password.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryRed,
            AppColors.primaryRed,
            AppColors.cream,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Responsive.getPadding(context),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon background
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: SvgPicture.asset(
                              'assets/silog.svg',
                              width: Responsive.isMobile(context) ? 60 : 80,
                              height: Responsive.isMobile(context) ? 60 : 80,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CargoInd',
                                style: TextStyle(
                                  fontSize:
                                      Responsive.isMobile(context) ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cream.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NetworkTestScreen(),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.network_check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Integrated Supply Chain Solution',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.black.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Username field
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'email',
                              prefixIcon: Icon(Icons.person,
                                  color: AppColors.primaryRed),
                              filled: true,
                              fillColor: AppColors.cream.withValues(alpha: 0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon:
                                  Icon(Icons.lock, color: AppColors.primaryRed),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.primaryRed,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppColors.cream.withValues(alpha: 0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                foregroundColor: AppColors.cream,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2)
                                  : const Text('Login',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Google Login
                          const SizedBox(height: 16),

                          // Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              icon: Image.asset(
                                'google/light_logo@4x.png', // Add this icon in assets folder
                                height: 24,
                              ),
                              label: const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: const BorderSide(color: Colors.black26),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                setState(() => _isLoading = true);

//   try {
//     final userCredential = await GoogleAuthService.signInWithGoogle();

//     if (userCredential == null) {
//       throw Exception('Google Sign-In canceled');
//     }

//     final user = userCredential.user;
//     if (user == null) {
//       throw Exception('No Firebase user');
//     }

//
//     final firebaseIdToken = await user.getIdToken(true);

// if (firebaseIdToken == null) {
//   throw Exception('Failed to get Firebase ID Token');
// }

// print('🔧 Firebase ID Token: ${firebaseIdToken.substring(0, 20)}...');

// //
// final authService = AuthService();
// await authService.loginWithGoogle(firebaseIdToken);

//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => MenuRoute(
//           username: user.displayName ?? user.email ?? '',
//         ),
//       ),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Google login gagal: $e'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   } finally {
//     setState(() => _isLoading = false);
//   }
                              },
                            ),
                          ),

                          // Admin Bypass Button (untuk testing)
                          const SizedBox(height: 16),
                          TextButton.icon(
                            icon: const Icon(Icons.admin_panel_settings,
                                size: 20),
                            label: const Text('Login sebagai Admin (Bypass)'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryRed,
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/admin-dashboard');
                            },
                          ),
                          const SizedBox(height: 8),

                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account? ',
                                style: TextStyle(
                                  color: AppColors.black.withValues(alpha: 0.7),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ));
  }
}
