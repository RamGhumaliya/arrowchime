import 'package:flutter/painting.dart';

/// Pure zoom / pan maths for the board camera (`docs/05` §4.3, `docs/03` §3).
///
/// * `1×` is "fit": the whole board inside the viewport minus [fitMargin];
///   zoom runs 1× – 4× ([maxMultiplier]).
/// * The view centre is clamped so the viewport never leaves the board plus a
///   20% margin ([panMargin]); when the whole region fits, it stays centred.
class ViewTransform {
  new({required this.worldSize, required this._viewport, this.fitMargin = 16}) {
    fit();
  }

  /// Size of the board (tray included) in world units.
  final Size worldSize;

  /// Screen margin kept around the board at fit, in dp.
  final double fitMargin;

  static const double maxMultiplier = 4;
  static const double panMargin = 0.2;

  Size _viewport;

  /// Zoom multiplier relative to fit, 1–4.
  double multiplier = 1;

  /// World point at the centre of the viewport.
  Offset center = Offset.zero;

  Size get viewport => _viewport;

  /// Pixels per world unit at 1×.
  double get fitZoom {
    final w = (_viewport.width - 2 * fitMargin) / worldSize.width;
    final h = (_viewport.height - 2 * fitMargin) / worldSize.height;
    final z = w < h ? w : h;
    return z > 0 ? z : 0.01;
  }

  /// Pixels per world unit now.
  double get zoom => fitZoom * multiplier;

  Offset get boardCenter => worldSize.center(Offset.zero);

  bool get isFit => multiplier == 1 && (center - boardCenter).distance < 0.01;

  Offset get _viewportCenter => _viewport.center(Offset.zero);

  /// Screen position -> world position.
  Offset toWorld(Offset screen) => center + (screen - _viewportCenter) / zoom;

  /// World position -> screen position.
  Offset toScreen(Offset world) => (world - center) * zoom + _viewportCenter;

  /// The viewport changed (rotation, resize): keep the multiplier and re-clamp.
  void resize(Size viewport) {
    _viewport = viewport;
    clamp();
  }

  /// Back to 1× with the board centred.
  void fit() {
    multiplier = 1;
    center = boardCenter;
  }

  /// Zooms to [newMultiplier] (clamped to 1–4) keeping the world point under
  /// [focalScreen] where it is.
  void zoomAbout(Offset focalScreen, double newMultiplier) {
    final anchor = toWorld(focalScreen);
    multiplier = newMultiplier.clamp(1.0, maxMultiplier);
    center = anchor - (focalScreen - _viewportCenter) / zoom;
    clamp();
  }

  /// Drags the view by a screen-space [delta] (the content follows the finger).
  void panByScreen(Offset delta) {
    center -= delta / zoom;
    clamp();
  }

  /// Keeps the viewport inside the board plus 20%.
  void clamp() {
    final margin =
        (worldSize.width > worldSize.height
            ? worldSize.width
            : worldSize.height) *
        panMargin;
    final region = (Offset.zero & worldSize).inflate(margin);
    final half = Offset(
      _viewport.width / (2 * zoom),
      _viewport.height / (2 * zoom),
    );
    double axis(double c, double lo, double hi, double mid) {
      if (lo > hi) return mid;
      return c.clamp(lo, hi);
    }

    center = Offset(
      axis(
        center.dx,
        region.left + half.dx,
        region.right - half.dx,
        region.center.dx,
      ),
      axis(
        center.dy,
        region.top + half.dy,
        region.bottom - half.dy,
        region.center.dy,
      ),
    );
  }
}
