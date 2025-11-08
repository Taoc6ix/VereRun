import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final userId = await DatabaseHelper.instance.getCurrentUserId();
    
    if (!mounted) return;
    
    if (userId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'VereRun',
          style: TextStyle(
            fontFamily: 'FugazOne',
            fontSize: 48,
            fontStyle: FontStyle.italic,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}