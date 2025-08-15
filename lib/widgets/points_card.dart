import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PointsCard extends StatelessWidget {
  final bool isAuthenticated;
  final double points;
  final String totalPointsLabel;

  const PointsCard({
    super.key,
    required this.isAuthenticated,
    required this.points,
    required this.totalPointsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAuthenticated
        ? CupertinoColors.activeGreen
        : CupertinoColors.destructiveRed;

    return Container(
      padding: const EdgeInsets.all(10),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Text(
            totalPointsLabel,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            points.toString(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
