import 'package:flutter/material.dart';
import '../repo/journal_repo.dart';

class SelfCareViewModel extends ChangeNotifier {
  final JournalRepo repository;

  SelfCareViewModel({required this.repository});
}
