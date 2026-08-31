// lib/core/models/report_model.dart

class ReportModel {
  final String id;
  final String patientId;
  final String patientName;
  final String reportText;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.reportText,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'reportText': reportText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id, // We pass the document ID separately from Firestore
      patientId: map['patientId'] as String? ?? '',
      patientName: map['patientName'] as String? ?? 'Unknown Patient',
      reportText: map['reportText'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}