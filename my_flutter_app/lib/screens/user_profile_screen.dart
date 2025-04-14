import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(decoration: InputDecoration(labelText: 'First Name')),
            TextFormField(decoration: InputDecoration(labelText: 'Last Name')),
            TextFormField(decoration: InputDecoration(labelText: 'Doctor')),
            SizedBox(height: 16),
            Button(),
          ],
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        print('Profile submitted!');
      },
      child: Text('Submit'),
    );
  }
}
