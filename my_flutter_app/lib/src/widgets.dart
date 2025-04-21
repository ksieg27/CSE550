// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'theme.dart';

class Header extends StatelessWidget {
  const Header(this.heading, {super.key});
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(heading, style: const TextStyle(fontSize: 24)),
  );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content, {super.key});
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text(content, style: const TextStyle(fontSize: 18)),
  );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail, {super.key});
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(detail, style: const TextStyle(fontSize: 18)),
      ],
    ),
  );
}

class StyledButton extends StatelessWidget {
  const StyledButton({required this.child, required this.onPressed, super.key});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.deepBlues),
    ),
    onPressed: onPressed,
    child: child,
  );
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
