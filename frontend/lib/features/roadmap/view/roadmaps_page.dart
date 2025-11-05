import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import 'single_roadmap_page.dart';
import '../../home/view/home_page.dart';

class RoadmapsPage extends StatefulWidget {
  const RoadmapsPage({super.key});

  @override
  State<RoadmapsPage> createState() => _RoadmapsPageState();
}

class _RoadmapsPageState extends State<RoadmapsPage> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await DioClient.dio.get('/user/my-roadmaps');
      setState(() {
        _items = List<dynamic>.from(res.data);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => const HomePage());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Roadmaps')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i] as Map<String, dynamic>;
                    final roadmap = Map<String, dynamic>.from(item['roadmap']);
                    final startedAt = DateTime.tryParse(
                      item['started_at'] ?? '',
                    );
                    final lastUpdated = DateTime.tryParse(
                      item['last_updated'] ?? '',
                    );
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(roadmap['career_name'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value:
                                  (item['completed_percentage'] ?? 0) / 100.0,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Completed: ${(item['completed_percentage'] ?? 0).toStringAsFixed(1)}%',
                            ),
                            if (startedAt != null)
                              Text(
                                'Started: ${DateFormat.yMMMd().add_jm().format(startedAt)}',
                              ),
                            if (lastUpdated != null)
                              Text(
                                'Last updated: ${DateFormat.yMMMd().add_jm().format(lastUpdated)}',
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Get.to(() => SingleRoadmapPage(data: item)),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
