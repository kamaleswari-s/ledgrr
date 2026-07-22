import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../providers/theme_provider.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  final _budgetController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String _selectedTheme = 'Deep Mint';
  String? _email;

  final List<String> _lightThemeNames = [
    'Deep Mint',
    'Dusty Rose',
    'Slate Blue',
    'Clay Violet',
    'Sunset Peach',
  ];

  final List<String> _darkThemeNames = [
    'Aurora',
    'Obsidian',
    'Cosmos',
    'Ember',
    'Steel and Jade',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data();
      if (mounted) {
        setState(() {
          _nameController.text = data?['name'] ?? '';
          _incomeController.text =
              (data?['monthlyIncome'] as num?)?.toStringAsFixed(0) ?? '';
          _budgetController.text =
              (data?['monthlyBudget'] as num?)?.toStringAsFixed(0) ?? '';
          _email = data?['email'] ?? _auth.currentUser?.email ?? '';
          _selectedTheme = data?['theme'] ?? 'Deep Mint';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final uid = _auth.currentUser!.uid;
      await _db.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'monthlyIncome':
            double.tryParse(_incomeController.text.trim()) ?? 0,
        'monthlyBudget':
            double.tryParse(_budgetController.text.trim()) ?? 0,
        'theme': _selectedTheme,
      });
      await _auth.currentUser
          ?.updateDisplayName(_nameController.text.trim());
      if (mounted) {
        final p = context.read<ThemeProvider>().palette;
        context.read<ThemeProvider>().setTheme(_selectedTheme);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved.',
                style: GoogleFonts.syne(
                    fontSize: 13, color: p.accentFg)),
            backgroundColor: p.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save. Try again.',
                style: GoogleFonts.syne(
                    fontSize: 13, color: Colors.white)),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;

    // For the user card we always want dark background with light text
    // In light themes: use palette.ink (dark) with white text
    // In dark themes: use palette.card with palette.ink text
    final cardBg = palette.isDark ? palette.card : palette.ink;
    final cardNameColor = palette.isDark ? palette.ink : Colors.white;
    final cardEmailColor =
        palette.isDark ? palette.inkMuted : Colors.white60;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: palette.accent, strokeWidth: 2))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Text('Profile',
                            style: GoogleFonts.syne(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: palette.ink,
                                letterSpacing: -0.5)),
                        const Spacer(),
                        Material(
                          color: palette.accent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _isSaving ? null : _saveChanges,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: _isSaving
                                  ? SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: palette.accentFg))
                                  : Text('Save',
                                      style: GoogleFonts.syne(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: palette.accentFg)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // User card — always readable
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: palette.isDark
                            ? Border.all(color: palette.border)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: palette.accent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text[0].toUpperCase()
                                    : 'L',
                                style: GoogleFonts.syne(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: palette.accentFg),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text
                                      : 'LEDGRR User',
                                  style: GoogleFonts.syne(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: cardNameColor),
                                ),
                                const SizedBox(height: 3),
                                Text(_email ?? '',
                                    style: GoogleFonts.syne(
                                        fontSize: 12,
                                        color: cardEmailColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionLabel('Personal', palette),
                    const SizedBox(height: 12),
                    _editField(
                      label: 'Full name',
                      controller: _nameController,
                      hint: 'Your name',
                      palette: palette,
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 24),

                    _sectionLabel('Financial settings', palette),
                    const SizedBox(height: 12),
                    _editField(
                      label: 'Approximate monthly income or allowance (₹)',
                      controller: _incomeController,
                      hint: '0',
                      palette: palette,
                      keyboardType: TextInputType.number,
                      helpText:
                          'Used as a reference for insights. Your actual balance is always calculated from your logged transactions.',
                    ),
                    const SizedBox(height: 14),
                    _editField(
                      label: 'Monthly spending limit (₹)',
                      controller: _budgetController,
                      hint: '0',
                      palette: palette,
                      keyboardType: TextInputType.number,
                      helpText:
                          'A soft guide for monthly spending. Log your actual transactions and LEDGRR will tell you where you stand.',
                    ),

                    const SizedBox(height: 24),

                    _sectionLabel('Theme', palette),
                    const SizedBox(height: 12),

                    _DropdownField(
                      label: 'Light theme',
                      value: _lightThemeNames.contains(_selectedTheme)
                          ? _selectedTheme
                          : null,
                      items: _lightThemeNames,
                      hint: 'Select a light theme',
                      palette: palette,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTheme = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    _DropdownField(
                      label: 'Dark theme',
                      value: _darkThemeNames.contains(_selectedTheme)
                          ? _selectedTheme
                          : null,
                      items: _darkThemeNames,
                      hint: 'Select a dark theme',
                      palette: palette,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTheme = val);
                      },
                    ),

                    if (_selectedTheme.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: palette.bg2,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.palette_outlined,
                                color: palette.accent, size: 16),
                            const SizedBox(width: 10),
                            Text('Selected: $_selectedTheme',
                                style: GoogleFonts.syne(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: palette.ink)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    _sectionLabel('About', palette),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        children: [
                          _infoRow('App', 'LEDGRR v1.0.0', palette),
                          Divider(height: 20, color: palette.border),
                          _infoRow('Currency', '₹ Indian Rupee', palette),
                          Divider(height: 20, color: palette.border),
                          _infoRow('Data', 'Firebase — Mumbai', palette),
                          Divider(height: 20, color: palette.border),
                          _infoRow('Access',
                              'Only visible when you\'re signed in', palette),
                          Divider(height: 20, color: palette.border),
                          _infoRow('Security',
                              'Your data is private to your account',
                              palette),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Material(
                      color: palette.isDark
                          ? const Color(0xFF3A0A0A)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _signOut,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text('Sign out',
                                style: GoogleFonts.syne(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFE53935))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String text, LedgrrPalette palette) {
    return Text(text,
        style: GoogleFonts.syne(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: palette.inkMuted,
            letterSpacing: 0.04));
  }

  Widget _editField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required LedgrrPalette palette,
    TextInputType keyboardType = TextInputType.text,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.syne(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.inkMuted,
                letterSpacing: 0.04)),
        const SizedBox(height: 6),
        Container(
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
                  fontSize: 14, color: palette.inkMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (helpText != null) ...[
          const SizedBox(height: 5),
          Text(helpText,
              style: GoogleFonts.syne(
                  fontSize: 11, color: palette.inkMuted, height: 1.4)),
        ],
      ],
    );
  }

  Widget _infoRow(String label, String value, LedgrrPalette palette) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.syne(
                fontSize: 13, color: palette.inkMuted)),
        const Spacer(),
        Text(value,
            style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.ink)),
      ],
    );
  }
}

// ─── DROPDOWN FIELD ────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String hint;
  final LedgrrPalette palette;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.hint,
    required this.palette,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.syne(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.inkMuted,
                letterSpacing: 0.04)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: palette.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint,
                  style: GoogleFonts.syne(
                      fontSize: 14, color: palette.inkMuted)),
              isExpanded: true,
              dropdownColor: palette.card,
              style: GoogleFonts.syne(
                fontSize: 14,
                color: palette.ink,
              ),
              icon: Icon(Icons.expand_more_rounded,
                  color: palette.inkMuted, size: 20),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item,
                            style: GoogleFonts.syne(
                                fontSize: 14, color: palette.ink)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}