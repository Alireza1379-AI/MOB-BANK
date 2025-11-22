import 'package:flutter/material.dart';
import '../../data/models.dart';

class DailyReportsScreen extends StatelessWidget {
  const DailyReportsScreen({super.key});

  DailyReport _sampleReport() => DailyReport(
        date: DateTime.now(),
        sessionRevenue: 420.0,
        serviceRevenue: 120.0,
        activeSessions: 8,
        completedRequests: 26,
        penalties: 30.0,
        serviceBreakdown: const {
          ServiceType.printing: 14,
          ServiceType.scanning: 4,
          ServiceType.typing: 6,
          ServiceType.refreshments: 2,
        },
      );

  @override
  Widget build(BuildContext context) {
    final report = _sampleReport();
    return Scaffold(
      appBar: AppBar(title: const Text('Daily reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary for ${report.date.toLocal().toIso8601String().substring(0, 10)}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(label: 'Session revenue', value: '\$${report.sessionRevenue.toStringAsFixed(2)}'),
                _StatCard(label: 'Service revenue', value: '\$${report.serviceRevenue.toStringAsFixed(2)}'),
                _StatCard(label: 'Penalties', value: '\$${report.penalties.toStringAsFixed(2)}'),
                _StatCard(label: 'Active sessions', value: report.activeSessions.toString()),
                _StatCard(label: 'Completed requests', value: report.completedRequests.toString()),
              ],
            ),
            const SizedBox(height: 16),
            Text('Service breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: report.serviceBreakdown.entries
                    .map((e) => ListTile(
                          title: Text(e.key.name),
                          trailing: Text(e.value.toString()),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
