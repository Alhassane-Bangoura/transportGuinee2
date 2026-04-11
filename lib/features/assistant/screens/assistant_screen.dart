import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/assistant_message.dart';
import '../services/assistant_service.dart';
import '../widgets/chat_bubble.dart';

class AssistantScreen extends StatefulWidget {
  final String userRole;
  const AssistantScreen({super.key, required this.userRole});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _assistantService = AssistantService(fallbackRole: 'DRIVER');
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<AssistantMessage> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  String? _currentConversationId;
  bool _isLoading = true;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);
      await _loadConversations();
      if (_conversations.isNotEmpty) {
        _currentConversationId = _conversations.first['id'];
        await _loadHistory(_currentConversationId);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error in loadInitialData: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadConversations() async {
    try {
      final convs = await _assistantService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = convs;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  Future<void> _loadHistory(String? conversationId) async {
    try {
      final history = await _assistantService.getHistory(conversationId: conversationId);
      if (mounted) {
        setState(() {
          _messages = history;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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

  Future<void> _startNewConversation() async {
    try {
      setState(() => _isLoading = true);
      final id = await _assistantService.createConversation('Discussion ${DateTime.now().day}/${DateTime.now().month}');
      await _loadConversations();
      if (mounted) {
        setState(() {
          _currentConversationId = id;
          _messages = [];
          _isLoading = false;
        });
        Navigator.pop(context); // Fermer le drawer
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur création discussion : $e')));
      }
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez vous reconnecter.')));
      return;
    }

    // Capture de l'ID actuel pour éviter les désynchronisations
    String? targetConvId = _currentConversationId;

    try {
      // 1. Créer la conversation si première fois
      if (targetConvId == null) {
        setState(() => _isTyping = true); // Indicateur préventif
        targetConvId = await _assistantService.createConversation(
          text.length > 25 ? '${text.substring(0, 25)}...' : text
        );
        _currentConversationId = targetConvId;
        await _loadConversations();
      }

      final userMessage = AssistantMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        role: widget.userRole,
        content: text,
        senderType: 'user',
        createdAt: DateTime.now(),
      );

      _messageController.clear();
      setState(() {
        _messages.add(userMessage);
        _isTyping = true;
      });
      _scrollToBottom();

      // 2. Envoyer à l'IA avec timeout géré dans le service
      final aiResponse = await _assistantService.sendMessage(
        text, 
        _messages.sublist(0, _messages.length - 1),
        conversationId: targetConvId,
      );
      
      if (mounted && _currentConversationId == targetConvId) {
        setState(() {
          _messages.add(aiResponse);
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error in _handleSend: $e');
      if (mounted) {
        setState(() => _isTyping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(label: 'Réessayer', onPressed: _handleSend, textColor: Colors.white),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          'Assistant IA',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : Stack(
                    children: [
                      if (_messages.isEmpty) _buildEmptyState(),
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) return _buildTypingIndicator();
                          return ChatBubble(message: _messages[index]);
                        },
                      ),
                    ],
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 64, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Bonjour ! Comment puis-je vous aider ?',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Posez une question sur vos trajets ou gares.',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.forum_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Mes Discussions',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _startNewConversation,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Nouvelle discussion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _conversations.isEmpty
                ? Center(
                    child: Text(
                      'Aucun historique',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textHint),
                    ),
                  )
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      final isSelected = conv['id'] == _currentConversationId;
                      return ListTile(
                        leading: Icon(
                          Icons.chat_bubble_outline_rounded, 
                          size: 20,
                          color: isSelected ? AppColors.primary : AppColors.textHint
                        ),
                        title: Text(
                          conv['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM à HH:mm').format(DateTime.parse(conv['created_at'])),
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textHint),
                        ),
                        onTap: () {
                          setState(() {
                            _currentConversationId = conv['id'];
                            _isLoading = true;
                          });
                          _loadHistory(conv['id']);
                          Navigator.pop(context);
                        },
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withOpacity(0.05),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "L'IA analyse votre demande...",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !_isLoading && !_isTyping,
                  decoration: InputDecoration(
                    hintText: 'Écrivez votre message...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: (_isLoading || _isTyping) ? null : _handleSend,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isLoading || _isTyping) ? AppColors.textHint : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!(_isLoading || _isTyping))
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
