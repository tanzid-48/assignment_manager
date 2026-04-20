import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _slideUp;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    // Status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 0.95, curve: Curves.easeInOut),
      ),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            children: [
              // Glow circle top center
              Positioned(
                top: -80,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: _fade.value * 0.6,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF534AB7).withOpacity(0.18),
                      ),
                    ),
                  ),
                ),
              ),

              // Small accent glow bottom right
              Positioned(
                bottom: 100,
                right: -40,
                child: Opacity(
                  opacity: _fade.value * 0.3,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF534AB7).withOpacity(0.15),
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Logo
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFF534AB7).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: const Color(0xFF534AB7).withOpacity(0.4),
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF534AB7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // App name
                    Opacity(
                      opacity: _fade.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: const Text(
                          'ASSIGNMENT MANAGER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tagline
                    Opacity(
                      opacity: _fade.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value * 1.3),
                        child: Column(children: [
                          const Text(
                            'Stay Organized. Stay Ahead.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F77DD),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'NEVER MISS A DEADLINE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.3),
                              letterSpacing: 2,
                            ),
                          ),
                        ]),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Progress bar
                    Opacity(
                      opacity: _fade.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progress.value,
                            backgroundColor:
                                Colors.white.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF534AB7)),
                            minHeight: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Made by
                    Opacity(
                      opacity: _fade.value * 0.7,
                      child: Column(children: [
                        Text(
                          'MADE BY',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.25),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tanzid Mondol',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7F77DD),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}