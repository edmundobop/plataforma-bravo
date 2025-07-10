import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/checklist.dart';
import '../../../../core/providers/providers.dart';

class ChecklistDetailsScreen extends ConsumerWidget {
  final String checklistId;

  const ChecklistDetailsScreen({super.key, required this.checklistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync =
        ref.watch(checklistServiceProvider).getChecklistById(checklistId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Checklist'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Checklist?>(
        future: checklistAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
            ));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Color(0xFFD32F2F)),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar checklist: ${snapshot.error}'),
                  const SizedBox(height: 16),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Checklist não encontrado.'));
          } else {
            final checklist = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações Gerais',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: const Color(0xFFD32F2F),
                                ),
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                              'Data do Checklist',
                              checklist.checklistDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]),
                          _DetailRow(
                              'Status Geral',
                              checklist.status
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase()),
                          _DetailRow('Realizado por',
                              checklist.userId), // TODO: Fetch user name
                          if (checklist.generalObservations != null &&
                              checklist.generalObservations!.isNotEmpty)
                            _DetailRow('Observações Gerais',
                                checklist.generalObservations!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Itens do Checklist',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: const Color(0xFFD32F2F),
                                ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: checklist.items.length,
                            itemBuilder: (context, index) {
                              final item = checklist.items[index];
                              return ListTile(
                                title: Text(item.description),
                                subtitle: Text(
                                  'Status: ${item.status.toString().split('.').last.toUpperCase()}'
                                  '${item.observation != null && item.observation!.isNotEmpty ? ' - Obs: ${item.observation}' : ''}',
                                ),
                                leading: Icon(
                                  _getChecklistItemIcon(item.status),
                                  color: _getChecklistItemColor(item.status),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  IconData _getChecklistItemIcon(ChecklistItemStatus status) {
    switch (status) {
      case ChecklistItemStatus.ok:
        return Icons.check_circle;
      case ChecklistItemStatus.notOk:
        return Icons.cancel;
      case ChecklistItemStatus.na:
        return Icons.info;
    }
  }

  Color _getChecklistItemColor(ChecklistItemStatus status) {
    switch (status) {
      case ChecklistItemStatus.ok:
        return Colors.green;
      case ChecklistItemStatus.notOk:
        return const Color(0xFFD32F2F);
      case ChecklistItemStatus.na:
        return Colors.grey;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
