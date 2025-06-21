import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  List<dynamic> pendingRequests = [];
  bool isLoading = true;
  Set<String> acceptedUserIds = {}; // Track accepted requesters
  Map<String, bool> acceptedRequests = {};

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    try {
      final data = await ApiService.fetchPendingFollowRequests();
      setState(() {
        pendingRequests = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Failed to load follow requests: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> acceptRequest(String requesterId) async {
    try {
      await ApiService.acceptFollowRequest(requesterId);
      setState(() {
      // ✅ Update the list directly by marking the request as accepted
      final index = pendingRequests.indexWhere((u) => u['_id'] == requesterId);
      if (index != -1) {
        pendingRequests[index]['isAccepted'] = true;
      }
      });
    } catch (e) {
      print("❌ Failed to accept request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingRequests.isEmpty
              ? const Center(child: Text('No new follow requests.'))
              : ListView.builder(
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    final user = pendingRequests[index];
                    final isAccepted = user['isAccepted'] == true;

                    return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 28,
                      color: Colors.grey,
                    ),
                  ),
                      title: Text(
                        user['name'] ?? 'Unnamed User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Wants to follow you'),
                      trailing: ElevatedButton(
                        onPressed:
                            isAccepted ? null : () => acceptRequest(user['_id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isAccepted ? Colors.grey : Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isAccepted ? "Accepted" : "Accept",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
