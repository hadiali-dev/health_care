// lib/core/services/report_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reports';

  /// Add a new report (Used by Patient)
  Future<void> addReport({
    required String patientId,
    required String patientName,
    required String reportText,
  }) async {
    // Generate a new document reference so we can get its auto-ID
    final docRef = _firestore.collection(_collection).doc();
    
    final report = ReportModel(
      id: docRef.id,
      patientId: patientId,
      patientName: patientName, // Storing name so staff doesn't have to do extra joins
      reportText: reportText,
      createdAt: DateTime.now(),
    );

    await docRef.set(report.toMap());
  }

  /// Get a stream of all reports (Used by Medical Staff)
  Stream<List<ReportModel>> getAllReportsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true) // Newest reports first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// Delete a specific report by ID (Used by Medical Staff)
  Future<void> deleteReport(String reportId) async {
    await _firestore.collection(_collection).doc(reportId).delete();
  }
}