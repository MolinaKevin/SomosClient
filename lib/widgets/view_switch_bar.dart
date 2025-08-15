import 'package:flutter/material.dart';

class ViewSwitchBar extends StatelessWidget {
  final Key? viewSwitchKey;
  final VoidCallback onTapList;

  const ViewSwitchBar({
    super.key,
    required this.onTapList,
    this.viewSwitchKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      key: viewSwitchKey,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _TabButton(label: 'Map', isSelected: true),
        SizedBox(width: 84),
        _TabButton(label: 'List', isSelected: false),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TabButton({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: Colors.white,
          decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}
