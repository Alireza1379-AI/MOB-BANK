import 'package:flutter/material.dart';
import '../../data/models.dart';

class OperatorDashboard extends StatelessWidget {
  const OperatorDashboard({super.key});

  List<ServiceRequest> _queue() => [
        ServiceRequest(
          id: 'req-3',
          userId: 'user-2',
          type: ServiceType.typing,
          quantity: 2,
          requestedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        ServiceRequest(
          id: 'req-4',
          userId: 'user-3',
          type: ServiceType.printing,
          quantity: 40,
          requestedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ];

  List<Session> _activeSessions() => [
        Session(
          id: 'sess-10',
          userId: 'user-2',
          computerId: 'pc-5',
          startTime: DateTime.now().subtract(const Duration(minutes: 20)),
          endTime: DateTime.now().add(const Duration(minutes: 40)),
          billedDuration: const Duration(hours: 1),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final queue = _queue();
    final sessions = _activeSessions();
    return Scaffold(
      appBar: AppBar(title: const Text('Operator dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _Pane(
                title: 'Service queue',
                child: ListView.separated(
                  itemCount: queue.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final request = queue[index];
                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceVariant,
                      leading: const Icon(Icons.pending_actions),
                      title: Text('${request.type.name} x${request.quantity}'),
                      subtitle: Text('Requested ${request.requestedAt.minute}m ago'),
                      trailing: FilledButton(
                        onPressed: () {},
                        child: const Text('Complete'),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Pane(
                title: 'Active sessions',
                child: ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.secondaryContainer,
                      leading: const Icon(Icons.computer),
                      title: Text('PC ${session.computerId}'),
                      subtitle: Text('Ends at ${session.endTime.hour}:${session.endTime.minute.toString().padLeft(2, '0')}'),
                      trailing: const Text('VIP discount'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pane extends StatelessWidget {
  final String title;
  final Widget child;
  const _Pane({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
