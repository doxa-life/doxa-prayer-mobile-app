import 'package:flutter/material.dart';

/// Shows or hides [child] by smoothly growing/shrinking its height while
/// fading it, anchored to the top so content below slides along with it.
///
/// While fully collapsed the child isn't built at all, so a closed section
/// costs nothing and its fields stay out of the focus and semantics trees.
/// With the system's reduce-motion setting on, it snaps open and shut.
class Collapsible extends StatefulWidget {
  const Collapsible({super.key, required this.expanded, required this.child});

  final bool expanded;
  final Widget child;

  static const Duration duration = Duration(milliseconds: 260);

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Collapsible.duration,
    value: widget.expanded ? 1 : 0,
  );
  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void initState() {
    super.initState();
    // Rebuild at the ends of the animation, when the child is added or
    // dropped (see build).
    _controller.addStatusListener((_) => setState(() {}));
  }

  @override
  void didUpdateWidget(Collapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded == oldWidget.expanded) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.expanded ? 1 : 0;
    } else if (widget.expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isDismissed) return const SizedBox.shrink();
    return SizeTransition(
      sizeFactor: _size,
      alignment: AlignmentDirectional.topStart,
      child: FadeTransition(opacity: _size, child: widget.child),
    );
  }
}
