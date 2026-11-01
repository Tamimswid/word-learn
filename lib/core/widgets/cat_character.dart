import 'dart:math' as math;

import 'package:flutter/material.dart';

enum CatExpression { neutral, happy, sad, surprised, shy, sleepy }

class CatCharacter extends StatefulWidget {
  const CatCharacter({
    super.key,
    this.expression = CatExpression.neutral,
    this.width = 280,
    this.height,
  });

  final CatExpression expression;
  final double width;
  final double? height;

  @override
  State<CatCharacter> createState() => _CatCharacterState();
}

class _CatCharacterState extends State<CatCharacter>
    with TickerProviderStateMixin {
  static const double _referenceWidth = 1122;
  static const double _referenceHeight = 1402;
  static const Curve _expressionCurve = Curves.easeInOutCubic;

  late final AnimationController _motionController;
  late final AnimationController _expressionController;
  late final Listenable _repaint;
  late _CatFace _previousFace;
  late _CatFace _targetFace;

  @override
  void initState() {
    super.initState();
    _previousFace = _CatFace.forExpression(widget.expression);
    _targetFace = _previousFace;
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _expressionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      value: 1,
    );
    _repaint = Listenable.merge([_motionController, _expressionController]);
  }

  @override
  void didUpdateWidget(covariant CatCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expression == widget.expression) return;

    _previousFace = _CatFace.lerp(
      _previousFace,
      _targetFace,
      _expressionCurve.transform(_expressionController.value),
    );
    _targetFace = _CatFace.forExpression(widget.expression);
    _expressionController.forward(from: 0);
  }

  @override
  void dispose() {
    _motionController.dispose();
    _expressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height:
          widget.height ?? widget.width * (_referenceHeight / _referenceWidth),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _referenceWidth,
          height: _referenceHeight,
          child: CustomPaint(
            painter: _CatPainter(
              motion: _motionController,
              transition: _expressionController,
              previousFace: _previousFace,
              targetFace: _targetFace,
              curve: _expressionCurve,
              repaint: _repaint,
            ),
          ),
        ),
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  _CatPainter({
    required this.motion,
    required this.transition,
    required this.previousFace,
    required this.targetFace,
    required this.curve,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final Animation<double> motion;
  final Animation<double> transition;
  final _CatFace previousFace;
  final _CatFace targetFace;
  final Curve curve;

  static const Color _ink = Color(0xFF24211F);
  static const Color _fur = Color(0xFFFFC84F);
  static const Color _furShadow = Color(0xFFF2A83C);
  static const Color _suit = Color(0xFFF8F4E9);
  static const Color _suitShadow = Color(0xFFE8E1D2);
  static const Color _blue = Color(0xFF438FC2);
  static const Color _blueDark = Color(0xFF286B9D);
  static const Color _glass = Color(0xFF202734);
  static const Color _glassDark = Color(0xFF151C28);
  static const Color _mouth = Color(0xFF3B2222);
  static const Color _tongue = Color(0xFFE57378);
  static const Color _nose = Color(0xFFE98385);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 1122, size.height / 1402);
    final wave = math.sin(motion.value * math.pi * 2);
    final counterWave = math.sin(motion.value * math.pi * 2 + math.pi);
    final face = _CatFace.lerp(
      previousFace,
      targetFace,
      curve.transform(transition.value),
    );

    _drawTail(canvas);
    _drawLegs(canvas, wave, counterWave);
    _drawBody(canvas);
    _drawLeftArm(canvas, wave);
    _drawRightArmAndTelescope(canvas, counterWave);
    _drawHelmet(canvas, face);
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) => true;

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke([double width = 6, Color color = _ink]) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  void _shape(Canvas canvas, Path path, Color color, [double width = 6]) {
    canvas.drawPath(path, _fill(color));
    canvas.drawPath(path, _stroke(width));
  }

  void _drawTail(Canvas canvas) {
    final tail = Path()
      ..moveTo(472, 906)
      ..cubicTo(442, 1000, 384, 1080, 310, 1092)
      ..cubicTo(244, 1103, 215, 1056, 224, 1004)
      ..cubicTo(232, 958, 274, 944, 304, 966)
      ..cubicTo(330, 985, 315, 1020, 285, 1028)
      ..cubicTo(267, 1033, 254, 1023, 255, 1007)
      ..cubicTo(237, 1055, 284, 1072, 326, 1053)
      ..cubicTo(382, 1027, 405, 956, 424, 895)
      ..close();
    _shape(canvas, tail, _fur);
    canvas.drawPath(
      Path()
        ..moveTo(421, 960)
        ..cubicTo(402, 1015, 364, 1062, 319, 1077),
      _stroke(15, _furShadow),
    );
    canvas.drawPath(
      Path()
        ..moveTo(258, 1063)
        ..cubicTo(243, 1046, 239, 1027, 242, 1009),
      _stroke(12, _furShadow),
    );
  }

  void _drawLegs(Canvas canvas, double wave, double counterWave) {
    canvas.save();
    canvas.translate(478, 907);
    canvas.rotate(wave * 0.018);
    canvas.translate(-478, -907);
    final leftLeg = Path()
      ..moveTo(438, 884)
      ..cubicTo(474, 879, 543, 897, 575, 927)
      ..cubicTo(573, 976, 591, 1042, 616, 1090)
      ..cubicTo(595, 1123, 548, 1142, 508, 1121)
      ..cubicTo(482, 1063, 459, 1004, 441, 947)
      ..close();
    _shape(canvas, leftLeg, _suit);
    canvas.drawPath(
      Path()
        ..moveTo(488, 1085)
        ..cubicTo(520, 1050, 571, 1042, 604, 1064),
      _stroke(5),
    );
    final leftBoot = Path()
      ..moveTo(506, 1102)
      ..cubicTo(540, 1075, 590, 1068, 619, 1088)
      ..cubicTo(629, 1106, 606, 1132, 573, 1144)
      ..cubicTo(540, 1155, 515, 1137, 506, 1102)
      ..close();
    _shape(canvas, leftBoot, _blueDark);
    canvas.drawPath(
      Path()
        ..moveTo(515, 1100)
        ..cubicTo(547, 1081, 584, 1077, 610, 1089),
      _stroke(9, _blue),
    );
    canvas.restore();

    canvas.save();
    canvas.translate(626, 890);
    canvas.rotate(counterWave * 0.02);
    canvas.translate(-626, -890);
    final rightLeg = Path()
      ..moveTo(588, 873)
      ..cubicTo(632, 861, 675, 879, 714, 910)
      ..cubicTo(748, 937, 778, 955, 797, 974)
      ..cubicTo(789, 1007, 760, 1036, 731, 1042)
      ..cubicTo(690, 1013, 651, 985, 615, 951)
      ..close();
    _shape(canvas, rightLeg, _suit);
    canvas.drawPath(
      Path()
        ..moveTo(705, 925)
        ..cubicTo(740, 916, 776, 938, 795, 970),
      _stroke(5),
    );
    final rightBoot = Path()
      ..moveTo(735, 1017)
      ..cubicTo(746, 974, 772, 945, 798, 948)
      ..cubicTo(823, 954, 814, 984, 792, 1012)
      ..cubicTo(771, 1040, 748, 1051, 735, 1017)
      ..close();
    _shape(canvas, rightBoot, _blueDark);
    canvas.drawPath(
      Path()
        ..moveTo(746, 1014)
        ..cubicTo(760, 980, 780, 960, 800, 958),
      _stroke(9, _blue),
    );
    canvas.restore();
  }

  void _drawBody(Canvas canvas) {
    final body = Path()
      ..moveTo(382, 731)
      ..cubicTo(442, 706, 564, 696, 623, 719)
      ..cubicTo(654, 756, 680, 813, 685, 862)
      ..cubicTo(665, 906, 585, 939, 489, 937)
      ..cubicTo(447, 936, 417, 925, 409, 900)
      ..cubicTo(405, 842, 393, 784, 382, 731)
      ..close();
    _shape(canvas, body, _suit);
    canvas.drawPath(
      Path()
        ..moveTo(641, 759)
        ..cubicTo(653, 793, 659, 819, 660, 843),
      _stroke(4, _suitShadow),
    );

    final belt = Path()
      ..moveTo(410, 886)
      ..cubicTo(483, 918, 608, 898, 681, 850)
      ..lineTo(687, 882)
      ..cubicTo(615, 936, 486, 959, 414, 925)
      ..close();
    _shape(canvas, belt, _blue, 5);

    canvas.save();
    canvas.translate(566, 824);
    canvas.rotate(-0.18);
    final panel = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 104, height: 84),
      const Radius.circular(15),
    );
    canvas.drawRRect(panel, _fill(_suit));
    canvas.drawRRect(panel, _stroke(5));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-24, -5), width: 25, height: 25),
      _fill(_blue),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-24, -5), width: 25, height: 25),
      _stroke(3),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(20, -13), width: 24, height: 24),
      _fill(const Color(0xFFD77B53)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(20, -13), width: 24, height: 24),
      _stroke(3),
    );
    canvas.drawLine(
      const Offset(-8, 23),
      const Offset(12, 18),
      _stroke(7, _suitShadow),
    );
    canvas.drawLine(
      const Offset(23, 18),
      const Offset(38, 14),
      _stroke(7, const Color(0xFF9B6253)),
    );
    canvas.restore();
  }

  void _drawLeftArm(Canvas canvas, double wave) {
    canvas.save();
    canvas.translate(392, 774);
    canvas.rotate(wave * 0.026);
    canvas.translate(-392, -774);
    final sleeve = Path()
      ..moveTo(405, 753)
      ..cubicTo(374, 760, 340, 777, 316, 797)
      ..cubicTo(308, 822, 317, 851, 337, 866)
      ..cubicTo(365, 863, 393, 850, 421, 832)
      ..close();
    _shape(canvas, sleeve, _suit);
    final cuff = Path()
      ..moveTo(319, 789)
      ..cubicTo(299, 806, 302, 846, 326, 869)
      ..lineTo(346, 854)
      ..cubicTo(329, 833, 327, 810, 337, 796)
      ..close();
    _shape(canvas, cuff, _blue, 5);
    final glove = Path()
      ..moveTo(310, 812)
      ..cubicTo(289, 810, 279, 797, 269, 800)
      ..cubicTo(256, 805, 264, 818, 277, 826)
      ..cubicTo(254, 823, 241, 832, 246, 844)
      ..cubicTo(250, 853, 263, 855, 276, 854)
      ..cubicTo(254, 857, 250, 870, 262, 878)
      ..cubicTo(272, 884, 285, 875, 294, 870)
      ..cubicTo(284, 886, 292, 895, 303, 888)
      ..cubicTo(318, 878, 326, 860, 326, 842)
      ..close();
    _shape(canvas, glove, _suit, 5);
    canvas.restore();
  }

  void _drawRightArmAndTelescope(Canvas canvas, double wave) {
    canvas.save();
    canvas.translate(625, 746);
    canvas.rotate(wave * 0.02);
    canvas.translate(-625, -746);

    final sleeve = Path()
      ..moveTo(612, 723)
      ..cubicTo(658, 718, 710, 690, 746, 673)
      ..cubicTo(768, 684, 782, 713, 778, 738)
      ..cubicTo(738, 770, 687, 793, 645, 796)
      ..close();
    _shape(canvas, sleeve, _suit);
    final cuff = Path()
      ..moveTo(738, 674)
      ..cubicTo(756, 663, 779, 677, 790, 704)
      ..cubicTo(799, 728, 790, 748, 773, 753)
      ..cubicTo(754, 737, 742, 706, 738, 674)
      ..close();
    _shape(canvas, cuff, _blue, 5);

    canvas.drawLine(
      const Offset(790, 704),
      const Offset(797, 593),
      _stroke(25, const Color(0xFF4B4D51)),
    );
    canvas.drawLine(const Offset(790, 704), const Offset(797, 593), _stroke(5));
    canvas.drawCircle(
      const Offset(789, 594),
      34,
      _fill(const Color(0xFF55585D)),
    );
    canvas.drawCircle(const Offset(789, 594), 34, _stroke(6));
    canvas.drawCircle(
      const Offset(780, 599),
      9,
      _fill(const Color(0xFF83888C)),
    );

    final tube = Path()
      ..moveTo(798, 565)
      ..lineTo(954, 423)
      ..cubicTo(974, 415, 1007, 464, 1014, 492)
      ..lineTo(848, 624)
      ..cubicTo(823, 629, 792, 591, 798, 565)
      ..close();
    _shape(canvas, tube, _suit);
    canvas.drawPath(
      Path()
        ..moveTo(827, 594)
        ..lineTo(984, 455),
      _stroke(13, _suitShadow),
    );
    canvas.drawPath(
      Path()
        ..moveTo(866, 548)
        ..cubicTo(878, 570, 895, 588, 916, 596),
      _stroke(5),
    );

    canvas.save();
    canvas.translate(988, 457);
    canvas.rotate(0.72);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 111, height: 145),
      _fill(_blue),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 111, height: 145),
      _stroke(6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(4, 0), width: 75, height: 108),
      _fill(_glassDark),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(4, 0), width: 75, height: 108),
      _stroke(5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-7, -29), width: 17, height: 29),
      _fill(const Color(0xFF7E8B99)),
    );
    canvas.restore();

    final glove = Path()
      ..moveTo(780, 678)
      ..cubicTo(768, 662, 750, 667, 751, 684)
      ..cubicTo(738, 680, 729, 693, 737, 707)
      ..cubicTo(725, 710, 729, 728, 743, 733)
      ..cubicTo(737, 746, 751, 757, 765, 748)
      ..cubicTo(779, 757, 794, 748, 792, 733)
      ..cubicTo(810, 731, 815, 714, 802, 704)
      ..cubicTo(814, 690, 801, 674, 787, 681)
      ..close();
    _shape(canvas, glove, _suit, 5);
    canvas.drawPath(
      Path()
        ..moveTo(752, 687)
        ..cubicTo(763, 691, 770, 704, 768, 716),
      _stroke(4),
    );
    canvas.restore();
  }

  void _drawHelmet(Canvas canvas, _CatFace face) {
    canvas.drawOval(const Rect.fromLTRB(125, 145, 785, 770), _fill(_suit));
    canvas.drawOval(const Rect.fromLTRB(125, 145, 785, 770), _stroke(7));

    final glassPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.35),
        radius: 0.9,
        colors: [_glass, _glassDark],
      ).createShader(const Rect.fromLTRB(175, 190, 740, 720));
    canvas.drawOval(const Rect.fromLTRB(175, 190, 740, 720), glassPaint);
    canvas.drawOval(const Rect.fromLTRB(175, 190, 740, 720), _stroke(6));
    _drawSpaceDetails(canvas);
    _drawHead(canvas, face);
    _drawStar(canvas);

    canvas.save();
    canvas.translate(159, 620);
    canvas.rotate(-0.25);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 80, height: 132),
      _fill(_suit),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 80, height: 132),
      _stroke(6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(2, 0), width: 38, height: 78),
      _fill(_blueDark),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(2, 0), width: 38, height: 78),
      _stroke(4),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-1, -29)
        ..quadraticBezierTo(-13, 0, 1, 28),
      _stroke(5, _blue),
    );
    canvas.restore();

    final collar = Path()
      ..moveTo(391, 737)
      ..cubicTo(452, 771, 567, 763, 635, 713)
      ..lineTo(642, 738)
      ..cubicTo(576, 794, 450, 801, 397, 765)
      ..close();
    _shape(canvas, collar, _blueDark, 5);
    canvas.drawPath(
      Path()
        ..moveTo(408, 747)
        ..cubicTo(470, 775, 564, 765, 620, 729),
      _stroke(8, _blue),
    );
  }

  void _drawSpaceDetails(Canvas canvas) {
    final starPaint = _stroke(4, const Color(0xFF9BA2A4));
    for (final center in const [
      Offset(399, 266),
      Offset(438, 290),
      Offset(490, 309),
      Offset(370, 329),
    ]) {
      canvas.drawLine(
        center + const Offset(-7, 0),
        center + const Offset(7, 0),
        starPaint,
      );
      canvas.drawLine(
        center + const Offset(0, -9),
        center + const Offset(0, 9),
        starPaint,
      );
    }
    canvas.drawCircle(
      const Offset(658, 337),
      27,
      _fill(const Color(0xFF69B6B5)),
    );
    canvas.save();
    canvas.translate(658, 337);
    canvas.rotate(0.25);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 91, height: 25),
      _stroke(5, const Color(0xFFAAA993)),
    );
    canvas.restore();
    canvas.save();
    canvas.translate(652, 273);
    canvas.rotate(-0.7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 23, height: 65),
      _fill(const Color(0xFF9BA6B2)),
    );
    canvas.restore();
  }

  void _drawHead(Canvas canvas, _CatFace face) {
    final head = Path()
      ..moveTo(276, 672)
      ..cubicTo(250, 595, 251, 489, 266, 419)
      ..lineTo(249, 344)
      ..cubicTo(247, 325, 263, 326, 279, 339)
      ..lineTo(353, 398)
      ..cubicTo(407, 382, 461, 379, 511, 380)
      ..lineTo(588, 284)
      ..cubicTo(600, 267, 613, 274, 615, 294)
      ..lineTo(645, 413)
      ..cubicTo(698, 457, 728, 522, 724, 586)
      ..cubicTo(720, 665, 654, 717, 567, 735)
      ..cubicTo(456, 757, 334, 737, 276, 672)
      ..close();
    _shape(canvas, head, _fur);

    final innerEar = Path()
      ..moveTo(568, 373)
      ..lineTo(599, 319)
      ..cubicTo(610, 341, 619, 367, 624, 392)
      ..close();
    canvas.drawPath(innerEar, _fill(_furShadow));

    final stripePaint = _stroke(14, _furShadow);
    canvas.drawLine(
      const Offset(391, 401),
      const Offset(411, 449),
      stripePaint,
    );
    canvas.drawLine(
      const Offset(435, 393),
      const Offset(452, 446),
      stripePaint,
    );
    canvas.drawLine(
      const Offset(479, 389),
      const Offset(490, 434),
      stripePaint,
    );
    canvas.drawLine(
      const Offset(546, 405),
      const Offset(583, 410),
      _stroke(10),
    );

    canvas.drawLine(
      const Offset(290, 653),
      const Offset(341, 644),
      _stroke(8, _furShadow),
    );
    canvas.drawLine(
      const Offset(296, 676),
      const Offset(342, 660),
      _stroke(8, _furShadow),
    );
    canvas.drawLine(
      const Offset(311, 695),
      const Offset(349, 675),
      _stroke(8, _furShadow),
    );
    canvas.drawLine(
      const Offset(670, 550),
      const Offset(712, 534),
      _stroke(8, _furShadow),
    );
    canvas.drawLine(
      const Offset(675, 572),
      const Offset(715, 560),
      _stroke(8, _furShadow),
    );

    _drawEye(
      canvas,
      const Offset(400, 568),
      const Size(132, 137),
      face.leftEye,
    );
    _drawEye(
      canvas,
      const Offset(588, 505),
      const Size(124, 132),
      face.rightEye,
    );

    if (face.blush > 0) {
      final blushPaint = Paint()
        ..color = const Color(0xFFE98276).withValues(alpha: face.blush * 0.55);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(341, 631), width: 57, height: 22),
        blushPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(660, 585), width: 51, height: 20),
        blushPaint,
      );
    }

    final nose = Path()
      ..moveTo(503, 581)
      ..quadraticBezierTo(518, 570, 531, 578)
      ..quadraticBezierTo(530, 590, 518, 596)
      ..close();
    _shape(canvas, nose, _nose, 4);
    canvas.drawLine(const Offset(518, 595), const Offset(521, 608), _stroke(4));
    _drawMouth(canvas, face.mouth);
  }

  void _drawEye(Canvas canvas, Offset center, Size size, _EyeStyle eye) {
    final effectiveCenter = center + eye.offset;
    final openness = eye.openness.clamp(0.0, 1.2);
    final width = size.width * eye.width;
    final height = size.height * eye.height * openness;

    if (height > 3) {
      final rect = Rect.fromCenter(
        center: effectiveCenter,
        width: width,
        height: height,
      );
      canvas.drawOval(rect, _fill(const Color(0xFFFFFEFF)));
      canvas.drawOval(rect, _stroke(5));
    }

    final pupilAlpha =
        (openness * 2).clamp(0.0, 1.0) * (1 - eye.happy) * (1 - eye.sleepy);
    if (pupilAlpha > 0) {
      final pupilPaint = Paint()..color = _ink.withValues(alpha: pupilAlpha);
      canvas.drawOval(
        Rect.fromCenter(
          center: effectiveCenter + eye.pupilOffset,
          width: 34 * eye.pupilScale,
          height: 38 * eye.pupilScale * openness.clamp(0.25, 1.0),
        ),
        pupilPaint,
      );
    }

    if (eye.happy > 0) {
      final path = Path()
        ..moveTo(effectiveCenter.dx - width * 0.42, effectiveCenter.dy + 8)
        ..quadraticBezierTo(
          effectiveCenter.dx,
          effectiveCenter.dy - size.height * 0.43,
          effectiveCenter.dx + width * 0.42,
          effectiveCenter.dy + 8,
        );
      canvas.drawPath(path, _stroke(7, _ink.withValues(alpha: eye.happy)));
    }

    if (eye.sleepy > 0) {
      final path = Path()
        ..moveTo(effectiveCenter.dx - width * 0.38, effectiveCenter.dy)
        ..quadraticBezierTo(
          effectiveCenter.dx,
          effectiveCenter.dy + 18,
          effectiveCenter.dx + width * 0.38,
          effectiveCenter.dy,
        );
      canvas.drawPath(path, _stroke(7, _ink.withValues(alpha: eye.sleepy)));
    }

    if (eye.sad > 0) {
      final lidPaint = _stroke(7, _ink.withValues(alpha: eye.sad));
      canvas.drawLine(
        effectiveCenter + Offset(-width * 0.36, -height * 0.27),
        effectiveCenter + Offset(width * 0.34, -height * 0.43),
        lidPaint,
      );
    }
  }

  void _drawMouth(Canvas canvas, _MouthStyle mouth) {
    final center = const Offset(525, 624) + mouth.offset;
    final width = 94 * mouth.width;
    final smile = mouth.smile;

    if (mouth.openness < 0.03) {
      final path = Path()
        ..moveTo(center.dx - width / 2, center.dy - smile * 8)
        ..quadraticBezierTo(
          center.dx,
          center.dy + smile * 25,
          center.dx + width / 2,
          center.dy - smile * 8,
        );
      canvas.drawPath(path, _stroke(6));
      return;
    }

    final height = 58 * mouth.height * mouth.openness;
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final path = Path();
    if (mouth.roundness > 0.5) {
      path.addOval(rect);
    } else {
      path
        ..moveTo(rect.left, center.dy - smile * 8)
        ..quadraticBezierTo(
          center.dx,
          rect.top - smile * 8,
          rect.right,
          center.dy - smile * 8,
        )
        ..quadraticBezierTo(
          center.dx + width * 0.12,
          rect.bottom,
          rect.left,
          center.dy - smile * 8,
        )
        ..close();
    }
    _shape(canvas, path, _mouth, 5);

    if (mouth.tongue > 0) {
      final tongue = Path()
        ..moveTo(center.dx - width * 0.27, center.dy + height * 0.25)
        ..quadraticBezierTo(
          center.dx,
          center.dy - height * 0.02,
          center.dx + width * 0.31,
          center.dy + height * 0.17,
        );
      canvas.drawPath(
        tongue,
        _stroke(12, _tongue.withValues(alpha: mouth.tongue)),
      );
    }

    if (mouth.fangs > 0) {
      final fangPaint = Paint()
        ..color = const Color(0xFFFFFEFF).withValues(alpha: mouth.fangs);
      for (final direction in const [-1.0, 1.0]) {
        final x = center.dx + direction * width * 0.29;
        final fang = Path()
          ..moveTo(x - 8, rect.top + 8)
          ..lineTo(x + 8, rect.top + 7)
          ..lineTo(x + 2, rect.top + 24)
          ..close();
        canvas.drawPath(fang, fangPaint);
      }
    }
  }

  void _drawStar(Canvas canvas) {
    const center = Offset(294, 430);
    final path = Path();
    for (var index = 0; index < 10; index++) {
      final radius = index.isEven ? 103.0 : 48.0;
      final angle = -math.pi / 2 - 0.2 + index * math.pi / 5;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    _shape(canvas, path, _fur, 6);
    canvas.drawPath(
      Path()
        ..moveTo(259, 350)
        ..quadraticBezierTo(278, 355, 299, 379),
      _stroke(7, const Color(0xFFFFDF82)),
    );
  }
}

class _CatFace {
  const _CatFace({
    required this.leftEye,
    required this.rightEye,
    required this.mouth,
    required this.blush,
  });

  factory _CatFace.forExpression(CatExpression expression) {
    return switch (expression) {
      CatExpression.neutral => _CatFace(
        leftEye: const _EyeStyle(),
        rightEye: const _EyeStyle(pupilOffset: Offset(-15, 3)),
        mouth: const _MouthStyle(),
        blush: 0,
      ),
      CatExpression.happy => _CatFace(
        leftEye: const _EyeStyle(openness: 0, happy: 1, offset: Offset(0, 8)),
        rightEye: const _EyeStyle(openness: 0, happy: 1, offset: Offset(0, 8)),
        mouth: const _MouthStyle(
          openness: 0.8,
          width: 1.08,
          height: 0.9,
          smile: 1,
          fangs: 0.8,
        ),
        blush: 0,
      ),
      CatExpression.sad => _CatFace(
        leftEye: const _EyeStyle(
          openness: 0.8,
          sad: 1,
          offset: Offset(0, 8),
          pupilOffset: Offset(5, 9),
        ),
        rightEye: const _EyeStyle(
          openness: 0.8,
          sad: 1,
          offset: Offset(0, 8),
          pupilOffset: Offset(-10, 10),
        ),
        mouth: const _MouthStyle(
          openness: 0,
          width: 0.64,
          smile: -1,
          fangs: 0,
          tongue: 0,
          offset: Offset(0, 13),
        ),
        blush: 0,
      ),
      CatExpression.surprised => _CatFace(
        leftEye: const _EyeStyle(
          openness: 1.1,
          width: 1.08,
          height: 1.08,
          offset: Offset(0, -5),
          pupilScale: 0.78,
        ),
        rightEye: const _EyeStyle(
          openness: 1.1,
          width: 1.08,
          height: 1.08,
          offset: Offset(0, -5),
          pupilOffset: Offset(-15, 3),
          pupilScale: 0.78,
        ),
        mouth: const _MouthStyle(
          width: 0.48,
          height: 1.2,
          roundness: 1,
          fangs: 0,
          tongue: 0,
          offset: Offset(0, 9),
        ),
        blush: 0,
      ),
      CatExpression.shy => _CatFace(
        leftEye: const _EyeStyle(
          openness: 0.68,
          width: 0.94,
          offset: Offset(0, 9),
          pupilOffset: Offset(3, 13),
        ),
        rightEye: const _EyeStyle(
          openness: 0.68,
          width: 0.94,
          offset: Offset(0, 9),
          pupilOffset: Offset(-12, 15),
        ),
        mouth: const _MouthStyle(
          openness: 0,
          width: 0.46,
          smile: 0.8,
          fangs: 0,
          tongue: 0,
          offset: Offset(0, 8),
        ),
        blush: 1,
      ),
      CatExpression.sleepy => _CatFace(
        leftEye: const _EyeStyle(openness: 0, sleepy: 1, offset: Offset(0, 12)),
        rightEye: const _EyeStyle(
          openness: 0,
          sleepy: 1,
          offset: Offset(0, 12),
        ),
        mouth: const _MouthStyle(
          openness: 0.2,
          width: 0.32,
          height: 0.42,
          fangs: 0,
          tongue: 0,
          offset: Offset(0, 14),
        ),
        blush: 0,
      ),
    };
  }

  final _EyeStyle leftEye;
  final _EyeStyle rightEye;
  final _MouthStyle mouth;
  final double blush;

  static _CatFace lerp(_CatFace from, _CatFace to, double t) {
    return _CatFace(
      leftEye: _EyeStyle.lerp(from.leftEye, to.leftEye, t),
      rightEye: _EyeStyle.lerp(from.rightEye, to.rightEye, t),
      mouth: _MouthStyle.lerp(from.mouth, to.mouth, t),
      blush: _lerp(from.blush, to.blush, t),
    );
  }
}

class _EyeStyle {
  const _EyeStyle({
    this.offset = Offset.zero,
    this.width = 1,
    this.height = 1,
    this.openness = 1,
    this.happy = 0,
    this.sad = 0,
    this.sleepy = 0,
    this.pupilOffset = const Offset(12, -2),
    this.pupilScale = 1,
  });

  final Offset offset;
  final double width;
  final double height;
  final double openness;
  final double happy;
  final double sad;
  final double sleepy;
  final Offset pupilOffset;
  final double pupilScale;

  static _EyeStyle lerp(_EyeStyle from, _EyeStyle to, double t) {
    return _EyeStyle(
      offset: Offset.lerp(from.offset, to.offset, t)!,
      width: _lerp(from.width, to.width, t),
      height: _lerp(from.height, to.height, t),
      openness: _lerp(from.openness, to.openness, t),
      happy: _lerp(from.happy, to.happy, t),
      sad: _lerp(from.sad, to.sad, t),
      sleepy: _lerp(from.sleepy, to.sleepy, t),
      pupilOffset: Offset.lerp(from.pupilOffset, to.pupilOffset, t)!,
      pupilScale: _lerp(from.pupilScale, to.pupilScale, t),
    );
  }
}

class _MouthStyle {
  const _MouthStyle({
    this.offset = Offset.zero,
    this.width = 1,
    this.height = 1,
    this.openness = 1,
    this.smile = 0,
    this.roundness = 0,
    this.fangs = 1,
    this.tongue = 1,
  });

  final Offset offset;
  final double width;
  final double height;
  final double openness;
  final double smile;
  final double roundness;
  final double fangs;
  final double tongue;

  static _MouthStyle lerp(_MouthStyle from, _MouthStyle to, double t) {
    return _MouthStyle(
      offset: Offset.lerp(from.offset, to.offset, t)!,
      width: _lerp(from.width, to.width, t),
      height: _lerp(from.height, to.height, t),
      openness: _lerp(from.openness, to.openness, t),
      smile: _lerp(from.smile, to.smile, t),
      roundness: _lerp(from.roundness, to.roundness, t),
      fangs: _lerp(from.fangs, to.fangs, t),
      tongue: _lerp(from.tongue, to.tongue, t),
    );
  }
}

double _lerp(double from, double to, double t) => from + (to - from) * t;
