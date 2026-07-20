import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
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
      final categorySpending = await _transactionService.getCategorySpending(
        _now.year, _now.month,
      );

      // Build weekly data for bar chart
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
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
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
    const palette = LedgrrColors.mint;

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
                  Text(
                    'Statistics',
                    style: GoogleFonts.syne(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: palette.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_monthName(_now.month)} ${_now.year}',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: palette.inkMuted,
                    ),
                  ),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
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
                        color: palette.accent,
                        strokeWidth: 2,
                      ),
                    )
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Income vs Expense cards
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
                    Text(
                      'Savings this month',
                      style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.inkMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${savingsRate.toStringAsFixed(0)}% saved',
                      style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: savings >= 0
                            ? palette.accent
                            : const Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatAmount(savings.abs()),
                  style: GoogleFonts.syne(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: savings >= 0
                        ? palette.ink
                        : const Color(0xFFE53935),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress bar
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

          // Income vs Expense donut chart
          Text(
            'Income vs Expense',
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
          ),

          const SizedBox(height: 14),

          if (_totalIncome == 0 && _totalExpense == 0)
            _EmptyChart(palette: palette, message: 'Add transactions to see your chart')
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
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: _totalExpense,
                            color: const Color(0xFFB5446E),
                            title: 'Spent',
                            radius: 60,
                            titleStyle: GoogleFonts.syne(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
                          value: _formatAmount(_totalIncome)),
                      const SizedBox(width: 24),
                      _LegendItem(
                          color: const Color(0xFFB5446E),
                          label: 'Spent',
                          value: _formatAmount(_totalExpense)),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Daily spending bar chart
          Text(
            'Last 7 days',
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
          ),

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
                      child: Text(
                        'No data yet',
                        style: GoogleFonts.syne(
                          fontSize: 13,
                          color: palette.inkMuted,
                        ),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _weeklyData
                            .map((d) => (d['expense'] as double))
                            .fold(0.0, (a, b) => a > b ? a : b) *
                            1.2,
                        barGroups: _weeklyData.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value['expense'] as double,
                                color: palette.accent,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < _weeklyData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      _weeklyData[index]['day'],
                                      style: GoogleFonts.syne(
                                        fontSize: 10,
                                        color: palette.inkMuted,
                                      ),
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
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: palette.border,
                            strokeWidth: 0.5,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ),
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
            Text(
              'No expense data yet',
              style: GoogleFonts.syne(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add some expenses to see your\nspending breakdown.',
              style: GoogleFonts.syne(
                fontSize: 13,
                color: palette.inkMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sortedCategories = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = _categorySpending.values.fold(0.0, (a, b) => a + b);

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
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 55,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total spent: ${_formatAmount(total)}',
                  style: GoogleFonts.syne(
                    fontSize: 12,
                    color: palette.inkMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Breakdown by category',
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
          ),

          const SizedBox(height: 12),

          // Category list
          ...sortedCategories.asMap().entries.map((e) {
            final color = _chartColors[e.key % _chartColors.length];
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
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _capitalize(e.value.key),
                            style: GoogleFonts.syne(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                            ),
                          ),
                        ),
                        Text(
                          _formatAmount(e.value.value),
                          style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: palette.ink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: GoogleFonts.syne(
                            fontSize: 11,
                            color: palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: palette.bg2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
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
          Text(
            label,
            style: GoogleFonts.syne(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: palette.inkMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isPositive ? palette.accent : const Color(0xFFB5446E),
              letterSpacing: -0.5,
            ),
          ),
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

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
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

  const _EmptyChart({required this.palette, required this.message});

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
        child: Text(
          message,
          style: GoogleFonts.syne(fontSize: 13, color: palette.inkMuted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}