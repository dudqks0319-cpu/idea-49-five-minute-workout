import 'package:flutter/material.dart';

void main() {
  runApp(const IdeaApp());
}

class IdeaApp extends StatelessWidget {
  const IdeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '5분 홈트 루틴',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5분 홈트 루틴')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('한 줄 컨셉', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('짧은 운동 루틴 추천과 기록'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '비즈니스 모델',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text('구독'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '프로젝트 메타',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text('카테고리: 건강'),
                  Text('MVP 난이도: 하'),
                  Text('플랫폼: Android / iOS / Web'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: null,
            child: const Text('다음 단계: Supabase API 연결'),
          ),
        ],
      ),
    );
  }
}
