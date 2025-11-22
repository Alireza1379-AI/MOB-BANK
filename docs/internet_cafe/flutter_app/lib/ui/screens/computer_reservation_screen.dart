import 'package:flutter/material.dart';
import '../../data/models.dart';

class ComputerReservationScreen extends StatelessWidget {
  const ComputerReservationScreen({super.key});

  List<Computer> _sampleComputers() => List.generate(12, (i) {
        final status = ComputerStatus.values[i % ComputerStatus.values.length];
        return Computer(
          id: 'pc-$i',
          label: 'PC ${i + 1}',
          status: status,
          reserved: status == ComputerStatus.reserved,
          currentSessionId: status == ComputerStatus.inUse ? 'sess-$i' : null,
        );
      });

  Color _statusColor(ComputerStatus status, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (status) {
      ComputerStatus.free => colors.secondaryContainer,
      ComputerStatus.reserved => colors.tertiaryContainer,
      ComputerStatus.inUse => colors.errorContainer,
      ComputerStatus.offline => colors.surfaceVariant,
    };
  }

  String _statusLabel(ComputerStatus status) {
    return switch (status) {
      ComputerStatus.free => 'Free',
      ComputerStatus.reserved => 'Reserved',
      ComputerStatus.inUse => 'In use',
      ComputerStatus.offline => 'Offline',
    };
  }

  @override
  Widget build(BuildContext context) {
    final computers = _sampleComputers();
    return Scaffold(
      appBar: AppBar(title: const Text('Reserve a computer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4 / 3,
          ),
          itemCount: computers.length,
          itemBuilder: (context, index) {
            final computer = computers[index];
            return Card(
              color: _statusColor(computer.status, context),
              child: InkWell(
                onTap: computer.status == ComputerStatus.free
                    ? () => _showReserveDialog(context, computer)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(computer.label, style: Theme.of(context).textTheme.titleMedium),
                      Text(_statusLabel(computer.status)),
                      if (computer.currentSessionId != null)
                        Text('Session: ${computer.currentSessionId}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showReserveDialog(BuildContext context, Computer computer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reserve ${computer.label}'),
        content: const Text('Select a time slot and confirm your booking.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Confirm')),
        ],
      ),
    );
  }
}
