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
  List<HistoryModel> historyItems = [];

  Future<void> loadHistory(String userId) async {
    isLoading = true;
    notifyListeners();

    historyItems = await repo.getHistory(userId);

    isLoading = false;
    notifyListeners();
  }

  Stream<List<HistoryModel>> getHistoryStream(String userId) {
    return repo.getHistoryStream(userId);
  }

  Future<void> addHistory(HistoryModel history, String userId) async {
    await repo.addHistory(history, userId);
  }

  Future<void> updateHistory(HistoryModel history, String userId) async {
    await repo.updateHistory(history, userId);
  }

  Future<void> deleteHistory(String userId, String historyId) async {
    await repo.deleteHistory(userId, historyId);
  }

  Future<void> exportCycleData() async {
    final cycleData = {
      "lastPeriod": "3 June 2026",
      "duration": "5 days",
      "irregularity": "April shorter cycle",
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
              "Cycle History",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Last Period: ${cycleData['lastPeriod']}"),
            pw.Text("Duration: ${cycleData['duration']}"),
            pw.Text("Irregularity: ${cycleData['irregularity']}"),
          ],
        ),
      ),
    );

    final pdfFile = File('${directory.path}/cycle_data.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(jsonFile.path), XFile(pdfFile.path)],
      text: 'Cycle Data Export',
    );
  }
}