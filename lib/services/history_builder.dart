import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryBuilder {
  static Map<String, dynamic>? build({
    required String collectionName,
    required String docId,
    required Map<String, dynamic> data,
    required String action,
  }) {
    final userId = data['userId'];

    if (userId == null || userId.toString().trim().isEmpty) {
      return null;
    }

    final historyId = '${collectionName}_${docId}_$action';

    switch (collectionName) {
      case 'medications':
        return {
          'id': historyId,
          'userId': userId,
          'type': 'medication',
          'title': action == 'created'
              ? 'Medication Added'
              : 'Medication Updated',
          'content': [
            '${data['name'] ?? 'Medication'}${data['dosage'] != null ? ' - ${data['dosage']}' : ''}',
            if (data['type'] != null) 'Type: ${data['type']}',
            if (data['schedule'] != null) 'Schedule: ${data['schedule']}',
          ],
          'details': action == 'created'
              ? '${data['name'] ?? 'Medication'} was added to your medication list.'
              : '${data['name'] ?? 'Medication'} was updated in your medication list.',
          'relatedId': docId,
          'relatedCollection': collectionName,
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

      case 'visits':
        return {
          'id': historyId,
          'userId': userId,
          'type': 'visit',
          'title': action == 'created' ? 'Visit Added' : 'Visit Updated',
          'content': [
            if (data['doctorName'] != null) 'Doctor: ${data['doctorName']}',
            if (data['treatment'] != null) 'Treatment: ${data['treatment']}',
            if (data['visitDate'] != null) 'Visit Date: ${data['visitDate']}',
            if (data['followUpDate'] != null)
              'Follow-up: ${data['followUpDate']}',
          ],
          'details': action == 'created'
              ? 'A doctor visit was added to your history.'
              : 'A doctor visit was updated in your history.',
          'relatedId': docId,
          'relatedCollection': collectionName,
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

      case 'journals':
      case 'journal':
        return {
          'id': historyId,
          'userId': userId,
          'type': 'journal',
          'title': action == 'created'
              ? 'Journal Added'
              : 'Journal Updated',
          'content': [
            data['title'] ?? 'Journal entry saved',
          ],
          'details':
          data['note'] ?? data['details'] ?? 'A journal note was saved.',
          'relatedId': docId,
          'relatedCollection': collectionName,
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

      case 'cycle':
      case 'cycles':
        return {
          'id': historyId,
          'userId': userId,
          'type': 'cycle',
          'title': action == 'created' ? 'Cycle Added' : 'Cycle Updated',
          'content': [
            if (data['lastPeriod'] != null)
              'Last Period: ${data['lastPeriod']}',
            if (data['duration'] != null) 'Duration: ${data['duration']}',
            if (data['irregularity'] != null)
              'Irregularity: ${data['irregularity']}',
          ],
          'details': 'Cycle information was saved.',
          'relatedId': docId,
          'relatedCollection': collectionName,
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

      case 'acne':
      case 'acne_records':
        return {
          'id': historyId,
          'userId': userId,
          'type': 'acne',
          'title': action == 'created'
              ? 'Acne Record Added'
              : 'Acne Record Updated',
          'content': [
            if (data['severity'] != null) 'Severity: ${data['severity']}',
            if (data['trigger'] != null) 'Trigger: ${data['trigger']}',
            if (data['treatment'] != null) 'Treatment: ${data['treatment']}',
          ],
          'details': 'An acne record was saved to your history.',
          'relatedId': docId,
          'relatedCollection': collectionName,
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

      case 'mood':
      case 'moods':
        return {
          'id': historyId,
          'userId': userId,
          'type': 'mood',
          'title': action == 'created' ? 'Mood Logged' : 'Mood Updated',
          'content': [
            if (data['mood'] != null) 'Mood: ${data['mood']}',
            if (data['note'] != null) 'Note: ${data['note']}',
          ],
          'details': 'A mood entry was saved to your history.',
          'relatedId': docId,
          'relatedCollection': collectionName,
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

      case 'images':
      case 'skin_images':
        return {
          'id': historyId,
          'userId': userId,
          'type': 'acne',
          'title': action == 'created'
              ? 'Skin Image Uploaded'
              : 'Skin Image Updated',
          'content': [
            'Skin progress image saved',
            if (data['category'] != null) 'Category: ${data['category']}',
            if (data['note'] != null) 'Note: ${data['note']}',
          ],
          'details': 'A skin progress image was saved to your history.',
          'relatedId': docId,
          'relatedCollection': collectionName,
          'imageUrl': data['imageUrl'] ?? data['url'] ?? '',
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

      default:
        return null;
    }
  }
}