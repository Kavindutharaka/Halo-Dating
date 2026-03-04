import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:halo/providers/auth_provider.dart';
import 'package:halo/screens/profile/edit_profile_screen.dart';
import 'package:halo/screens/premium/premium_screen.dart';
import 'package:halo/screens/verification/verification_screen.dart';
import 'package:halo/screens/settings/blocked_users_screen.dart';
import 'package:halo/utils/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile header
            CircleAvatar(
              radius: 50,
              backgroundImage: user != null && user.photoUrls.isNotEmpty
                  ? CachedNetworkImageProvider(user.photoUrls.first)
                  : null,
              child: user == null || user.photoUrls.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.isVerified == true) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, color: Colors.blue, size: 20),
                ],
                if (user?.isPremium == true) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.star,
                      color: AppTheme.premiumGold, size: 20),
                ],
              ],
            ),
            if (user != null)
              Text(
                '${user.age} - ${user.city}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 24),

            // Edit profile
            _settingsTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              ),
            ),

            // Premium
            _settingsTile(
              icon: Icons.star,
              title: user?.isPremium == true ? 'Premium (Active)' : 'Go Premium',
              iconColor: AppTheme.premiumGold,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PremiumScreen(),
                ),
              ),
            ),

            // Verification
            _settingsTile(
              icon: Icons.verified_user,
              title: _verificationTitle(user),
              iconColor: user?.isVerified == true
                  ? AppTheme.successColor
                  : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VerificationScreen(),
                ),
              ),
            ),

            // Blocked users
            _settingsTile(
              icon: Icons.block,
              title: 'Blocked Users',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BlockedUsersScreen(),
                ),
              ),
            ),

            const Divider(height: 32),

            // Sign out
            _settingsTile(
              icon: Icons.logout,
              title: 'Sign Out',
              iconColor: AppTheme.errorColor,
              titleColor: AppTheme.errorColor,
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  String _verificationTitle(dynamic user) {
    if (user == null) return 'Get Verified';
    if (user.isVerified) return 'Verified';
    switch (user.verificationStatus.name) {
      case 'pending':
        return 'Verification Pending';
      case 'rejected':
        return 'Verification Rejected';
      default:
        return 'Get Verified';
    }
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
