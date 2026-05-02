import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../assistant/models/assistant_message.dart';
import '../../assistant/services/assistant_service.dart';
import '../../assistant/widgets/chat_bubble.dart';

class DriverAIAssistant extends StatefulWidget {
  const DriverAIAssistant({super.key});

  @override
  State<DriverAIAssistant> createState() => _DriverAIAssistantState();
}

class _DriverAIAssistantState extends State<DriverAIAssistant> {
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
      final convs = await _assistantService.getConversations();
      _conversations = convs;
      
      if (_conversations.isNotEmpty) {
        _currentConversationId = _conversations.first['id'];
        final history = await _assistantService.getHistory(conversationId: _currentConversationId);
        setState(() {
          _messages = history;
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
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

  Future<void> _createNewChat() async {
    setState(() {
      _currentConversationId = null;
      _messages = [];
      _messageController.clear();
      _isTyping = false;
    });
    if (mounted && Navigator.canPop(context)) {
      try { Scaffold.of(context).closeEndDrawer(); } catch (e) {}
    }
  }

  Future<void> _switchToConversation(String id) async {
    setState(() {
      _isLoading = true;
      _currentConversationId = id;
    });
    try {
      final history = await _assistantService.getHistory(conversationId: id);
      setState(() {
        _messages = history;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteConversation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: const Text('Voulez-vous supprimer cette conversation ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await _assistantService.deleteConversation(id);
      setState(() {
        _conversations.removeWhere((c) => c['id'] == id);
        if (_currentConversationId == id) {
          _currentConversationId = null;
          _messages = [];
        }
      });
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() {
      _messages.add(AssistantMessage(
        id: DateTime.now().toString(),
        userId: user.id,
        role: 'DRIVER',
        content: text,
        senderType: 'user',
        createdAt: DateTime.now(),
      ));
      _isTyping = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      if (_currentConversationId == null) {
        _currentConversationId = await _assistantService.createConversation(
          text.length > 20 ? '${text.substring(0, 20)}...' : text
        );
        final newConvs = await _assistantService.getConversations();
        setState(() => _conversations = newConvs);
      }

      final response = await _assistantService.sendMessage(
        text, 
        _messages.sublist(0, _messages.length - 1),
        conversationId: _currentConversationId
      );

      setState(() {
        _messages.add(response);
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      endDrawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Assistant Pro',
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(onPressed: _createNewChat, icon: const Icon(Icons.add_comment_outlined, color: AppColors.primary)),
          Builder(builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
          )),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _messages.isEmpty ? _buildEmptyState() : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) return _buildTypingIndicator();
                    return ChatBubble(message: _messages[index]);
                  },
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.local_shipping_outlined, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Assistant Chauffeur', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Posez-moi des questions sur vos trajets\nou vos revenus en Guinée.', 
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Réflexion en cours...', style: GoogleFonts.plusJakartaSans(fontStyle: FontStyle.italic, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Votre question...'),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(onPressed: _handleSend, icon: const Icon(Icons.send, color: Colors.white, size: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E293B)),
            child: Center(child: Icon(Icons.history, color: Colors.white, size: 50)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final c = _conversations[index];
                return ListTile(
                  leading: const Icon(Icons.chat_bubble_outline, size: 20),
                  title: Text(c['title'] ?? 'Sans titre'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _deleteConversation(c['id']),
                  ),
                  onTap: () {
                    _switchToConversation(c['id']);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
