import 'package:flutter/material.dart';

import 'app.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = await SupabaseService.bootstrapFromEnvironment();
  runApp(EnergyCoachApp(service: service));
}
