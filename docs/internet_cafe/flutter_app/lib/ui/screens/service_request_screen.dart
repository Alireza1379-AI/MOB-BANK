import 'package:flutter/material.dart';
import '../../data/models.dart';

class ServiceRequestScreen extends StatelessWidget {
  const ServiceRequestScreen({super.key});

  List<ServiceRequest> _requests() => [
        ServiceRequest(
          id: 'req-1',
          userId: 'user-1',
          type: ServiceType.printing,
          quantity: 12,
          requestedAt: DateTime.now().subtract(const Duration(minutes: 6)),
        ),
        ServiceRequest(
          id: 'req-2',
          userId: 'user-1',
          type: ServiceType.scanning,
          quantity: 4,
          requestedAt: DateTime.now().subtract(const Duration(minutes: 14)),
          fulfilled: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final requests = _requests();
    return Scaffold(
      appBar: AppBar(title: const Text('Request services')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewRequestDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final request = requests[index];
          return ListTile(
            tileColor: Theme.of(context).colorScheme.surfaceVariant,
            title: Text('${request.type.name} x${request.quantity}'),
            subtitle: Text('Requested at ${request.requestedAt.hour}:${request.requestedAt.minute.toString().padLeft(2, '0')}'),
            trailing: Chip(
              label: Text(request.fulfilled ? 'Done' : 'In queue'),
              backgroundColor: request.fulfilled
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }

  void _showNewRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New service request'),
        content: const Text('Pick a service type, quantity, and priority.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Submit')),
        ],
      ),
    );
  }
}
