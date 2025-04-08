import 'package:flutter/material.dart';

class AppColors {
  static const Color offBlue = Color(0xFFE0F7FA);
  static const Color deepBlues = Color(0xFF2C3E50);
  static const Color getItGreen = Color(0xFF76C7C0);
  static const Color urgentOrange = Color(0xFFF4A261);
  static const Color white = Color(0xFFFFFFFF);
  // Add more colors as needed
}

class MyAppHeader extends StatelessWidget {
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final String? actionTooltip;
  final Color backgroundColor;
  final Color textColor;
  final bool roundedCorners;

  const MyAppHeader({
    super.key,
    required this.title,
    this.actionIcon,
    this.onActionPressed,
    this.actionTooltip,
    this.backgroundColor = const Color(0xFF2C3E50), // AppColors.deepBlues
    this.textColor = Colors.white,
    this.roundedCorners = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            roundedCorners
                ? BorderRadius.only(
                  topLeft: Radius.circular(9.0),
                  topRight: Radius.circular(9.0),
                )
                : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontSize: screenHeight * 0.03,
            ),
            textAlign: TextAlign.center,
          ),

          // Action button (if provided)
          if (actionIcon != null)
            Positioned(
              right: 10,
              child: Container(
                height: screenHeight * 0.05,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    actionIcon,
                    color: const Color(0xFFF4A261), // AppColors.urgentOrange
                    size: screenHeight * 0.02,
                  ),
                  onPressed: onActionPressed,
                  tooltip: actionTooltip,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MyConfirmationButton extends StatelessWidget {
  final String text;
  final IconData? actionIcon;
  final VoidCallback? actionOnPressed;
  final String? actionTooltip;
  final Color backgroundColor;
  final Color textColor;

  const MyConfirmationButton({
    super.key,
    required this.text,
    this.actionIcon,
    this.actionOnPressed,
    this.actionTooltip,
    this.backgroundColor = const Color(0xFF76C7C0), // AppColors.getItGreen
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.07,
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: actionOnPressed,
        icon: Icon(actionIcon),
        label: Text(text, style: TextStyle(fontSize: screenHeight * 0.03)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.getItGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
        ),
      ),
    );
  }
}
