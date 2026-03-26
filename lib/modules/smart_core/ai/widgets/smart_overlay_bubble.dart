import 'package:flutter/material.dart';
import '../ai_assistant_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SmartOverlayBubble extends StatefulWidget {
  final String userRole;
  
  const SmartOverlayBubble({super.key, required this.userRole});

  @override
  State<SmartOverlayBubble> createState() => _SmartOverlayBubbleState();
}

class _SmartOverlayBubbleState extends State<SmartOverlayBubble> {
  late final AiAssistantService _aiService;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isExpanded = false;
  bool _isSpeaking = false;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _aiService = AiAssistantService(role: widget.userRole);
    _initTts();
  }

  void _initTts() {
    _flutterTts.setLanguage("fr-FR");
    _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }

  void _handleSend() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
      _controller.clear();
      _isTyping = true;
    });

    try {
      await _stopSpeaking();
      final response = await _aiService.sendMessage(userMessage);
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': response});
          _isTyping = false;
        });
        _speak(response);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': "Erreur: Impossible de contacter l'assistant."});
          _isTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isExpanded) _buildChatWindow(),
            const SizedBox(height: 10),
            _buildFloatingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Icon(
          _isExpanded ? Icons.close : Icons.auto_awesome,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildChatWindow() {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Assistant ${widget.userRole}',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildLoadingBubble();
        }
        final msg = _messages[index];
        final isUser = msg['sender'] == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              msg['text']!,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        child: const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                fillColor: Colors.grey[200],
                filled: true,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _handleSend,
            icon: const Icon(Icons.send, color: AppColors.primary),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
