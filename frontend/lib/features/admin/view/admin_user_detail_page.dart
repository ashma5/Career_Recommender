import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/admin_service.dart';
import '../../roadmap/view/single_roadmap_page.dart';

class AdminUserDetailPage extends StatefulWidget {
  final int userId;
  const AdminUserDetailPage({super.key, required this.userId});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminService.getUserDetail(widget.userId);
      setState(() {
        _detail = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_detail != null)
                    _UserCard(
                      user: Map<String, dynamic>.from(_detail!['user'] ?? {}),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Roadmaps',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...List<Map<String, dynamic>>.from(
                    _detail!['roadmaps'] ?? [],
                  ).map((r) {
                    final startedAt = DateTime.tryParse(r['started_at'] ?? '');
                    final updatedAt = DateTime.tryParse(
                      r['last_updated'] ?? '',
                    );
                    final percent = (r['completed_percentage'] ?? 0)
                        .toStringAsFixed(1);
                    final career =
                        r['roadmap']?['career_name']?.toString().replaceAll(
                          '-',
                          ' ',
                        ) ??
                        '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Get.to(() => SingleRoadmapPage(data: r));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF667eea).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.map,
                                      color: Color(0xFF667eea),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      career,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$percent%',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: (r['completed_percentage'] ?? 0) / 100.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF667eea),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (startedAt != null)
                                    Text(
                                      'Started: ${DateFormat.yMMMd().format(startedAt)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (updatedAt != null)
                                    Text(
                                      'Updated: ${DateFormat.yMMMd().format(updatedAt)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserCard({required this.user});
  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(user['created_at'] ?? '');
    final updatedAt = DateTime.tryParse(user['updated_at'] ?? '');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['full_name'] ?? user['email'] ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(user['email'] ?? ''),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    user['is_active'] == true ? 'Active' : 'Inactive',
                  ),
                ),
                Chip(label: Text('Roadmaps: ${user['roadmap_count'] ?? 0}')),
                if (createdAt != null)
                  Chip(
                    label: Text(
                      'Created: ${DateFormat.yMMMd().format(createdAt)}',
                    ),
                  ),
                if (updatedAt != null)
                  Chip(
                    label: Text(
                      'Updated: ${DateFormat.yMMMd().format(updatedAt)}',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
