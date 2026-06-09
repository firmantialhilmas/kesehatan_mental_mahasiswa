// lib/src/features/insightmind/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/user.dart';

final userProvider = StateProvider<User?>((ref) => null);