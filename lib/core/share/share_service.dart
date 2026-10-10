import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'share_service.g.dart';

/// Sharing a result (`docs/03` §7 Daily Knot card), behind an interface so
/// tests can record what would be shared.
abstract interface class ShareService {
  /// Opens the system share sheet with [text] and, if given, a PNG [image].
  Future<void> share({required String text, Uint8List? image});
}

/// [ShareService] on `share_plus`.
class SharePlusService implements ShareService {
  const new();

  @override
  Future<void> share({required String text, Uint8List? image}) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: [
          if (image != null)
            XFile.fromData(
              image,
              mimeType: 'image/png',
              name: 'arrowchime_daily.png',
            ),
        ],
      ),
    );
  }
}

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) => const SharePlusService();
