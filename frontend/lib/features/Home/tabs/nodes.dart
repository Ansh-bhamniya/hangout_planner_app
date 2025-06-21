import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:frontend_01/services/api_service.dart';

class Nodes extends StatefulWidget {
  const Nodes({super.key});

  @override
  State<Nodes> createState() => _NodesState();
}

class _NodesState extends State<Nodes> {
  final Graph graph = Graph()..isTree = false;
  final Map<String, Node> userNodes = {};
  final Map<String, String> userNames = {}; // 

  String? myId;
  Set<String> friendsOf = {};
  Set<String> friendsOfFriends = {};

  @override
  void initState() {
    super.initState();
    fetchGraphData();
  }

  Future<void> fetchGraphData() async {
    try {
      final data = await ApiService.fetchNetwork();
      myId = data['currentUserId'];
      final List<String> direct = List<String>.from(data['directFriends']);
      final List<String> fof = List<String>.from(data['friendsOfFriends']);
      final List allUsers = data['allUsers'];

      friendsOf = direct.toSet();
      friendsOfFriends = fof.toSet();

      void addNode(String id, String name) {
        if (!userNodes.containsKey(id)) {
          final node = Node.Id(id);
          userNodes[id] = node;
          userNames[id] = name;
          graph.addNode(node);
        }
      }

      // Add self node
      addNode(myId!, 'Me');

      // Connect direct friends
      for (var fId in direct) {
        final friend = allUsers.firstWhere((u) => u['_id'] == fId, orElse: () => null);
        if (friend != null) {
          addNode(fId, friend['name'] ?? 'Friend');
          graph.addEdge(userNodes[myId!]!, userNodes[fId]!);
        }
      }

      // Add and connect FOF and strangers
      for (var user in allUsers) {
        final uid = user['_id'] as String;
        final uname = user['name'] ?? 'User';

        if (uid == myId || userNodes.containsKey(uid)) continue;

        addNode(uid, uname);

        // Connect FOFs to their friend
        if (fof.contains(uid)) {
          for (String fId in direct) {
            graph.addEdge(userNodes[fId]!, userNodes[uid]!);
          }
        }
      }

      setState(() {});
    } catch (e) {
      print("❌ Error loading network: $e");
    }
  }

  Widget nodeBuilder(Node node) {
    final id = node.key!.value as String;
    final name = userNames[id] ?? 'User';

    Color color;
    if (id == myId) {
      color = Colors.blue;
    } else if (friendsOf.contains(id)) {
      color = Colors.green;
    } else if (friendsOfFriends.contains(id)) {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }

    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        name.length > 8 ? name.substring(0, 8) : name,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userNodes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.01,
              maxScale: 5.6,
              child: GraphView(
                graph: graph,
                algorithm: FruchtermanReingoldAlgorithm(),
                builder: nodeBuilder,
              ),
            ),
    );
  }
}
