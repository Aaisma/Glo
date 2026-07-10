import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryBuilder {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// Builds and saves a new history document.
  ///
  /// Every call creates a new document, so repeated updates do not
  /// overwrite previous history records.
  static Future<void> save({
    required String collectionName,
    required String docId,
    required Map<String, dynamic> data,
    required String action,
  }) async {
    final historyData = build(
      collectionName: collectionName,
      docId: docId,
      data: data,
      action: action,
    );

    if (historyData == null) {
      return;
    }

    final historyId = historyData['id'] as String;

    await _firestore
        .collection('history')
        .doc(historyId)
        .set(historyData);
  }

  /// Creates the history data map.
  static Map<String, dynamic>? build({
    required String collectionName,
    required String docId,
    required Map<String, dynamic> data,
    required String action,
  }) {
    final userId = data['userId']?.toString().trim();

    if (userId == null || userId.isEmpty) {
      return null;
    }

    final normalizedCollectionName =
    collectionName.trim().toLowerCase();

    final normalizedAction = action.trim().toLowerCase();

    final isCreated = normalizedAction == 'created';
    final isDeleted = normalizedAction == 'deleted';

    // Creates a new unique ID for every history record.
    final historyId =
        _firestore.collection('history').doc().id;

    final commonData = <String, dynamic>{
      'id': historyId,
      'userId': userId,
      'relatedId': docId,
      'relatedCollection': normalizedCollectionName,
      'action': normalizedAction,
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    switch (normalizedCollectionName) {
      case 'medications':
        return {
          ...commonData,
          'type': 'medication',
          'title': isCreated
              ? 'Medication Added'
              : isDeleted
              ? 'Medication Deleted'
              : 'Medication Updated',
          'content': [
            '${data['name'] ?? 'Medication'}'
                '${data['dosage'] != null ? ' - ${data['dosage']}' : ''}',
            if (data['type'] != null)
              'Type: ${data['type']}',
            if (data['schedule'] != null)
              'Schedule: ${data['schedule']}',
          ],
          'details': isCreated
              ? '${data['name'] ?? 'Medication'} was added to your medication list.'
              : isDeleted
              ? '${data['name'] ?? 'Medication'} was removed from your medication list.'
              : '${data['name'] ?? 'Medication'} was updated in your medication list.',
        };

      case 'visits':
        return {
          ...commonData,
          'type': 'visit',
          'title': isCreated
              ? 'Visit Added'
              : isDeleted
              ? 'Visit Deleted'
              : 'Visit Updated',
          'content': [
            if (data['doctorName'] != null)
              'Doctor: ${data['doctorName']}',
            if (data['treatment'] != null)
              'Treatment: ${data['treatment']}',
            if (data['visitDate'] != null)
              'Visit Date: ${data['visitDate']}',
            if (data['followUpDate'] != null)
              'Follow-up: ${data['followUpDate']}',
          ],
          'details': isCreated
              ? 'A doctor visit was added to your history.'
              : isDeleted
              ? 'A doctor visit was removed.'
              : 'A doctor visit was updated in your history.',
        };

      case 'journals':
      case 'journal':
        return {
          ...commonData,
          'type': 'journal',
          'title': isCreated
              ? 'Journal Added'
              : isDeleted
              ? 'Journal Deleted'
              : 'Journal Updated',
          'content': [
            data['title']?.toString() ??
                'Journal entry saved',
          ],
          'details': isDeleted
              ? 'A journal entry was removed.'
              : data['note']?.toString() ??
              data['details']?.toString() ??
              'A journal note was saved.',
        };

      case 'cycle':
      case 'cycles':
        return {
          ...commonData,
          'type': 'cycle',
          'title': isCreated
              ? 'Cycle Added'
              : isDeleted
              ? 'Cycle Deleted'
              : 'Cycle Updated',
          'content': [
            if (data['lastPeriod'] != null)
              'Last Period: ${data['lastPeriod']}',
            if (data['duration'] != null)
              'Duration: ${data['duration']}',
            if (data['irregularity'] != null)
              'Irregularity: ${data['irregularity']}',
          ],
          'details': isDeleted
              ? 'Cycle information was removed.'
              : 'Cycle information was saved.',
        };

      case 'acne':
      case 'acne_records':
        return {
          ...commonData,
          'type': 'acne',
          'title': isCreated
              ? 'Acne Record Added'
              : isDeleted
              ? 'Acne Record Deleted'
              : 'Acne Record Updated',
          'content': [
            if (data['severity'] != null)
              'Severity: ${data['severity']}',
            if (data['trigger'] != null)
              'Trigger: ${data['trigger']}',
            if (data['treatment'] != null)
              'Treatment: ${data['treatment']}',
          ],
          'details': isDeleted
              ? 'An acne record was removed.'
              : 'An acne record was saved to your history.',
        };

      case 'mood':
      case 'moods':
        return {
          ...commonData,
          'type': 'mood',
          'title': isCreated
              ? 'Mood Logged'
              : isDeleted
              ? 'Mood Deleted'
              : 'Mood Updated',
          'content': [
            if (data['mood'] != null)
              'Mood: ${data['mood']}',
            if (data['note'] != null)
              'Note: ${data['note']}',
          ],
          'details': isDeleted
              ? 'A mood entry was removed.'
              : 'A mood entry was saved to your history.',
        };

      case 'images':
      case 'skin_images':
        return {
          ...commonData,
          'type': 'acne',
          'title': isCreated
              ? 'Skin Image Uploaded'
              : isDeleted
              ? 'Skin Image Deleted'
              : 'Skin Image Updated',
          'content': [
            isDeleted
                ? 'Skin progress image removed'
                : 'Skin progress image saved',
            if (data['category'] != null)
              'Category: ${data['category']}',
            if (data['note'] != null)
              'Note: ${data['note']}',
          ],
          'details': isDeleted
              ? 'A skin progress image was removed.'
              : 'A skin progress image was saved to your history.',
          'imageUrl':
          data['imageUrl'] ?? data['url'] ?? '',
        };

      default:
        return null;
    }
  }
}