import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';
import '../../config/api_keys.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _transactionService = TransactionService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  List<_Message> _messages = [];
  bool _isLoading = false;
  String _userContext = '';

  final List<String> _quickPrompts = [
    'How much have I spent today?',
    'How much have I spent this week?',
    'How much have I spent this month?',
    'What is my top spending category?',
    'Am I within my budget?',
    'Can I afford to eat out this week?',
    'What if I cancelled all my subscriptions?',
    'What if I saved ₹500 more every month?',
    'How am I doing financially this month?',
    'What should I focus on this month?',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserContext();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Pulls fresh numbers from Firestore. Called on screen open AND
  // right before every single message is sent — never relies on a
  // stale snapshot from whenever the chat happened to be opened.
  // This is what makes Ask Your Money genuinely real-time: log a
  // transaction, ask a question thirty seconds later, get an answer
  // built on the new number, not the old one.
  Future<void> _loadUserContext() async {
    try {
      final now = DateTime.now();
      final uid = _uid;

      final userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final name =
          (userData['name'] as String? ?? 'Student').split(' ').first;
      final monthlyIncome =
          (userData['monthlyIncome'] as num?)?.toDouble() ?? 0;
      final monthlyBudget =
          (userData['monthlyBudget'] as num?)?.toDouble() ?? 0;

      final todaySummary = await _transactionService.getDailySummary(now);
      final weekSummary = await _transactionService.getWeeklySummary();
      final monthSummary = await _transactionService.getMonthlySummary(
        now.year, now.month,
      );

      final todayIncome = todaySummary['income'] ?? 0.0;
      final todayExpense = todaySummary['expense'] ?? 0.0;
      final weekIncome = weekSummary['income'] ?? 0.0;
      final weekExpense = weekSummary['expense'] ?? 0.0;
      final monthIncome = monthSummary['income'] ?? 0.0;
      final monthExpense = monthSummary['expense'] ?? 0.0;
      final monthSavings = monthIncome - monthExpense;

      final balance = await _transactionService.getTrueBalance();

      final categories = await _transactionService.getCategorySpending(
        now.year, now.month,
      );
      final sortedCats = categories.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topCats = sortedCats
          .take(5)
          .map((e) =>
              '${e.key}: ₹${e.value.toStringAsFixed(0)}')
          .join(', ');

      final eventsSnapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('events')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('date',
              isLessThanOrEqualTo: Timestamp.fromDate(
                  now.add(const Duration(days: 30))))
          .orderBy('date')
          .get();

      final events = eventsSnapshot.docs.map((d) {
        final data = d.data();
        final date = (data['date'] as Timestamp).toDate();
        final days = date.difference(now).inDays;
        final budget =
            (data['budget'] as num?)?.toDouble() ?? 0;
        final saved =
            (data['savedAmount'] as num?)?.toDouble() ?? 0;
        return '${data['name']} in $days days (goal: ₹${budget.toStringAsFixed(0)}, saved: ₹${saved.toStringAsFixed(0)})';
      }).join('; ');

      final txSnapshot =
          await _transactionService.getTransactionsStream().first;
      final txCount = txSnapshot.docs.length;

      _userContext = '''
'You are LEDGRR\'s financial assistant for Indian students. Be honest, direct, and personal — like a trusted friend who knows their finances. Never give generic advice. Always use their actual numbers. Keep answers under 120 words. Do not use bullet points. Speak only in plain conversational English. Never use Hindi, Tamil, or any other language. Never say Namaste or any non-English greeting. Always greet in English only. Never tell the user you will remember something for next time. You do not have memory between sessions. If they share information in chat, use it only for this conversation. You have data for three different time frames — today, this week (last 7 days), and this month. Always match your answer to the time frame the user actually asks about. If they say "today", use today\'s numbers. If they say "this week", use the week numbers. If they don\'t specify, default to this month.',

User: $name
True Balance: ₹${balance.toStringAsFixed(0)}
Monthly income setting: ₹${monthlyIncome.toStringAsFixed(0)}
Monthly budget limit: ₹${monthlyBudget.toStringAsFixed(0)}

Today — income: ₹${todayIncome.toStringAsFixed(0)}, expense: ₹${todayExpense.toStringAsFixed(0)}
This week (last 7 days) — income: ₹${weekIncome.toStringAsFixed(0)}, expense: ₹${weekExpense.toStringAsFixed(0)}
This month — income: ₹${monthIncome.toStringAsFixed(0)}, expense: ₹${monthExpense.toStringAsFixed(0)}, savings: ₹${monthSavings.toStringAsFixed(0)}

Top spending categories this month: ${topCats.isEmpty ? 'No data yet' : topCats}
Upcoming events (next 30 days): ${events.isEmpty ? 'None' : events}
Total transactions logged: $txCount

Answer their question using only this data, matched to the correct time frame. If they ask something you cannot answer from this data, say so honestly. Never make up numbers.
''';
    } catch (e) {
      _userContext =
          'You are LEDGRR\'s financial assistant for Indian students. Speak only in plain conversational English. Never use Hindi, Tamil, or any other language. Never say Namaste or any other greeting in any language. The user\'s data could not be loaded right now. Tell them honestly that something went wrong loading their data, and to try again in a moment.';
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

        setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.every((r) => r == ConnectivityResult.none);
    if (isOffline) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(_Message(
            text:
                'Ask Your Money needs an internet connection to work. Try again once you\'re back online.',
            isUser: false,
          ));
        });
      }
      _scrollToBottom();
      return;
    }

    // Refresh context right before this message goes out, so every
    // answer reflects whatever was logged up to this exact second —
    // not whatever the numbers happened to be when the chat opened.
    await _loadUserContext();

    try {
      final messages = [
        {'role': 'system', 'content': _userContext},
        ..._messages
            .where((m) => !m.isLoading)
            .map((m) => {
                  'role': m.isUser ? 'user' : 'assistant',
                  'content': m.text,
                }),
      ];

      final response = await http.post(
        Uri.parse(
            'https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'openai/gpt-oss-120b',
          'messages': messages,
          'max_tokens': 200,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content']
            as String;
        if (mounted) {
          setState(() {
            _isLoading = false;
            _messages.add(_Message(text: reply.trim(), isUser: false));
          });
        }
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(_Message(
            text:
                'Something went wrong. Check your connection and try again.',
            isUser: false,
          ));
        });
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;

    return Scaffold(
      backgroundColor: palette.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ask Your',
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                              letterSpacing: -0.5)),
                      Text('Money',
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.accent,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const Spacer(),
                  if (_messages.isNotEmpty)
                    Material(
                      color: palette.bg2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            setState(() => _messages.clear()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(12),
                            border:
                                Border.all(color: palette.border),
                          ),
                          child: Text('Clear',
                              style: GoogleFonts.syne(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: palette.inkMuted)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 11, color: palette.inkMuted),
                  const SizedBox(width: 5),
                  Text(
                    'Your data is summarized and sent securely. Nothing is stored.',
                    style: GoogleFonts.syne(
                        fontSize: 11, color: palette.inkMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(palette)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                          24, 0, 24, 16),
                      itemCount:
                          _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == _messages.length && _isLoading) {
                          return _buildTypingIndicator(palette);
                        }
                        final msg = _messages[i];
                        return _buildMessage(msg, palette);
                      },
                    ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.bg2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.syne(
                            fontSize: 14, color: palette.ink),
                        decoration: InputDecoration(
                          hintText: 'Ask anything about your money...',
                          hintStyle: GoogleFonts.syne(
                              fontSize: 13,
                              color: palette.inkMuted),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: _sendMessage,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _isLoading
                          ? null
                          : () => _sendMessage(_controller.text),
                      child: Container(
                        width: 48, height: 48,
                        child: _isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: palette.accentFg),
                              )
                            : Icon(Icons.send_rounded,
                                color: palette.accentFg, size: 20),
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

  Widget _buildEmptyState(LedgrrPalette palette) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.isDark ? palette.bg2 : palette.ink,
              borderRadius: BorderRadius.circular(20),
              border: palette.isDark
                  ? Border.all(color: palette.border)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ask me anything.',
                    style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: palette.isDark
                            ? palette.ink
                            : Colors.white,
                        letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text(
                  'I know your balance, your spending, your upcoming events. Ask in plain English and I will answer with your actual numbers.',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: palette.isDark
                          ? palette.inkMuted
                          : Colors.white70,
                      height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Try asking',
              style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.inkMuted)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickPrompts.map((prompt) {
              return GestureDetector(
                onTap: () => _sendMessage(prompt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.border),
                  ),
                  child: Text(prompt,
                      style: GoogleFonts.syne(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: palette.ink)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_Message msg, LedgrrPalette palette) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: palette.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('RR',
                    style: GoogleFonts.syne(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: palette.accentFg)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? palette.accent
                    : palette.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: palette.border),
              ),
              child: Text(msg.text,
                  style: GoogleFonts.syne(
                      fontSize: 14,
                      color: isUser
                          ? palette.accentFg
                          : palette.ink,
                      height: 1.5)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(LedgrrPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('RR',
                  style: GoogleFonts.syne(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: palette.accentFg)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0, palette: palette),
                const SizedBox(width: 4),
                _Dot(delay: 150, palette: palette),
                const SizedBox(width: 4),
                _Dot(delay: 300, palette: palette),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isLoading;

  const _Message({
    required this.text,
    required this.isUser,
    this.isLoading = false,
  });
}

class _Dot extends StatefulWidget {
  final int delay;
  final LedgrrPalette palette;

  const _Dot({required this.delay, required this.palette});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          color: widget.palette.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}