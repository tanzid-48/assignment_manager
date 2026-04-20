import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assignment_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssignmentProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primary.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
            child: const Text('Settings',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SettingsCard([
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark theme',
                    trailing: Switch(
                      value: p.isDarkMode,
                      onChanged: (_) => p.toggleDarkMode(),
                      activeColor: scheme.primary,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                _SettingsCard([
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: 'v1.0.0',
                  ),
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Developer',
                    subtitle: 'Tanzid Mondol',
                  ),
                ]),
                const SizedBox(height: 12),
                _SettingsCard([
                  _SettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Clear All Assignments',
                    subtitle: 'Delete all assignments permanently',
                    titleColor: Colors.red.shade600,
                    onTap: () => _confirmClear(context, p),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, AssignmentProvider p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All?'),
        content: const Text('সব assignment permanently delete হবে।'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              for (final a in List.from(p.assignments)) {
                await p.delete(a.id);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete All',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard(this.children);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.15)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: scheme.primary, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: titleColor ?? scheme.onSurface)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12, color: scheme.onSurface.withOpacity(0.5))),
      trailing: trailing,
    );
  }
}