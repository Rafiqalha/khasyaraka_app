import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/group_chat/logic/group_chat_controller.dart';
import 'package:scout_os_app/features/group_chat/data/group_chat_models.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:intl/intl.dart';

class GroupChatRoomPage extends StatefulWidget {
  final GroupChatRoom room;

  const GroupChatRoomPage({super.key, required this.room});

  @override
  State<GroupChatRoomPage> createState() => _GroupChatRoomPageState();
}

class _GroupChatRoomPageState extends State<GroupChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupChatController>().fetchMessages(widget.room.id);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    final controller = context.read<GroupChatController>();
    final messages = controller.getMessages(widget.room.id);
    if (messages.isEmpty) return;

    setState(() { _isLoadingMore = true; });
    
    final oldestId = messages.last.id;
    await controller.fetchMessages(widget.room.id, beforeId: oldestId);
    
    final newMessages = controller.getMessages(widget.room.id);
    if (newMessages.length == messages.length) {
      _hasMore = false;
    }
    
    setState(() { _isLoadingMore = false; });
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    
    context.read<GroupChatController>().sendMessage(widget.room.id, text);
    _messageController.clear();
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthController>().currentUser?.id ?? '';
    final userIdInt = int.tryParse(currentUserId) ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room.name,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            if (widget.room.description != null)
              Text(
                widget.room.description!,
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<GroupChatController>(
              builder: (context, controller, child) {
                final messages = controller.getMessages(widget.room.id);
                
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Bottom to top
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final msg = messages[index];
                    final isMe = msg.senderId == userIdInt;
                    final isSystem = msg.senderType == 'system';
                    
                    if (isSystem) {
                      return _buildSystemMessage(msg);
                    }
                    
                    return _buildBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(GroupChatMessage msg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE066),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE5C85C),
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            msg.content,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB8860B), // Darker yellow-brown
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(GroupChatMessage msg, bool isMe) {
    final timeStr = DateFormat('HH:mm').format(msg.createdAt);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1CB0F6).withOpacity(0.2),
              child: Text(
                msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1CB0F6),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      msg.senderName,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF1CB0F6) : AppColors.charcoalSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                    border: isMe ? null : Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: isMe ? const Color(0xFF1899D6) : Colors.black.withOpacity(0.4),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.content,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                  child: Text(
                    timeStr,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (isMe) const SizedBox(width: 24), // Offset for symmetry
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.charcoalSurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 2)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.deepCharcoal,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                ),
                child: TextField(
                  controller: _messageController,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    hintStyle: GoogleFonts.nunito(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF58A700),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
