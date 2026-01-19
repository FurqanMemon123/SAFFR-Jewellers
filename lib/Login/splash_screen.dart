import 'package:flutter/material.dart';
import 'package:jewellery_app/Login/Wrapper.dart';
import '../../utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
// Wrapper file ko yahan import karna mat bhoolna, example:
// import '../wrapper.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    // Auth logic hata di hai, ab yeh sirf timer ke baad Wrapper par jayega
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          // Yahan apni Wrapper class call karo
          MaterialPageRoute(builder: (_) => const Wrapper()), 
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diamond,
                  size: 70,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "SAFFR JEWELLERS",
                style: GoogleFonts.playfairDisplay(
                  textStyle: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Elegance • Beauty • Luxury",
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    letterSpacing: 1.2,
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