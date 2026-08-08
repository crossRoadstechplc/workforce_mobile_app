import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.schedule_rounded, color: Colors.white, size: 32),
              ),
              SizedBox(height: 16),
              Text('Workforce', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
}
