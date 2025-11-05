import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/config/base_url_page.dart';
import '../../academic/view/academic_questions_page.dart';
import '../../roadmap/view/roadmaps_page.dart';
// import '../../admin/view/admin_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _me;
  bool _loading = true;
  bool _loadingRoadmaps = true;
  List<dynamic> _roadmaps = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = await AuthService.me();
    List<dynamic> rms = [];
    try {
      final res = await DioClient.dio.get('/user/my-roadmaps');
      rms = List<dynamic>.from(res.data);
    } catch (_) {}
    setState(() {
      _me = me;
      _roadmaps = rms;
      _loading = false;
      _loadingRoadmaps = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ctaHeight = size.height * 0.20;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.admin_panel_settings),
          //   onPressed: () => Get.to(() => const AdminLoginPage()),
          //   tooltip: 'Admin Panel',
          // ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              DioClient.reset();
              Get.offAll(() => BaseUrlPage());
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  // Top CTA 20%
                  Container(
                    height: ctaHeight,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: _PredictCard(me: _me),
                  ),
                  // Bottom 80% roadmaps
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: _loadingRoadmaps
                          ? const Center(child: CircularProgressIndicator())
                          : _roadmaps.isEmpty
                          ? _EmptyRoadmaps(
                              onOpen: () => Get.to(() => const RoadmapsPage()),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _roadmaps.length,
                              itemBuilder: (context, i) {
                                final item =
                                    _roadmaps[i] as Map<String, dynamic>;
                                final career =
                                    item['roadmap']?['career_name'] ?? '';
                                final percent =
                                    (item['completed_percentage'] ?? 0)
                                        .toStringAsFixed(1);
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    title: Text(career),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value:
                                              (item['completed_percentage'] ??
                                                  0) /
                                              100.0,
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Completed: $percent%'),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () =>
                                        Get.to(() => const RoadmapsPage()),
                                  ),
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

class _PredictCard extends StatelessWidget {
  final Map<String, dynamic>? me;
  const _PredictCard({required this.me});

  @override
  Widget build(BuildContext context) {
    final title = me != null
        ? 'Hi, ${me!['full_name'] ?? me!['email']}'
        : 'Welcome';
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Start your career prediction now',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
            ),
            onPressed: () async {
              final me = await AuthService.me();
              if (me == null) {
                Get.snackbar('Session expired', 'Please login again');
                Get.offAll(() => BaseUrlPage());
                return;
              }
              final name = (me['full_name'] ?? me['email'] ?? 'User') as String;
              Get.to(() => AcademicQuestionsPage(userName: name));
            },
            child: const Text('Predict Career'),
          ),
        ],
      ),
    );
  }
}

class _EmptyRoadmaps extends StatelessWidget {
  final VoidCallback onOpen;
  const _EmptyRoadmaps({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alt_route, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No roadmaps yet'),
          const SizedBox(height: 8),
          TextButton(onPressed: onOpen, child: const Text('Open Roadmaps')),
        ],
      ),
    );
  }
}
