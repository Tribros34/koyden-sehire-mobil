import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/admin_invite_network_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_invite_network_controller.dart';

class AdminInviteNetworkView extends StatefulWidget {
  const AdminInviteNetworkView({super.key});

  @override
  State<AdminInviteNetworkView> createState() =>
      _AdminInviteNetworkViewState();
}

class _AdminInviteNetworkViewState
    extends State<AdminInviteNetworkView> {
  late final AdminInviteNetworkController _ctrl;

  @override
  void initState() {
    super.initState();
    final repo = Get.find<AdminRepository>();
    _ctrl = Get.put(AdminInviteNetworkController(repo));
  }

  @override
  void dispose() {
    Get.delete<AdminInviteNetworkController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Davet Ağı',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Üreticiler arasındaki davet ilişkileri.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_ctrl.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_ctrl.error.value),
                    TextButton(
                        onPressed: _ctrl.load,
                        child: const Text('Tekrar Dene')),
                  ],
                ),
              );
            }
            final root = _ctrl.root.value;
            if (root == null) {
              return const Center(child: Text('Ağ verisi bulunamadı.'));
            }
            return RefreshIndicator(
              onRefresh: _ctrl.load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _NodeTree(node: root, depth: 0),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _NodeTree extends StatefulWidget {
  final InviteNode node;
  final int depth;
  const _NodeTree({required this.node, required this.depth});

  @override
  State<_NodeTree> createState() => _NodeTreeState();
}

class _NodeTreeState extends State<_NodeTree> {
  bool _expanded = true;

  Color _trustColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFE63946);
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final hasChildren = node.invitees.isNotEmpty;
    final indentWidth = widget.depth * 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indentWidth),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.push('/admin/farmers/${node.id}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    if (node.isFoundingFarmer)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.hub,
                            size: 16, color: Color(0xFF2D6A4F)),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.fullName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            node.city,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (node.inviteCode != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          node.inviteCode!,
                          style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: Colors.grey),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _trustColor(node.trustScore).withOpacity(0.15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        node.trustScore.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _trustColor(node.trustScore),
                        ),
                      ),
                    ),
                    if (hasChildren) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Icon(
                          _expanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasChildren && _expanded)
          ...node.invitees.map(
            (child) => _NodeTree(node: child, depth: widget.depth + 1),
          ),
      ],
    );
  }
}
