import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:frontend_01/services/api_service.dart';
import 'trip_tab.dart';

class Nodes extends StatefulWidget {
  const Nodes({super.key});

  @override
  State<Nodes> createState() => _NodesState();
}

class _NodesState extends State<Nodes> {
  final Graph graph = Graph()..isTree = false;
  final Map<String, Node> userNodes = {};
  final Map<String, String> userNames = {}; // id -> name
  final Set<String> selectedNodes = {}; // stores selected node ids

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

      addNode(myId!, 'Me');
      selectedNodes.add(myId!); // default selected

      for (var fId in direct) {
        final friend = allUsers.firstWhere((u) => u['_id'] == fId, orElse: () => null);
        if (friend != null) {
          addNode(fId, friend['name'] ?? 'Friend');
          graph.addEdge(userNodes[myId!]!, userNodes[fId]!);
        }
      }

      for (var user in allUsers) {
        final uid = user['_id'] as String;
        final uname = user['name'] ?? 'User';

        if (uid == myId || userNodes.containsKey(uid)) continue;

        addNode(uid, uname);

      if (fof.contains(uid)) {
        // Connect FOF to any one friend (to avoid multiple lines)
        final friend = direct.firstWhere(
          (fId) => userNodes.containsKey(fId),
          orElse: () => '',
        );
        if (friend != null) {
          graph.addEdge(userNodes[friend]!, userNodes[uid]!);
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
      color = selectedNodes.contains(id) ? Colors.green[800]! : Colors.green;
    } else if (friendsOfFriends.contains(id)) {
      color = selectedNodes.contains(id) ? Colors.orange[800]! : Colors.orange;
    } else {
      color = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (id == myId) return;
        if (friendsOf.contains(id) || friendsOfFriends.contains(id)) {
          setState(() {
            if (selectedNodes.contains(id)) {
              selectedNodes.remove(id);
            } else {
              selectedNodes.add(id);
            }
          });
        }
      },
      child: Container(
        width: 70,
        height: 70,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            name.length > 8 ? name.substring(0, 8) : name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }

  void goToTripScreen() async {
    String title = '';
    String message = '';

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Create Trip"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (val) => title = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Message'),
                onChanged: (val) => message = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripTab(
                      selectedIds: selectedNodes.toList(),
                      // myId: myId!,
                      title: title,
                      message: message,
                    ),
                  ),
                );
              },
              child: const Text("Next"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Graph")),
      floatingActionButton: selectedNodes.length > 1
          ? FloatingActionButton.extended(
              onPressed: goToTripScreen,
              icon: const Icon(Icons.send),
              label: const Text("Create Trip"),
            )
          : null,
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
