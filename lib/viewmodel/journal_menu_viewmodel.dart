import 'package:flutter/material.dart';
import '../repo/journal_repo.dart';

class JournalMenuViewModel extends ChangeNotifier {
  final JournalRepo repository;

  JournalMenuViewModel({required this.repository});
}
