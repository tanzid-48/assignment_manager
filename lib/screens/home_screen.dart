import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import 'add_assignment_screen.dart';
import 'detail_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
} class _HomeScreenState extends State<HomeScreen> {

  final List<Widget> _screens = const [
    _HomeTab(),
    _AddTab(),
    _StatsTab(),
    _SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = context.watch<AssignmentProvider>();
    final currentIndex = p.currentTab;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            top: BorderSide(color: scheme.outline.withOpacity(0.1)),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: (i) => p.setCurrentTab(i),
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle_rounded,
                  label: 'Add',
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: (i) => p.setCurrentTab(i),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Stats',
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: (i) => p.setCurrentTab(i),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: (i) => p.setCurrentTab(i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? scheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? activeIcon : icon,
              color:
                  active ? scheme.primary : scheme.onSurface.withOpacity(0.4),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color:
                    active ? scheme.primary : scheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssignmentProvider>();
    final scheme = Theme.of(context).colorScheme;
    final filters = [
      'All',
      'Pending',
      'In Progress',
      'Completed',
      'High Priority'
    ];

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.primary.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Assignment Manager',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  IconButton(
                    onPressed: () => p.toggleDarkMode(),
                    icon: Icon(
                        p.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stat('Total', p.totalCount),
                  _Stat('Pending', p.pendingCount),
                  _Stat('In Progress', p.inProgressCount),
                  _Stat('Done', p.completedCount),
                ],
              ),
              const SizedBox(height: 12),
              if (p.totalCount > 0) ...[
                Text(
                    '${((p.completedCount / p.totalCount) * 100).round()}% completed',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: p.completedCount / p.totalCount,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                onChanged: p.setSearch,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search assignments...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filter chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final f = filters[i];
              final active = f == p.filterStatus;
              return GestureDetector(
                onTap: () => p.setFilter(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: active ? scheme.primary : Colors.transparent,
                    border: Border.all(
                        color: active
                            ? scheme.primary
                            : scheme.outline.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(f,
                      style: TextStyle(
                          fontSize: 12,
                          color: active
                              ? Colors.white
                              : scheme.onSurface.withOpacity(0.6))),
                ),
              );
            },
          ),
        ),

        // List
        Expanded(
          child: p.filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 64, color: scheme.onSurface.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('No assignments found',
                          style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.4))),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            context.read<AssignmentProvider>().setCurrentTab(1),
                        child: const Text('+ Add Assignment'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  itemCount: p.filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _AssignmentCard(a: p.filtered[i]),
                ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text('$value',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ]),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment a;
  const _AssignmentCard({required this.a});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final daysLeft = a.deadline.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 2 && a.status != 'Completed';

    Color priorityColor() {
      switch (a.priority) {
        case 'High':
          return Colors.red.shade100;
        case 'Medium':
          return Colors.orange.shade100;
        default:
          return Colors.green.shade100;
      }
    }

    Color priorityText() {
      switch (a.priority) {
        case 'High':
          return Colors.red.shade700;
        case 'Medium':
          return Colors.orange.shade800;
        default:
          return Colors.green.shade700;
      }
    }

    Color statusColor() {
      switch (a.status) {
        case 'Pending':
          return const Color(0xFFEEEDFE);
        case 'In Progress':
          return const Color(0xFFE6F1FB);
        default:
          return const Color(0xFFEAF3DE);
      }
    }

    Color statusText() {
      switch (a.status) {
        case 'Pending':
          return const Color(0xFF3C3489);
        case 'In Progress':
          return const Color(0xFF0C447C);
        default:
          return const Color(0xFF27500A);
      }
    }

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(assignment: a))),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUrgent
                ? Colors.red.shade300
                : scheme.outline.withOpacity(0.15),
            width: isUrgent ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            if (isUrgent)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 14, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Text(
                    daysLeft < 0
                        ? 'Overdue by ${-daysLeft} days!'
                        : daysLeft == 0
                            ? 'Due today!'
                            : 'Due tomorrow!',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(a.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: priorityColor(),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(a.priority,
                          style: TextStyle(
                              fontSize: 11,
                              color: priorityText(),
                              fontWeight: FontWeight.w500)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(a.subject,
                      style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withOpacity(0.55))),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: statusColor(),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(a.status,
                            style:
                                TextStyle(fontSize: 11, color: statusText())),
                      ),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 12, color: scheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text(
                          '${a.deadline.day}/${a.deadline.month}/${a.deadline.year}',
                          style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface.withOpacity(0.4)),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Tab ───────────────────────────────────────────
class _AddTab extends StatelessWidget {
  const _AddTab();

  @override
  Widget build(BuildContext context) {
    return const AddAssignmentScreen(fromNav: true);
  }
}

// ── Stats Tab ─────────────────────────────────────────
class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return const StatisticsScreen(fromNav: true);
  }
}

// ── Settings Tab ──────────────────────────────────────
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
