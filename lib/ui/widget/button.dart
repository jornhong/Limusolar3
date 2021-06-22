import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    Key? key,
    required this.icon,
    required this.text,
    this.color,
    required this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  final String icon;
  final String text;
  final Color? color;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: color,
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(icon, fit: BoxFit.scaleDown,),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
