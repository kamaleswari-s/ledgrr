import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── RESULT MODEL ───────────────────────────────────────────────────────────

class ArchetypeResult {
  final String id;
  final String name;
  final String tagline;
  final double score;
  final List<String> lessonIds;

  const ArchetypeResult({
    required this.id,
    required this.name,
    required this.tagline,
    required this.score,
    required this.lessonIds,
  });
}

class _ArchetypeMeta {
  final String name;
  final String tagline;
  final List<String> lessonIds;

  const _ArchetypeMeta({
    required this.name,
    required this.tagline,
    required this.lessonIds,
  });
}

// ─── SPENDER ARCHETYPE SERVICE ──────────────────────────────────────────────
//
// Computes a real-time spender personality from actual Firestore data —
// no waiting for month-end. Every call re-reads the last 30 days (plus a
// 90-day window specifically for detecting recurring/ghost charges,
// since those need more history to spot a pattern reliably).
//
// Requires at least `minTransactionsRequired` logged transactions in the
// last 30 days before assigning any archetype at all — below that, the
// signal is too thin to be meaningful, and the caller should just show
// the full lesson library with no personalization banner yet.
//
// This is heuristic, not exact science. Each archetype gets a 0-100
// score from simple, explainable rules on real data (spending timing,
// category shares, dues, jar/event patterns, logging consistency).
// Whichever scores highest wins. Ties are broken by whichever archetype
// appears first in `_archetypeMeta` below, which is ordered roughly by
// how actionable/important that pattern is to surface.
class SpenderArchetypeService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static const int minTransactionsRequired = 5;
  static const Duration _window = Duration(days: 30);
  static const Duration _ghostWindow = Duration(days: 90);

  Future<ArchetypeResult?> computeArchetype() async {
    final uid = _uid;
    final now = DateTime.now();
    final windowStart = now.subtract(_window);

    // ── Pull last 30 days of transactions ──────────────────────────────
    final txSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(windowStart))
        .get();

    final txs = txSnap.docs.map((d) => d.data()).toList();
    if (txs.length < minTransactionsRequired) return null;

    double income = 0;
    double expense = 0;
    final Map<String, double> categoryTotals = {};
    double weekendExpense = 0;
    double firstWeekExpense = 0;
    double untrackedIncome = 0;
    final Set<String> loggedDays = {};

    const untrackedIncomeCategories = {
      'freelance', 'other_income', 'gift', 'refund', 'business',
    };

    for (final t in txs) {
      final type = t['type'] as String? ?? 'expense';
      final amount = (t['amount'] as num?)?.toDouble() ?? 0;
      final category = t['category'] as String? ?? 'other_expense';
      final date = (t['date'] as Timestamp?)?.toDate() ?? now;
      loggedDays.add('${date.year}-${date.month}-${date.day}');

      if (type == 'income') {
        income += amount;
        if (untrackedIncomeCategories.contains(category)) {
          untrackedIncome += amount;
        }
      } else {
        expense += amount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        final isWeekend = date.weekday == DateTime.friday ||
            date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
        if (isWeekend) weekendExpense += amount;
        if (date.day <= 7) firstWeekExpense += amount;
      }
    }

    final totalExpense = expense == 0 ? 1.0 : expense;
    final savingsRate = income > 0 ? (income - expense) / income : 0.0;
    final frontLoadShare = firstWeekExpense / totalExpense;
    final weekendShare = weekendExpense / totalExpense;
    final loggingConsistency = loggedDays.length / 30.0;
    final otherShare = (categoryTotals['other_expense'] ?? 0) / totalExpense;

    const comfortCategories = {
      'food', 'dining', 'coffee', 'shopping',
      'entertainment', 'personalcare', 'social',
    };
    double comfortSpend = 0;
    for (final c in comfortCategories) {
      comfortSpend += categoryTotals[c] ?? 0;
    }
    final comfortShare = comfortSpend / totalExpense;

    // ── Recurring/ghost-like charges — needs a longer window to spot ───
    final ghostSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(now.subtract(_ghostWindow)))
        .get();

    final Map<String, List<DateTime>> ghostCandidates = {};
    for (final d in ghostSnap.docs) {
      final data = d.data();
      if ((data['type'] as String?) != 'expense') continue;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final category = data['category'] as String? ?? '';
      final date = (data['date'] as Timestamp?)?.toDate();
      if (date == null) continue;
      final key = '$category|${amount.round()}';
      ghostCandidates.putIfAbsent(key, () => []).add(date);
    }

    int recurringChargeCount = 0;
    ghostCandidates.forEach((key, dates) {
      if (dates.length < 2) return;
      dates.sort();
      for (int i = 1; i < dates.length; i++) {
        final gap = dates[i].difference(dates[i - 1]).inDays;
        if (gap >= 20 && gap <= 40) {
          recurringChargeCount++;
          break;
        }
      }
    });

    // ── Dues ─────────────────────────────────────────────────────────
    final duesSnap =
        await _db.collection('users').doc(uid).collection('dues').get();
    int activeOwedToMe = 0;
    int activeIOwe = 0;
    for (final d in duesSnap.docs) {
      final data = d.data();
      final current = (data['currentAmount'] as num?)?.toDouble() ?? 0;
      if (current <= 0) continue;
      if (data['direction'] == 'owed_to_me') {
        activeOwedToMe++;
      } else {
        activeIOwe++;
      }
    }

    // ── Savings Jars ─────────────────────────────────────────────────
    final jarsSnap =
        await _db.collection('users').doc(uid).collection('piggybanks').get();
    int activeJars = 0;
    int completedJars = 0;
    bool hasEmergencyJar = false;
    final List<DateTime> jarDepositDates = [];

    for (final j in jarsSnap.docs) {
      final data = j.data();
      final current = (data['currentAmount'] as num?)?.toDouble() ?? 0;
      final goal = (data['goalAmount'] as num?)?.toDouble() ?? 0;
      final name = (data['name'] as String? ?? '').toLowerCase();
      if (name.contains('emergency')) hasEmergencyJar = true;
      if (goal > 0 && current >= goal) {
        completedJars++;
      } else if (current > 0) {
        activeJars++;
      }

      final entriesSnap = await j.reference
          .collection('entries')
          .where('type', isEqualTo: 'deposit')
          .get();
      for (final e in entriesSnap.docs) {
        final date = (e.data()['date'] as Timestamp?)?.toDate();
        if (date != null) jarDepositDates.add(date);
      }
    }

    double jarGapStdDev = 0;
    if (jarDepositDates.length >= 3) {
      jarDepositDates.sort();
      final gaps = <int>[];
      for (int i = 1; i < jarDepositDates.length; i++) {
        gaps.add(jarDepositDates[i].difference(jarDepositDates[i - 1]).inDays);
      }
      final meanGap = gaps.reduce((a, b) => a + b) / gaps.length;
      final variance = gaps
              .map((g) => (g - meanGap) * (g - meanGap))
              .reduce((a, b) => a + b) /
          gaps.length;
      jarGapStdDev = variance > 0 ? sqrt(variance) : 0;
    }

    // ── Event Wallet ─────────────────────────────────────────────────
    final eventsSnap =
        await _db.collection('users').doc(uid).collection('events').get();
    int activeEvents = 0;
    bool hasEmergencyEvent = false;
    int deadlineHeavyEvents = 0;

    for (final e in eventsSnap.docs) {
      final data = e.data();
      final budget = (data['budget'] as num?)?.toDouble() ?? 0;
      final saved = (data['savedAmount'] as num?)?.toDouble() ?? 0;
      final name = (data['name'] as String? ?? '').toLowerCase();
      final date = (data['date'] as Timestamp?)?.toDate();
      if (name.contains('emergency')) hasEmergencyEvent = true;
      if (budget > 0) activeEvents++;
      if (date != null && date.isAfter(now)) {
        final daysLeft = date.difference(now).inDays;
        if (daysLeft <= 5 && saved < budget * 0.5) {
          deadlineHeavyEvents++;
        }
      }
    }

    // ── Score every archetype (0-100, heuristic) ────────────────────
    final scores = <String, double>{};

    scores['ledger_ghost'] =
        loggingConsistency <= 0.4 ? (1 - loggingConsistency) * 90 : 0;

    scores['debt_juggler'] =
        activeIOwe >= 2 ? 60 + activeIOwe * 10 : activeIOwe * 20.0;

    scores['emergency_less_optimist'] =
        (!hasEmergencyJar && !hasEmergencyEvent && savingsRate >= 0)
            ? 55
            : 0;

    scores['subscription_sleepwalker'] =
        recurringChargeCount >= 2 ? 70.0 : 0;

    scores['ghost_host'] =
        recurringChargeCount == 1 ? 55.0 : 0;

    scores['reformed_ghost'] = (recurringChargeCount == 0 &&
            ghostCandidates.values.any((d) => d.length >= 2))
        ? 40
        : 0;

    scores['category_blind_spot'] =
        otherShare >= 0.25 ? 55 + otherShare * 40 : otherShare * 100;

    scores['comfort_buyer'] = comfortShare >= 0.4
        ? 65 + comfortShare * 20
        : comfortShare * 80;

    scores['weekend_warrior'] =
        weekendShare >= 0.5 ? 60 + weekendShare * 20 : weekendShare * 90;

    scores['front_loader'] =
        frontLoadShare >= 0.5 ? 70.0 : frontLoadShare * 100;

    scores['social_spender'] = (activeOwedToMe + activeIOwe) >= 2
        ? 55 + (activeOwedToMe + activeIOwe) * 8
        : (activeOwedToMe + activeIOwe) * 20.0;

    scores['silent_earner'] = (untrackedIncome > 0 && income > 0)
        ? ((untrackedIncome / income) >= 0.2
            ? 60.0
            : (untrackedIncome / income) * 100)
        : 0;

    scores['deadline_saver'] =
        deadlineHeavyEvents >= 1 ? 55 + deadlineHeavyEvents * 15 : 0;

    scores['sprinter_saver'] = jarGapStdDev >= 15 ? 60.0 : jarGapStdDev * 3;

    scores['one_goal_wonder'] =
        (completedJars >= 1 && activeJars == 0 && activeEvents == 0)
            ? 55
            : 0;

    scores['goal_chaser'] =
        (activeJars + activeEvents) >= 3 ? 65.0 : (activeJars + activeEvents) * 15.0;

    scores['steady_saver'] =
        (savingsRate >= 0.15 ? 60 : 0) + (loggingConsistency * 20);

    scores['overcorrector'] = 0; // needs multi-month history — placeholder

    // ── Pick the winner ──────────────────────────────────────────────
    String? bestId;
    double bestScore = 0;
    for (final id in _archetypeMeta.keys) {
      final score = scores[id] ?? 0;
      if (score > bestScore) {
        bestScore = score;
        bestId = id;
      }
    }

    if (bestId == null || bestScore <= 0) return null;

    final meta = _archetypeMeta[bestId]!;
    return ArchetypeResult(
      id: bestId,
      name: meta.name,
      tagline: meta.tagline,
      score: bestScore,
      lessonIds: meta.lessonIds,
    );
  }

  // Ordered roughly by how important/actionable the pattern is —
  // this order also acts as the tie-break priority when two archetypes
  // score identically.
  static final Map<String, _ArchetypeMeta> _archetypeMeta = {
    'ledger_ghost': const _ArchetypeMeta(
      name: 'The Ledger Ghost',
      tagline: 'You barely tell LEDGRR what\'s happening in your money life.',
      lessonIds: [
        'new_inconsistent_logging_cost',
        'f5',
        'new_two_minute_log',
        'new_lose_by_not_knowing',
        'new_logging_as_trigger',
        'new_reconstruct_untracked_month',
      ],
    ),
    'debt_juggler': const _ArchetypeMeta(
      name: 'The Debt Juggler',
      tagline: 'You\'re owing more than one person at once, and letting it stack.',
      lessonIds: [
        'c12',
        'm3',
        'new_debt_map',
        'new_juggling_costs_more',
        'new_snowball_method',
        'new_stop_new_debt_first',
      ],
    ),
    'emergency_less_optimist': const _ArchetypeMeta(
      name: 'The Emergency-less Optimist',
      tagline: 'Doing fine right now, with zero cushion if that changes.',
      lessonIds: [
        'c5',
        'm5',
        'm13',
        'new_wont_happen_to_me',
        'new_build_ef_without_deprivation',
        'new_what_counts_as_emergency',
      ],
    ),
    'subscription_sleepwalker': const _ArchetypeMeta(
      name: 'The Subscription Sleepwalker',
      tagline: 'You see the alert. You still don\'t act on it.',
      lessonIds: [
        'new_default_opt_out_trap',
        'c15',
        'new_why_ignore_same_alert',
        'new_3strike_rule',
        'new_autopay_not_autopilot',
        'new_awareness_to_cancellation',
      ],
    ),
    'ghost_host': const _ArchetypeMeta(
      name: 'The Ghost Host',
      tagline: 'A forgotten recurring charge is quietly living in your account.',
      lessonIds: ['c1', 'f6', 'c8', 'f10', 'new_forgotten_trial', 'new_recurring_audit'],
    ),
    'reformed_ghost': const _ArchetypeMeta(
      name: 'The Reformed Ghost',
      tagline: 'You caught your ghost money and shut it down. Stay sharp.',
      lessonIds: [
        'new_your_new_networth_story',
        'new_redirect_saved_money',
        'new_ghost_to_growth',
        'new_vigilant_after_winning',
        'new_old_ghosts_return',
        'new_fixed_leak_funded_goal',
      ],
    ),
    'category_blind_spot': const _ArchetypeMeta(
      name: 'The Category Blind Spot',
      tagline: '"Other" has quietly become one of your biggest categories.',
      lessonIds: [
        'new_other_dangerous_category',
        'new_15min_recategorization',
        'new_biggest_unlabeled_category',
        'new_categories_matching_life',
        'new_cost_of_vague_labels',
        'new_i_dont_know_where_it_went',
      ],
    ),
    'comfort_buyer': const _ArchetypeMeta(
      name: 'The Comfort Buyer',
      tagline: 'You spend to feel better, not because you planned to.',
      lessonIds: [
        'new_recognizing_triggers',
        'm6',
        'f7',
        'new_24hr_rule',
        'new_replace_reward',
        'new_what_buying_comfort',
      ],
    ),
    'weekend_warrior': const _ArchetypeMeta(
      name: 'The Weekend Warrior',
      tagline: 'Disciplined all week. Then Friday happens.',
      lessonIds: [
        'new_friday_spike',
        'c14',
        'new_plan_fun_not_overspend',
        'new_weekday_discipline_weekend_blind',
        'new_treat_yourself_cost',
        'new_weekend_cap',
      ],
    ),
    'front_loader': const _ArchetypeMeta(
      name: 'The Front-Loader',
      tagline: 'You go hard the first week, then scrape by for the rest.',
      lessonIds: [
        'f1',
        'f13',
        'm7',
        'new_midmonth_cliff',
        'new_envelope_method',
        'new_weekly_reset',
      ],
    ),
    'social_spender': const _ArchetypeMeta(
      name: 'The Social Spender',
      tagline: 'Group plans keep costing more than you expect.',
      lessonIds: [
        'f9',
        'c4',
        'new_fair_share_split',
        'new_saying_no_plan',
        'new_cost_keeping_up',
        'new_enjoy_going_out',
      ],
    ),
    'silent_earner': const _ArchetypeMeta(
      name: 'The Silent Earner',
      tagline: 'Money comes in from a few places, but none of it\'s organized.',
      lessonIds: ['m11', 'f12', 'm2', 'new_untracked_income_disappears', 'new_side_income_own_home', 'new_extra_money_real_budget'],
    ),
    'deadline_saver': const _ArchetypeMeta(
      name: 'The Deadline Saver',
      tagline: 'You only save once the date is nearly here.',
      lessonIds: [
        'c6',
        'new_panic_save_pattern',
        'new_starting_before_ready',
        'new_procrastination_cost_rupees',
        'new_ill_save_later_to_now',
        'new_beat_own_deadline',
      ],
    ),
    'sprinter_saver': const _ArchetypeMeta(
      name: 'The Sprinter Saver',
      tagline: 'You save in bursts, not a rhythm.',
      lessonIds: ['c10', 'c3', 'f4', 'new_burst_to_standing_order', 'new_consistency_over_intensity', 'new_two_week_rule'],
    ),
    'one_goal_wonder': const _ArchetypeMeta(
      name: 'The One-Goal Wonder',
      tagline: 'You finished a goal — and the habit finished with it.',
      lessonIds: [
        'new_one_goal_trap',
        'new_second_habit_before_needed',
        'new_ill_think_later_rarely_happens',
        'new_diversify_saving',
        'new_onetime_to_habitual',
        'new_gap_between_goals',
      ],
    ),
    'goal_chaser': const _ArchetypeMeta(
      name: 'The Goal Chaser',
      tagline: 'You\'re juggling several goals at once. Genuinely good at it.',
      lessonIds: ['c7', 'm8', 'new_prioritizing_goals', 'new_spreading_too_thin', 'new_sequencing_goals', 'new_consolidate_goals'],
    ),
    'steady_saver': const _ArchetypeMeta(
      name: 'The Steady Saver',
      tagline: 'Disciplined, low-drama, quietly building something real.',
      lessonIds: ['m1', 'm4', 'm15', 'c9', 'new_boring_investing', 'new_stepup_sip'],
    ),
    'overcorrector': const _ArchetypeMeta(
      name: 'The Overcorrector',
      tagline: 'Big swings between saving hard and spending hard.',
      lessonIds: [
        'new_break_restrict_splurge',
        'new_why_extreme_budgets_break',
        'new_sawtooth_pattern',
        'new_sustainable_beats_aggressive',
        'new_guilt_not_strategy',
        'new_budget_you_wont_rebel_against',
      ],
    ),
  };
}