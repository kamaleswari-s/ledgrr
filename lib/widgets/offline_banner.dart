import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// A slim banner that appears at the very top of the screen whenever
// the device has no internet connection, and disappears the instant
// it reconnects. This doesn't fix every screen's individual loading
// state, it just makes sure the user always understands *why*
// something isn't updating, instead of staring at a stuck spinner
// with no explanation.
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInitial();
    Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted) setState(() => _isOffline = offline);
    });
  }

  Future<void> _checkInitial() async {
    final result = await Connectivity().checkConnectivity();
    final offline = result.every((r) => r == ConnectivityResult.none);
    if (mounted) setState(() => _isOffline = offline);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _isOffline ? 34 : 0,
          color: const Color(0xFFE53935),
          child: _isOffline
              ? Center(
                  child: Text(
                    'You\'re offline. Some things may not update right now.',
                    style: GoogleFonts.syne(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                )
              : null,
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}