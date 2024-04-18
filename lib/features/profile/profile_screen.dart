import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';

/// Profile and settings.
///
/// Auth comes from Provider, the setting toggles are local setState and are
/// never persisted anywhere. Restarting the app resets them.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _priceDropAlerts = true;
  bool _darkMode = false;
  String _currency = 'THB';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          Container(
            color: kPrimary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Member since ${user?.memberSince ?? '-'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('${favorites.count}', 'Saved'),
                _buildStat('5', 'Viewings'),
                _buildStat('2', 'Enquiries'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text('New listings matching your searches'),
            value: _pushNotifications,
            onChanged: (v) {
              setState(() {
                _pushNotifications = v;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Email alerts'),
            subtitle: const Text('Weekly digest of new properties'),
            value: _emailAlerts,
            onChanged: (v) {
              setState(() {
                _emailAlerts = v;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Price drop alerts'),
            subtitle: const Text('When a saved property drops in price'),
            value: _priceDropAlerts,
            onChanged: (v) {
              setState(() {
                _priceDropAlerts = v;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSectionHeader('Preferences'),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            trailing: Text(
              _currency,
              style: TextStyle(color: Colors.grey[700]),
            ),
            onTap: _pickCurrency,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: Text(
              _language,
              style: TextStyle(color: Colors.grey[700]),
            ),
            onTap: _pickLanguage,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: const Text('Not implemented yet'),
            value: _darkMode,
            onChanged: (v) {
              setState(() {
                _darkMode = v;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not implemented')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not implemented')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not implemented')),
              );
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(20),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: kDanger),
              label: const Text('Log out', style: TextStyle(color: kDanger)),
              onPressed: () => _confirmLogout(context),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'HouseFinder v1.4.2 (18)',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _pickCurrency() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['THB', 'USD', 'EUR', 'SGD'].map((c) {
              return ListTile(
                title: Text(c),
                trailing:
                    _currency == c ? const Icon(Icons.check, color: kPrimary) : null,
                onTap: () {
                  setState(() {
                    _currency = c;
                  });
                  Navigator.of(sheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _pickLanguage() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'ไทย', '中文'].map((l) {
              return ListTile(
                title: Text(l),
                trailing:
                    _language == l ? const Icon(Icons.check, color: kPrimary) : null,
                onTap: () {
                  setState(() {
                    _language = l;
                  });
                  Navigator.of(sheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('You will need to sign in again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthProvider>().logout();
              },
              child: const Text('Log out', style: TextStyle(color: kDanger)),
            ),
          ],
        );
      },
    );
  }
}
