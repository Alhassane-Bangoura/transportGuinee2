import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/assistant_message.dart';

class ChatBubble extends StatelessWidget {
  final AssistantMessage message;
  final VoidCallback? onPlayAudio;

  const ChatBubble({
    super.key,
    required this.message,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.senderType == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              ),
              boxShadow: isUser 
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
              border: isUser ? null : Border.all(color: AppColors.border),
            ),
            child: Text(
              message.content,
              style: GoogleFonts.plusJakartaSans(
                color: isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          if (!isUser && onPlayAudio != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: GestureDetector(
                onTap: onPlayAudio,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volume_up_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Écouter la réponse',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
