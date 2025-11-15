import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// Models
enum InsightsRange { last7, last30, last90, all }

class DailyCompletion {
  final DateTime date;
  final int completed;
  DailyCompletion(this.date, this.completed);
}

class Streak {
  final String habit;
  final int days;
  Streak(this.habit, this.days);
}

class InsightData {
  final List<DailyCompletion> daily;
  final Map<String, int> categories;
  final Map<String, int> habits;
  final List<Streak> streaks;
  final int totalCompleted;
  final int completionRate;
  final String bestDay;
  final int bestDayCount;

  InsightData({
    required this.daily,
    required this.categories,
    required this.habits,
    required this.streaks,
    required this.totalCompleted,
    required this.completionRate,
    required this.bestDay,
    required this.bestDayCount,
  });
}

/// Mock Data Generator
InsightData _generateMockData(InsightsRange range) {
  final now = DateTime.now();
  final dayCount = range == InsightsRange.last7
      ? 7
      : range == InsightsRange.last30
      ? 30
      : range == InsightsRange.last90
      ? 90
      : 365;

  final daily = List.generate(dayCount, (i) {
    return DailyCompletion(
      now.subtract(Duration(days: dayCount - i - 1)),
      6 + (i % 8),
    );
  });

  final totalCompleted = daily.fold<int>(0, (sum, d) => sum + d.completed);
  final bestDay = daily.reduce((a, b) => a.completed > b.completed ? a : b);

  return InsightData(
    daily: daily,
    categories: {'Work': 145, 'Personal': 89, 'Health': 67, 'Learning': 54},
    habits: {
      'Morning Meditation': 24,
      'Exercise': 18,
      'Reading': 22,
      'Journaling': 15,
      'Water Intake': 28,
    },
    streaks: [
      Streak('Drink Water', 14),
      Streak('Morning Meditation', 7),
      Streak('Reading', 5),
      Streak('Exercise', 3),
    ],
    totalCompleted: totalCompleted,
    completionRate: (totalCompleted / (dayCount * 10) * 100).round(),
    bestDay: [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][bestDay.date.weekday - 1],
    bestDayCount: bestDay.completed,
  );
}

final List<String> aiInsights = [
  'You\'re most productive on Wednesdays.',
  'Your peak hours are between 10 AM and 12 PM.',
  'Tasks completed on weekdays are 40% higher.',
  'Your consistency has improved by 15% this month.',
];

final List<String> suggestedActions = [
  'Try scheduling tasks earlier — you complete 22% more before noon.',
  'Increase weekend habit goals gradually.',
  'Your exercise habits spike mid-week. Consider diversifying.',
  'Plan review sessions on Fridays for better retention.',
];

/// Providers
final insightsRangeProvider = StateProvider<InsightsRange>((ref) {
  return InsightsRange.last30;
});

final insightsDataProvider = StateProvider.family<InsightData, InsightsRange>((
  ref,
  range,
) {
  return _generateMockData(range);
});

final aiInsightsProvider = StateProvider<String>((ref) {
  final index = DateTime.now().millisecond % aiInsights.length;
  return aiInsights[index];
});

final suggestedActionsProvider = StateProvider<List<String>>((ref) {
  return suggestedActions;
});

/// Main Screen
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _openRangeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _RangeSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedRange = ref.watch(insightsRangeProvider);
    final insightData = ref.watch(insightsDataProvider(selectedRange));
    final aiInsight = ref.watch(aiInsightsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _openRangeSelector,
                        icon: const Icon(Icons.calendar_today, size: 20),
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          debugPrint('Open filters');
                        },
                        icon: const Icon(Icons.tune, size: 20),
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Time Range Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _RangeChip(
                      label: '7D',
                      isSelected: selectedRange == InsightsRange.last7,
                      onTap: () {
                        ref.read(insightsRangeProvider.notifier).state =
                            InsightsRange.last7;
                        _fadeController.forward(from: 0);
                      },
                    ),
                    const SizedBox(width: 8),
                    _RangeChip(
                      label: '30D',
                      isSelected: selectedRange == InsightsRange.last30,
                      onTap: () {
                        ref.read(insightsRangeProvider.notifier).state =
                            InsightsRange.last30;
                        _fadeController.forward(from: 0);
                      },
                    ),
                    const SizedBox(width: 8),
                    _RangeChip(
                      label: '90D',
                      isSelected: selectedRange == InsightsRange.last90,
                      onTap: () {
                        ref.read(insightsRangeProvider.notifier).state =
                            InsightsRange.last90;
                        _fadeController.forward(from: 0);
                      },
                    ),
                    const SizedBox(width: 8),
                    _RangeChip(
                      label: 'All Time',
                      isSelected: selectedRange == InsightsRange.all,
                      onTap: () {
                        ref.read(insightsRangeProvider.notifier).state =
                            InsightsRange.all;
                        _fadeController.forward(from: 0);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Productivity Overview Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Productivity Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _OverviewMetric(
                          label: 'Completion Rate',
                          value: '${insightData.completionRate}%',
                        ),
                        _OverviewMetric(
                          label: 'Total Completed',
                          value: '${insightData.totalCompleted}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _OverviewMetric(
                          label: 'Best Day',
                          value: insightData.bestDay,
                        ),
                        _OverviewMetric(
                          label: 'Peak Count',
                          value: '${insightData.bestDayCount}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Line Chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Completion Trend',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: _LineChartWidget(data: insightData.daily),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Pie Chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 280,
                      child: _PieChartWidget(
                        categories: insightData.categories,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Habit Breakdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habit Breakdown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your consistency over the selected period',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: insightData.habits.entries.map((entry) {
                        final percentage = (entry.value / 28 * 100).round();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '$percentage%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.withValues(
                                    alpha: 0.1,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Top Streaks
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Streaks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: insightData.streaks.map((streak) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            debugPrint('Open habit detail: ${streak.habit}');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.1),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🔥 ${streak.habit}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${streak.days}-day streak',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Colors.red.shade500,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          /// AI Insights Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.04),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.15),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: Colors.blue.shade500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Insights',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Text(
                        aiInsight,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Suggested Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: suggestedActions.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key('action_${entry.key}'),
                          direction: DismissDirection.horizontal,
                          onDismissed: (_) {
                            debugPrint('Dismissed action: ${entry.value}');
                          },
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade500,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.done, color: Colors.white),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.1),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 16,
                                  color: Colors.amber.shade600,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.grey.shade700,
                                          height: 1.5,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          /// Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }
}

/// Range Chip Widget
class _RangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade500 : Colors.white,
            border: Border.all(
              color: isSelected
                  ? Colors.blue.shade500
                  : Colors.grey.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Overview Metric Widget
class _OverviewMetric extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Line Chart Widget
class _LineChartWidget extends StatelessWidget {
  final List<DailyCompletion> data;

  const _LineChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY =
        data
            .fold<int>(0, (max, d) => d.completed > max ? d.completed : max)
            .toDouble() +
        2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (data.length / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final date = data[value.toInt()].date;
                  return Text(
                    '${date.month}/${date.day}',
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: Theme.of(context).textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (i) {
              return FlSpot(i.toDouble(), data[i].completed.toDouble());
            }),
            isCurved: true,
            color: Colors.blue.shade500,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: Colors.blue.shade500,
                    strokeWidth: 0,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pie Chart Widget
class _PieChartWidget extends StatefulWidget {
  final Map<String, int> categories;

  const _PieChartWidget({required this.categories});

  @override
  State<_PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<_PieChartWidget> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue.shade400,
      Colors.pink.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
    ];

    final entries = widget.categories.entries.toList();
    final total = widget.categories.values.fold<int>(0, (sum, v) => sum + v);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (i) {
                final entry = entries[i];
                final isTouched = i == touchedIndex;
                final radius = isTouched ? 60.0 : 50.0;
                final percentage = (entry.value / total * 100).toStringAsFixed(
                  0,
                );

                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: entry.value.toDouble(),
                  title: '$percentage%',
                  radius: radius,
                  badgeWidget: isTouched
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              }),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              centerSpaceColor: Colors.white,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    touchedIndex =
                        pieTouchResponse?.touchedSection?.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: entries.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[entry.key % colors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value.key,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Range Selector Modal
class _RangeSelectorModal extends ConsumerWidget {
  const _RangeSelectorModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(insightsRangeProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date Range',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ...[
            ('Last 7 Days', InsightsRange.last7),
            ('Last 30 Days', InsightsRange.last30),
            ('Last 90 Days', InsightsRange.last90),
            ('All Time', InsightsRange.all),
          ].map((item) {
            final isSelected = selectedRange == item.$2;
            return GestureDetector(
              onTap: () {
                ref.read(insightsRangeProvider.notifier).state = item.$2;
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue.shade500
                        : Colors.grey.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.$1,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.blue.shade500
                            : Colors.black87,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check, color: Colors.blue.shade500),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
