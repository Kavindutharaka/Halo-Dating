import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reportedByUid;
  final String reportedUserUid;
  final String reason;
  final String? details;
  final DateTime reportedAt;
  final bool isResolved;

  ReportModel({
    required this.id,
    required this.reportedByUid,
    required this.reportedUserUid,
    required this.reason,
    this.details,
    DateTime? reportedAt,
    this.isResolved = false,
  }) : reportedAt = reportedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportedByUid': reportedByUid,
      'reportedUserUid': reportedUserUid,
      'reason': reason,
      'details': details,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'isResolved': isResolved,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      reportedByUid: map['reportedByUid'] ?? '',
      reportedUserUid: map['reportedUserUid'] ?? '',
      reason: map['reason'] ?? '',
      details: map['details'],
      reportedAt:
          (map['reportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isResolved: map['isResolved'] ?? false,
    );
  }
}
