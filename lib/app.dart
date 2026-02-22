import 'package:flutter/material.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/supabase_service.dart';

class EnergyCoachApp extends StatefulWidget {
  const EnergyCoachApp({super.key, required this.service});

  final SupabaseService service;

  @override
  State<EnergyCoachApp> createState() => _EnergyCoachAppState();
}

class _EnergyCoachAppState extends State<EnergyCoachApp> {
  late final AuthProvider _authProvider;
  late final TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(service: widget.service);
    _taskProvider = TaskProvider(service: widget.service, authProvider: _authProvider);
    _authProvider.addListener(_onAuthChanged);

    if (_authProvider.isLoggedIn) {
      _taskProvider.refresh();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    _authProvider.dispose();
    _taskProvider.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (_authProvider.isLoggedIn) {
      _taskProvider.refresh();
    } else {
      _taskProvider.clear();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '5분 홈트 루틴',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
        useMaterial3: true,
      ),
      home: _authProvider.isLoggedIn
          ? HomeScreen(authProvider: _authProvider, taskProvider: _taskProvider)
          : LoginScreen(authProvider: _authProvider),
    );
  }
}
