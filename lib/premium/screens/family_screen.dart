import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet/premium/providers/family_provider.dart';
import 'package:pet/premium/widgets/premium_gate.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family View'),
        actions: [
          IconButton(
            onPressed: () => _showAddMember(context),
            icon: const Icon(Icons.person_add_rounded),
          ),
        ],
      ),
      body: PremiumGate(
        title: 'Family view',
        subtitle: 'Share budgets with your household.',
        child: Consumer<FamilyProvider>(
          builder: (context, provider, _) {
            if (provider.members.isEmpty) {
              return const Center(child: Text('No family members yet.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final member = provider.members[index];
                return ListTile(
                  title: Text(member.name),
                  subtitle: Text(member.role),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => provider.removeMember(member.id),
                  ),
                );
              },
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemCount: provider.members.length,
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAddMember(BuildContext context) async {
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                context.read<FamilyProvider>().addMember(
                  name: nameController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
