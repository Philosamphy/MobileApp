import 'package:flutter/material.dart';

/// 简单的文本显示组件
class SimpleTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const SimpleTextWidget({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? Theme.of(context).textTheme.bodyMedium);
  }
}

/// 简单的按钮组件
class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SimpleButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}

/// 简单的卡片组件
class SimpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SimpleCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
