import re

with open('lib/features/passenger/screens/passenger_ai_assistant.dart', 'r') as f:
    text = f.read()

header = """
import 'package:intl/intl.dart';
import '../../../core/models/trip.dart';
import '../../../core/services/trip_service.dart';

enum ChatMessageType { user, assistant, travelCard }

class ChatMessage {
  final String text;
  final ChatMessageType type;
  final Trip? tripData;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.type, required this.timestamp, this.tripData});
}
"""

# Insert imports and classes right after the last import
last_import_index = text.rfind("import '")
insert_pos = text.find("\n", last_import_index) + 1
text = text[:insert_pos] + header + text[insert_pos:]

# Replace the state class
# First, let's locate the beginning of the state class
state_start = text.find('class _PassengerAIAssistantState extends State<PassengerAIAssistant> {')

state_replacement = """class _PassengerAIAssistantState extends State<PassengerAIAssistant> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Stricly online for your journey',
      type: ChatMessageType.assistant,
      timestamp: DateTime.now(),
    ));
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
    if (text.trim().isEmpty) return;

    final userText = text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userText,
        type: ChatMessageType.user,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    try {
      final msgLower = userText.toLowerCase();
      String responseText = "Désolé, je suis uniquement formé pour vous aider à trouver des trajets ou gérer vos billets. Pouvez-vous préciser ?";
      Trip? responseTrip;

      if (msgLower.contains('bonjour') || msgLower.contains('salut')) {
        responseText = "Bonjour ! Comment puis-je vous aider avec vos déplacements aujourd'hui ?";
      } else if (msgLower.contains('billet') || msgLower.contains('historique') || msgLower.contains('réservation')) {
        responseText = "Pour consulter vos billets et réservations, veuillez vous rendre dans l'onglet 'Billets' ou 'Trajets' depuis le menu principal !";
      } else if (msgLower.contains('trajet') || msgLower.contains('bus') || msgLower.contains('aller') || msgLower.contains('cherch')) {
        String? dest;
        final cities = ['kankan', 'labé', 'labe', 'kindia', 'mamou', 'nzérékoré', 'nzerekore', 'siguiri'];
        for (final c in cities) {
          if (msgLower.contains(c)) {
            dest = c;
            break;
          }
        }

        if (dest != null) {
          setState(() {
            _messages.add(ChatMessage(
              text: "Je recherche les trajets pour $dest... 🔍",
              type: ChatMessageType.assistant,
              timestamp: DateTime.now(),
            ));
          });
          
          final res = await TripService.getAllTrips();
          final allTrips = res.data ?? [];
          // Filter matching destinations
          final matching = allTrips.where((t) => t.arrivalCityName.toLowerCase().contains(dest!)).toList();

          if (matching.isNotEmpty) {
            responseText = "J'ai trouvé ${matching.length} trajet(s) vers $dest ! Voici le prochain :";
            responseTrip = matching.first;
          } else {
            responseText = "Désolé, je ne trouve aucun trajet prévu pour $dest en ce moment.";
          }
        } else {
          responseText = "Pour quelle destination cherchez-vous un trajet ? (Ex: Labé, Kankan)";
        }
      }

      setState(() {
        _messages.add(ChatMessage(
          text: responseText,
          type: ChatMessageType.assistant,
          timestamp: DateTime.now(),
        ));
        if (responseTrip != null) {
          _messages.add(ChatMessage(
            text: '',
            type: ChatMessageType.travelCard,
            timestamp: DateTime.now(),
            tripData: responseTrip,
          ));
        }
        _isLoading = false;
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Une erreur de connexion est survenue. Veuillez réessayer.",
          type: ChatMessageType.assistant,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'GUINEETRANSPORT',
          style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(AppAssets.aiAssistantAvatar),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
            itemCount: _messages.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildWelcomeMessage();
              final msg = _messages[index - 1];
              
              Widget content;
              if (msg.type == ChatMessageType.user) {
                content = _buildUserMessage(msg.text, msg.timestamp);
              } else if (msg.type == ChatMessageType.travelCard) {
                content = _buildTravelCard(msg.tripData!);
              } else {
                content = _buildAssistantMessage(msg.text);
              }
              return Padding(padding: const EdgeInsets.only(bottom: 24), child: content);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuickReplyChips(),
                _buildChatInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 16),
        Text('AI Assistant', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
        Text('STRICTLY ONLINE FOR YOUR JOURNEY', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildUserMessage(String text, DateTime time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 15, color: Colors.white, height: 1.4)),
            const SizedBox(height: 4),
            Text(DateFormat('HH:mm').format(time), style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 15, color: Colors.white, height: 1.4, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildTravelCard(Trip trip) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SERVICE ${trip.syndicateName ?? ''}'.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                  child: Text('${trip.availableSeats} PLACES', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStation(DateFormat('HH:mm').format(trip.departureTime), trip.departureCityName, trip.departureStationName),
                    Expanded(
                      child: Column(
                        children: [
                          Text(trip.formattedDuration, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                              Expanded(child: Container(height: 2, color: AppColors.border)),
                              const Icon(Icons.directions_bus, color: AppColors.primary, size: 16),
                              Expanded(child: Container(height: 2, color: AppColors.border)),
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.primary, width: 2), shape: BoxShape.circle)),
                            ],
                          ),
                          Text('DIRECT', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        ],
                      ),
                    ),
                    _buildStation('...', trip.arrivalCityName, trip.arrivalStationName, isEnd: true),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: AppColors.border)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRIX DU BILLET', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
                        Text(trip.formattedPrice, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bientôt disponible')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Réserver', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStation(String time, String city, String sub, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(city, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
        Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textSecondary.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildQuickReplyChips() {
    final chips = ['Trajets demain', 'Prix pour Labé ?', 'Bus du matin', 'Mes billets'];
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ActionChip(
          label: Text(chips[i], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.surface,
          labelStyle: const TextStyle(color: Colors.white),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          onPressed: () => _handleSubmitted(chips[i]),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background.withValues(alpha: 0), AppColors.background],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: _handleSubmitted,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un trajet, un prix...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _messageController.clear();
                    },
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary)
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSubmitted(_messageController.text),
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))]),
              child: _isLoading 
                  ? const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
"""

with open('lib/features/passenger/screens/passenger_ai_assistant.dart', 'w') as f:
    f.write(text[:state_start] + state_replacement)
