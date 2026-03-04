import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:halo/models/match_model.dart';
import 'package:halo/models/user_model.dart';
import 'package:halo/providers/auth_provider.dart';
import 'package:halo/providers/match_provider.dart';
import 'package:halo/screens/chat/chat_screen.dart';
import 'package:halo/screens/premium/premium_screen.dart';
import 'package:halo/utils/theme.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().firebaseUser?.uid;
      if (uid != null) {
        context.read<MatchProvider>().listenToMatches(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.userModel;
    final isPremium = currentUser?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: Consumer<MatchProvider>(
        builder: (context, matchProvider, _) {
          if (matchProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (matchProvider.matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No matches yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Keep swiping to find your match!',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          if (!isPremium) {
            // Free users can see they have matches but can't interact
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 60,
                      color: AppTheme.premiumGold,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You have ${matchProvider.matches.length} match${matchProvider.matches.length == 1 ? '' : 'es'}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upgrade to Premium to see who matched with you and start chatting!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PremiumScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star),
                      label: const Text('Go Premium'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.premiumGold,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matchProvider.matches.length,
            itemBuilder: (context, index) {
              final match = matchProvider.matches[index];
              final otherUser = matchProvider.getMatchedUser(
                match.id,
                currentUser!.uid,
              );

              if (otherUser == null) {
                return const SizedBox.shrink();
              }

              return _buildMatchTile(match, otherUser);
            },
          );
        },
      ),
    );
  }

  Widget _buildMatchTile(MatchModel match, UserModel otherUser) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: otherUser.photoUrls.isNotEmpty
              ? CachedNetworkImageProvider(otherUser.photoUrls.first)
              : null,
          child: otherUser.photoUrls.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        title: Row(
          children: [
            Text(
              otherUser.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (otherUser.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: Colors.blue, size: 16),
            ],
          ],
        ),
        subtitle: Text(
          match.lastMessage ?? 'Say hello!',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: match.lastMessage != null
                ? AppTheme.textSecondary
                : AppTheme.primaryColor,
            fontStyle: match.lastMessage != null
                ? FontStyle.normal
                : FontStyle.italic,
          ),
        ),
        trailing: match.lastMessageAt != null
            ? Text(
                timeago.format(match.lastMessageAt!),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                matchId: match.id,
                otherUser: otherUser,
              ),
            ),
          );
        },
      ),
    );
  }
}
