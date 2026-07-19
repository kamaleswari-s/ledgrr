import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../setup/setup_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  const AuthScreen({super.key, this.isSignUp = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isSignUp;
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  PasswordStrength _passwordStrength = const PasswordStrength(
    level: PasswordLevel.empty,
    score: 0,
    maxScore: 5,
    tips: [],
    label: '',
  );

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordStrength =
          AuthService.checkPasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        if (_nameController.text.trim().isEmpty) throw 'Please enter your name.';
        if (_emailController.text.trim().isEmpty) throw 'Please enter your email.';
        if (_passwordController.text.isEmpty) throw 'Please enter a password.';
        if (_passwordController.text != _confirmPasswordController.text) {
          throw 'Passwords do not match.';
        }
        if (_passwordStrength.level == PasswordLevel.weak) {
          throw 'Your password is too weak. Make it stronger.';
        }
        await _authService.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        if (_emailController.text.trim().isEmpty) throw 'Please enter your email.';
        if (_passwordController.text.isEmpty) throw 'Please enter your password.';
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SetupScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength.level) {
      case PasswordLevel.weak:
        return const Color(0xFFE53935);
      case PasswordLevel.medium:
        return const Color(0xFFF57C00);
      case PasswordLevel.strong:
        return const Color(0xFF1A8C7A);
      default:
        return Colors.transparent;
    }
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
                    child: Icon(Icons.arrow_back_rounded,
                        color: palette.ink, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                      rightColor: palette.accent),
                ),
              ),
              const SizedBox(height: 24),
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

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFE53935).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Color(0xFFE53935), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: GoogleFonts.syne(
                                fontSize: 13,
                                color: const Color(0xFFE53935))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_isSignUp) ...[
                _buildLabel('Full name', palette),
                const SizedBox(height: 8),
                _buildField(
                    controller: _nameController,
                    hint: 'What should we call you?',
                    palette: palette,
                    keyboardType: TextInputType.name),
                const SizedBox(height: 16),
              ],

              _buildLabel('Email', palette),
              const SizedBox(height: 8),
              _buildField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  palette: palette,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              if (_isSignUp) ...[
                _buildLabel('Phone number', palette),
                const SizedBox(height: 8),
                _buildField(
                    controller: _phoneController,
                    hint: '+91 00000 00000',
                    palette: palette,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 5),
                Text('Used for UPI sync and account security only.',
                    style: GoogleFonts.syne(
                        fontSize: 11, color: palette.inkMuted)),
                const SizedBox(height: 16),
              ],

              _buildLabel('Password', palette),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _passwordController,
                hint: _isSignUp
                    ? 'Create a strong password'
                    : 'Enter your password',
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                palette: palette,
              ),

              if (_isSignUp && _passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                _PasswordStrengthMeter(
                  strength: _passwordStrength,
                  strengthColor: _strengthColor,
                  palette: palette,
                ),
              ],

              if (_isSignUp) ...[
                const SizedBox(height: 16),
                _buildLabel('Confirm password', palette),
                const SizedBox(height: 8),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hint: 'Re-enter your password',
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  palette: palette,
                ),
                if (_confirmPasswordController.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        _passwordController.text ==
                                _confirmPasswordController.text
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                        size: 14,
                        color: _passwordController.text ==
                                _confirmPasswordController.text
                            ? const Color(0xFF1A8C7A)
                            : const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _passwordController.text ==
                                _confirmPasswordController.text
                            ? 'Passwords match'
                            : 'Passwords do not match',
                        style: GoogleFonts.syne(
                          fontSize: 11,
                          color: _passwordController.text ==
                                  _confirmPasswordController.text
                              ? const Color(0xFF1A8C7A)
                              : const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              if (!_isSignUp) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Forgot password?',
                      style: GoogleFonts.syne(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: palette.accent)),
                ),
              ],

              const SizedBox(height: 32),

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
                                  color: palette.accentFg),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp
                        ? 'Already have an account? '
                        : 'New to LEDGRR? ',
                    style: GoogleFonts.syne(
                        fontSize: 13, color: palette.inkMuted),
                  ),
                  GestureDetector(
                    onTap: _toggleMode,
                    child: Text(
                      _isSignUp ? 'Sign in' : 'Create account',
                      style: GoogleFonts.syne(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.accent),
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
                      Icon(Icons.lock_outline_rounded,
                          size: 15, color: palette.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Read-only access. No card numbers stored. No transfer permissions. RBI-compliant framework.',
                          style: GoogleFonts.syne(
                              fontSize: 12,
                              color: palette.ink,
                              height: 1.55),
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
    return Text(text,
        style: GoogleFonts.syne(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: palette.inkMuted,
            letterSpacing: 0.05));
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
        style: GoogleFonts.syne(fontSize: 15, color: palette.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.syne(fontSize: 14, color: palette.inkMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required LedgrrPalette palette,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: palette.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: GoogleFonts.syne(fontSize: 15, color: palette.ink),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.syne(
                    fontSize: 14, color: palette.inkMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: palette.inkMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;
  final Color strengthColor;
  final LedgrrPalette palette;

  const _PasswordStrengthMeter({
    required this.strength,
    required this.strengthColor,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            final filled = i < strength.score;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: filled ? strengthColor : palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        if (strength.level != PasswordLevel.empty)
          Text(strength.label,
              style: GoogleFonts.syne(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: strengthColor)),
        if (strength.tips.isNotEmpty) ...[
          const SizedBox(height: 6),
          ...strength.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Icon(Icons.arrow_right_rounded,
                        size: 14, color: palette.inkMuted),
                    const SizedBox(width: 4),
                    Text(tip,
                        style: GoogleFonts.syne(
                            fontSize: 11, color: palette.inkMuted)),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

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