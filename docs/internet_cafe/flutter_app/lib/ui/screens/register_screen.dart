import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Get started', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 12),
              SwitchListTile(
                value: true,
                onChanged: (_) {},
                title: const Text('VIP membership'),
                subtitle: const Text('Apply VIP discounts to sessions and services.'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/customer'),
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
