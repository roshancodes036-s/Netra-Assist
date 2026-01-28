import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

// 1. ProCard
class ProCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  const ProCard({super.key, required this.child, this.padding, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle)),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                  padding: padding ?? const EdgeInsets.all(16), child: child))),
    );
  }
}

// 2. ProPageLayout
class ProPageLayout extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const ProPageLayout(
      {super.key,
      required this.title,
      required this.icon,
      required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
        child: Column(children: [
          Row(children: [
            Icon(icon, color: AppColors.primaryAccent, size: 28),
            const SizedBox(width: 12),
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 28, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 24),
          Expanded(child: child)
        ]));
  }
}

// 3. Neon Input Wrapper
class NeonInputWrapper extends StatelessWidget {
  final Widget child;
  const NeonInputWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
              colors: [AppColors.primaryAccent, Colors.blue])),
      child: Container(
          decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(29)),
          child: child),
    );
  }
}

// 4. Modern Chat Bubble
class ModernChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final bool isAnimated;
  final VoidCallback? onAnimationEnd;
  const ModernChatBubble(
      {super.key,
      required this.isUser,
      required this.text,
      this.isAnimated = false,
      this.onAnimationEnd});

  @override
  Widget build(BuildContext context) {
    List<String> parts = text.split('```');
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        decoration: BoxDecoration(
            color: isUser ? AppColors.primaryAccent : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (isUser)
            Text(text,
                style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))
          else
            ...parts.map((part) {
              if (parts.indexOf(part) % 2 == 0) {
                return Text(part,
                    style:
                        GoogleFonts.outfit(color: Colors.white, fontSize: 16));
              } else {
                return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.vsBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade800)),
                    child: SelectableText.rich(
                        CodeHighlighter.highlight(part.trim()),
                        style: GoogleFonts.firaCode(fontSize: 14)));
              }
            })
        ]),
      ),
    );
  }
}

// 5. Code Highlighter Logic
class CodeHighlighter {
  static TextSpan highlight(String code) {
    List<TextSpan> spans = [];
    RegExp tokenRegex = RegExp(
        r'(//.*)|(".*?")|(\b(import|class|void|var|final|const|return|if|else|extends|with|implements|new|this|super|true|false)\b)|(\b[A-Z][a-zA-Z0-9]*\b)',
        multiLine: true);
    int lastMatchEnd = 0;
    for (var match in tokenRegex.allMatches(code)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: code.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: AppColors.vsNormal)));
      }
      String token = match.group(0)!;
      Color color = AppColors.vsNormal;
      if (match.group(1) != null) {
        color = AppColors.vsComment;
      } else if (match.group(2) != null)
        color = AppColors.vsString;
      else if (match.group(3) != null)
        color = AppColors.vsKeyword;
      else if (match.group(5) != null) color = AppColors.vsType;
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < code.length) {
      spans.add(TextSpan(
          text: code.substring(lastMatchEnd),
          style: const TextStyle(color: AppColors.vsNormal)));
    }
    return TextSpan(children: spans);
  }
}

// 6. Status Badge
class StatusBadge extends StatefulWidget {
  final bool isDevMode;
  const StatusBadge({super.key, required this.isDevMode});
  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.primaryAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FadeTransition(
            opacity: _opacity,
            child: const Icon(Icons.circle,
                size: 10, color: AppColors.primaryAccent)),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
              widget.isDevMode
                  ? "Ready to Build & Debug 🛠️"
                  : "Vision Intelligence Active 👁️",
              key: ValueKey<bool>(widget.isDevMode),
              style: GoogleFonts.firaCode(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5)),
        ),
      ]),
    );
  }
}
