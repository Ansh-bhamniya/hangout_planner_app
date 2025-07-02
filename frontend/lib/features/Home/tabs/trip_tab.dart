import 'package:flutter/material.dart';
import 'package:frontend_01/services/api_service.dart';

class TripTab extends StatefulWidget {
  final List<String> selectedIds;
  final String title;
  final String message;

  const TripTab({
    super.key,
    required this.selectedIds,
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
      await ApiService.sendTripRequest(
        selectedIds: widget.selectedIds,
        title: widget.title,
        message: widget.message,
      );
      setState(() => statusMessage = "✅ Trip created and sent to ${widget.selectedIds.length} users");

      // Optional: Navigate back after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => statusMessage = "❌ Error: $e");
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
            Text("📩 Message:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.message),
            const SizedBox(height: 20),
            Text("👥 Participants:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedIds.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text(widget.selectedIds[index]),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isSending) const Center(child: CircularProgressIndicator()),
            if (statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  statusMessage,
                  style: TextStyle(
                    color: statusMessage.contains("Error") ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
