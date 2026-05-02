import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../modules/smart_core/ai/ai_assistant_service.dart';
import 'package:intl/intl.dart';

class StationAdminAIAssistant extends StatefulWidget {
  const StationAdminAIAssistant({super.key});

  @override
  State<StationAdminAIAssistant> createState() => _StationAdminAIAssistantState();
}

class _StationAdminAIAssistantState extends State<StationAdminAIAssistant> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late final AiAssistantService _aiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _aiService = AiAssistantService(role: 'STATION_ADMIN');
    _addAssistantMessage("Bonjour Admin. Je suis prêt à vous aider dans la gestion de votre gare. Que souhaitez-vous analyser aujourd'hui ?");
  }

  void _addAssistantMessage(String text) {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'text': text,
        'time': DateFormat('HH:mm').format(DateTime.now()),
      });
    });
  }

  Future<void> _handleSend() async {
    final query = _messageController.text.trim();
    if (query.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': query,
        'time': DateFormat('HH:mm').format(DateTime.now()),
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Préparation de l'historique pour l'IA
    final history = _messages.reversed
        .take(5)
        .where((m) => m['text'] != null)
        .map((m) => {
              'role': m['role'] as String,
              'content': m['text'] as String,
            })
        .toList();

    final response = await _aiService.sendMessage(query, history: history.cast<Map<String, String>>());

    setState(() {
      _isLoading = false;
      _addAssistantMessage(response);
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  if (msg['role'] == 'assistant') {
                    return _buildAIMessage(msg['text'], msg['time']);
                  } else {
                    return _buildUserMessage(msg['text'], msg['time']);
                  }
                },
              ),
            ),
            if (_isLoading)
               Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "L'assistant analyse les données...",
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            _buildSuggestionChips(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                'GUINEE TRANSPORT',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Assistant de Gare Intelligent',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  textStyle: const TextStyle(letterSpacing: 2),
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.account_circle, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20), topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(color: AppColors.primary.withOpacity(0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Text(text, style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14, height: 1.5)),
                ),
                const SizedBox(height: 6),
                Text('Assistant • $time', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20), topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20), bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(text, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, height: 1.5)),
                ),
                const SizedBox(height: 6),
                Text('Moi • $time', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = ['Rapport du jour', 'Statut des véhicules', 'Recettes gare'];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            _messageController.text = suggestions[i];
            _handleSend();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Center(
              child: Text(
                suggestions[i],
                style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14),
                onSubmitted: (_) => _handleSend(),
                decoration: const InputDecoration(
                  hintText: 'Posez une question...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
