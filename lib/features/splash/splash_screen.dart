import 'dart:developer';

import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.isProvider});
  final bool? isProvider;

  Future<void> _processSplash(BuildContext context) async =>
      Future.delayed(const Duration(seconds: 2), () {
        log("Splash screen completed");
        if (!context.mounted) return;
        context.goNamed(Routes.login);
      });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _processSplash(context),
      builder: (context, snapshot) => Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Image.asset(
            'assets/taal.png',
            width: 250,
          ),
        ),
      ),
    );
  }
}
