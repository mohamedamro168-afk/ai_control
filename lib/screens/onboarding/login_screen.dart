import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);

        // Save user name
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', googleUser.displayName ?? 'صديقي');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      _showError('خطأ في تسجيل الدخول: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131f),
        title: const Text('رقم الهاتف'),
        content: TextField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+201xxxxxxxxx',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (phone) {
            Navigator.pop(ctx);
            _verifyPhoneNumber(phone);
          },
        ),
      ),
    );
  }

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    setState(() => _isLoading = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _handleSuccessfulLogin();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError('خطأ: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _showOTPDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      _showError('خطأ: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOTPDialog(String verificationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131f),
        title: const Text('أدخل كود التحقق'),
        content: TextField(
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(hintText: '000000'),
          onSubmitted: (otp) {
            Navigator.pop(ctx);
            _verifyOTP(verificationId, otp);
          },
        ),
      ),
    );
  }

  Future<void> _verifyOTP(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      _handleSuccessfulLogin();
    } catch (e) {
      _showError('كود خاطئ: $e');
    }
  }

  Future<void> _handleSuccessfulLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser;
    await prefs.setString('user_name', user?.displayName ?? 'صديقي');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'مرحبًا بك 👋',
                style: TextStyle(
                  color: Color(0xFFf0f0f8),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.mail),
                label: const Text('تسجيل الدخول عبر Gmail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7c6ef7),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithPhoneNumber,
                icon: const Icon(Icons.phone),
                label: const Text('تسجيل الدخول عبر رقم الهاتف'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1e1e32),
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFF7c6ef7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
