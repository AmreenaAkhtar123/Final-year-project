import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              clipBehavior: Clip.none,
              children: [

                // =========================================================
                // TOP LARGE CIRCLE
                // =========================================================
                //
                // This is intentionally much larger than the screen.
                // Only the lower part of the circle is visible.
                //
                Positioned(
                  top: height * 0.070,
                  left: -width * 0.62,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: width * 2.24,
                      height: width * 2.24,
                      child: CustomPaint(
                        painter: _TopLargeCirclePainter(),
                      ),
                    ),
                  ),
                ),

                // =========================================================
                // TOP RIGHT MINT DOT
                // =========================================================

                Positioned(
                  top: height * 0.077,
                  right: width * 0.22,
                  child: const _DecorativeDot(
                    size: 12,
                  ),
                ),

                // =========================================================
// LOWER LARGE CIRCLE
// =========================================================

                Positioned(
                  bottom: height * -0.1,
                  left: -width * 0.09,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: width * 1.10,
                      height: height * 0.45,
                      child: CustomPaint(
                        painter: _BottomLargeCirclePainter(),
                      ),
                    ),
                  ),
                ),

                // =========================================================
// LOWER LEFT MINT DOT
// =========================================================

                Positioned(
                  left: width * 0.055,
                  bottom: height * 0.165,
                  child: const _DecorativeDot(
                    size: 12,
                  ),
                ),


                // =========================================================
                // BOTTOM LEFT LARGE CIRCLE
                // =========================================================

                Positioned(
                  left: -width * 0.36,
                  bottom: height * 0.35,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: width * 0.37,
                      height: width * 0.37,
                      child: CustomPaint(
                        painter: _BottomLeftCirclePainter(),
                      ),
                    ),
                  ),
                ),



                // =========================================================
                // BOTTOM RIGHT SOFT MINT CIRCLE
                // =========================================================

                Positioned(
                  right: -width * 0.27,
                  bottom: -height * 0.045,
                  child: IgnorePointer(
                    child: Container(
                      width: width * 0.70,
                      height: width * 0.70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: RadialGradient(
                          center: const Alignment(0.25, 0.15),
                          radius: 0.85,
                          colors: [
                            AppColors.mint.withValues(alpha: 0.42),
                            AppColors.lightMint.withValues(alpha: 0.28),
                            AppColors.lightMint.withValues(alpha: 0.08),
                            AppColors.lightMint.withValues(alpha: 0.0),
                          ],
                          stops: const [
                            0.0,
                            0.45,
                            0.75,
                            1.0,
                          ],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withValues(alpha: 0.12),
                            blurRadius: 35,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================================================
                // 3 x 3 DOT GRID
                // =========================================================

                Positioned(
                  right: width * 0.18,
                  bottom: height * 0.145,
                  child: const _DotGrid(),
                ),

                // =========================================================
                // MAIN CONTENT
                // =========================================================

                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.09,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: width * 0.72,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: height * 0.075),

                        const Icon(
                          Icons.favorite_border_rounded,
                          size: 30,
                          color: AppColors.mint,
                          weight: 1,
                        ),

                        SizedBox(height: height * 0.035),

                        const Text(
                          'AI Companion for\na Better You',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.8,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


// ==========================================================================
// TOP LARGE CIRCLE
// ==========================================================================

class _TopLargeCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderMint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}


// ==========================================================================
// BOTTOM LEFT CIRCLE
// ==========================================================================

class _BottomLeftCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderMint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(
      size.width * 0.72,
      size.height * 0.50,
    );

    final radius = size.width * 0.49;

    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}


// ==========================================================================
// DECORATIVE DOT
// ==========================================================================

class _DecorativeDot extends StatelessWidget {
  final double size;

  const _DecorativeDot({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.mint,
        shape: BoxShape.circle,
      ),
    );
  }
}


// ==========================================================================
// 3 x 3 DOT GRID
// ==========================================================================

class _DotGrid extends StatelessWidget {
  const _DotGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
            (_) => Row(
          children: List.generate(
            3,
                (_) => Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(
                  alpha: 0.45,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// LOWER LARGE CIRCLE PAINTER
// =========================================================

class _BottomLargeCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderMint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    path.moveTo(
      size.width * 0.02,
      size.height * 0.35,
    );

    path.cubicTo(
      size.width * 0.25,
      size.height * 0.43,
      size.width * 0.40,
      size.height * 0.47,
      size.width * 0.55,
      size.height * 0.47,
    );

    path.cubicTo(
      size.width * 0.72,
      size.height * 0.47,
      size.width * 0.88,
      size.height * 0.42,
      size.width * 0.98,
      size.height * 0.32,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}