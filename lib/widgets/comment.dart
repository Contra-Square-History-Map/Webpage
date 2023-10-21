import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

final _linkRegex = RegExp(r'\(([^)]+)\)\[([^\]]+)\]');
List<InlineSpan> linkText(String text) {

  final bodyMatches = _linkRegex.allMatches(text);

  List<InlineSpan> textSpans = [];
  int previousEnd = 0;

  for (final match in bodyMatches) {
    final linkText = match.group(1);
    final linkUrl = match.group(2);

    if (match.start > previousEnd) {
      final nonLinkText = text.substring(previousEnd, match.start);
      textSpans.add(TextSpan(
        text: nonLinkText,
      ));
    }

    if (linkText != null && linkUrl != null) {
      textSpans.add(
        TextSpan(
          text: linkText,
          style: const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final destination = Uri.parse(linkUrl);
              launchUrl(destination);
            },
        ),
      );
    } else {
      textSpans.add(
        const TextSpan(
          text: "[INVALID LINK]",
        ),
      );
    }

    previousEnd = match.end;
  }

  if (previousEnd < text.length) {
    final remainingText = text.substring(previousEnd);
    textSpans.add(
      TextSpan(
        text: remainingText,
      ),
    );
  }

  return textSpans;
}

class Comment extends StatelessWidget {
  const Comment(
      {Key? key, required this.commentAuthor, required this.commentText})
      : super(key: key);

  final String commentAuthor;
  final String commentText;

  @override
  Widget build(BuildContext context) {

    final authorTextSpans = linkText(commentAuthor);
    final bodyTextSpans = linkText(commentText);

    return Align(
      alignment: Alignment.topLeft,
      child: RichText(
        softWrap: true,
        text: TextSpan(
          children: [
            TextSpan(
              children: authorTextSpans,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ":"),
            const TextSpan(text: "\n"),
            ...bodyTextSpans,
            const TextSpan(text: "\n"),
          ],
        ),
      ),
    );
  }
}
