import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:halo/models/user_model.dart';
import 'package:halo/providers/auth_provider.dart';
import 'package:halo/services/firestore_service.dart';
import 'package:halo/utils/theme.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _firestoreService = FirestoreService();
  List<UserModel> _blockedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    final users = <UserModel>[];
    for (final uid in user.blockedUsers) {
      final blockedUser = await _firestoreService.getUser(uid);
      if (blockedUser != null) {
        users.add(blockedUser);
      }
    }

    setState(() {
      _blockedUsers = users;
      _isLoading = false;
    });
  }

  Future<void> _unblockUser(String blockedUserId) async {
    final currentUserId = context.read<AuthProvider>().firebaseUser!.uid;

    await _firestoreService.unblockUser(
      currentUserId: currentUserId,
      blockedUserId: blockedUserId,
    );

    await context.read<AuthProvider>().refreshUser();

    setState(() {
      _blockedUsers.removeWhere((u) => u.uid == blockedUserId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _blockedUsers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.block, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No blocked users',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blockedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _blockedUsers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrls.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  user.photoUrls.first)
                              : null,
                          child: user.photoUrls.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.city),
                        trailing: TextButton(
                          onPressed: () => _unblockUser(user.uid),
                          child: const Text('Unblock'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
