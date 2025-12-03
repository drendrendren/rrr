
import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackground extends StatefulWidget {
  final Widget? child;
  final double? speed;

  const SpaceBackground({super.key, this.child, this.speed});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final int starCount = 60;
  final Random random = Random();
  late List<Offset> starPositions;
  late List<double> starSizes;
  late List<Color> starColors;

  @override
  void initState() {
    super.initState();

    // speed 파라미터가 없으면 기본 25초
    final durationSeconds = widget.speed != null
        ? (1 / widget.speed! * 25).clamp(5, 100) // 최소/최대 제한
        : 25.0;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSeconds.toInt()),
    )..repeat();

    starPositions = List.generate(
      starCount,
      (_) => Offset(random.nextDouble(), random.nextDouble()),
    );
    starSizes = List.generate(
      starCount,
      (_) => 0.3 + random.nextDouble() * 0.7,
    );
    starColors = List.generate(starCount, (_) => _randomStarColor());
  }

  Color _randomStarColor() {
    final colors = [
      Colors.white,
      Colors.blue.shade200,
      Colors.purpleAccent.shade100,
      Colors.cyanAccent.shade100,
      Colors.pink.shade100,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              startAngle: 0,
              endAngle: 2 * pi,
              transform: GradientRotation(_controller.value * 2 * pi),
              colors: [
                Colors.deepPurple.shade900,
                Colors.purple.shade800,
                Colors.indigo.shade900,
                Colors.deepPurple.shade900,
              ],
              stops: const [0.0, 0.4, 0.8, 1.0],
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: StarPainter(
              starPositions,
              starSizes,
              starColors,
              _controller.value,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class StarPainter extends CustomPainter {
  final List<Offset> stars;
  final List<double> sizes;
  final List<Color> colors;
  final double animationValue;

  StarPainter(this.stars, this.sizes, this.colors, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var i = 0; i < stars.length; i++) {
      final star = stars[i];
      final dx = star.dx * size.width;
      final dy = star.dy * size.height;

      final phase = i * 0.3;
      final opacity =
          0.3 + 0.7 * (0.5 + 0.5 * sin(animationValue * 6 * pi + phase));

      final radius = sizes[i] * (0.8 + 0.5 * opacity);

      paint.color = colors[i].withOpacity(opacity);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}
