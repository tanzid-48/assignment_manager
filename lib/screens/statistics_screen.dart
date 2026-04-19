import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/assignment_provider.dart';
import '../models/assignment.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssignmentProvider>();
    final scheme = Theme.of(context).colorScheme;
    final assignments = p.assignments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: assignments.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_outlined,
                      size: 64, color: scheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text('No data yet — add some assignments!',
                      style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.4))),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary cards
                _SummaryCards(assignments: assignments),
                const SizedBox(height: 16),

                // Donut chart — Status breakdown
                _SectionTitle('Status Breakdown'),
                const SizedBox(height: 8),
                _DonutChart(assignments: assignments),
                const SizedBox(height: 16),

                // Bar chart — Subject wise
                _SectionTitle('Assignments by Subject'),
                const SizedBox(height: 8),
                _SubjectBarChart(assignments: assignments),
                const SizedBox(height: 16),

                // Priority breakdown
                _SectionTitle('Priority Breakdown'),
                const SizedBox(height: 8),
                _PriorityChart(assignments: assignments),
                const SizedBox(height: 16),

                // Upcoming deadlines
                _SectionTitle('Upcoming Deadlines'),
                const SizedBox(height: 8),
                _UpcomingList(assignments: assignments),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary));
  }
}

// Summary cards
class _SummaryCards extends StatelessWidget {
  final List<Assignment> assignments;
  const _SummaryCards({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = assignments.length;
    final completed = assignments.where((a) => a.status == 'Completed').length;
    final overdue = assignments.where((a) =>
        a.deadline.isBefore(DateTime.now()) &&
        a.status != 'Completed').length;
    final pct = total == 0 ? 0 : ((completed / total) * 100).round();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _StatCard('Total', '$total', Icons.assignment_outlined,
            const Color(0xFF534AB7), const Color(0xFFEEEDFE)),
        _StatCard('Completed', '$completed', Icons.check_circle_outline,
            const Color(0xFF3B6D11), const Color(0xFFEAF3DE)),
        _StatCard('Overdue', '$overdue', Icons.warning_amber_outlined,
            const Color(0xFFA32D2D), const Color(0xFFFCEBEB)),
        _StatCard('Progress', '$pct%', Icons.trending_up,
            const Color(0xFF0C447C), const Color(0xFFE6F1FB)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  const _StatCard(this.label, this.value, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ]),
      ]),
    );
  }
}

// Donut chart — Status
class _DonutChart extends StatelessWidget {
  final List<Assignment> assignments;
  const _DonutChart({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final pending = assignments.where((a) => a.status == 'Pending').length;
    final inProgress = assignments.where((a) => a.status == 'In Progress').length;
    final completed = assignments.where((a) => a.status == 'Completed').length;
    final total = assignments.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (pending > 0)
                    PieChartSectionData(
                      value: pending.toDouble(),
                      color: const Color(0xFF534AB7),
                      title: '$pending',
                      radius: 35,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  if (inProgress > 0)
                    PieChartSectionData(
                      value: inProgress.toDouble(),
                      color: const Color(0xFF378ADD),
                      title: '$inProgress',
                      radius: 35,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  if (completed > 0)
                    PieChartSectionData(
                      value: completed.toDouble(),
                      color: const Color(0xFF639922),
                      title: '$completed',
                      radius: 35,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend('Pending', const Color(0xFF534AB7),
                  '${_pct(pending, total)}%'),
              const SizedBox(height: 10),
              _Legend('In Progress', const Color(0xFF378ADD),
                  '${_pct(inProgress, total)}%'),
              const SizedBox(height: 10),
              _Legend('Completed', const Color(0xFF639922),
                  '${_pct(completed, total)}%'),
            ],
          ),
        ],
      ),
    );
  }

  int _pct(int val, int total) =>
      total == 0 ? 0 : ((val / total) * 100).round();
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  final String value;
  const _Legend(this.label, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
      const SizedBox(width: 6),
      Text(value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}

// Bar chart — Subject wise
class _SubjectBarChart extends StatelessWidget {
  final List<Assignment> assignments;
  const _SubjectBarChart({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Subject wise count
    final Map<String, int> subjectCount = {};
    for (final a in assignments) {
      subjectCount[a.subject] = (subjectCount[a.subject] ?? 0) + 1;
    }
    final subjects = subjectCount.keys.toList();
    final maxVal = subjectCount.values.isEmpty
        ? 1
        : subjectCount.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        children: subjects.map((subject) {
          final count = subjectCount[subject]!;
          final pct = count / maxVal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subject,
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withOpacity(0.7)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('$count',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: const Color(0xFFEEEDFE),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF534AB7)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Priority chart
class _PriorityChart extends StatelessWidget {
  final List<Assignment> assignments;
  const _PriorityChart({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final high = assignments.where((a) => a.priority == 'High').length;
    final medium = assignments.where((a) => a.priority == 'Medium').length;
    final low = assignments.where((a) => a.priority == 'Low').length;
    final total = assignments.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.15)),
      ),
      child: Column(children: [
        _PriorityRow('High', high, total, const Color(0xFFA32D2D),
            const Color(0xFFFCEBEB)),
        const SizedBox(height: 10),
        _PriorityRow('Medium', medium, total, const Color(0xFF854F0B),
            const Color(0xFFFAEEDA)),
        const SizedBox(height: 10),
        _PriorityRow('Low', low, total, const Color(0xFF3B6D11),
            const Color(0xFFEAF3DE)),
      ]),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final Color bg;
  const _PriorityRow(this.label, this.count, this.total, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Row(children: [
      Container(
        width: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: bg,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text('$count',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}

// Upcoming deadlines list
class _UpcomingList extends StatelessWidget {
  final List<Assignment> assignments;
  const _UpcomingList({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final upcoming = assignments
        .where((a) =>
            a.status != 'Completed' &&
            a.deadline.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    if (upcoming.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outline.withOpacity(0.15)),
        ),
        child: Text('No upcoming deadlines!',
            style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        children: upcoming.take(5).map((a) {
          final daysLeft = a.deadline.difference(DateTime.now()).inDays;
          return ListTile(
            title: Text(a.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(a.subject,
                style: TextStyle(
                    fontSize: 12, color: scheme.onSurface.withOpacity(0.5))),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: daysLeft <= 2
                    ? const Color(0xFFFCEBEB)
                    : const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                daysLeft == 0
                    ? 'Today'
                    : daysLeft == 1
                        ? 'Tomorrow'
                        : '$daysLeft days',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: daysLeft <= 2
                        ? const Color(0xFFA32D2D)
                        : const Color(0xFF3C3489)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}