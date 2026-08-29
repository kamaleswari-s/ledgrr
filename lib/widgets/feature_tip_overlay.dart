import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class FeatureTip {
  final String icon;
  final String title;
  final String description;

  const FeatureTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// Shows a sequence of bottom tip cards, one at a time, dimming the rest
// of the screen slightly. Never shows again once completed or skipped,
// tracked via a SharedPreferences flag unique to this tour.
class FeatureTipOverlay extends StatefulWidget {
  final List<FeatureTip> tips;
  final VoidCallback onFinished;

  const FeatureTipOverlay({
    super.key,
    required this.tips,
    required this.onFinished,
  });

  static const String _seenKey = 'hasSeenHomeFeatureTour';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_seenKey) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }

  @override
  State<FeatureTipOverlay> createState() => _FeatureTipOverlayState();
}

class _FeatureTipOverlayState extends State<FeatureTipOverlay> {
  int _index = 0;

  void _next() {
    if (_index < widget.tips.length - 1) {
      setState(() => _index++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await FeatureTipOverlay.markSeen();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tips[_index];
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.45),
        child: Stack(
          children: [
            Positioned(
              left: 20, right: 20, bottom: 90,
              child: _TipCard(
                tip: tip,
                index: _index,
                total: widget.tips.length,
                onNext: _next,
                onSkip: _finish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final FeatureTip tip;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TipCard({
    required this.tip,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  IconData _iconFor(String key) {
    switch (key) {
      case 'add':
        return Icons.add_rounded;
      case 'camera':
        return Icons.camera_alt_outlined;
      case 'ghost':
        return Icons.blur_on_rounded;
      case 'dues':
        return Icons.swap_horiz_rounded;
      case 'ask':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = LedgrrColors.mint;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: palette.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconFor(tip.icon),
                      color: palette.accent, size: 22),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSkip,
                  child: Icon(Icons.close_rounded,
                      color: palette.inkMuted, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(tip.title,
                style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: palette.ink)),
            const SizedBox(height: 6),
            Text(tip.description,
                style: GoogleFonts.syne(
                    fontSize: 13, color: palette.inkMuted, height: 1.5)),
            const SizedBox(height: 16),
            Row(
              children: [
                Row(
                  children: List.generate(total, (i) {
                    return Container(
                      margin: const EdgeInsets.only(right: 5),
                      width: i == index ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == index
                            ? palette.accent
                            : palette.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                Material(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onNext,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: Text(
                        index == total - 1 ? 'Got it' : 'Next',
                        style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: palette.accentFg),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}