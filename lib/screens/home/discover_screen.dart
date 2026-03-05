import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:halo/models/user_model.dart';
import 'package:halo/providers/auth_provider.dart';
import 'package:halo/providers/discover_provider.dart';
import 'package:halo/screens/profile/view_profile_screen.dart';
import 'package:halo/screens/home/filter_sheet.dart';
import 'package:halo/utils/theme.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfiles());
  }

  void _loadProfiles() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.userModel;
    if (user == null) return;

    context.read<DiscoverProvider>().loadProfiles(
          currentUserId: user.uid,
          blockedUsers: user.blockedUsers,
          isPremium: user.isPremium,
        );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FilterSheet(),
    ).then((_) => _loadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halo'),
        actions: [
          if (currentUser?.isPremium == true)
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showFilterSheet,
            ),
        ],
      ),
      body: Consumer<DiscoverProvider>(
        builder: (context, discover, _) {
          if (discover.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (discover.profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore_off,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No more profiles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back later for new people',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _loadProfiles,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          // Daily likes counter for free users
          final remainingLikes = currentUser != null && !currentUser.isPremium
              ? 15 - (currentUser.dailyLikesUsed)
              : null;

          return Column(
            children: [
              if (remainingLikes != null)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$remainingLikes likes remaining today',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              Expanded(
                child: CardSwiper(
                  controller: _swiperController,
                  cardsCount: discover.profiles.length,
                  numberOfCardsDisplayed:
                      discover.profiles.length > 1 ? 2 : 1,
                  backCardOffset: const Offset(0, -30),
                  padding: const EdgeInsets.all(16),
                  onSwipe: (previousIndex, currentIndex, direction) {
                    // Capture profile before modifying the list
                    final profile = discover.profiles[previousIndex];
                    // Always remove the swiped card immediately
                    discover.removeProfile(previousIndex);
                    if (direction == CardSwiperDirection.right) {
                      _onLike(profile);
                    }
                    return true;
                  },
                  cardBuilder: (context, index, horizontalOffset,
                      verticalOffset) {
                    if (index >= discover.profiles.length) {
                      return const SizedBox.shrink();
                    }
                    return _buildProfileCard(discover.profiles[index]);
                  },
                ),
              ),
              // Action buttons
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 24, left: 40, right: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(
                      icon: Icons.close,
                      color: AppTheme.errorColor,
                      onTap: () {
                        _swiperController.swipe(CardSwiperDirection.left);
                      },
                    ),
                    _actionButton(
                      icon: Icons.favorite,
                      color: AppTheme.primaryColor,
                      size: 60,
                      onTap: () {
                        _swiperController.swipe(CardSwiperDirection.right);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(UserModel user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProfileScreen(user: user, showActions: true),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  user.photoUrls.isNotEmpty ? user.photoUrls.first : '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[200]),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 60),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user.name}, ${user.age}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (user.isVerified)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 22,
                          ),
                        if (user.isPremium) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: AppTheme.premiumGold,
                            size: 22,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.city,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    if (user.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        user.bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    double size = 50,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }

  void _onLike(UserModel likedUser) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.userModel!;

    if (!currentUser.canLikeToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have used all your daily likes. Go Premium for unlimited likes!'),
        ),
      );
      return;
    }

    final isMatch = await context.read<DiscoverProvider>().likeProfile(
          fromUserId: currentUser.uid,
          toUserId: likedUser.uid,
        );

    if (isMatch && mounted) {
      _showMatchDialog(likedUser);
    }

    // Refresh user data for daily like count
    await authProvider.refreshUser();
  }

  void _showMatchDialog(UserModel matchedUser) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                color: AppTheme.primaryColor,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                "It's a Match!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You and ${matchedUser.name} liked each other',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Swiping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
