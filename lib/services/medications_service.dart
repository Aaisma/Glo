import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medication_model.dart';

class MedicationsService {
  final FirebaseFirestore _db;

  MedicationsService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _medicationsRef =>
      _db.collection('medications');

  CollectionReference<Map<String, dynamic>> get _historyRef =>
      _db.collection('history');

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }
  }

  void _validateMedicationId(String? id) {
    if (id == null || id.trim().isEmpty) {
      throw Exception('Medication ID is required.');
    }
  }

  Future<void> addMedication(MedicationModel med, String userId) async {
    _validateUserId(userId);

    final medicationRef = _medicationsRef.doc();
    final historyRef = _historyRef.doc();

    med.id = medicationRef.id;
    med.userId = userId;

    final medicationData = {
      ...med.toMap(),
      'id': medicationRef.id,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final historyData = _buildMedicationHistoryData(
      historyId: historyRef.id,
      userId: userId,
      medicationId: medicationRef.id,
      medicationData: medicationData,
      action: 'created',
    );

    final batch = _db.batch();

    batch.set(medicationRef, medicationData);
    batch.set(historyRef, historyData);

    await batch.commit();
  }

  Future<void> updateMedication(MedicationModel med, String userId) async {
    _validateUserId(userId);
    _validateMedicationId(med.id);

    med.userId = userId;

    final medicationRef = _medicationsRef.doc(med.id);
    final historyRef = _historyRef.doc();

    final medicationData = {
      ...med.toMap(),
      'id': med.id,
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final historyData = _buildMedicationHistoryData(
      historyId: historyRef.id,
      userId: userId,
      medicationId: med.id!,
      medicationData: medicationData,
      action: 'updated',
    );

    final batch = _db.batch();

    batch.set(
      medicationRef,
      medicationData,
      SetOptions(merge: true),
    );

    batch.set(historyRef, historyData);

    await batch.commit();
  }

  Future<void> deleteMedication(String id) async {
    _validateMedicationId(id);

    await _medicationsRef.doc(id).delete();
  }

  Future<List<MedicationModel>> getMedications(String userId) async {
    _validateUserId(userId);

    final snapshot = await _medicationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => MedicationModel.fromMap(
        doc.data(),
        doc.id,
      ),
    )
        .toList();
  }

  Stream<List<MedicationModel>> getMedicationsStream(String userId) {
    _validateUserId(userId);

    return _medicationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => MedicationModel.fromMap(
          doc.data(),
          doc.id,
        ),
      )
          .toList(),
    );
  }

  Stream<int> getMedicationCountStream(String userId) {
    _validateUserId(userId);

    return _medicationsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
    );
  }

  Stream<int> getAllMedicationCountStream() {
    return _medicationsRef.snapshots().map(
          (snapshot) => snapshot.docs.length,
    );
  }

  Map<String, dynamic> _buildMedicationHistoryData({
    required String historyId,
    required String userId,
    required String medicationId,
    required Map<String, dynamic> medicationData,
    required String action,
  }) {
    final name = _getStringValue(
      medicationData,
      [
        'name',
        'medicationName',
        'medicineName',
      ],
      fallback: 'Medication',
    );

    final dosage = _getStringValue(
      medicationData,
      [
        'dosage',
        'dose',
      ],
    );

    final type = _getStringValue(
      medicationData,
      [
        'type',
        'medicationType',
      ],
    );

    final schedule = _getStringValue(
      medicationData,
      [
        'schedule',
        'frequency',
        'time',
      ],
    );

    final doctorName = _getStringValue(
      medicationData,
      [
        'doctorName',
        'doctor',
      ],
    );

    final instructions = _getStringValue(
      medicationData,
      [
        'instructions',
        'instruction',
        'notes',
      ],
    );

    final content = <String>[
      dosage.isEmpty ? name : '$name - $dosage',
      if (type.isNotEmpty) 'Type: $type',
      if (schedule.isNotEmpty) 'Schedule: $schedule',
      if (doctorName.isNotEmpty) 'Doctor: $doctorName',
    ];

    return {
      'id': historyId,
      'userId': userId,
      'type': 'medication',
      'title': action == 'created'
          ? 'Medication Added'
          : 'Medication Updated',
      'content': content,
      'details': instructions.isNotEmpty
          ? instructions
          : action == 'created'
          ? '$name was added to your medication list.'
          : '$name was updated in your medication list.',
      'relatedId': medicationId,
      'relatedCollection': 'medications',
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String _getStringValue(
      Map<String, dynamic> data,
      List<String> keys, {
        String fallback = '',
      }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }
}