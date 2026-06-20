import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> sharePost({required String authorName, required String content, String? imageUrl}) async {
    final text = 'Post by $authorName:\n\n"$content"${imageUrl != null ? "\n\nAttached Image: $imageUrl" : ""}\n\nShared via SocialSpace';
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: '$authorName\'s post',
      ),
    );
  }
}
