import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'main_screen.dart';
import 'onboarding_page.dart';

class LoadingPage extends StatefulWidget {
  final bool showOnboarding;
  const LoadingPage({super.key, required this.showOnboarding});

  @override
  State<LoadingPage> createState() => _LoadingPage();
}

class _LoadingPage extends State<LoadingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    Future<void>.delayed(const Duration(milliseconds: 2500)).then((_) {
      if (!mounted) return;
      final route = MaterialPageRoute(
        builder: (_) => widget.showOnboarding ? const OnboardingPage() : MainScreen(),
      );
      Navigator.of(context).pushReplacement(route);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.95),
                  colorScheme.primaryContainer.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Soft bokeh circles
          Positioned(
            top: -80,
            left: -40,
            child: _BlurCircle(color: colorScheme.onPrimary.withOpacity(0.08), size: 220),
          ),
          Positioned(
            bottom: -60,
            right: -30,
            child: _BlurCircle(color: colorScheme.onPrimary.withOpacity(0.06), size: 260),
          ),

          // Content
          FadeTransition(
            opacity: _fadeIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Single compass with filling progress
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => CustomPaint(
                  size: const Size.square(96),
                  painter: _CompassProgressPainter(
                    color: colorScheme.onPrimary,
                    progress: _controller.value,
                  ),
                ),
              ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Travel Guide',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Откройте для себя любимые места',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 64,
            spreadRadius: 24,
          ),
        ],
      ),
    );
  }
}

class _CompassProgressPainter extends CustomPainter {
  final Color color;
  final double progress; // 0.0..1.0
  _CompassProgressPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 6;

    // Background ring
    final ringBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = color.withOpacity(0.25);
    canvas.drawCircle(center, radius, ringBg);

    // Foreground progress arc
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = color;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, ring);

    // Static compass needle
    final needle = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.95);
    final path = Path();
    path.moveTo(center.dx, center.dy - radius + 8);
    path.lineTo(center.dx + 8, center.dy + 4);
    path.lineTo(center.dx, center.dy + 0);
    path.lineTo(center.dx - 8, center.dy + 4);
    path.close();
    canvas.drawPath(path, needle);
  }

  @override
  bool shouldRepaint(covariant _CompassProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// Lazy imports to avoid circular dependencies
// (no-op)