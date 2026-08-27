import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class KhetiqApp extends StatelessWidget {
  const KhetiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KhetIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
