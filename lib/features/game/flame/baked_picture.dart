import 'dart:math' as math;
import 'dart:ui';

/// Per-frame facts the board components share (set by `ArrowGame`).
class BoardRenderContext {
  /// The part of the board currently on screen, in world units. Components
  /// outside it skip drawing.
  Rect visible = Rect.largest;

  /// Device pixels per world unit at the current zoom.
  double pxPerUnit = 1;

  /// A pinch, drag or zoom animation is running: re-baking waits until it
  /// ends, unless an image is badly blurry.
  bool interacting = false;

  /// How many images may still be baked this frame (a pinch across a zoom
  /// bucket would otherwise bake every arrow in one frame).
  int bakesLeft = 0;
}

/// A drawing that is painted into an [Image] once per zoom bucket and then
/// blitted, instead of replaying its blurred shadows and gradients every frame.
///
/// While no image fits (first frames, a zoom bucket just changed, bake budget
/// used up) it falls back to a vector [Picture], so nothing ever pops out.
class BakedPicture {
  new({
    required this.bounds,
    required this.paintInto,
    this.maxDimension = 1024,
  });

  /// World rectangle the drawing covers (shadow and rim included).
  final Rect bounds;

  /// Paints the drawing in world coordinates.
  final void Function(Canvas canvas) paintInto;

  /// Longest side of the baked image, in pixels.
  final int maxDimension;

  static final Paint _blit = Paint()..filterQuality = FilterQuality.low;

  Picture? _vector;
  Image? _image;
  double _scale = 0;

  /// Forget what was drawn (the look changed); it is re-baked on demand.
  void invalidate() {
    _vector?.dispose();
    _vector = null;
    _image?.dispose();
    _image = null;
    _scale = 0;
  }

  /// Releases the GPU memory.
  void dispose() => invalidate();

  /// Whether a baked image is currently held (tests).
  bool get isBaked => _image != null;

  /// Pixels per world unit of the bucket for [pxPerUnit]: a power of two,
  /// never so large that the image would exceed [maxDimension].
  double bucketFor(double pxPerUnit) {
    final limit = maxDimension / math.max(bounds.width, bounds.height);
    final wanted = math.max(pxPerUnit, 0.25);
    final bucket = math.pow(2, (math.log(wanted) / math.ln2).ceil());
    return math.min(bucket.toDouble(), limit);
  }

  /// Draws into [canvas]; [context] decides the zoom bucket and the budget.
  void paint(Canvas canvas, BoardRenderContext context) {
    final want = bucketFor(context.pxPerUnit);
    // Too blurry now, or sharper than needed once the gesture is over.
    final urgent = _image == null || _scale < want / 2;
    final refine =
        !context.interacting && (_scale < want - 1e-9 || _scale > want * 2);
    if ((urgent || refine) && context.bakesLeft > 0) {
      context.bakesLeft--;
      _bake(want);
    }
    final image = _image;
    if (image == null) {
      canvas.drawPicture(_vector ??= _record());
      return;
    }
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      bounds,
      _blit,
    );
  }

  Picture _record() {
    final recorder = PictureRecorder();
    paintInto(Canvas(recorder));
    return recorder.endRecording();
  }

  void _bake(double scale) {
    final width = math.max(1, (bounds.width * scale).ceil());
    final height = math.max(1, (bounds.height * scale).ceil());
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(width / bounds.width, height / bounds.height)
      ..translate(-bounds.left, -bounds.top);
    paintInto(canvas);
    final picture = recorder.endRecording();
    final old = _image;
    _image = picture.toImageSync(width, height);
    _scale = scale;
    picture.dispose();
    old?.dispose();
  }
}
