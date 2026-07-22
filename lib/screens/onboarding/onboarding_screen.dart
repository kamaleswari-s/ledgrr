import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_FeatureData> _features = const [
    _FeatureData(
      iconType: 'sentence',
      name: 'Daily Sentence',
      desc:
          'Every morning LEDGRR reads your finances and gives you one honest sentence. Not a dashboard. Not a graph. Just the truth — in plain English.',
    ),
    _FeatureData(
      iconType: 'balance',
      name: 'True Balance',
      desc:
          'Not what your bank shows. Your real available money — calculated from every rupee that came in and every rupee that went out. From day one.',
    ),
    _FeatureData(
      iconType: 'ghost',
      name: 'Ghost Money Detector',
      desc:
          'Forgotten subscriptions, recurring charges you stopped noticing — LEDGRR scans your transactions and surfaces every rupee silently draining you.',
    ),
    _FeatureData(
      iconType: 'memory',
      name: 'Money Memory',
      desc:
          'An auto-written daily financial journal. LEDGRR writes your money story. You add your own notes. Read it at the end of the month and see yourself clearly.',
    ),
    _FeatureData(
      iconType: 'calendar',
      name: 'Event Wallet',
      desc:
          'Appa\'s birthday. Goa trip. Diwali shopping. Save toward life moments before they arrive. LEDGRR nudges you when the date is close and your goal is not.',
    ),
    _FeatureData(
      iconType: 'spendlist',
      name: 'Spend List',
      desc:
          'Plan your spending before you leave. Set a budget cap, check off items as you buy, watch your balance update live. No more overspending at the store.',
    ),
    _FeatureData(
      iconType: 'stats',
      name: 'Statistics + Identity',
      desc:
          'Charts, category breakdowns, and LEDGRR\'s honest take on your month. Plus your spender identity — are you a Steady Saver, a Front-Loader, or a Comfort Buyer?',
    ),
    _FeatureData(
      iconType: 'learn',
      name: 'Learn Finance',
      desc:
          '44 lessons across 3 levels. Plain English. Real Indian examples. From what a budget actually is to how compound interest works — built for students, not accountants.',
    ),
    _FeatureData(
      iconType: 'chat',
      name: 'Ask Your Money',
      desc:
          'Type any question. "Can I afford Pondicherry this weekend?" LEDGRR reads your actual balance, upcoming events, and spending rate — then answers honestly.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _features.length + 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = LedgrrColors.mint;
    final totalPages = _features.length + 2;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage < totalPages - 1)
                    GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          totalPages - 1,
                          duration:
                              const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text('Skip',
                          style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: palette.inkMuted)),
                    )
                  else
                    const SizedBox(width: 40),
                  const Spacer(),
                  Row(
                    children: List.generate(totalPages, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? palette.accent
                              : palette.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentPage + 1}/$totalPages',
                    style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: palette.inkMuted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) =>
                    setState(() => _currentPage = i),
                children: [
                  _WelcomePage(palette: palette),
                  ..._features.map(
                    (f) =>
                        _FeaturePage(feature: f, palette: palette),
                  ),
                  _GetStartedPage(palette: palette),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Material(
                      color: palette.bg2,
                      borderRadius: BorderRadius.circular(100),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: _prevPage,
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(100),
                            border:
                                Border.all(color: palette.border),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              color: palette.ink, size: 20),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (_currentPage < totalPages - 1)
                    Material(
                      color: palette.accent,
                      borderRadius: BorderRadius.circular(100),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: _nextPage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          child: Text(
                            _currentPage == 0
                                ? 'See features'
                                : 'Next',
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: palette.accentFg),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WELCOME PAGE ──────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final LedgrrPalette palette;
  const _WelcomePage({required this.palette});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: palette.ink,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: _RRPainter(
                leftColor: palette.bg2,
                rightColor: palette.accent,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: palette.bg2,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: palette.border),
            ),
            child: Text('Finance clarity for students',
                style: GoogleFonts.syne(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: palette.accent,
                    letterSpacing: 0.04)),
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Old word.\n',
                  style: GoogleFonts.syne(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: palette.ink,
                    height: 1.15,
                    letterSpacing: -1,
                  ),
                ),
                TextSpan(
                  text: 'New brain.',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 38,
                    fontStyle: FontStyle.italic,
                    color: palette.accent,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'LEDGRR is a finance app built for students who are tired of being overwhelmed by money. One honest sentence every morning. Real data. No jargon. No guilt.',
            style: GoogleFonts.syne(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: palette.inkMuted,
                height: 1.65),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _StatChip(label: '9 features', palette: palette),
              const SizedBox(width: 8),
              _StatChip(
                  label: '1 daily sentence', palette: palette),
              const SizedBox(width: 8),
              _StatChip(label: '0 jargon', palette: palette),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final LedgrrPalette palette;
  const _StatChip({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.bg2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Text(label,
          style: GoogleFonts.syne(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: palette.ink)),
    );
  }
}

// ─── FEATURE DATA ──────────────────────────────────────────────────────────

class _FeatureData {
  final String iconType;
  final String name;
  final String desc;
  const _FeatureData({
    required this.iconType,
    required this.name,
    required this.desc,
  });
}

// ─── FEATURE PAGE ──────────────────────────────────────────────────────────

class _FeaturePage extends StatelessWidget {
  final _FeatureData feature;
  final LedgrrPalette palette;
  const _FeaturePage(
      {required this.feature, required this.palette});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: palette.bg2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomPaint(
              painter: _IconPainter(
                  type: feature.iconType, color: palette.accent),
            ),
          ),
          const SizedBox(height: 32),
          Text(feature.name,
              style: GoogleFonts.syne(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: palette.ink,
                  letterSpacing: -0.8,
                  height: 1.2)),
          const SizedBox(height: 8),
          Container(
            width: 40, height: 3,
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(feature.desc,
              style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: palette.ink,
                  height: 1.7)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── GET STARTED PAGE ──────────────────────────────────────────────────────

class _GetStartedPage extends StatelessWidget {
  final LedgrrPalette palette;
  const _GetStartedPage({required this.palette});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'Ready to know\nyour truth?',
            style: GoogleFonts.syne(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: palette.ink,
                letterSpacing: -1,
                height: 1.15),
          ),
          const SizedBox(height: 16),
          Text(
            'LEDGRR never stores your card details. It reads your transactions to give you clarity — nothing else.',
            style: GoogleFonts.syne(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: palette.inkMuted,
                height: 1.65),
          ),
          const SizedBox(height: 40),
          Material(
            color: palette.accent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        const AuthScreen(isSignUp: true)),
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text('Create your account',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: palette.accentFg)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: palette.bg2,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        const AuthScreen(isSignUp: false)),
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Center(
                  child: Text('I already have an account',
                      style: GoogleFonts.syne(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.ink)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.bg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 16, color: palette.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No card numbers, no bank login, no transfer permissions. You control every entry — your money stays yours.',
                    style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: palette.ink,
                        height: 1.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── ICON PAINTER ──────────────────────────────────────────────────────────

class _IconPainter extends CustomPainter {
  final String type;
  final Color color;

  const _IconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (type) {
      // Daily Sentence — speech quote marks
      case 'sentence':
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(cx - 8, cy - 2),
                width: 14, height: 14),
            3.14, 3.14, false, lp2);
        canvas.drawLine(
            Offset(cx - 8, cy + 5), Offset(cx - 4, cy + 11), lp2);
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(cx + 6, cy - 2),
                width: 14, height: 14),
            3.14, 3.14, false, lp2);
        canvas.drawLine(
            Offset(cx + 6, cy + 5), Offset(cx + 10, cy + 11), lp2);
        break;

      // True Balance — scales
      case 'balance':
        canvas.drawLine(
            Offset(cx, cy - 16), Offset(cx, cy + 16), p);
        canvas.drawLine(
            Offset(cx - 14, cy - 2), Offset(cx + 14, cy - 2), p);
        canvas.drawLine(
            Offset(cx - 14, cy - 2), Offset(cx - 14, cy + 8), p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx - 14, cy + 11),
                    width: 16, height: 5),
                const Radius.circular(2)),
            pf);
        canvas.drawLine(
            Offset(cx + 14, cy - 2), Offset(cx + 14, cy - 10), p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx + 14, cy - 13),
                    width: 16, height: 5),
                const Radius.circular(2)),
            pf);
        break;

      // Ghost Money Detector
      case 'ghost':
        final path = Path();
        path.moveTo(cx - 14, cy + 14);
        path.lineTo(cx - 14, cy - 4);
        path.quadraticBezierTo(cx - 14, cy - 18, cx, cy - 18);
        path.quadraticBezierTo(cx + 14, cy - 18, cx + 14, cy - 4);
        path.lineTo(cx + 14, cy + 14);
        path.lineTo(cx + 7, cy + 8);
        path.lineTo(cx, cy + 14);
        path.lineTo(cx - 7, cy + 8);
        path.close();
        canvas.drawPath(path, p);
        canvas.drawCircle(Offset(cx - 5, cy - 4), 2.5, pf);
        canvas.drawCircle(Offset(cx + 5, cy - 4), 2.5, pf);
        break;

      // Money Memory — open book
      case 'memory':
        canvas.drawLine(
            Offset(cx, cy - 14), Offset(cx, cy + 14), p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 18, cy - 14, cx, cy + 14),
                const Radius.circular(3)),
            p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx, cy - 14, cx + 18, cy + 14),
                const Radius.circular(3)),
            p);
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(cx - 14, cy - 6), Offset(cx - 4, cy - 6), lp2);
        canvas.drawLine(
            Offset(cx - 14, cy), Offset(cx - 4, cy), lp2);
        canvas.drawLine(
            Offset(cx - 14, cy + 6), Offset(cx - 4, cy + 6), lp2);
        canvas.drawLine(
            Offset(cx + 4, cy - 6), Offset(cx + 14, cy - 6), lp2);
        canvas.drawLine(
            Offset(cx + 4, cy), Offset(cx + 14, cy), lp2);
        break;

      // Event Wallet — calendar
      case 'calendar':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx, cy + 2),
                    width: 30, height: 26),
                const Radius.circular(5)),
            p);
        canvas.drawLine(
            Offset(cx - 15, cy - 4), Offset(cx + 15, cy - 4), p);
        canvas.drawLine(
            Offset(cx - 8, cy - 12), Offset(cx - 8, cy - 4), p);
        canvas.drawLine(
            Offset(cx + 8, cy - 12), Offset(cx + 8, cy - 4), p);
        canvas.drawCircle(Offset(cx - 6, cy + 4), 2, pf);
        canvas.drawCircle(Offset(cx, cy + 4), 2, pf);
        canvas.drawCircle(Offset(cx + 6, cy + 4), 2, pf);
        canvas.drawCircle(Offset(cx - 6, cy + 10), 2, pf);
        canvas.drawCircle(Offset(cx, cy + 10), 2, pf);
        break;

      // Spend List — checklist
      case 'spendlist':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx, cy),
                    width: 30, height: 32),
                const Radius.circular(6)),
            p);
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        final check1 = Path();
        check1.moveTo(cx - 10, cy - 8);
        check1.lineTo(cx - 7, cy - 5);
        check1.lineTo(cx - 2, cy - 11);
        canvas.drawPath(check1, lp2);
        canvas.drawLine(
            Offset(cx, cy - 8), Offset(cx + 10, cy - 8), lp2);
        final check2 = Path();
        check2.moveTo(cx - 10, cy);
        check2.lineTo(cx - 7, cy + 3);
        check2.lineTo(cx - 2, cy - 3);
        canvas.drawPath(check2, lp2);
        canvas.drawLine(Offset(cx, cy), Offset(cx + 10, cy), lp2);
        canvas.drawCircle(
            Offset(cx - 8, cy + 8), 3,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
        canvas.drawLine(
            Offset(cx, cy + 8), Offset(cx + 10, cy + 8), lp2);
        break;

      // Statistics + Identity — bar chart with person
      case 'stats':
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(cx - 14, cy + 12), Offset(cx + 14, cy + 12), lp2);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 12, cy + 2, cx - 6, cy + 12),
                const Radius.circular(2)),
            pf);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 3, cy - 4, cx + 3, cy + 12),
                const Radius.circular(2)),
            pf);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx + 6, cy - 10, cx + 12, cy + 12),
                const Radius.circular(2)),
            pf);
        canvas.drawCircle(Offset(cx + 10, cy - 14), 4, p);
        break;

      // Learn Finance — book with star
      case 'learn':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx - 2, cy + 2),
                    width: 24, height: 30),
                const Radius.circular(4)),
            p);
        canvas.drawLine(
            Offset(cx - 2, cy - 13), Offset(cx - 2, cy + 17), p);
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(cx - 10, cy - 4), Offset(cx - 4, cy - 4), lp2);
        canvas.drawLine(
            Offset(cx - 10, cy + 2), Offset(cx - 4, cy + 2), lp2);
        canvas.drawLine(
            Offset(cx - 10, cy + 8), Offset(cx - 4, cy + 8), lp2);
        canvas.drawCircle(Offset(cx + 10, cy - 10), 7, p);
        canvas.drawLine(
            Offset(cx + 10, cy - 15), Offset(cx + 10, cy - 5), lp2);
        canvas.drawLine(
            Offset(cx + 5, cy - 10), Offset(cx + 15, cy - 10), lp2);
        break;

      // Ask Your Money — chat bubble
      case 'chat':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx, cy - 2),
                    width: 28, height: 22),
                const Radius.circular(10)),
            p);
        final tail = Path();
        tail.moveTo(cx - 4, cy + 9);
        tail.lineTo(cx - 10, cy + 16);
        tail.lineTo(cx + 2, cy + 9);
        canvas.drawPath(tail, p);
        canvas.drawCircle(Offset(cx - 7, cy - 2), 2, pf);
        canvas.drawCircle(Offset(cx, cy - 2), 2, pf);
        canvas.drawCircle(Offset(cx + 7, cy - 2), 2, pf);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── RR LOGO PAINTER ───────────────────────────────────────────────────────

class _RRPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  const _RRPainter(
      {required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 18, cy + 18);
    lp.lineTo(cx - 18, cy - 8);
    lp.quadraticBezierTo(cx - 18, cy - 18, cx - 10, cy - 18);
    lp.quadraticBezierTo(cx - 2, cy - 18, cx - 2, cy - 8);
    lp.quadraticBezierTo(cx - 2, cy + 2, cx - 10, cy + 2);
    lp.lineTo(cx - 4, cy + 18);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 18, cy + 18);
    rp.lineTo(cx + 18, cy - 8);
    rp.quadraticBezierTo(cx + 18, cy - 18, cx + 10, cy - 18);
    rp.quadraticBezierTo(cx + 2, cy - 18, cx + 2, cy - 8);
    rp.quadraticBezierTo(cx + 2, cy + 2, cx + 10, cy + 2);
    rp.lineTo(cx + 4, cy + 18);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}