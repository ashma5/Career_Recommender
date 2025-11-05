import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import '../../../../core/network/dio_client.dart';

class SingleRoadmapPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const SingleRoadmapPage({super.key, required this.data});

  @override
  State<SingleRoadmapPage> createState() => _SingleRoadmapPageState();
}

class _SingleRoadmapPageState extends State<SingleRoadmapPage> {
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    final roadmap = Map<String, dynamic>.from(_data['roadmap']);
    final rd = Map<String, dynamic>.from(roadmap['roadmap_data']);
    final startedAt = DateTime.tryParse(_data['started_at'] ?? '');
    final lastUpdated = DateTime.tryParse(_data['last_updated'] ?? '');

    // Start from second-level: render children of root as top nodes
    final List<dynamic> topChildren = (rd['children'] as List<dynamic>? ?? []);

    return Scaffold(
      appBar: AppBar(title: Text(roadmap['career_name'] ?? 'Roadmap')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed: ${(_data['completed_percentage'] ?? 0).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (_data['completed_percentage'] ?? 0) / 100.0,
                  ),
                  const SizedBox(height: 6),
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
            ),
          ),
          const SizedBox(height: 12),
          // Render second-level nodes as starting points (no root title)
          Column(
            children: [
              for (final child in topChildren)
                if (child is Map<String, dynamic>)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _GraphNode(node: child, depth: 0),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GraphNode extends StatefulWidget {
  final Map<String, dynamic> node;
  final int depth;

  const _GraphNode({required this.node, required this.depth});

  @override
  State<_GraphNode> createState() => _GraphNodeState();
}

class _GraphNodeState extends State<_GraphNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.node['name'] ?? '';
    final details = widget.node['details'] as String?;
    final children = widget.node['children'] as List<dynamic>?;
    final completed = (widget.node['completed'] ?? false) as bool;

    final Color color = [
      Colors.deepPurple,
      Colors.teal,
      Colors.blue,
    ][widget.depth % 3];

    final bool isLeaf = children == null || children.isEmpty;

    // Mobile-friendly: reduce connector footprint on small widths
    final isNarrow = MediaQuery.of(context).size.width < 420;
    final connectorWidth = 10.0;
    final connectorHeight = 44.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: connectorWidth,
              child: CustomPaint(
                painter: _ConnectorPainter(color: color),
                size: Size(double.infinity, connectorHeight),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isNarrow ? 4 : 20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: isNarrow ? 12 : 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isNarrow ? 2.0 : 4.0,
                      vertical: isNarrow ? 14.0 : 18.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _expanded ? Icons.expand_less : Icons.expand_more,
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (isLeaf)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: completed
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  completed ? 'Completed' : 'Pending',
                                  style: TextStyle(
                                    color: completed
                                        ? Colors.green
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (_expanded && details != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(details),
                            ),
                          ),
                        if (_expanded && children != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12.0,
                              left: 8,
                              right: 8,
                              bottom: 4,
                            ),
                            child: Column(
                              children: [
                                for (final c in children)
                                  if (c is Map<String, dynamic>)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: _GraphNode(
                                        node: c,
                                        depth: widget.depth + 1,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final Color color;
  _ConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // vertical line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    // elbow to the card
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
