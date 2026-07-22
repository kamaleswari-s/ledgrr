import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LogoExportScreen extends StatefulWidget {
  const LogoExportScreen({super.key});

  @override
  State<LogoExportScreen> createState() => _LogoExportScreenState();
}

class _LogoExportScreenState extends State<LogoExportScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _exportPng() async {
    setState(() => _isExporting = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final blob = html.Blob([pngBytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'ledgrr_logo.png')
        ..click();
      html.Url.revokeObjectUrl(url);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Logo Export (temporary)')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  width: 512,
                  height: 512,
                  color: const Color(0xFF071C18),
                  child: CustomPaint(
                    painter: _RRPainter(
                      leftColor: const Color(0xFFD2EDE9),
                      rightColor: const Color(0xFF1A8C7A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isExporting ? null : _exportPng,
                child: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Export as PNG'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Copy of the logo painter, scaled up for a 512x512 canvas.
class _RRPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  const _RRPainter({required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.047
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.047
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 128;

    final lp = Path();
    lp.moveTo(cx - 18 * s, cy + 18 * s);
    lp.lineTo(cx - 18 * s, cy - 8 * s);
    lp.quadraticBezierTo(
        cx - 18 * s, cy - 18 * s, cx - 10 * s, cy - 18 * s);
    lp.quadraticBezierTo(
        cx - 2 * s, cy - 18 * s, cx - 2 * s, cy - 8 * s);
    lp.quadraticBezierTo(
        cx - 2 * s, cy + 2 * s, cx - 10 * s, cy + 2 * s);
    lp.lineTo(cx - 4 * s, cy + 18 * s);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 18 * s, cy + 18 * s);
    rp.lineTo(cx + 18 * s, cy - 8 * s);
    rp.quadraticBezierTo(
        cx + 18 * s, cy - 18 * s, cx + 10 * s, cy - 18 * s);
    rp.quadraticBezierTo(
        cx + 2 * s, cy - 18 * s, cx + 2 * s, cy - 8 * s);
    rp.quadraticBezierTo(
        cx + 2 * s, cy + 2 * s, cx + 10 * s, cy + 2 * s);
    rp.lineTo(cx + 4 * s, cy + 18 * s);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}