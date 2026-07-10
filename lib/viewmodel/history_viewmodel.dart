import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../model/history_model.dart';
import '../repo/history_repo.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryRepo repo;

  HistoryViewModel(this.repo);

  bool isLoading = false;
  bool isExporting = false;

  String? errorMessage;

  List<HistoryModel> historyItems = [];

  Future<void> loadHistory(String userId) async {
    if (userId.trim().isEmpty) {
      errorMessage = 'User ID is required.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      historyItems = await repo.getHistory(userId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<HistoryModel>> getHistoryStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.error('User ID is required.');
    }

    return repo.getHistoryStream(userId);
  }

  Stream<int> getAllHistoryCountStream() {
    return repo.getAllHistoryCountStream();
  }

  Stream<int> getUserHistoryCountStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.error('User ID is required.');
    }

    return repo.getUserHistoryCountStream(userId);
  }

  Future<void> addHistory(
      HistoryModel history,
      String userId,
      ) async {
    if (userId.trim().isEmpty) {
      errorMessage = 'User ID is required.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await repo.addHistory(history, userId);
      historyItems = await repo.getHistory(userId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHistory(
      HistoryModel history,
      String userId,
      ) async {
    if (userId.trim().isEmpty) {
      errorMessage = 'User ID is required.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await repo.updateHistory(history, userId);
      historyItems = await repo.getHistory(userId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHistory(
      String userId,
      String historyId,
      ) async {
    if (userId.trim().isEmpty) {
      errorMessage = 'User ID is required.';
      notifyListeners();
      return;
    }

    if (historyId.trim().isEmpty) {
      errorMessage = 'History ID is required.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await repo.deleteHistory(userId, historyId);
      historyItems = await repo.getHistory(userId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportCycleData({
    required List<HistoryModel> items,
  }) async {
    isExporting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cycleHistory = items
          .where(
            (item) => item.type.trim().toLowerCase() == 'cycle',
      )
          .toList()
        ..sort(
              (first, second) => second.date.compareTo(first.date),
        );

      if (cycleHistory.isEmpty) {
        throw Exception('No cycle history is available to export.');
      }

      final exportData = {
        'title': 'Cycle History',
        'exportedAt': DateTime.now().toIso8601String(),
        'totalRecords': cycleHistory.length,
        'records': cycleHistory.map((item) {
          return {
            'title': item.title,
            'content': item.content,
            'details': item.details,
            'date': item.date.toIso8601String(),
          };
        }).toList(),
      };

      final directory = await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final jsonFile = File(
        '${directory.path}/cycle_data_$timestamp.json',
      );

      const jsonEncoder = JsonEncoder.withIndent('  ');

      await jsonFile.writeAsString(
        jsonEncoder.convert(exportData),
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (_) {
            return [
              pw.Text(
                'Cycle History',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Total records: ${cycleHistory.length}',
                style: const pw.TextStyle(
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 20),
              ...cycleHistory.map(
                    (item) => _buildCyclePdfSection(item),
              ),
            ];
          },
        ),
      );

      final pdfFile = File(
        '${directory.path}/cycle_data_$timestamp.pdf',
      );

      await pdfFile.writeAsBytes(
        await pdf.save(),
      );

      await Share.shareXFiles(
        [
          XFile(jsonFile.path),
          XFile(pdfFile.path),
        ],
        text: 'Cycle Data Export',
        subject: 'Cycle History',
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  pw.Widget _buildCyclePdfSection(HistoryModel item) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            item.title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            _formatDate(item.date),
            style: const pw.TextStyle(
              fontSize: 11,
            ),
          ),
          pw.SizedBox(height: 10),
          ...item.content.map(
                (contentItem) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Text(
                contentItem,
                style: const pw.TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (item.details.trim().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              item.details,
              style: const pw.TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}