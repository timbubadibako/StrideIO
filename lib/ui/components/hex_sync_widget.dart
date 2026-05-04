import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HexSyncWidget extends StatelessWidget {
  final int syncPercentage;

  const HexSyncWidget({super.key, required this.syncPercentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonCyan.withOpacity(0.1 + (syncPercentage / 100) * 0.2), 
            blurRadius: 30 + (syncPercentage.toDouble() / 2),
          )
        ]
      ),
      alignment: Alignment.center,
      child: Skeleton.keep(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$syncPercentage', 
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                shadows: [Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 10)]
              )
            ),
            Text(
              '% SYNC', 
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.neonCyan,
                letterSpacing: 2.0,
              )
            ),
          ],
        ),
      ),
    );
  }
}
