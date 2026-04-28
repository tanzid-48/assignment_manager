import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../providers/assignment_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = context.watch<AssignmentProvider>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: scheme.outline.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary.withOpacity(0.15),
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.email ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: scheme.primary),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user.displayName != null)
                          Text(user.displayName!,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        Text(
                          user.email ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              color:
                                  scheme.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Dark mode toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.dark_mode_outlined,
                      color: scheme.primary, size: 22),
                  const SizedBox(width: 12),
                  const Text('Dark Mode',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                ]),
                Switch(
                  value: p.isDarkMode,
                  onChanged: (_) => p.toggleDarkMode(),
                  activeColor: scheme.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withOpacity(0.15)),
            ),
            child: Row(children: [
              Icon(Icons.notifications_outlined,
                  color: scheme.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notifications',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    Text(
                      '3 days before, 1 day before, and on due day',
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          const SizedBox(height: 32),

          // Logout button
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text(
                      'Your data is saved in the cloud. You can sign in again anytime.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Sign out',
                            style: TextStyle(
                                color: Colors.red.shade600))),
                  ],
                ),
              );
              if (confirm == true) {
                context.read<AssignmentProvider>().clearOnLogout();
                await AuthService.instance.signOut();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}