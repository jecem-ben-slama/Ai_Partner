import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AiToolSelection extends StatelessWidget {
  final String label;
  final Widget page;

  const AiToolSelection({super.key, required this.label, required this.page});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(
          MediaQuery.sizeOf(context).width * 0.8,
          MediaQuery.sizeOf(context).height * 0.1,
        ),

        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(24)),
        ),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}
