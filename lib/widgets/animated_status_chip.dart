import 'package:flutter/material.dart';

class AnimatedStatusChip extends StatefulWidget {
  final String status;
  final VoidCallback? onTap;

  const AnimatedStatusChip({Key? key, required this.status, this.onTap})
    : super(key: key);

  @override
  State<AnimatedStatusChip> createState() => _AnimatedStatusChipState();
}

class _AnimatedStatusChipState extends State<AnimatedStatusChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'approved':
      case 'issued':
        return Colors.green;
      case 'rejected':
      case 'revoked':
        return Colors.red;
      case 'pending':
      case 'pending_review':
        return Colors.orange;
      case 'expired':
        return Colors.grey;
      case 'draft':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (widget.status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
      case 'pending_review':
        return 'Pending Review';
      case 'issued':
        return 'Issued';
      case 'revoked':
        return 'Revoked';
      case 'expired':
        return 'Expired';
      case 'draft':
        return 'Draft';
      default:
        return widget.status;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status.toLowerCase()) {
      case 'approved':
      case 'issued':
        return Icons.check_circle;
      case 'rejected':
      case 'revoked':
        return Icons.cancel;
      case 'pending':
      case 'pending_review':
        return Icons.schedule;
      case 'expired':
        return Icons.warning;
      case 'draft':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTap: () {
                if (widget.onTap != null) {
                  _animationController.reverse().then((_) {
                    widget.onTap!();
                    _animationController.forward();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(), color: color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
