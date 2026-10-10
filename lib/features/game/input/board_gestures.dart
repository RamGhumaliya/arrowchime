import 'dart:async';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Raw pointer handling for the board (`docs/03` §3), without the 300 ms tap
/// delay a double-tap recogniser would add:
///
/// * one finger, no drag → [onTap] on release (instant, so Flow feels tight);
/// * one finger held 250 ms → [onPeekStart] … [onPeekEnd];
/// * one finger dragging → [onPan]; two fingers → [onZoom] about their centre
///   plus [onPan] with the centre's movement; mouse wheel → [onZoom];
/// * two quick taps on empty felt → [onDoubleTapEmpty] (the second one only,
///   because [onTap] reports whether it hit an arrow).
class BoardGestures extends StatefulWidget {
  const new({
    required this.onTap,
    required this.onPan,
    required this.onZoom,
    required this.onPeekStart,
    required this.onPeekEnd,
    required this.onDoubleTapEmpty,
    required this.child,
    this.onTouchDown,
    this.onTouchUp,
    super.key,
  });

  /// Returns whether the tap hit an arrow.
  final bool Function(Offset position) onTap;
  final void Function(Offset delta) onPan;
  final void Function(Offset focal, double factor) onZoom;
  final void Function(Offset position) onPeekStart;
  final VoidCallback onPeekEnd;
  final void Function(Offset position) onDoubleTapEmpty;

  /// A single finger lands / lets go (press feedback on the arrow below).
  final void Function(Offset position)? onTouchDown;
  final VoidCallback? onTouchUp;
  final Widget child;

  @override
  State<BoardGestures> createState() => _BoardGesturesState();
}

class _BoardGesturesState extends State<BoardGestures> {
  final Map<int, Offset> _pointers = {};
  Offset? _downAt;
  bool _moved = false;
  bool _peeking = false;
  Timer? _holdTimer;
  double _lastSpread = 0;
  Offset _lastFocal = Offset.zero;
  Timer? _doubleTimer;
  Offset? _lastEmptyPos;

  @override
  void dispose() {
    _holdTimer?.cancel();
    _doubleTimer?.cancel();
    super.dispose();
  }

  void _down(PointerDownEvent e) {
    _pointers[e.pointer] = e.localPosition;
    if (_pointers.length == 1) {
      _downAt = e.localPosition;
      _moved = false;
      widget.onTouchDown?.call(e.localPosition);
      _holdTimer?.cancel();
      _holdTimer = Timer(TBGesture.peekHold, () {
        if (!_moved && _pointers.length == 1 && _downAt != null) {
          _peeking = true;
          widget.onPeekStart(_downAt!);
        }
      });
    } else {
      widget.onTouchUp?.call();
      _cancelHold();
      _moved = true;
      _lastSpread = _spread();
      _lastFocal = _focal();
    }
  }

  void _move(PointerMoveEvent e) {
    final previous = _pointers[e.pointer];
    if (previous == null) return;
    _pointers[e.pointer] = e.localPosition;
    if (_pointers.length >= 2) {
      final spread = _spread();
      final focal = _focal();
      if (_lastSpread > 0 && spread > 0) {
        widget.onZoom(focal, spread / _lastSpread);
      }
      widget.onPan(focal - _lastFocal);
      _lastSpread = spread;
      _lastFocal = focal;
      return;
    }
    final origin = _downAt;
    if (!_moved && origin != null) {
      if ((e.localPosition - origin).distance > TBGesture.slop) {
        _moved = true;
        _cancelHold();
        widget.onTouchUp?.call();
      }
    }
    if (_moved && !_peeking) widget.onPan(e.localPosition - previous);
  }

  void _up(PointerUpEvent e) {
    final wasSingle = _pointers.length == 1;
    _pointers.remove(e.pointer);
    final peeking = _peeking;
    _cancelHold();
    widget.onTouchUp?.call();
    if (peeking) {
      _peeking = false;
      widget.onPeekEnd();
      return;
    }
    if (wasSingle && !_moved) {
      final hit = widget.onTap(e.localPosition);
      final first = _lastEmptyPos;
      if (hit) {
        _clearDouble();
      } else if (first != null &&
          (e.localPosition - first).distance <= TBGesture.slop * 4) {
        _clearDouble();
        widget.onDoubleTapEmpty(e.localPosition);
      } else {
        _clearDouble();
        _lastEmptyPos = e.localPosition;
        _doubleTimer = Timer(TBGesture.doubleTap, _clearDouble);
      }
    }
    if (_pointers.length == 1) {
      // One finger of a pinch lifted: carry on as a pan without a jump.
      _downAt = _pointers.values.first;
      _lastFocal = _downAt!;
    }
  }

  void _cancel(PointerCancelEvent e) {
    _pointers.remove(e.pointer);
    _cancelHold();
    widget.onTouchUp?.call();
    if (_peeking) {
      _peeking = false;
      widget.onPeekEnd();
    }
  }

  void _signal(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      final factor = e.scrollDelta.dy < 0 ? 1.12 : 1 / 1.12;
      widget.onZoom(e.localPosition, factor);
    }
  }

  void _clearDouble() {
    _doubleTimer?.cancel();
    _doubleTimer = null;
    _lastEmptyPos = null;
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  double _spread() {
    final p = _pointers.values.toList();
    return p.length < 2 ? 0 : (p[0] - p[1]).distance;
  }

  Offset _focal() {
    final p = _pointers.values.toList();
    if (p.length < 2) return p.isEmpty ? Offset.zero : p.first;
    return (p[0] + p[1]) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: _up,
      onPointerCancel: _cancel,
      onPointerSignal: _signal,
      child: widget.child,
    );
  }
}
