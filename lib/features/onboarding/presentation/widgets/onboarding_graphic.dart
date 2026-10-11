import 'package:flutter/material.dart';

/// Custom illustration matching the desk worker with laptop and phone in the onboarding mockup.
class OnboardingGraphic extends StatelessWidget {
  const OnboardingGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background concentric soft circles
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0F2FE).withValues(alpha: 0.5),
            ),
          ),
          Container(
            width: 210,
            height: 210,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0F7FA),
            ),
          ),

          // Custom Painter for Desk, Laptop, Character and Phone
          CustomPaint(
            size: const Size(260, 260),
            painter: _DeskWorkerPainter(),
          ),
        ],
      ),
    );
  }
}

class _DeskWorkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Desk Base Line
    final deskPaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 100, cy + 70),
      Offset(cx + 100, cy + 70),
      deskPaint,
    );

    // 2. Character Body / Blue Sweater
    final bodyPaint = Paint()..color = const Color(0xFF00B4D8);
    final bodyPath = Path()
      ..moveTo(cx - 55, cy + 70)
      ..quadraticBezierTo(cx - 50, cy - 10, cx, cy - 10)
      ..quadraticBezierTo(cx + 50, cy - 10, cx + 55, cy + 70)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Collar / neckline
    final neckPaint = Paint()..color = const Color(0xFFFFD1B3);
    final collarPath = Path()
      ..moveTo(cx - 16, cy - 8)
      ..quadraticBezierTo(cx, cy + 4, cx + 16, cy - 8)
      ..close();
    canvas.drawPath(collarPath, neckPaint);

    // 3. Head & Face
    final facePaint = Paint()..color = const Color(0xFFFFD1B3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 35), width: 44, height: 50),
      facePaint,
    );

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF1E232E);
    final hairPath = Path()
      ..moveTo(cx - 24, cy - 40)
      ..quadraticBezierTo(cx - 10, cy - 65, cx + 5, cy - 60)
      ..quadraticBezierTo(cx + 25, cy - 58, cx + 24, cy - 36)
      ..lineTo(cx + 20, cy - 44)
      ..quadraticBezierTo(cx, cy - 48, cx - 20, cy - 42)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Eyes
    final featurePaint = Paint()
      ..color = const Color(0xFF1E232E)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 8, cy - 34), 2.2, featurePaint);
    canvas.drawCircle(Offset(cx + 8, cy - 34), 2.2, featurePaint);

    // Eyebrows & Stress lines
    final browPaint = Paint()
      ..color = const Color(0xFF1E232E)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 12, cy - 40), Offset(cx - 4, cy - 38), browPaint);
    canvas.drawLine(Offset(cx + 4, cy - 38), Offset(cx + 12, cy - 40), browPaint);

    // Little open focused mouth
    final mouthPaint = Paint()..color = const Color(0xFFFF6B4A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 24), width: 8, height: 6),
      mouthPaint,
    );

    // 4. Laptop on Desk (Right side)
    final laptopPaint = Paint()..color = Colors.white;
    final laptopBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final laptopScreen = Path()
      ..moveTo(cx + 15, cy + 70)
      ..lineTo(cx + 25, cy + 30)
      ..lineTo(cx + 70, cy + 30)
      ..lineTo(cx + 60, cy + 70)
      ..close();
    canvas.drawPath(laptopScreen, laptopPaint);
    canvas.drawPath(laptopScreen, laptopBorder);

    // Laptop logo / icon
    canvas.drawCircle(Offset(cx + 43, cy + 50), 3, Paint()..color = const Color(0xFF00B4D8));

    // Mouse / pad
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 2, cy + 70), width: 16, height: 10),
      Paint()..color = const Color(0xFFE2E8F0),
    );

    // 5. Phone in Hand (Left/Center)
    final phonePaint = Paint()..color = const Color(0xFF8B5CF6);
    final phoneScreen = Paint()..color = const Color(0xFFC4B5FD);
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 6, cy + 22), width: 18, height: 32),
      const Radius.circular(4),
    );
    canvas.drawRRect(phoneRect, phonePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 6, cy + 22), width: 14, height: 26),
        const Radius.circular(2),
      ),
      phoneScreen,
    );

    // 6. Alert / Focus Sparkles above head
    final sparkPaint = Paint()
      ..color = const Color(0xFFFF6B4A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left sparks
    canvas.drawLine(Offset(cx - 38, cy - 65), Offset(cx - 48, cy - 60), sparkPaint);
    canvas.drawLine(Offset(cx - 48, cy - 60), Offset(cx - 36, cy - 50), sparkPaint);
    canvas.drawLine(Offset(cx - 36, cy - 50), Offset(cx - 46, cy - 42), sparkPaint);

    // Right sparks
    canvas.drawLine(Offset(cx + 38, cy - 65), Offset(cx + 48, cy - 60), sparkPaint);
    canvas.drawLine(Offset(cx + 48, cy - 60), Offset(cx + 36, cy - 50), sparkPaint);
    canvas.drawLine(Offset(cx + 36, cy - 50), Offset(cx + 46, cy - 42), sparkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
