import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:halo/models/user_model.dart';
import 'package:halo/providers/auth_provider.dart';
import 'package:halo/services/firestore_service.dart';
import 'package:halo/services/storage_service.dart';
import 'package:halo/utils/theme.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _idPhoto;
  File? _selfiePhoto;
  bool _isLoading = false;
  final _imagePicker = ImagePicker();
  final _storageService = StorageService();
  final _firestoreService = FirestoreService();

  Future<void> _pickIdPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _idPhoto = File(picked.path));
    }
  }

  Future<void> _takeSelfie() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked != null) {
      setState(() => _selfiePhoto = File(picked.path));
    }
  }

  Future<void> _submitVerification() async {
    if (_idPhoto == null || _selfiePhoto == null) return;

    setState(() => _isLoading = true);

    try {
      final uid = context.read<AuthProvider>().firebaseUser!.uid;

      final idUrl = await _storageService.uploadVerificationDoc(
        userId: uid,
        file: _idPhoto!,
        docType: 'id',
      );

      final selfieUrl = await _storageService.uploadVerificationDoc(
        userId: uid,
        file: _selfiePhoto!,
        docType: 'selfie',
      );

      await _firestoreService.submitVerification(
        userId: uid,
        idPhotoUrl: idUrl,
        selfieUrl: selfieUrl,
      );

      await context.read<AuthProvider>().refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification submitted! We\'ll review it shortly.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final status = user?.verificationStatus ?? VerificationStatus.none;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            if (status == VerificationStatus.pending)
              _statusBanner(
                Icons.hourglass_top,
                'Verification Pending',
                'Your documents are being reviewed. This usually takes 24-48 hours.',
                AppTheme.warningColor,
              ),
            if (status == VerificationStatus.approved)
              _statusBanner(
                Icons.verified,
                'Verified!',
                'Your identity has been verified. You have a verified badge on your profile.',
                AppTheme.successColor,
              ),
            if (status == VerificationStatus.rejected)
              _statusBanner(
                Icons.cancel,
                'Verification Rejected',
                'Please try again with clearer photos of your ID and selfie.',
                AppTheme.errorColor,
              ),

            if (status == VerificationStatus.none ||
                status == VerificationStatus.rejected) ...[
              const SizedBox(height: 24),
              const Text(
                'Get Verified',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify your identity to get a verified badge. Verified women get Premium for free!',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your ID and selfie are never shown publicly. Only admins can see them for verification.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Step 1: ID Photo
              const Text(
                'Step 1: Upload your NIC/Passport',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickIdPhoto,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _idPhoto != null
                          ? AppTheme.successColor
                          : Colors.grey[300]!,
                      width: _idPhoto != null ? 2 : 1,
                    ),
                  ),
                  child: _idPhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_idPhoto!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.badge_outlined,
                                size: 40, color: AppTheme.textSecondary),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload ID photo',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Step 2: Selfie
              const Text(
                'Step 2: Take a selfie',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _takeSelfie,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selfiePhoto != null
                          ? AppTheme.successColor
                          : Colors.grey[300]!,
                      width: _selfiePhoto != null ? 2 : 1,
                    ),
                  ),
                  child: _selfiePhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child:
                              Image.file(_selfiePhoto!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                size: 40, color: AppTheme.textSecondary),
                            SizedBox(height: 8),
                            Text(
                              'Tap to take selfie',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: (_idPhoto != null && _selfiePhoto != null && !_isLoading)
                    ? _submitVerification
                    : null,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit for Verification'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBanner(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
