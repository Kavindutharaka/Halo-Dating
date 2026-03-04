import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:halo/providers/auth_provider.dart';
import 'package:halo/services/storage_service.dart';
import 'package:halo/utils/constants.dart';
import 'package:halo/utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _city;
  late List<String> _photoUrls;
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  // Questionnaire controllers
  final Map<String, TextEditingController> _personalityControllers = {};
  final Map<String, TextEditingController> _lifestyleControllers = {};
  final Map<String, TextEditingController> _relationshipControllers = {};
  final Map<String, TextEditingController> _funControllers = {};

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel!;
    _nameController = TextEditingController(text: user.name);
    _bioController = TextEditingController(text: user.bio);
    _city = user.city;
    _photoUrls = List.from(user.photoUrls);

    for (final prompt in AppConstants.personalityPrompts) {
      _personalityControllers[prompt] =
          TextEditingController(text: user.personalityAnswers[prompt] ?? '');
    }
    for (final prompt in AppConstants.lifestylePrompts) {
      _lifestyleControllers[prompt] =
          TextEditingController(text: user.lifestyleAnswers[prompt] ?? '');
    }
    for (final prompt in AppConstants.relationshipPrompts) {
      _relationshipControllers[prompt] =
          TextEditingController(text: user.relationshipAnswers[prompt] ?? '');
    }
    for (final prompt in AppConstants.funPrompts) {
      _funControllers[prompt] =
          TextEditingController(text: user.funAnswers[prompt] ?? '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _personalityControllers.values.forEach((c) => c.dispose());
    _lifestyleControllers.values.forEach((c) => c.dispose());
    _relationshipControllers.values.forEach((c) => c.dispose());
    _funControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_photoUrls.length >= 6) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() => _isLoading = true);
      try {
        final uid = context.read<AuthProvider>().firebaseUser!.uid;
        final url = await _storageService.uploadProfilePhoto(
          userId: uid,
          file: File(picked.path),
        );
        setState(() {
          _photoUrls.add(url);
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removePhoto(int index) async {
    if (_photoUrls.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need at least one photo')),
      );
      return;
    }
    final url = _photoUrls[index];
    setState(() {
      _photoUrls.removeAt(index);
    });
    await _storageService.deleteProfilePhoto(url);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.userModel!;

    final personalityAnswers = <String, String>{};
    for (final entry in _personalityControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        personalityAnswers[entry.key] = entry.value.text;
      }
    }

    final lifestyleAnswers = <String, String>{};
    for (final entry in _lifestyleControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        lifestyleAnswers[entry.key] = entry.value.text;
      }
    }

    final relationshipAnswers = <String, String>{};
    for (final entry in _relationshipControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        relationshipAnswers[entry.key] = entry.value.text;
      }
    }

    final funAnswers = <String, String>{};
    for (final entry in _funControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        funAnswers[entry.key] = entry.value.text;
      }
    }

    final updatedUser = user.copyWith(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      city: _city,
      photoUrls: _photoUrls,
      personalityAnswers: personalityAnswers,
      lifestyleAnswers: lifestyleAnswers,
      relationshipAnswers: relationshipAnswers,
      funAnswers: funAnswers,
    );

    await authProvider.updateProfile(updatedUser);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            const Text(
              'Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photoUrls.length + 1,
                itemBuilder: (context, index) {
                  if (index == _photoUrls.length) {
                    return GestureDetector(
                      onTap: _addPhoto,
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Icon(Icons.add_a_photo,
                            color: AppTheme.textSecondary),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: _photoUrls[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Basic info
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _city,
              decoration: const InputDecoration(labelText: 'City'),
              items: AppConstants.sriLankanCities
                  .map((city) =>
                      DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (value) => setState(() => _city = value),
            ),
            const SizedBox(height: 32),

            // Questionnaire sections
            _buildSection('PERSONALITY', AppConstants.personalityPrompts,
                _personalityControllers),
            _buildSection('LIFESTYLE', AppConstants.lifestylePrompts,
                _lifestyleControllers),
            _buildSection('RELATIONSHIP', AppConstants.relationshipPrompts,
                _relationshipControllers),
            _buildSection(
                'FUN', AppConstants.funPrompts, _funControllers),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> prompts,
    Map<String, TextEditingController> controllers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...prompts.map((prompt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: controllers[prompt],
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: prompt,
                  counterText: '',
                ),
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
