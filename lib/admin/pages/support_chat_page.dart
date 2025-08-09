import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_support_chat_provider.dart';
import '../../models/support_chat_model.dart';
import '../../theme/colors.dart';
import '../widgets/chat_stats_widget.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({Key? key}) : super(key: key);

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  SupportThread? selectedThread;
  final TextEditingController _messageController = TextEditingController();
  bool showChatDetail = false; // Control for mobile navigation

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminSupportChatProvider>();
      provider.loadAllThreads();
      provider.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    context.read<AdminSupportChatProvider>().stopAutoRefresh();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: Text(
          showChatDetail && selectedThread != null && !isTablet 
              ? selectedThread!.userName.isNotEmpty 
                  ? selectedThread!.userName 
                  : 'Khách hàng'
              : 'Quản lý Chat Hỗ trợ'
        ),
        backgroundColor: const Color(0xFF9C6B53),
        foregroundColor: Colors.white,
        leading: showChatDetail && !isTablet
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    showChatDetail = false;
                    selectedThread = null;
                  });
                },
              )
            : null,
        actions: [
          if (!showChatDetail || isTablet)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AdminSupportChatProvider>().loadAllThreads();
              },
            ),
        ],
      ),
      body: Consumer<AdminSupportChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mobile layout - show either list or detail
          if (!isTablet) {
            if (showChatDetail && selectedThread != null) {
              return _buildChatArea(provider);
            } else {
              return _buildChatList(provider);
            }
          }

          // Tablet/Desktop layout - show both side by side
          return Row(
            children: [
              // Thread List (Left Panel)
              SizedBox(
                width: 350,
                child: _buildChatList(provider),
              ),
              // Chat Area (Right Panel)
              Expanded(
                child: selectedThread == null
                    ? _buildEmptyChatArea()
                    : _buildChatArea(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatList(AdminSupportChatProvider provider) {
    return Column(
      children: [
        // Chat Statistics (only show on main list view)
        if (!showChatDetail || MediaQuery.of(context).size.width > 768)
          ChatStatsWidget(
            threads: provider.threads,
            isLoading: provider.isLoading,
          ),
        
        // Thread List
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: MediaQuery.of(context).size.width > 768
                  ? Border(right: BorderSide(color: Colors.grey.shade300))
                  : null,
            ),
            child: Column(
              children: [
                // List Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Cuộc trò chuyện (${provider.threads.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Thread List
                Expanded(
                  child: provider.threads.isEmpty
                      ? _buildEmptyThreadList()
                      : ListView.builder(
                          itemCount: provider.threads.length,
                          itemBuilder: (context, index) {
                            final thread = provider.threads[index];
                            return _buildThreadItem(thread);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreadItem(SupportThread thread) {
    final isSelected = selectedThread?.id == thread.id;
    final lastMessage = thread.messages.isNotEmpty ? thread.messages.last : null;
    final hasUnreadFromUser = lastMessage?.sender == 'user';

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedThread = thread;
            showChatDetail = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with notification dot
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      thread.userName.isNotEmpty 
                          ? thread.userName[0].toUpperCase() 
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (hasUnreadFromUser)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name
                    Text(
                      thread.userName.isNotEmpty ? thread.userName : 'Khách hàng',
                      style: TextStyle(
                        fontWeight: hasUnreadFromUser ? FontWeight.bold : FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      thread.userEmail,
                      style: TextStyle(
                        fontSize: 14, 
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    
                    // Last message
                    if (lastMessage != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            lastMessage.sender == 'user' 
                                ? Icons.person 
                                : Icons.admin_panel_settings,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lastMessage.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: hasUnreadFromUser 
                                    ? FontWeight.w500 
                                    : FontWeight.normal,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Trailing info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(thread.updatedAt),
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.grey[500],
                    ),
                  ),
                  if (hasUnreadFromUser) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyThreadList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có cuộc trò chuyện nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Khách hàng sẽ xuất hiện ở đây khi bắt đầu chat',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatArea() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chọn một cuộc trò chuyện để bắt đầu',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tin nhắn sẽ hiển thị ở đây',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(AdminSupportChatProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: MediaQuery.of(context).size.width <= 768
            ? null
            : Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    selectedThread!.userName.isNotEmpty 
                        ? selectedThread!.userName[0].toUpperCase() 
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedThread!.userName.isNotEmpty 
                            ? selectedThread!.userName 
                            : 'Khách hàng',
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        selectedThread!.userEmail,
                        style: const TextStyle(
                          fontSize: 14, 
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: selectedThread!.messages.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có tin nhắn nào',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: selectedThread!.messages.length,
                      itemBuilder: (context, index) {
                        final messages = selectedThread!.messages.reversed.toList();
                        final message = messages[index];
                        final isAdmin = message.sender == 'admin';
                        
                        return _buildMessageBubble(message, isAdmin);
                      },
                    ),
            ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập phản hồi...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, 
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () {
                          // TODO: Implement file attachment
                        },
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) => _sendAdminMessage(provider),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: provider.isSending 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: provider.isSending ? null : () => _sendAdminMessage(provider),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage message, bool isAdmin) {
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: isAdmin 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            // Sender info
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isAdmin) ...[
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      'Khách hàng',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ] else ...[
                    const Icon(Icons.admin_panel_settings, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      'Admin',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAdmin ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                  bottomRight: Radius.circular(isAdmin ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isAdmin ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.createdAt != null ? _formatTime(message.createdAt!) : '',
                    style: TextStyle(
                      fontSize: 11,
                      color: isAdmin ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendAdminMessage(AdminSupportChatProvider provider) async {
    if (_messageController.text.trim().isNotEmpty && selectedThread != null) {
      final success = await provider.sendAdminMessage(
        selectedThread!.id,
        _messageController.text.trim(),
      );
      
      if (success) {
        _messageController.clear();
        setState(() {
          selectedThread = provider.threads.firstWhere((t) => t.id == selectedThread!.id);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Gửi tin nhắn thất bại'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
