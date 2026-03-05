import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:halo/models/user_model.dart';
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
                '${user.age} · ${user.city}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 24),

            // Free Premium banner for verified women
            if (user != null &&
                user.gender == Gender.female &&
                user.isVerified &&
                !user.isPremium)
              _buildFemalePremiumBanner(context, user),

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

  /// Promotional banner shown only for verified women who don't have premium yet.
  Widget _buildFemalePremiumBanner(BuildContext context, UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            const Row(
              children: [
                Text('👑', style: TextStyle(fontSize: 26)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Free Premium Unlocked!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'You\'re a verified woman on Halo 🎉 Enjoy unlimited likes, advanced filters, and more — completely free!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Benefits row
            const Row(
              children: [
                _BenefitChip(label: '∞ Likes'),
                SizedBox(width: 8),
                _BenefitChip(label: '🔍 Filters'),
                SizedBox(width: 8),
                _BenefitChip(label: '⚡ Priority'),
              ],
            ),
            const SizedBox(height: 16),
            // Claim button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _claimFreePremium(context, user),
                child: const Text('Claim Free Premium →'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _claimFreePremium(BuildContext context, UserModel user) async {
    final authProvider = context.read<AuthProvider>();
    final updatedUser = user.copyWith(
      isPremium: true,
      premiumUntil: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    await authProvider.updateProfile(updatedUser);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Premium activated! Enjoy Halo Premium for free.'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _verificationTitle(UserModel? user) {
    if (user == null) return 'Get Verified';
    if (user.isVerified) return 'Verified ✓';
    switch (user.verificationStatus) {
      case VerificationStatus.pending:
        return 'Verification Pending';
      case VerificationStatus.rejected:
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

/// Small rounded chip used inside the female premium banner.
class _BenefitChip extends StatelessWidget {
  final String label;
  const _BenefitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
