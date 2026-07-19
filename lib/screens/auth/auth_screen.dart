import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  const AuthScreen({super.key, this.isSignUp = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isSignUp;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isSignUp = !_isSignUp);
  }

  void _submit() {
  setState(() => _isLoading = true);
  Future.delayed(const Duration(seconds: 1), () {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final palette = LedgrrColors.mint;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Back button
              Material(
                color: palette.bg2,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: palette.ink,
                      size: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: palette.ink,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: CustomPaint(
                  painter: _RRPainter(
                    leftColor: palette.bg2,
                    rightColor: palette.accent,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                _isSignUp ? 'Create your\naccount' : 'Welcome\nback',
                style: GoogleFonts.syne(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: palette.ink,
                  letterSpacing: -1,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isSignUp
                    ? 'Start understanding your money today.'
                    : 'Your financial clarity is waiting.',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: palette.inkMuted,
                ),
              ),

              const SizedBox(height: 36),

              // Name field — signup only
              if (_isSignUp) ...[
                _buildLabel('Full name', palette),
                const SizedBox(height: 8),
                _buildField(
                  controller: _nameController,
                  hint: 'What should we call you?',
                  palette: palette,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
              ],

              // Email
              _buildLabel('Email', palette),
              const SizedBox(height: 8),
              _buildField(
                controller: _emailController,
                hint: 'you@example.com',
                palette: palette,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Phone — signup only
              if (_isSignUp) ...[
                _buildLabel('Phone number', palette),
                const SizedBox(height: 8),
                _buildField(
                  controller: _phoneController,
                  hint: '+91 00000 00000',
                  palette: palette,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 5),
                Text(
                  'Used for UPI sync and account security only.',
                  style: GoogleFonts.syne(
                    fontSize: 11,
                    color: palette.inkMuted,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Password
              _buildLabel('Password', palette),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.syne(
                          fontSize: 15,
                          color: palette.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: _isSignUp
                              ? 'Create a strong password'
                              : 'Enter your password',
                          hintStyle: GoogleFonts.syne(
                            fontSize: 14,
                            color: palette.inkMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: palette.inkMuted,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!_isSignUp) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: palette.accent,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Submit button
              Material(
                color: _isLoading
                    ? palette.accent.withOpacity(0.7)
                    : palette.accent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isLoading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: palette.accentFg,
                              ),
                            )
                          : Text(
                              _isSignUp ? 'Create account' : 'Sign in',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: palette.accentFg,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp
                        ? 'Already have an account? '
                        : 'New to LEDGRR? ',
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      color: palette.inkMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleMode,
                    child: Text(
                      _isSignUp ? 'Sign in' : 'Create account',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.accent,
                      ),
                    ),
                  ),
                ],
              ),

              if (_isSignUp) ...[
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
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: palette.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Read-only access. No card numbers stored. No transfer permissions. RBI-compliant framework.',
                          style: GoogleFonts.syne(
                            fontSize: 12,
                            color: palette.ink,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, LedgrrPalette palette) {
    return Text(
      text,
      style: GoogleFonts.syne(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: palette.inkMuted,
        letterSpacing: 0.05,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required LedgrrPalette palette,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: palette.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.syne(
          fontSize: 15,
          color: palette.ink,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.syne(
            fontSize: 14,
            color: palette.inkMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
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
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 14, cy + 14);
    lp.lineTo(cx - 14, cy - 6);
    lp.quadraticBezierTo(cx - 14, cy - 14, cx - 8, cy - 14);
    lp.quadraticBezierTo(cx - 2, cy - 14, cx - 2, cy - 6);
    lp.quadraticBezierTo(cx - 2, cy + 2, cx - 8, cy + 2);
    lp.lineTo(cx - 3, cy + 14);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 14, cy + 14);
    rp.lineTo(cx + 14, cy - 6);
    rp.quadraticBezierTo(cx + 14, cy - 14, cx + 8, cy - 14);
    rp.quadraticBezierTo(cx + 2, cy - 14, cx + 2, cy - 6);
    rp.quadraticBezierTo(cx + 2, cy + 2, cx + 8, cy + 2);
    rp.lineTo(cx + 3, cy + 14);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}