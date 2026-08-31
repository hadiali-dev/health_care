import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class PatientService {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<UserModel>> streamAllPatients() {
    return _usersCollection
        .where('role', isEqualTo: 'patient')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList());
  }

  Future<void> updateHealthStatus(String uid, String newStatus) async {
    await _usersCollection.doc(uid).update({'healthStatus': newStatus});
  }
}