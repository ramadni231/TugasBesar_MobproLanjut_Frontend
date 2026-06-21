import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugas_besar/inti/rute/rute_aplikasi.dart';
import 'package:tugas_besar/umum/utilitas/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0, // 1.0 means bottom of the screen
      end: 0.0,   // 0.0 means center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward();

    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Wait for the animation to finish + a little extra time
    await Future.delayed(const Duration(milliseconds: 4000));

    if (!mounted) return;

    final user = await UserSession().getUser();
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/${user.peran}');
    } else {
      Navigator.of(context).pushReplacementNamed(RuteAplikasi.masuk);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Match the login screen blue background
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Logo animates from bottom of screen to center
                Transform.translate(
                  offset: Offset(0, _slideAnimation.value * (screenHeight / 2)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      LucideIcons.bookOpen,
                      size: 80,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                
                // Text fades in at the center after logo arrives
                Transform.translate(
                  offset: const Offset(0, 120), // Positioned below the logo
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'My Presensiku',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w400, // Thinner font
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sistem Presensi Akademik',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
