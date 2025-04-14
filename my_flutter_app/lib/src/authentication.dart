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
    return Column(
      mainAxisAlignment: !loggedIn ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: !loggedIn ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: StyledButton(
                onPressed: () {
                  !loggedIn ? context.push('/sign-in') : signOut();
                },
                child: !loggedIn ? const Text('Sign-in') : const Text('Logout'),
              ),
            ),
            if (loggedIn) ...[
              Visibility(
                visible: loggedIn,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 8),
                  child: StyledButton(
                    onPressed: () {
                      context.push('/screens/user_profile_screen');
                    },
                    child: const Text('Profile'),
                  ),
                ),
              ),
              Visibility(
                visible: loggedIn,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 8),
                  child: StyledButton(
                    onPressed: () {
                      context.push('/screens/med_manage');
                    },
                    child: const Text('Medications'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
