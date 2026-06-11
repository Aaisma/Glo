import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'view/glo_splash_screen.dart';
import 'view/navigation_icon/dashboard_page.dart';
import 'view/survey_page.dart';
import 'view/dashboard_card/ovulation_period_page.dart';
import 'package:provider/provider.dart';
import 'view/dashboard_card/log_symptoms_page.dart';
import 'repo/period_repo_impl.dart';
import 'repo/ovulation_repo_impl.dart';
import 'viewmodel/period_view_model.dart';
import 'viewmodel/ovulation_view_model.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PeriodViewModel(PeriodRepoImpl())),
        ChangeNotifierProvider(create: (_) => OvulationViewModel(OvulationRepoImpl())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Again Project',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: const OvulationPage(),
      ),
    );
  }
}
