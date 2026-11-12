import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/pet_state.dart';

/// Original grid artwork, painted locally; no downloaded character assets.
class PixelPet extends StatefulWidget {
  const PixelPet(
      {super.key,
      required this.personality,
      required this.action,
      required this.actions});
  final Personality personality;
  final PetAction? action;
  final int actions;
  @override
  State<PixelPet> createState() => _PixelPetState();
}

class _PixelPetState extends State<PixelPet>
    with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  Timer? idle;
  bool blinking = false;
  bool get reduceMotion => MediaQuery.disableAnimationsOf(context);
  @override
  void initState() {
    super.initState();
    idle = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || reduceMotion) return;
      blinking = true;
      motion.forward(from: 0);
    });
    motion.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => blinking = false);
      }
    });
  }

  @override
  void didUpdateWidget(PixelPet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actions != widget.actions && !reduceMotion) {
      blinking = false;
      motion.forward(from: 0);
    }
  }

  @override
  void dispose() {
    idle?.cancel();
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: AnimatedBuilder(
          animation: motion,
          builder: (context, _) => CustomPaint(
                size: const Size(210, 210),
                painter: _PetPainter(widget.personality, widget.action,
                    reduceMotion ? 0 : motion.value, blinking),
              )));
}

class _PetPainter extends CustomPainter {
  _PetPainter(this.personality, this.action, this.progress, this.blinking);
  final Personality personality;
  final PetAction? action;
  final double progress;
  final bool blinking;
  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height) / 24;
    final wave = math.sin(progress * math.pi * 4);
    final bounce = action == PetAction.play
        ? -wave.abs() * 2
        : -math.sin(progress * math.pi) * .4;
    canvas.save();
    canvas.translate((size.width - unit * 24) / 2, bounce * unit);
    void box(double x, double y, double w, double h, Color color) {
      canvas.drawRect(Rect.fromLTWH(x * unit, y * unit, w * unit, h * unit),
          Paint()..color = color);
    }

    const ink = Color(0xFF403747);
    final body = switch (personality) {
      Personality.normal => const Color(0xFFE8AC74),
      Personality.angel => const Color(0xFFFFE5A0),
      Personality.rebel => const Color(0xFFB3A2D5),
      Personality.memeGoblin => const Color(0xFFA6CB82),
      Personality.philosopher => const Color(0xFF8CB9CB),
    };
    box(5, 21, 14, 1, const Color(0x223C2931));
    box(6, 5, 4, 5, ink);
    box(14, 5, 4, 5, ink);
    box(7, 6, 2, 4, body);
    box(15, 6, 2, 4, body);
    box(5, 9, 14, 11, ink);
    box(4, 11, 16, 7, ink);
    box(6, 10, 12, 9, body);
    box(5, 12, 14, 5, body);
    box(7, 19, 3, 2, ink);
    box(14, 19, 3, 2, ink);
    box(8, 16, 8, 3, const Color(0x44FFFFFF));
    final asleep = action == PetAction.rest && progress > 0 && progress < 1;
    final eyesClosed = asleep || (blinking && progress < .65);
    box(8, 12, 2, eyesClosed ? 1 : 2, ink);
    box(14, 12, 2, eyesClosed ? 1 : 2, ink);
    box(11, 15, 2,
        action == PetAction.feed && progress > 0 && progress < 1 ? 2 : 1, ink);
    box(6, 14, 2, 1, const Color(0xFFDF8C8F));
    box(16, 14, 2, 1, const Color(0xFFDF8C8F));
    if (personality == Personality.angel) {
      box(8, 2, 8, 1, const Color(0xFFE5B544));
      box(7, 3, 1, 1, const Color(0xFFE5B544));
      box(16, 3, 1, 1, const Color(0xFFE5B544));
    }
    if (personality == Personality.rebel) {
      box(7, 11, 3, 1, ink);
      box(15, 10, 2, 1, ink);
    }
    if (personality == Personality.memeGoblin) {
      box(7, 11, 4, 2, ink);
      box(13, 11, 4, 2, ink);
      box(11, 11, 2, 1, ink);
    }
    if (personality == Personality.philosopher) {
      box(7, 11, 4, 1, ink);
      box(13, 11, 4, 1, ink);
      box(10, 18, 4, 3, const Color(0xFFE8E3D6));
    }
    if (action == PetAction.feed && progress > 0 && progress < 1) {
      box(18, 16, 4, 3, const Color(0xFFF9D960));
      box(19, 15, 2, 1, const Color(0xFF629D64));
    }
    if (asleep) {
      box(19, 5, 3, 1, ink);
      box(21, 6, 1, 1, ink);
      box(19, 7, 3, 1, ink);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PetPainter oldDelegate) =>
      oldDelegate.personality != personality ||
      oldDelegate.action != action ||
      oldDelegate.progress != progress ||
      oldDelegate.blinking != blinking;
}
