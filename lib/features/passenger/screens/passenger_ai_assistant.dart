import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/trip.dart';
import '../../../core/services/trip_service.dart';
import '../../assistant/services/assistant_service.dart';
import '../../assistant/models/assistant_message.dart';

enum ChatMessageType { user, assistant, travelCard }

class ChatMessageUI {
  final String text;
  final ChatMessageType type;
  final Trip? tripData;
  final DateTime timestamp;

  ChatMessageUI({required this.text, required this.type, required this.timestamp, this.tripData});
}

class PassengerAIAssistant extends StatefulWidget {
  const PassengerAIAssistant({super.key});

  @override
  State<PassengerAIAssistant> createState() => _PassengerAIAssistantState();
}

class _PassengerAIAssistantState extends State<PassengerAIAssistant> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _assistantService = AssistantService(fallbackRole: 'PASSAGER');
  
  List<Map<String, dynamic>> _conversations = [];
  List<ChatMessageUI> _messages = [];
  bool _isLoading = true;
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final conversations = await _assistantService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          if (conversations.isNotEmpty) {
            _switchToConversation(conversations.first['id']);
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _switchToConversation(String? id) async {
    if (id == null) {
      setState(() {
        _currentConversationId = null;
        _messages = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final history = await _assistantService.getHistory(conversationId: id);
      if (mounted) {
        setState(() {
          _currentConversationId = id;
          _messages = history.map((m) => ChatMessageUI(
            text: m.content,
            type: m.senderType == 'user' ? ChatMessageType.user : ChatMessageType.assistant,
            timestamp: m.createdAt,
          )).toList();
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewChat() async {
    setState(() {
      _currentConversationId = null;
      _messages = [];
      _messageController.clear();
      _isLoading = false;
    });
    // Fermer le drawer seulement s'il est ouvert
    if (mounted && Navigator.canPop(context)) {
       // On ne pop que si on est dans un Drawer (vérification simple par le contexte)
       try { Scaffold.of(context).closeEndDrawer(); } catch (e) {}
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSubmitted(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessageUI(
        text: query,
        type: ChatMessageType.user,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // 1. Initialiser la conversation si besoin
      if (_currentConversationId == null) {
        _currentConversationId = await _assistantService.createConversation(
          query.length > 30 ? '${query.substring(0, 30)}...' : query
        );
        // Rafraîchir la liste des conversations en arrière-plan
        _assistantService.getConversations().then((convs) {
          if (mounted) setState(() => _conversations = convs);
        });
      }

      // 2. Appel au service avec historique
      final historyForService = _messages
          .where((m) => m.type != ChatMessageType.travelCard)
          .map((m) => AssistantMessage(
                id: '', userId: '', createdAt: m.timestamp,
                role: 'PASSAGER', content: m.text,
                senderType: m.type == ChatMessageType.user ? 'user' : 'ai'
              ))
          .toList();

      final aiResponse = await _assistantService.sendMessage(
        query, historyForService, conversationId: _currentConversationId
      );

      // 3. Logique locale pour afficher un TravelCard
      Trip? specialTrip;
      final msgLower = query.toLowerCase();
      if (msgLower.contains('labé') || msgLower.contains('mamou') || msgLower.contains('conakry')) {
        final res = await TripService.getUpcomingTrips(limit: 5);
        if (res.data != null && res.data!.isNotEmpty) {
           if (aiResponse.content.toLowerCase().contains('trouvé') || aiResponse.content.toLowerCase().contains('disponible')) {
             specialTrip = res.data!.first;
           }
        }
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessageUI(
            text: aiResponse.content,
            type: ChatMessageType.assistant,
            timestamp: DateTime.now(),
          ));
          if (specialTrip != null) {
            _messages.add(ChatMessageUI(
              text: '',
              type: ChatMessageType.travelCard,
              timestamp: DateTime.now(),
              tripData: specialTrip,
            ));
          }
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur assistant : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Assistant Voyage',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: AppColors.primary, size: 20),
            onPressed: _createNewChat,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary, size: 24),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      if (msg.type == ChatMessageType.user) {
                        return _buildUserMessage(msg.text, msg.timestamp);
                      } else if (msg.type == ChatMessageType.travelCard) {
                        return Padding(padding: const EdgeInsets.only(bottom: 24), child: _buildTravelCard(msg.tripData!));
                      } else {
                        return _buildAssistantMessage(msg.text);
                      }
                    },
                  ),
          ),
          if (_isLoading && _messages.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
            ),
          _buildQuickReplyChips(),
          _buildChatInput(),
        ],
      ),
    );
  }

  Future<void> _deleteConversation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la discussion ?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _assistantService.deleteConversation(id);
        if (mounted) {
          setState(() {
            _conversations.removeWhere((c) => c['id'] == id);
            if (_currentConversationId == id) {
              _currentConversationId = null;
              _messages = [];
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Discussion supprimée')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Mes Conversations',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_rounded, color: AppColors.primary),
            title: Text('Nouvelle discussion', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            onTap: _createNewChat,
          ),
          const Divider(),
          Expanded(
            child: _conversations.isEmpty
                ? Center(child: Text('Aucun historique', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      final isSelected = conv['id'] == _currentConversationId;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withOpacity(0.1),
                        leading: Icon(Icons.chat_bubble_outline_rounded, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
                        title: Text(
                          conv['title'] ?? 'Discussion sans titre',
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteConversation(conv['id']),
                        ),
                        onTap: () {
                          _switchToConversation(conv['id']);
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

  Widget _buildUserMessage(String text, DateTime time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
          child: Text(text, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(text, style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14, height: 1.4)),
        ),
      ),
    );
  }

  Widget _buildTravelCard(Trip trip) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trip.departureCityName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                Text(trip.arrivalCityName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trip.formattedPrice, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 18)),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                  child: const Text('Réserver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplyChips() {
    final chips = ['Trajets demain', 'Prix pour Labé ?', 'Mes billets'];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ActionChip(
          label: Text(chips[i], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.surface,
          onPressed: () => _handleSubmitted(chips[i]),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppColors.border)),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Posez votre question...', border: InputBorder.none),
                onSubmitted: _handleSubmitted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSubmitted(_messageController.text),
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: _isLoading ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
