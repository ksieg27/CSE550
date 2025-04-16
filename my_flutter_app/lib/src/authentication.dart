// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({super.key, required this.loggedIn, required this.signOut});

  final bool loggedIn;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    if (loggedIn) {
      // Automatically navigate to the Todays_Meds page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push('/screens/todays_meds');
      });
      return const SizedBox.shrink(); // Return an empty widget while navigating
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StyledButton(
                onPressed: () {
                  context.push('/sign-in');
                },
                child: const Text('Sign-in'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
