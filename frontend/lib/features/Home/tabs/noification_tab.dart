import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  List<dynamic> pendingRequests = [];
  List<dynamic> tripRequests = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    initializeUserData();
    fetchPendingRequests();
    fetchTripRequests();
  }

  // void getUserId() async {
  //   currentUserId = await ApiService.getUserId();
  // }
  Future<void> initializeUserData() async {
  currentUserId = await ApiService.getUserId();
  await fetchPendingRequests();
  await fetchTripRequests();
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

  Future<void> fetchTripRequests() async {
    try {
      final trips = await ApiService.fetchIncomingTrips();

      setState(() {
        tripRequests = trips;
      });
      
      print("✅ Fetched ${trips.length} trip requests");
    } catch (e) {
      print("❌ Failed to fetch trip notifications: $e");
    }
  }

  Future<void> acceptRequest(String requesterId) async {
    try {
      await ApiService.acceptFollowRequest(requesterId);
      setState(() {
        final index = pendingRequests.indexWhere((u) => u['_id'] == requesterId);
        if (index != -1) {
          pendingRequests[index]['isAccepted'] = true;
        }
      });
    } catch (e) {
      print("❌ Failed to accept request: $e");
    }
  }

  Future<void> approveTrip(String tripId) async {
    try {
      await ApiService.approveTripRequest(tripId);
      await fetchTripRequests();
    } catch (e) {
      print("❌ Failed to approve trip: $e");
    }
  }

  Future<void> inviteUser(String tripId, String userId) async {
    try {
      await ApiService.sendTripInvite(tripId, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invite sent")),
      );
      await fetchTripRequests();
      print('button_hai :${tripId}, ${userId}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    }
  }

  // Simplified - now the backend handles the invite logic
  bool canInviteParticipant(Map<String, dynamic> participant) {
    // The backend now provides this information directly
    return participant['visible'] == false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("Follow Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...pendingRequests.map((user) {
                  final isAccepted = user['isAccepted'] == true;
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 28, color: Colors.white),
                    ),
                    title: Text(
                      user['name'] ?? 'Unnamed User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Wants to follow you'),
                    trailing: ElevatedButton(
                      onPressed: isAccepted ? null : () => acceptRequest(user['_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAccepted ? Colors.grey : Colors.green,
                      ),
                      child: Text(
                        isAccepted ? "Accepted" : "Accept",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("Trip Invitations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...tripRequests.map((trip) {
                  final status = trip['status'] ?? 'pending';
                  final List<dynamic> participants = trip['participants'] ?? [];
                  final bool approvedByMe = trip['approvedByMe'] == true;
                  final String creatorId = trip['creator']['_id'];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ExpansionTile(
                      title: Text(trip['title'] ?? 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Trip created by: ${trip['creator']['name']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
                          Text(trip['message'] ?? ''),
                          Text(
                            "Status: ${status.toUpperCase()}",
                            style: TextStyle(
                              fontSize: 12,
                              color: status == 'approved' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            approvedByMe ? "You have approved" : "Awaiting your approval",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Trip Participants", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...participants.where((p) {
  final user = p['user'];
  final String userId = user['_id'];
  return userId != creatorId; // ✅ This hides the creator from the participant list
}).map((participant) {
                          final user = participant['user'];
                          final String userId = user['_id'];
                          final bool isCreator = userId == creatorId;
                          final bool isCurrentUser = userId == currentUserId;
                          final String displayName = isCreator ? "${user['name']} (Creator)" : user['name'];
                          final String participantStatus = participant['status'] ?? 'pending';
                          final bool participantVisible = participant['visible'] ?? false;

                          // Determine if invite button should be shown
                          final bool showInviteButton = canInviteParticipant(participant);

                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(displayName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Status: $participantStatus"),
                                if (participantVisible && participantStatus == 'pending')
                                  const Text("Invited", style: TextStyle(color: Colors.blue, fontSize: 12)),
                              ],
                            ),
                            trailing: showInviteButton
                                ? ElevatedButton(
                                    onPressed: () => inviteUser(trip['_id'], userId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: const Text("Invite", style: TextStyle(color: Colors.white)),
                                  )
                                : null,
                          );
                        }).toList(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: approvedByMe ? null : () => approveTrip(trip['_id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: approvedByMe ? Colors.grey : Colors.green,
                            ),
                            child: Text(
                              approvedByMe ? "Already Approved" : "Approve Trip",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}