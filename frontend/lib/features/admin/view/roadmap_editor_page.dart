import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/auth/admin_service.dart';

class RoadmapEditorPage extends StatefulWidget {
  final int? roadmapId;
  final Map<String, dynamic>? existingRoadmap;
  const RoadmapEditorPage({super.key, this.roadmapId, this.existingRoadmap});

  @override
  State<RoadmapEditorPage> createState() => _RoadmapEditorPageState();
}

class _RoadmapEditorPageState extends State<RoadmapEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _careerNameController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0');
  bool _loading = false;
  bool _isEditing = false;

  // Top-level nodes (no synthetic root)
  List<RoadmapNode> _nodes = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.roadmapId != null || widget.existingRoadmap != null;
    if (_isEditing && widget.existingRoadmap != null) {
      _hydrateFromExisting(widget.existingRoadmap!);
    }
  }

  void _hydrateFromExisting(Map<String, dynamic> r) {
    final careerName = (r['career_name'] as String? ?? '').replaceAll('-', ' ');
    final version = r['version']?.toString() ?? '1.0';
    final roadmapData = Map<String, dynamic>.from(r['roadmap_data'] ?? {});

    _careerNameController.text = careerName.isNotEmpty
        ? careerName
        : (roadmapData['name'] as String? ?? '');
    _versionController.text = version;

    final List<dynamic> topChildren =
        (roadmapData['children'] as List<dynamic>? ?? []);
    _nodes = _buildNodesFromChildren(topChildren, 0);
    setState(() {});
  }

  List<RoadmapNode> _buildNodesFromChildren(List<dynamic> children, int level) {
    return children.whereType<Map<String, dynamic>>().map((c) {
      final name = c['name']?.toString() ?? '';
      final details = c['details']?.toString() ?? '';
      final sub = _buildNodesFromChildren(
        (c['children'] as List<dynamic>? ?? []),
        level + 1,
      );
      return RoadmapNode(
        name: name,
        details: details,
        children: sub,
        level: level,
      );
    }).toList();
  }

  void _addTopLevelNode() {
    setState(() {
      _nodes.add(
        RoadmapNode(name: 'New Topic', details: '', children: [], level: 0),
      );
    });
  }

  void _addChildNode(RoadmapNode parent) {
    if (parent.level >= 3) return; // Max depth 4 (0..3)
    setState(() {
      parent.children.add(
        RoadmapNode(
          name: 'New Node',
          details: '',
          children: [],
          level: parent.level + 1,
        ),
      );
    });
  }

  void _removeTopNode(RoadmapNode node) {
    setState(() => _nodes.remove(node));
  }

  void _removeChildNode(RoadmapNode parent, RoadmapNode child) {
    setState(() => parent.children.remove(child));
  }

  Map<String, dynamic> _buildRoadmapData() {
    return {
      'name': _careerNameController.text,
      'children': _nodes.map((n) => _buildNodeData(n)).toList(),
    };
  }

  Map<String, dynamic> _buildNodeData(RoadmapNode node) {
    final data = <String, dynamic>{'name': node.name, 'details': node.details};
    if (node.children.isNotEmpty) {
      data['children'] = node.children.map((c) => _buildNodeData(c)).toList();
    }
    return data;
  }

  Future<void> _saveRoadmap() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nodes.isEmpty) {
      Get.snackbar('Error', 'Please add at least one roadmap section');
      return;
    }
    setState(() => _loading = true);
    try {
      final data = {
        'career_name': _careerNameController.text.replaceAll(' ', '-'),
        'version': _versionController.text,
        'is_active': true, // default; activation handled in dashboard actions
        'roadmap_data': _buildRoadmapData(),
      };
      if (_isEditing && widget.roadmapId != null) {
        await AdminService.updateRoadmap(widget.roadmapId!, data);
        Get.snackbar('Success', 'Roadmap updated successfully');
      } else {
        await AdminService.createRoadmap(data);
        Get.snackbar('Success', 'Roadmap created successfully');
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Roadmap' : 'Create Roadmap'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _loading ? null : _saveRoadmap,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header Form
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   'Roadmap Details',
                  //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _careerNameController,
                          decoration: InputDecoration(
                            labelText: 'Career Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _versionController,
                          decoration: InputDecoration(
                            labelText: 'Version',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addTopLevelNode,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Section'),
                    ),
                  ),
                ],
              ),
            ),

            // Roadmap Tree
            Expanded(
              child: _nodes.isEmpty
                  ? const Center(child: Text('No sections added yet'))
                  : InteractiveViewer(
                      constrained: true,
                      minScale: 0.75,
                      maxScale: 2.5,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _nodes.map((n) {
                                return _TopNodeWidget(
                                  node: n,
                                  onAddChild: _addChildNode,
                                  onRemove: _removeTopNode,
                                  onRemoveChild: _removeChildNode,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoadmapNode {
  String name;
  String details;
  List<RoadmapNode> children;
  int level;
  RoadmapNode({
    required this.name,
    required this.details,
    required this.children,
    required this.level,
  });
}

class _TopNodeWidget extends StatelessWidget {
  final RoadmapNode node;
  final Function(RoadmapNode) onAddChild;
  final Function(RoadmapNode) onRemove;
  final Function(RoadmapNode, RoadmapNode) onRemoveChild;
  const _TopNodeWidget({
    required this.node,
    required this.onAddChild,
    required this.onRemove,
    required this.onRemoveChild,
  });

  @override
  Widget build(BuildContext context) {
    return _NodeWidget(
      node: node,
      onAddChild: onAddChild,
      onRemove: onRemove,
      onRemoveChild: onRemoveChild,
    );
  }
}

class _NodeWidget extends StatefulWidget {
  final RoadmapNode node;
  final Function(RoadmapNode) onAddChild;
  final Function(RoadmapNode) onRemove;
  final Function(RoadmapNode, RoadmapNode) onRemoveChild;
  const _NodeWidget({
    required this.node,
    required this.onAddChild,
    required this.onRemove,
    required this.onRemoveChild,
  });
  @override
  State<_NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<_NodeWidget> {
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _expanded = true;
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.node.name;
    _detailsController.text = widget.node.details;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      const Color(0xFFf093fb),
      const Color(0xFFf5576c),
    ];
    final color = colors[widget.node.level % colors.length];
    return Container(
      margin: EdgeInsets.only(left: widget.node.level * 2.0, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Node name',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    onChanged: (v) => widget.node.name = v,
                  ),
                ),
                if (widget.node.level < 2)
                  IconButton(
                    onPressed: () => widget.onAddChild(widget.node),
                    icon: const Icon(Icons.add),
                    color: color,
                  ),
                IconButton(
                  onPressed: () => widget.onRemove(widget.node),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TextFormField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (v) => widget.node.details = v,
                  ),
                  if (widget.node.children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: widget.node.children.map((child) {
                          return _NodeWidget(
                            node: child,
                            onAddChild: widget.onAddChild,
                            onRemove: (n) =>
                                widget.onRemoveChild(widget.node, n),
                            onRemoveChild: widget.onRemoveChild,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
