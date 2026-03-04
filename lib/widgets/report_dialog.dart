import 'package:flutter/material.dart';
import 'package:halo/services/firestore_service.dart';
import 'package:halo/utils/theme.dart';

class ReportDialog extends StatefulWidget {
  final String reportedByUid;
  final String reportedUserUid;
  final String reportedUserName;

  const ReportDialog({
    super.key,
    required this.reportedByUid,
    required this.reportedUserUid,
    required this.reportedUserName,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;
  final _firestoreService = FirestoreService();

  final List<String> _reasons = [
    'Fake profile',
    'Inappropriate photos',
    'Harassment',
    'Spam',
    'Underage user',
    'Offensive content',
    'Other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    try {
      await _firestoreService.reportUser(
        reportedByUid: widget.reportedByUid,
        reportedUserUid: widget.reportedUserUid,
        reason: _selectedReason!,
        details: _detailsController.text.isNotEmpty
            ? _detailsController.text
            : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report ${widget.reportedUserName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Why are you reporting this user?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            ..._reasons.map((reason) => RadioListTile<String>(
                  value: reason,
                  groupValue: _selectedReason,
                  title: Text(reason, style: const TextStyle(fontSize: 14)),
                  dense: true,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) =>
                      setState(() => _selectedReason = value),
                )),
            const SizedBox(height: 8),
            TextFormField(
              controller: _detailsController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Additional details (optional)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      (_selectedReason != null && !_isSubmitting)
                          ? _submit
                          : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
