import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  int _currentNavIndex = 0;

  // Mock data — will be replaced with real Firebase data later
  final String _dailySentence =
      'You\'re stable — but a ₹9,800 storm is forming on the 3rd. 11 days to prepare.';
  final String _trueBalance = '₹4,210';
  final String _ghostAmount = '₹1,219';
  final String _fogLevel = 'Low';
  final bool _isStable = true;

  final List<_QuickAction> _quickActions = const [
    _QuickAction(iconType: 'spendlist', label: 'Spend List'),
    _QuickAction(iconType: 'ghost', label: 'Ghosts'),
    _QuickAction(iconType: 'storm', label: 'Bill Storm'),
    _QuickAction(iconType: 'chat', label: 'Ask Money'),
    _QuickAction(iconType: 'memory', label: 'Memory'),
    _QuickAction(iconType: 'rewind', label: 'Rewind'),
  ];

  final List<_ActivityItem> _recentActivity = const [
    _ActivityItem(
      title: 'Ghost cleared',
      subtitle: 'Arjun paid back ₹600',
      amount: '+₹600',
      isPositive: true,
      time: '2h ago',
    ),
    _ActivityItem(
      title: 'Subscription detected',
      subtitle: 'Hotstar — unused 34 days',
      amount: '₹299/mo',
      isPositive: false,
      time: '1d ago',
    ),
    _ActivityItem(
      title: 'Spend List completed',
      subtitle: 'Stayed ₹760 under cap',
      amount: '-₹7,240',
      isPositive: true,
      time: '2d ago',
    ),
    _ActivityItem(
      title: 'Bill Storm detected',
      subtitle: 'Rent + EMI + Netflix — Mar 3',
      amount: '₹9,800',
      isPositive: false,
      time: '3d ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideUp = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = LedgrrColors.mint;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.translate(
                offset: Offset(0, _slideUp.value),
                child: child,
              ),
            );
          },
          child: CustomScrollView(
            slivers: [
              // Top bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      // Logo + name
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: palette.ink,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: CustomPaint(
                          painter: _RRPainter(
                            leftColor: palette.bg2,
                            rightColor: palette.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'LEDG',
                              style: GoogleFonts.syne(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: palette.ink,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'RR',
                              style: GoogleFonts.syne(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: palette.accent,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Notification bell
                      Material(
                        color: palette.bg2,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {},
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: palette.border),
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: palette.ink,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Profile avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: palette.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'R',
                            style: GoogleFonts.syne(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: palette.accentFg,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, Riri',
                        style: GoogleFonts.syne(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: palette.inkMuted,
                          letterSpacing: 0.02,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here is your truth for today.',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: palette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Daily Sentence Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: palette.ink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: palette.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _isStable ? 'Stable' : 'Attention needed',
                                style: GoogleFonts.syne(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: palette.accent,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Daily sentence',
                              style: GoogleFonts.syne(
                                fontSize: 10,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '"$_dailySentence"',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _SentenceChip(
                              label: 'True Balance',
                              value: _trueBalance,
                              palette: palette,
                            ),
                            const SizedBox(width: 8),
                            _SentenceChip(
                              label: 'Ghosts',
                              value: _ghostAmount,
                              palette: palette,
                            ),
                            const SizedBox(width: 8),
                            _SentenceChip(
                              label: 'Fog',
                              value: _fogLevel,
                              palette: palette,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Three stat cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'True Balance',
                          value: _trueBalance,
                          sublabel: 'after all debts',
                          iconType: 'balance',
                          palette: palette,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Ghost Money',
                          value: _ghostAmount,
                          sublabel: 'found this week',
                          iconType: 'ghost',
                          palette: palette,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Fog Level',
                          value: _fogLevel,
                          sublabel: 'you are clear',
                          iconType: 'fog',
                          palette: palette,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick actions',
                        style: GoogleFonts.syne(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _quickActions.map((action) {
                          return _QuickActionButton(
                            action: action,
                            palette: palette,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent activity
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Row(
                    children: [
                      Text(
                        'Recent activity',
                        style: GoogleFonts.syne(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: palette.ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'See all',
                        style: GoogleFonts.syne(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: palette.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Activity list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = _recentActivity[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: palette.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: palette.bg2,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomPaint(
                                painter: _IconPainter(
                                  type: item.isPositive ? 'ghost' : 'storm',
                                  color: item.isPositive
                                      ? palette.accent
                                      : const Color(0xFFB5446E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.syne(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: palette.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: GoogleFonts.syne(
                                      fontSize: 11,
                                      color: palette.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.amount,
                                  style: GoogleFonts.syne(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: item.isPositive
                                        ? palette.accent
                                        : const Color(0xFFB5446E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.time,
                                  style: GoogleFonts.syne(
                                    fontSize: 10,
                                    color: palette.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _recentActivity.length,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),

      // Bottom nav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: palette.card,
          border: Border(
            top: BorderSide(color: palette.border),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentNavIndex == 0,
                  palette: palette,
                  onTap: () => setState(() => _currentNavIndex = 0),
                ),
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Spend List',
                  isActive: _currentNavIndex == 1,
                  palette: palette,
                  onTap: () => setState(() => _currentNavIndex = 1),
                ),
                _NavItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'Memory',
                  isActive: _currentNavIndex == 2,
                  palette: palette,
                  onTap: () => setState(() => _currentNavIndex = 2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isActive: _currentNavIndex == 3,
                  palette: palette,
                  onTap: () => setState(() => _currentNavIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SENTENCE CHIP ─────────────────────────────────────────────────────────

class _SentenceChip extends StatelessWidget {
  final String label;
  final String value;
  final LedgrrPalette palette;

  const _SentenceChip({
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 9,
                color: Colors.white54,
                letterSpacing: 0.04,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STAT CARD ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final String iconType;
  final LedgrrPalette palette;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.iconType,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(
              painter: _IconPainter(
                type: iconType,
                color: palette.accent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.syne(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: palette.ink,
            ),
          ),
          Text(
            sublabel,
            style: GoogleFonts.syne(
              fontSize: 9,
              color: palette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QUICK ACTION ──────────────────────────────────────────────────────────

class _QuickAction {
  final String iconType;
  final String label;
  const _QuickAction({required this.iconType, required this.label});
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  final LedgrrPalette palette;

  const _QuickActionButton({
    required this.action,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: palette.bg2,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: CustomPaint(
                painter: _IconPainter(
                  type: action.iconType,
                  color: palette.accent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          action.label,
          style: GoogleFonts.syne(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: palette.inkMuted,
          ),
        ),
      ],
    );
  }
}

// ─── ACTIVITY ITEM ─────────────────────────────────────────────────────────

class _ActivityItem {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.time,
  });
}

// ─── NAV ITEM ──────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final LedgrrPalette palette;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? palette.accent.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? palette.accent : palette.inkMuted,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.syne(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? palette.accent : palette.inkMuted,
            ),
          ),
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
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (type) {
      case 'ghost':
        final path = Path();
        path.moveTo(cx - 10, cy + 10);
        path.lineTo(cx - 10, cy - 2);
        path.quadraticBezierTo(cx - 10, cy - 12, cx, cy - 12);
        path.quadraticBezierTo(cx + 10, cy - 12, cx + 10, cy - 2);
        path.lineTo(cx + 10, cy + 10);
        path.lineTo(cx + 5, cy + 6);
        path.lineTo(cx, cy + 10);
        path.lineTo(cx - 5, cy + 6);
        path.close();
        canvas.drawPath(path, p);
        canvas.drawCircle(Offset(cx - 3, cy - 2), 1.8, pf);
        canvas.drawCircle(Offset(cx + 3, cy - 2), 1.8, pf);
        break;

      case 'chat':
        final rRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx, cy - 2), width: 20, height: 16),
          const Radius.circular(7),
        );
        canvas.drawRRect(rRect, p);
        final tail = Path();
        tail.moveTo(cx - 3, cy + 6);
        tail.lineTo(cx - 7, cy + 11);
        tail.lineTo(cx + 1, cy + 6);
        canvas.drawPath(tail, p);
        canvas.drawCircle(Offset(cx - 5, cy - 2), 1.5, pf);
        canvas.drawCircle(Offset(cx, cy - 2), 1.5, pf);
        canvas.drawCircle(Offset(cx + 5, cy - 2), 1.5, pf);
        break;

      case 'fog':
        final fogP1 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        final fogP2 = Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        final fogP3 = Paint()
          ..color = color.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(cx - 11, cy - 5), Offset(cx + 11, cy - 5), fogP1);
        canvas.drawLine(Offset(cx - 8, cy), Offset(cx + 8, cy), fogP2);
        canvas.drawLine(
            Offset(cx - 6, cy + 5), Offset(cx + 6, cy + 5), fogP3);
        canvas.drawCircle(Offset(cx + 14, cy - 5), 3, pf);
        break;

      case 'storm':
        final cloud = Path();
        cloud.moveTo(cx - 10, cy - 2);
        cloud.quadraticBezierTo(cx - 10, cy - 10, cx - 3, cy - 10);
        cloud.quadraticBezierTo(cx - 1, cy - 14, cx + 4, cy - 13);
        cloud.quadraticBezierTo(cx + 11, cy - 11, cx + 10, cy - 4);
        cloud.quadraticBezierTo(cx + 13, cy - 2, cx + 10, cy + 1);
        cloud.lineTo(cx - 10, cy + 1);
        cloud.close();
        canvas.drawPath(cloud, p);
        canvas.drawLine(
            Offset(cx - 5, cy + 4), Offset(cx - 7, cy + 10), p);
        canvas.drawLine(Offset(cx, cy + 4), Offset(cx - 1, cy + 10), p);
        canvas.drawLine(
            Offset(cx + 5, cy + 4), Offset(cx + 4, cy + 10), p);
        break;

      case 'balance':
        canvas.drawLine(Offset(cx, cy - 11), Offset(cx, cy + 11), p);
        canvas.drawLine(
            Offset(cx - 10, cy - 1), Offset(cx + 10, cy - 1), p);
        canvas.drawLine(
            Offset(cx - 10, cy - 1), Offset(cx - 10, cy + 5), p);
        final lp = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx - 10, cy + 8), width: 11, height: 4),
          const Radius.circular(1.5),
        );
        canvas.drawRRect(lp, pf);
        canvas.drawLine(
            Offset(cx + 10, cy - 1), Offset(cx + 10, cy - 7), p);
        final rp = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx + 10, cy - 10), width: 11, height: 4),
          const Radius.circular(1.5),
        );
        canvas.drawRRect(rp, pf);
        break;

      case 'firstaid':
        final vRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: 6, height: 20),
          const Radius.circular(3),
        );
        final hRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 6),
          const Radius.circular(3),
        );
        canvas.drawRRect(vRect, pf);
        canvas.drawRRect(hRect, pf);
        break;

      case 'memory':
        canvas.drawLine(Offset(cx, cy - 10), Offset(cx, cy + 10), p);
        final lPage = RRect.fromRectAndRadius(
          Rect.fromLTRB(cx - 13, cy - 10, cx, cy + 10),
          const Radius.circular(2),
        );
        canvas.drawRRect(lPage, p);
        final rPage = RRect.fromRectAndRadius(
          Rect.fromLTRB(cx, cy - 10, cx + 13, cy + 10),
          const Radius.circular(2),
        );
        canvas.drawRRect(rPage, p);
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(cx - 10, cy - 4), Offset(cx - 3, cy - 4), lp2);
        canvas.drawLine(Offset(cx - 10, cy), Offset(cx - 3, cy), lp2);
        canvas.drawLine(
            Offset(cx - 10, cy + 4), Offset(cx - 3, cy + 4), lp2);
        canvas.drawLine(
            Offset(cx + 3, cy - 4), Offset(cx + 10, cy - 4), lp2);
        canvas.drawLine(Offset(cx + 3, cy), Offset(cx + 10, cy), lp2);
        break;

      case 'rewind':
        final arc = Path();
        arc.moveTo(cx + 7, cy - 9);
        arc.quadraticBezierTo(cx - 12, cy - 9, cx - 12, cy + 1);
        arc.quadraticBezierTo(cx - 12, cy + 10, cx + 3, cy + 10);
        canvas.drawPath(arc, p);
        final ah = Path();
        ah.moveTo(cx + 7, cy - 13);
        ah.lineTo(cx + 7, cy - 5);
        ah.lineTo(cx + 12, cy - 9);
        ah.close();
        canvas.drawPath(ah, pf);
        break;

      case 'spendlist':
        final listRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 24),
          const Radius.circular(4),
        );
        canvas.drawRRect(listRect, p);
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        final c1 = Path();
        c1.moveTo(cx - 7, cy - 5);
        c1.lineTo(cx - 5, cy - 3);
        c1.lineTo(cx - 1, cy - 8);
        canvas.drawPath(c1, lp2);
        canvas.drawLine(Offset(cx + 1, cy - 5), Offset(cx + 7, cy - 5), lp2);
        final c2 = Path();
        c2.moveTo(cx - 7, cy + 1);
        c2.lineTo(cx - 5, cy + 3);
        c2.lineTo(cx - 1, cy - 2);
        canvas.drawPath(c2, lp2);
        canvas.drawLine(Offset(cx + 1, cy + 1), Offset(cx + 7, cy + 1), lp2);
        canvas.drawCircle(
            Offset(cx - 6, cy + 7),
            2,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
        canvas.drawLine(Offset(cx + 1, cy + 7), Offset(cx + 7, cy + 7), lp2);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── RR PAINTER ────────────────────────────────────────────────────────────

class _RRPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  const _RRPainter({required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 11, cy + 11);
    lp.lineTo(cx - 11, cy - 5);
    lp.quadraticBezierTo(cx - 11, cy - 11, cx - 6, cy - 11);
    lp.quadraticBezierTo(cx - 1, cy - 11, cx - 1, cy - 5);
    lp.quadraticBezierTo(cx - 1, cy + 1, cx - 6, cy + 1);
    lp.lineTo(cx - 2, cy + 11);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 11, cy + 11);
    rp.lineTo(cx + 11, cy - 5);
    rp.quadraticBezierTo(cx + 11, cy - 11, cx + 6, cy - 11);
    rp.quadraticBezierTo(cx + 1, cy - 11, cx + 1, cy - 5);
    rp.quadraticBezierTo(cx + 1, cy + 1, cx + 6, cy + 1);
    rp.lineTo(cx + 2, cy + 11);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}