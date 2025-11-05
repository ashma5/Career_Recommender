def calculate_completion_percentage(roadmap_data: dict, progress_data: dict) -> float:
    """Calculate completion percentage based only on leaf nodes (final steps with details)"""
    leaf_nodes = find_leaf_nodes(roadmap_data)
    total_leaf_nodes = len(leaf_nodes)
    
    if total_leaf_nodes == 0:
        return 0.0
    
    completed_leaf_nodes = sum(1 for node_id in leaf_nodes if progress_data.get(node_id, False))
    return round((completed_leaf_nodes / total_leaf_nodes) * 100, 2)

def find_leaf_nodes(node: dict) -> list:
    """Find all leaf nodes (nodes with details but no children)"""
    leaf_nodes = []
    
    # Check if this is a leaf node (has details but no children)
    if node.get('details') and node.get('node_id') and (not node.get('children') or len(node.get('children', [])) == 0):
        leaf_nodes.append(node['node_id'])
    
    # Recursively check children
    if node.get('children'):
        for child in node['children']:
            leaf_nodes.extend(find_leaf_nodes(child))
    
    return leaf_nodes

def count_nodes(node: dict) -> int:
    """Count all nodes in the roadmap"""
    count = 1  # Count current node
    if 'children' in node and node['children']:
        for child in node['children']:
            count += count_nodes(child)
    return count

def generate_node_ids(roadmap_data: dict, parent_path: str = "") -> dict:
    """Generate unique IDs for all nodes in the roadmap"""
    if 'name' not in roadmap_data:
        return roadmap_data
    
    node_name = roadmap_data['name'].lower().replace(' ', '_')
    node_id = f"{parent_path}_{node_name}" if parent_path else node_name
    
    roadmap_data['node_id'] = node_id
    
    if 'children' in roadmap_data and roadmap_data['children']:
        for i, child in enumerate(roadmap_data['children']):
            roadmap_data['children'][i] = generate_node_ids(child, node_id)
    
    return roadmap_data