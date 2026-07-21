import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _transactionService = TransactionService();
  final _now = DateTime.now();
  bool _isLoading = true;

  double _totalIncome = 0;
  double _totalExpense = 0;
  Map<String, double> _categorySpending = {};
  List<Map<String, dynamic>> _weeklyData = [];
  int _totalTransactionCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final summary = await _transactionService.getMonthlySummary(
        _now.year, _now.month,
      );
      final categorySpending =
          await _transactionService.getCategorySpending(
        _now.year, _now.month,
      );

      // Get total transaction count for data gate
      final allStream = _transactionService.getTransactionsStream();
      final allSnapshot = await allStream.first;
      final count = allSnapshot.docs.length;

      // Build weekly data
      final weeklyData = <Map<String, dynamic>>[];
      for (int i = 6; i >= 0; i--) {
        final date = _now.subtract(Duration(days: i));
        final dayData = await _transactionService.getMonthlySummary(
          date.year, date.month,
        );
        weeklyData.add({
          'day': _dayLabel(date.weekday),
          'expense': dayData['expense'] ?? 0,
          'income': dayData['income'] ?? 0,
        });
      }

      if (mounted) {
        setState(() {
          _totalIncome = summary['income'] ?? 0;
          _totalExpense = summary['expense'] ?? 0;
          _categorySpending = categorySpending;
          _weeklyData = weeklyData;
          _totalTransactionCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _dayLabel(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatAmount(double amount) {
    if (amount >= 100000)
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // ─── SPENDER IDENTITY ────────────────────────────────────────────────────

  Map<String, String> _getSpenderIdentity() {
    if (_totalTransactionCount < 10) {
      return {
        'type': 'The Explorer',
        'description':
            'You are just getting started. Log more transactions and LEDGRR will reveal your true spender identity.',
        'tip': 'Log at least 10 transactions to unlock your full profile.',
        'locked': 'true',
      };
    }

    final savings = _totalIncome - _totalExpense;
    final savingsRate =
        _totalIncome > 0 ? savings / _totalIncome : 0.0;
    final topCategory = _categorySpending.isNotEmpty
        ? _categorySpending.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : null;

    final foodSpending = (_categorySpending['food'] ?? 0) +
        (_categorySpending['dining'] ?? 0) +
        (_categorySpending['coffee'] ?? 0) +
        (_categorySpending['groceries'] ?? 0);
    final socialSpending = (_categorySpending['social'] ?? 0) +
        (_categorySpending['entertainment'] ?? 0);
    final subSpending =
        _categorySpending['subscriptions'] ?? 0;

    // Steady Saver
    if (savingsRate >= 0.2) {
      return {
        'type': 'The Steady Saver',
        'description':
            'You save more than 20% of your income consistently. This is genuinely rare and powerful. Keep this up.',
        'tip':
            'Consider moving your savings into an FD or SIP to put them to work.',
        'locked': 'false',
      };
    }

    // Subscriptions Trap
    if (_totalExpense > 0 && subSpending / _totalExpense > 0.2) {
      return {
        'type': 'The Subscriptions Trap',
        'description':
            'More than 20% of your spending goes to subscriptions. Run Ghost Money Detector to see what you might be forgetting.',
        'tip':
            'Cancel any subscription you have not used in the last 30 days.',
        'locked': 'false',
      };
    }

    // Social Spender
    if (_totalExpense > 0 &&
        socialSpending / _totalExpense > 0.25) {
      return {
        'type': 'The Social Spender',
        'description':
            'Food, outings, and entertainment dominate your spending. Your money follows your social life.',
        'tip':
            'Set a weekly social budget and stick to it. Pre-decide the limit before the weekend.',
        'locked': 'false',
      };
    }

    // Comfort Buyer
    if (_totalExpense > 0 &&
        foodSpending / _totalExpense > 0.35) {
      return {
        'type': 'The Comfort Buyer',
        'description':
            'Food and dining take up more than a third of your spending. Comfort spending is real — just make it intentional.',
        'tip':
            'Try cooking twice a week and see how much you save by month end.',
        'locked': 'false',
      };
    }

    // Feast or Famine
    if (savingsRate < 0) {
      return {
        'type': 'The Feast or Famine',
        'description':
            'You are spending more than you earn this month. This is a signal, not a judgment.',
        'tip':
            'Identify your top 2 expense categories and set a cap for each next month.',
        'locked': 'false',
      };
    }

    // Front Loader — check weekly data
    final firstHalfSpend = _weeklyData
        .take(3)
        .fold(0.0, (sum, d) => sum + (d['expense'] as double));
    final secondHalfSpend = _weeklyData
        .skip(3)
        .fold(0.0, (sum, d) => sum + (d['expense'] as double));

    if (secondHalfSpend > 0 && firstHalfSpend / (secondHalfSpend + 1) > 2) {
      return {
        'type': 'The Front-Loader',
        'description':
            'You spend heavily early in the period and get tight toward the end. Classic pattern.',
        'tip':
            'Divide your budget into weekly chunks at the start of each month.',
        'locked': 'false',
      };
    }

    // Default — Planner
    return {
      'type': 'The Planner',
      'description':
          'Your spending is balanced and relatively consistent. You are building good habits.',
      'tip': topCategory != null
          ? 'Your top category is ${_capitalize(topCategory)}. Keep an eye on it.'
          : 'Keep logging consistently for deeper insights.',
      'locked': 'false',
    };
  }

  // ─── LEDGRR'S TAKE ───────────────────────────────────────────────────────

  List<String> _getInsights() {
    final insights = <String>[];
    final savings = _totalIncome - _totalExpense;
    final savingsRate =
        _totalIncome > 0 ? savings / _totalIncome * 100 : 0.0;

    if (_totalTransactionCount < 5) return insights;

    // Savings insight
    if (savingsRate >= 20) {
      insights.add(
          'You saved ${savingsRate.toStringAsFixed(0)}% of your income this month. That puts you ahead of most students your age.');
    } else if (savingsRate > 0 && savingsRate < 10) {
      insights.add(
          'You saved ${savingsRate.toStringAsFixed(0)}% this month. Small but real. Try to push it to 15% next month.');
    } else if (savings < 0) {
      insights.add(
          'Spending exceeded income by ${_formatAmount(savings.abs())} this month. Review your top 2 categories.');
    }

    // Top category insight
    if (_categorySpending.isNotEmpty) {
      final top = _categorySpending.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      final topPct = _totalExpense > 0
          ? top.value / _totalExpense * 100
          : 0.0;
      if (topPct > 30) {
        insights.add(
            '${_capitalize(top.key)} is your biggest spend at ${topPct.toStringAsFixed(0)}% of total expenses — ₹${top.value.toStringAsFixed(0)}. Is this intentional?');
      }
    }

    // Subscription insight
    final subSpend = _categorySpending['subscriptions'] ?? 0;
    if (subSpend > 0) {
      insights.add(
          'You spent ${_formatAmount(subSpend)} on subscriptions this month. Run Ghost Money Detector to check if all of them are still active.');
    }

    // Positive streak
    if (_totalTransactionCount >= 15 && savings > 0) {
      insights.add(
          'You have logged $_totalTransactionCount transactions this month. The more you log, the more accurate your picture gets.');
    }

    return insights;
  }

  final List<Color> _chartColors = [
    const Color(0xFF1A8C7A),
    const Color(0xFFB5446E),
    const Color(0xFF2D7DD2),
    const Color(0xFF7B5EA7),
    const Color(0xFFE05C2A),
    const Color(0xFF00897B),
    const Color(0xFFEC407A),
    const Color(0xFF558B2F),
    const Color(0xFF5C6BC0),
    const Color(0xFFEF5350),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Text('Statistics',
                      style: GoogleFonts.syne(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: palette.ink,
                          letterSpacing: -0.5)),
                  const Spacer(),
                  Text('${_monthName(_now.month)} ${_now.year}',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: palette.inkMuted)),
                ],
              ),
            ),

            // Tab bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: palette.accentFg,
                  unselectedLabelColor: palette.inkMuted,
                  labelStyle: GoogleFonts.syne(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.syne(
                      fontSize: 13, fontWeight: FontWeight.w400),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Categories'),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: palette.accent, strokeWidth: 2))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(palette),
                        _buildCategoriesTab(palette),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(LedgrrPalette palette) {
    final savings = _totalIncome - _totalExpense;
    final savingsRate = _totalIncome > 0
        ? (savings / _totalIncome * 100).clamp(0, 100)
        : 0.0;
    final identity = _getSpenderIdentity();
    final insights = _getInsights();
    final isLocked = identity['locked'] == 'true';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SPENDER IDENTITY CARD ─────────────────────────────────────
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('Your spender identity',
                          style: GoogleFonts.syne(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: palette.accent)),
                    ),
                    if (isLocked) ...[
                      const Spacer(),
                      Icon(Icons.lock_outline_rounded,
                          color: palette.isDark
                              ? palette.inkMuted
                              : Colors.white38,
                          size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  identity['type']!,
                  style: GoogleFonts.syne(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: palette.isDark
                          ? palette.ink
                          : Colors.white,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  identity['description']!,
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: palette.isDark
                          ? palette.inkMuted
                          : Colors.white70,
                      height: 1.6),
                ),
                if (!isLocked) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            color: palette.accent, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(identity['tip']!,
                              style: GoogleFonts.syne(
                                  fontSize: 12,
                                  color: palette.isDark
                                      ? palette.ink
                                      : Colors.white,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isLocked) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Log ${(10 - _totalTransactionCount).clamp(0, 10)} more transactions to unlock.',
                    style: GoogleFonts.syne(
                        fontSize: 11,
                        color: palette.isDark
                            ? palette.inkMuted
                            : Colors.white54),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── SUMMARY CARDS ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Income',
                  value: _formatAmount(_totalIncome),
                  isPositive: true,
                  palette: palette,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Total Spent',
                  value: _formatAmount(_totalExpense),
                  isPositive: false,
                  palette: palette,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Savings card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Savings this month',
                        style: GoogleFonts.syne(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: palette.inkMuted)),
                    const Spacer(),
                    Text('${savingsRate.toStringAsFixed(0)}% saved',
                        style: GoogleFonts.syne(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: savings >= 0
                                ? palette.accent
                                : const Color(0xFFE53935))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_formatAmount(savings.abs()),
                    style: GoogleFonts.syne(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: savings >= 0
                            ? palette.ink
                            : const Color(0xFFE53935),
                        letterSpacing: -0.5)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (savingsRate / 100).clamp(0.0, 1.0),
                    backgroundColor: palette.bg2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      savings >= 0
                          ? palette.accent
                          : const Color(0xFFE53935),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Income vs Expense chart
          Text('Income vs Expense',
              style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.ink)),
          const SizedBox(height: 14),

          if (_totalIncome == 0 && _totalExpense == 0)
            _EmptyChart(
                palette: palette,
                message:
                    'Add transactions to see your chart')
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: _totalIncome,
                            color: palette.accent,
                            title: 'Income',
                            radius: 60,
                            titleStyle: GoogleFonts.syne(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          PieChartSectionData(
                            value: _totalExpense,
                            color: const Color(0xFFB5446E),
                            title: 'Spent',
                            radius: 60,
                            titleStyle: GoogleFonts.syne(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ],
                        centerSpaceRadius: 50,
                        sectionsSpace: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendItem(
                          color: palette.accent,
                          label: 'Income',
                          value: _formatAmount(_totalIncome),
                          palette: palette),
                      const SizedBox(width: 24),
                      _LegendItem(
                          color: const Color(0xFFB5446E),
                          label: 'Spent',
                          value: _formatAmount(_totalExpense),
                          palette: palette),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Last 7 days bar chart
          Text('Last 7 days',
              style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.ink)),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: SizedBox(
              height: 180,
              child: _weeklyData.isEmpty
                  ? Center(
                      child: Text('No data yet',
                          style: GoogleFonts.syne(
                              fontSize: 13,
                              color: palette.inkMuted)))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _weeklyData
                                .map((d) =>
                                    (d['expense'] as double))
                                .fold(0.0,
                                    (a, b) => a > b ? a : b) *
                            1.2,
                        barGroups: _weeklyData
                            .asMap()
                            .entries
                            .map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value['expense']
                                    as double,
                                color: palette.accent,
                                width: 20,
                                borderRadius:
                                    const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < _weeklyData.length) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                            top: 6),
                                    child: Text(
                                      _weeklyData[index]['day'],
                                      style: GoogleFonts.syne(
                                          fontSize: 10,
                                          color:
                                              palette.inkMuted),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) =>
                              FlLine(
                            color: palette.border,
                            strokeWidth: 0.5,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ),

          // ── LEDGRR'S TAKE ─────────────────────────────────────────────
          if (insights.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text("LEDGRR's take",
                style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: palette.ink)),
            const SizedBox(height: 4),
            Text('Based on your activity this month.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted)),
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(
                              top: 6, right: 10),
                          decoration: BoxDecoration(
                            color: palette.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(insight,
                              style: GoogleFonts.syne(
                                  fontSize: 13,
                                  color: palette.ink,
                                  height: 1.6)),
                        ),
                      ],
                    ),
                  ),
                )),
          ],

          // Data gate message
          if (_totalTransactionCount < 5) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.bg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: palette.accent, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add ${5 - _totalTransactionCount} more transactions to unlock deeper insights and your spender identity.',
                      style: GoogleFonts.syne(
                          fontSize: 12,
                          color: palette.ink,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(LedgrrPalette palette) {
    if (_categorySpending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                color: palette.inkMuted, size: 48),
            const SizedBox(height: 12),
            Text('No expense data yet',
                style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.ink)),
            const SizedBox(height: 6),
            Text(
              'Add some expenses to see your\nspending breakdown.',
              style: GoogleFonts.syne(
                  fontSize: 13, color: palette.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sortedCategories = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total =
        _categorySpending.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Donut chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sortedCategories
                          .asMap()
                          .entries
                          .take(8)
                          .map((e) {
                        final color = _chartColors[
                            e.key % _chartColors.length];
                        final pct = e.value.value / total * 100;
                        return PieChartSectionData(
                          value: e.value.value,
                          color: color,
                          title: pct > 8
                              ? '${pct.toStringAsFixed(0)}%'
                              : '',
                          radius: 55,
                          titleStyle: GoogleFonts.syne(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        );
                      }).toList(),
                      centerSpaceRadius: 55,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Total spent: ${_formatAmount(total)}',
                    style: GoogleFonts.syne(
                        fontSize: 12, color: palette.inkMuted)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('Breakdown by category',
              style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.ink)),
          const SizedBox(height: 12),

          ...sortedCategories.asMap().entries.map((e) {
            final color =
                _chartColors[e.key % _chartColors.length];
            final pct = e.value.value / total * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_capitalize(e.value.key),
                              style: GoogleFonts.syne(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: palette.ink)),
                        ),
                        Text(_formatAmount(e.value.value),
                            style: GoogleFonts.syne(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: palette.ink)),
                        const SizedBox(width: 8),
                        Text('${pct.toStringAsFixed(0)}%',
                            style: GoogleFonts.syne(
                                fontSize: 11,
                                color: palette.inkMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: palette.bg2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ─── SUMMARY CARD ──────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  final LedgrrPalette palette;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.isPositive,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.syne(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: palette.inkMuted)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isPositive
                      ? palette.accent
                      : const Color(0xFFB5446E),
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }
}

// ─── LEGEND ITEM ───────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final LedgrrPalette palette;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.syne(
                    fontSize: 11, color: palette.inkMuted)),
            Text(value,
                style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.ink)),
          ],
        ),
      ],
    );
  }
}

// ─── EMPTY CHART ───────────────────────────────────────────────────────────

class _EmptyChart extends StatelessWidget {
  final LedgrrPalette palette;
  final String message;

  const _EmptyChart(
      {required this.palette, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Center(
        child: Text(message,
            style: GoogleFonts.syne(
                fontSize: 13, color: palette.inkMuted),
            textAlign: TextAlign.center),
      ),
    );
  }
}