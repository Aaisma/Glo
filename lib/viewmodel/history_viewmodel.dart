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
  String? errorMessage;
  List<HistoryModel> historyItems = [];

  Future<void> loadHistory(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      historyItems = await repo.getHistory(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<HistoryModel>> getHistoryStream(String userId) {
    return repo.getHistoryStream(userId);
  }

  Stream<int> getAllHistoryCountStream() {
    return repo.getAllHistoryCountStream();
  }

  Stream<int> getUserHistoryCountStream(String userId) {
    return repo.getUserHistoryCountStream(userId);
  }

  Future<void> addHistory(
      HistoryModel history,
      String userId,
      ) async {
    await repo.addHistory(history, userId);
    await loadHistory(userId);
  }

  Future<void> updateHistory(
      HistoryModel history,
      String userId,
      ) async {
    await repo.updateHistory(history, userId);
    await loadHistory(userId);
  }

  Future<void> deleteHistory(
      String userId,
      String historyId,
      ) async {
    await repo.deleteHistory(userId, historyId);
    await loadHistory(userId);
  }

  Future<void> exportCycleData({required List<HistoryModel> items}) async {
    final cycleHistory = historyItems.where((item) => item.type == 'cycle').toList();

    final cycleData = {
      "title": cycleHistory.isNotEmpty ? cycleHistory.first.title : "Cycle History",
      "content": cycleHistory.isNotEmpty ? cycleHistory.first.content : [],
      "details": cycleHistory.isNotEmpty ? cycleHistory.first.details : "",
      "date": cycleHistory.isNotEmpty
          ? cycleHistory.first.date.toIso8601String()
          : DateTime.now().toIso8601String(),
    };

    final directory = await getApplicationDocumentsDirectory();

    final jsonFile = File('${directory.path}/cycle_data.json');
    await jsonFile.writeAsString(jsonEncode(cycleData));

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              cycleData['title'].toString(),
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),

            if (cycleData['content'] is List)
              ...(cycleData['content'] as List).map(
                    (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(item.toString()),
                ),
              ),

            pw.SizedBox(height: 12),
            pw.Text(cycleData['details'].toString()),
          ],
        ),
      ),
    );

    final pdfFile = File('${directory.path}/cycle_data.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [
        XFile(jsonFile.path),
        XFile(pdfFile.path),
      ],
      text: 'Cycle Data Export',
    );
  }
}