import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:halo/providers/auth_provider.dart';
import 'package:halo/services/firestore_service.dart';
import 'package:halo/utils/theme.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isProcessing = false;
  final _firestoreService = FirestoreService();

  Future<void> _subscribePremium() async {
    setState(() => _isProcessing = true);

    try {
      // TODO: Integrate Stripe payment flow here
      // For MVP, we'll simulate a successful payment
      // In production, use flutter_stripe package to:
      // 1. Create a PaymentIntent on your backend
      // 2. Present Stripe payment sheet
      // 3. On success, activate premium

      final uid = context.read<AuthProvider>().firebaseUser!.uid;
      await _firestoreService.activatePremium(uid);
      await context.read<AuthProvider>().refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium activated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final isPremium = user?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Premium badge
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.premiumGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                size: 50,
                color: AppTheme.premiumGold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPremium ? 'You are Premium!' : 'Go Premium',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPremium
                  ? 'Enjoy all premium features'
                  : 'Unlock all features for \$10/month',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Features list
            _featureItem(
              Icons.visibility,
              'See Who Likes You',
              'View everyone who matched with you',
            ),
            _featureItem(
              Icons.chat_bubble_outline,
              'Unlimited Chat',
              'Chat with all your matches',
            ),
            _featureItem(
              Icons.filter_list,
              'Advanced Filters',
              'Filter by location, age, and more',
            ),
            _featureItem(
              Icons.favorite,
              'Unlimited Likes',
              'Like as many profiles as you want',
            ),
            _featureItem(
              Icons.star_outline,
              'Premium Badge',
              'Stand out with a premium badge',
            ),
            _featureItem(
              Icons.trending_up,
              'Priority Visibility',
              'Your profile appears first to others',
            ),
            _featureItem(
              Icons.block,
              'No Ads',
              'Enjoy an ad-free experience',
            ),
            const SizedBox(height: 32),

            if (!isPremium) ...[
              // Price
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '\$10',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'per month',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _subscribePremium,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Subscribe Now'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment processed via Stripe.\nCancel anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Active Premium Member',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                    if (user?.premiumUntil != null)
                      Text(
                        'Expires: ${user!.premiumUntil!.day}/${user.premiumUntil!.month}/${user.premiumUntil!.year}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
