// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/app.dart';
import 'src/features/insightmind/domain/entities/screening_history.dart';
import 'src/features/insightmind/domain/entities/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INIT HIVE
  await Hive.initFlutter();

  // REGISTER ADAPTER (SETELAH GENERATE)
  Hive.registerAdapter(ScreeningHistoryAdapter());
  Hive.registerAdapter(UserAdapter());

  // LOG INIT (DEBUG)
  debugPrint('Hive & Adapter initialized');

  // BUKA BOX
  await Hive.openBox<ScreeningHistory>('screening_history');
  await Hive.openBox<User>('user_profile');

  runApp(const ProviderScope(child: InsightMindApp()));
}
