import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'repo/user_repo_impl.dart';
import 'repo/acne_repo_impl.dart';

import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/acne_tracker_viewmodel.dart';

import 'view/acne/acne_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AcneTestApp());
}

class AcneTestApp extends StatelessWidget {
  const AcneTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel(userRepo: UserRepoImpl())),
        ChangeNotifierProvider(create: (_) => AcneTrackerViewModel(AcneRepoImpl())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Acne Tracker Test',
        theme: ThemeData(primarySwatch: Colors.pink),
        home: const AcneTrackerPage(),
      ),
    );
  }
}