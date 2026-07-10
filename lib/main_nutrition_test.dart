import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'repo/nutrition_repo_impl.dart';
import 'viewmodel/nutrition_tracker_viewmodel.dart';
import 'view/nutrition_tracker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MealTestApp());
}

class MealTestApp extends StatelessWidget {
  const MealTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NutritionTrackerViewModel(NutritionRepoImpl())),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NutritionTrackerScreen(),
      ),
    );
  }
}