import 'package:flutter/material.dart';
import '../repo/journal_repo.dart';

class PhysicalActivityViewModel extends ChangeNotifier {
  final JournalRepo repository;

  PhysicalActivityViewModel({required this.repository});
}
