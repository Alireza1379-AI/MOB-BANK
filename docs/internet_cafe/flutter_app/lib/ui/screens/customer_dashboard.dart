import 'package:flutter/material.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _DashboardCard(
              title: 'Reserve a computer',
              subtitle: 'Book time slots with live availability.',
              icon: Icons.computer,
              onTap: () => Navigator.pushNamed(context, '/reserve'),
            ),
            _DashboardCard(
              title: 'Request services',
              subtitle: 'Printing, scanning, typing and more.',
              icon: Icons.print,
              onTap: () => Navigator.pushNamed(context, '/services'),
            ),
            _DashboardCard(
              title: 'Invoices',
              subtitle: 'Review past sessions and receipts.',
              icon: Icons.receipt_long,
              onTap: () {},
            ),
            _DashboardCard(
              title: 'Usage history',
              subtitle: 'See time spent and discounts applied.',
              icon: Icons.history,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
