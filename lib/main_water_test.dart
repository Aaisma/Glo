import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'repo/water_tracker_repo_impl.dart';
import 'viewmodel/water_tracker_viewmodel.dart';
import 'view/water/water_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WaterTestApp());
}

class WaterTestApp extends StatelessWidget {
  const WaterTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WaterTrackerViewModel(WaterTrackerRepoImpl())),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WaterTrackerScreen(),
      ),
    );
  }
}