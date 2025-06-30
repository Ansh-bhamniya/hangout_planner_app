import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class TripTab extends StatefulWidget {
  final List<String> selectedIds;
  final String myId;
  final String title;
  final String message;

  const TripTab({
    super.key,
    required this.selectedIds,
    required this.myId,
    required this.title,
    required this.message,
  });

  @override
  State<TripTab> createState() => _TripTabState();
}

class _TripTabState extends State<TripTab> {
  bool isSending = false;
  String statusMessage = "";

  Future<void> sendTripRequest() async {
    setState(() => isSending = true);
    try {
      final response = await ApiService.sendTripRequest(
        creatorId: widget.myId,
        selectedIds: widget.selectedIds,
        title: widget.title,
        message: widget.message,
      );
      setState(() => statusMessage = "Trip created and sent to ${widget.selectedIds.length} users");
    } catch (e) {
      setState(() => statusMessage = "Error sending trip request: $e");
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  void initState() {
    super.initState();
    sendTripRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Message:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.message),
            const SizedBox(height: 20),
            Text("Participants:", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedIds.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text(widget.selectedIds[index]),
                ),
              ),
            ),
            if (isSending) const CircularProgressIndicator(),
            if (statusMessage.isNotEmpty) Text(statusMessage),
          ],
        ),
      ),
    );
  }
}
