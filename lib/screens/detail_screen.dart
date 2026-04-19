import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import 'add_assignment_screen.dart';

class DetailScreen extends StatelessWidget {
  final Assignment assignment;
  const DetailScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final daysLeft = assignment.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && assignment.status != 'Completed';

    Color statusColor(String s) {
      switch (s) {
        case 'Pending': return const Color(0xFFEEEDFE);
        case 'In Progress': return const Color(0xFFE6F1FB);
        default: return const Color(0xFFEAF3DE);
      }
    }

    Color statusText(String s) {
      switch (s) {
        case 'Pending': return const Color(0xFF3C3489);
        case 'In Progress': return const Color(0xFF0C447C);
        default: return const Color(0xFF27500A);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddAssignmentScreen(assignment: assignment)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primary.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _pill(assignment.priority, Colors.white24, Colors.white),
                const SizedBox(width: 8),
                _pill(assignment.status, Colors.white24, Colors.white),
              ]),
              const SizedBox(height: 14),
              Text(assignment.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text(assignment.subject,
                  style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 12),

          // Deadline info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red.shade50 : scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isOverdue ? Colors.red.shade200 : scheme.outline.withOpacity(0.15)),
            ),
            child: Row(children: [
              Icon(
                isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_outlined,
                color: isOverdue ? Colors.red.shade600 : scheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(assignment.deadline),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? Colors.red.shade700 : scheme.onSurface),
                ),
                Text(
                  isOverdue
                      ? 'Overdue by ${-daysLeft} days'
                      : daysLeft == 0
                          ? 'Due today!'
                          : '$daysLeft days remaining',
                  style: TextStyle(
                      fontSize: 13,
                      color: isOverdue ? Colors.red.shade600 : scheme.onSurface.withOpacity(0.5)),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // Description
          if (assignment.description != null && assignment.description!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.outline.withOpacity(0.15)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Notes',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary)),
                const SizedBox(height: 8),
                Text(assignment.description!,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: scheme.onSurface.withOpacity(0.8))),
              ]),
            ),
          const SizedBox(height: 12),

          // Quick status update
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withOpacity(0.15)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Update Status',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: scheme.primary)),
              const SizedBox(height: 12),
              Row(
                children: ['Pending', 'In Progress', 'Completed'].map((s) {
                  final active = assignment.status == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await context.read<AssignmentProvider>().update(
                              assignment.copyWith(status: s),
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? statusColor(s) : Colors.transparent,
                          border: Border.all(
                              color: active ? statusText(s) : scheme.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(s,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    active ? FontWeight.w600 : FontWeight.normal,
                                color: active
                                    ? statusText(s)
                                    : scheme.onSurface.withOpacity(0.5))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),

          const SizedBox(height: 12),
          Text(
            'Created ${DateFormat('dd MMM yyyy').format(assignment.createdAt)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: scheme.onSurface.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 12, color: fg)),
    );
  }

  void _delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure delete this assignment'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<AssignmentProvider>().delete(assignment.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}