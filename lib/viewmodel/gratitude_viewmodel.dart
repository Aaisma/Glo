import 'package:flutter/material.dart';
import '../repo/journal_repo.dart';

class GratitudeViewModel extends ChangeNotifier {
  final JournalRepo repository;

  GratitudeViewModel({required this.repository});
}
