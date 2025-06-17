import 'package:flutter/material.dart';

class ApprovalCard extends StatelessWidget {
  final String filename;
  final String uploader;
  final String uploadDate;
  final VoidCallback? onApprove;
  final Function(String)? onRejectWithComment;

  const ApprovalCard({
    super.key,
    required this.filename,
    required this.uploader,
    required this.uploadDate,
    required this.onApprove,
    required this.onRejectWithComment,
  });

  void _showRejectDialog(BuildContext context) {
    if (onRejectWithComment == null) return;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject "$filename"'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRejectWithComment!(controller.text.trim());
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(filename),
        subtitle: Text(
          'Uploader: $uploader\nUploaded on: $uploadDate',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check),
              color: Colors.green,
              onPressed: onApprove,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.red,
              onPressed: () => _showRejectDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}



