import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  late TabController _tab;
  late AnimationController _animationController;

  // Chat variables
  final List<ChatMessage> _chatMessages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  String _activeChatUser = '';
  String _activeChatInitials = '';
  bool _showChatView = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  final List<_NotifData> _notifs = [
    _NotifData(
      id: '1',
      initials: 'MZ',
      title: 'Ai – Maize Plant',
      subtitle: 'shared the scanned results',
      detail: 'Your scan shows 95% confidence',
      time: '3 hours ago',
      isChat: true,
      chatUser: 'Ai – Maize Plant',
    ),
    _NotifData(
      id: '2',
      initials: 'DD',
      title: 'Diagnosis Disease',
      subtitle: 'has sent email update for',
      detail: 'Secure your account',
      time: '5 hours ago',
      isChat: false,
      chatUser: '',
    ),
    _NotifData(
      id: '3',
      initials: 'RD',
      title: 'Maize Plant Organization',
      subtitle: 'shared the meeting',
      detail: 'Online Course',
      time: '3 hours ago',
      isChat: true,
      chatUser: 'Maize Plant Organization',
    ),
    _NotifData(
      id: '4',
      initials: 'AM',
      title: 'Ai -Maize Detector',
      subtitle: 'sent you some details about your last scan',
      detail: '',
      time: '5 hours ago',
      isChat: true,
      chatUser: 'Ai -Maize Detector',
    ),
  ];

  void _openChat(_NotifData notification) {
    setState(() {
      _activeChatUser = notification.chatUser;
      _activeChatInitials = notification.initials;
      _showChatView = true;
      _chatMessages.clear();
      _loadDemoMessages();
    });
    _animationController.forward();
  }

  void _loadDemoMessages() {
    _chatMessages.addAll([
      ChatMessage(
        text: "Hello! How can I help you with your maize crop?",
        isUser: false,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        text: "I noticed some spots on my maize leaves. What should I do?",
        isUser: true,
        time: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        text:
            "That sounds like a possible fungal infection. Can you share a photo of the affected leaves?",
        isUser: false,
        time: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isTyping = true;
    });

    final userMessage = ChatMessage(
      text: _messageController.text.trim(),
      isUser: true,
      time: DateTime.now(),
    );

    setState(() {
      _chatMessages.add(userMessage);
      _messageController.clear();
    });

    // Simulate AI/bot response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isTyping = false;
        _chatMessages.add(
          ChatMessage(
            text:
                "Thank you for your message. Our expert will review your concern and get back to you shortly. In the meantime, I recommend checking our disease detection feature for immediate assistance.",
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    if (_showChatView) {
      return _buildChatView();
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.bgLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppTheme.textDark,
              size: 18,
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryGreen,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.mark_chat_unread_outlined,
              color: AppTheme.primaryGreen,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Mark all as read',
                    style: GoogleFonts.poppins(),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textGrey,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Recent activity'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _NotifList(notifs: _notifs, onChatTap: _openChat),
          _NotifList(
            notifs: _notifs.where((n) => n.time == '3 hours ago').toList(),
            onChatTap: _openChat,
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildChatView() {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            setState(() {
              _showChatView = false;
              _animationController.reverse();
            });
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppTheme.textDark,
              size: 18,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _activeChatInitials,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _activeChatUser,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Online',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.videocam_outlined,
              color: AppTheme.primaryGreen,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppTheme.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == 0) {
                  return _buildTypingIndicator();
                }
                final messageIndex = _isTyping ? index - 1 : index;
                final message = _chatMessages.reversed.toList()[messageIndex];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? AppTheme.primaryGradient
              : LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
          borderRadius: BorderRadius.circular(message.isUser ? 20 : 20)
              .copyWith(
                bottomRight: message.isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(20),
                bottomLeft: message.isUser
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
              ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: message.isUser ? Colors.white : AppTheme.textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.time),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: message.isUser
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            20,
          ).copyWith(bottomLeft: const Radius.circular(4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: child,
                  );
                },
              );
            }),
            const SizedBox(width: 4),
            Text(
              'typing',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.softGreen,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.attach_file,
                color: AppTheme.primaryGreen,
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textGrey,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifData {
  final String id;
  final String initials;
  final String title;
  final String subtitle;
  final String detail;
  final String time;
  final bool isChat;
  final String chatUser;

  _NotifData({
    required this.id,
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.time,
    required this.isChat,
    required this.chatUser,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class _NotifList extends StatelessWidget {
  final List<_NotifData> notifs;
  final Function(_NotifData) onChatTap;

  const _NotifList({required this.notifs, required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    if (notifs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final n = notifs[i];
        return GestureDetector(
          onTap: () {
            if (n.isChat) {
              onChatTap(n);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: n.isChat
                  ? AppTheme.softGreen.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Text(
                      n.initials,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (n.isChat)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              title: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                  children: [
                    TextSpan(
                      text: n.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' ${n.subtitle}'),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (n.detail.isNotEmpty)
                    Text(
                      n.detail,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  Text(
                    n.time,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
              trailing: n.isChat
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Reply',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

// ─── SETTINGS SCREEN ───────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoSave = true;
  String _selectedLanguage = 'English';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ignore: unused_field
  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.notifications_outlined,
      'label': 'Alerts',
      'color': const Color(0xFF2E7D32),
      'value': true,
    },
    {
      'icon': Icons.cloud_sync_rounded,
      'label': 'Backup',
      'color': const Color(0xFF1565C0),
      'value': false,
    },
    {
      'icon': Icons.security_rounded,
      'label': 'Privacy',
      'color': const Color(0xFFE65100),
      'value': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // ── App bar (kama dashboard) ──
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leadingWidth: 56,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppTheme.textDark,
                      size: 18,
                    ),
                  ),
                ),
                title: Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.restore_rounded,
                      color: AppTheme.primaryGreen,
                    ),
                    onPressed: () {
                      _showResetDialog();
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Profile Banner Card (styled like dashboard banner) ──
                      _buildProfileBanner(),
                      const SizedBox(height: 24),

                      // ── Quick Settings Chips (kama quick actions kwenye dashboard) ──
                      _buildQuickSettings(),
                      const SizedBox(height: 28),

                      // ── Settings Sections ──
                      _buildSettingsSection(
                        title: 'Preferences',
                        icon: Icons.tune_rounded,
                        children: [
                          _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle:
                                'Use dark theme for better reading at night',
                            trailing: Switch(
                              value: _darkMode,
                              onChanged: (v) => setState(() => _darkMode = v),
                              activeThumbColor: AppTheme.primaryGreen,
                            ),
                          ),
                          const Divider(height: 1, indent: 54),
                          _SettingsTile(
                            icon: Icons.notifications_active_outlined,
                            title: 'Push Notifications',
                            subtitle: 'Receive alerts about plant health',
                            trailing: Switch(
                              value: _notifications,
                              onChanged: (v) =>
                                  setState(() => _notifications = v),
                              activeThumbColor: AppTheme.primaryGreen,
                            ),
                          ),
                          const Divider(height: 1, indent: 54),
                          _SettingsTile(
                            icon: Icons.save_rounded,
                            title: 'Auto-save Scans',
                            subtitle: 'Automatically save scan history',
                            trailing: Switch(
                              value: _autoSave,
                              onChanged: (v) => setState(() => _autoSave = v),
                              activeThumbColor: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildSettingsSection(
                        title: 'Language & Region',
                        icon: Icons.language_rounded,
                        children: [
                          _SettingsTile(
                            icon: Icons.translate_rounded,
                            title: 'App Language',
                            subtitle: 'Currently: $_selectedLanguage',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () => _showLanguageDialog(),
                          ),
                          const Divider(height: 1, indent: 54),
                          _SettingsTile(
                            icon: Icons.public_rounded,
                            title: 'Region',
                            subtitle: 'Tanzania (East Africa)',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildSettingsSection(
                        title: 'Account & Security',
                        icon: Icons.security_rounded,
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Profile Information',
                            subtitle: 'View and edit your profile',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 54),
                          _SettingsTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Privacy & Security',
                            subtitle: 'Manage your data privacy',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 54),
                          _SettingsTile(
                            icon: Icons.history_rounded,
                            title: 'Scan History',
                            subtitle: 'View all your past scans',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildSettingsSection(
                        title: 'Support & About',
                        icon: Icons.support_agent_rounded,
                        children: [
                          _SettingsTile(
                            icon: Icons.info_outline_rounded,
                            title: 'About Ai-Maize Detector',
                            subtitle: 'Version 1.0.0 (Build 101)',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () => Navigator.pushNamed(context, '/about'),
                          ),
                          const Divider(height: 1, indent: 54),
                          _SettingsTile(
                            icon: Icons.share_outlined,
                            title: 'Share App',
                            subtitle: 'Share with fellow farmers',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 54),
                          _SettingsTile(
                            icon: Icons.star_outline_rounded,
                            title: 'Rate Us',
                            subtitle: 'Rate this app on Play Store',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 54),
                          _SettingsTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Help Center',
                            subtitle: 'FAQs and support',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textGrey,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Sign out button
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showSignOutDialog(),
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppTheme.errorRed,
                          ),
                          label: Text(
                            'Sign Out',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.errorRed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  // ── PROFILE BANNER (styled like dashboard banner) ──
  Widget _buildProfileBanner() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF4CAF50)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primaryGreen,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Adam Farmer',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'adamfarmer112@gmail.com',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ── QUICK SETTINGS CHIPS ──
  Widget _buildQuickSettings() {
    return Row(
      children: [
        _QuickSettingChip(
          icon: Icons.notifications_outlined,
          label: 'Alerts',
          color: const Color(0xFF2E7D32),
          isActive: _notifications,
          onTap: () => setState(() => _notifications = !_notifications),
        ),
        const SizedBox(width: 10),
        _QuickSettingChip(
          icon: Icons.cloud_sync_rounded,
          label: 'Backup',
          color: const Color(0xFF1565C0),
          isActive: false,
          onTap: () {},
        ),
        const SizedBox(width: 10),
        _QuickSettingChip(
          icon: Icons.security_rounded,
          label: 'Privacy',
          color: const Color(0xFFE65100),
          isActive: true,
          onTap: () {},
        ),
      ],
    );
  }

  // ── SETTINGS SECTION WIDGET ──
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.softGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryGreen, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Language',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              language: 'English',
              isSelected: _selectedLanguage == 'English',
              onTap: () {
                setState(() => _selectedLanguage = 'English');
                Navigator.pop(ctx);
              },
            ),
            _LanguageOption(
              language: 'Swahili',
              isSelected: _selectedLanguage == 'Swahili',
              onTap: () {
                setState(() => _selectedLanguage = 'Swahili');
                Navigator.pop(ctx);
              },
            ),
            _LanguageOption(
              language: 'French',
              isSelected: _selectedLanguage == 'French',
              onTap: () {
                setState(() => _selectedLanguage = 'French');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to reset all settings to default?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _darkMode = false;
                _notifications = true;
                _autoSave = true;
                _selectedLanguage = 'English';
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings reset to default'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Reset', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Sign Out', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}

// ── QUICK SETTING CHIP (kama dashboard quick actions) ──
class _QuickSettingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickSettingChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? color : color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? color : color.withOpacity(0.6),
                size: 22,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? color : color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SETTINGS TILE (improved) ──
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.softGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textGrey),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

// ── LANGUAGE OPTION ──
class _LanguageOption extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        language,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
// ─── ABOUT SCREEN ─────────────────────────────────────────────────────────

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.bgLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppTheme.textDark,
              size: 18,
            ),
          ),
        ),
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryGreen,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo area
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.grass_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MaizeAI',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Professional About Us',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'MaizeAI is an intelligent mobile application developed to help farmers effectively protect, monitor, and manage their maize crops using advanced artificial intelligence technology. The app allows users to capture clear images of maize leaves and plants directly from their mobile devices, which are then analyzed by our AI system to identify visible disease symptoms.\n\nBy detecting common maize diseases at an early stage, MaizeAI helps farmers take timely action before problems spread and cause serious crop damage.\n\nIn addition to disease detection, MaizeAI provides reliable, easy-to-understand, and practical treatment recommendations tailored to the identified condition. Our mission is to empower farmers with fast, accurate, and user-friendly digital tools that improve crop health, increase overall yield, and reduce losses caused by disease.\n\nBy combining agricultural expertise with modern AI innovation, MaizeAI supports smarter decision-making and promotes sustainable and efficient farming practices for a better agricultural future.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textDark,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

// ─── PRIVACY SCREEN ────────────────────────────────────────────────────────

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.bgLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppTheme.textDark,
              size: 18,
            ),
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryGreen,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PolicySection(
              title: 'MaizeAI Privacy Policy',
              content:
                  'MaizeAI ("we," "our," or "us") respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, store, and protect information when you use the MaizeAI mobile application and its related services.\n\nBy using MaizeAI, you agree to the collection and use of information in accordance with this Privacy Policy.',
            ),
            _PolicySection(
              title: 'Information We Collect',
              content:
                  'We may collect personal information that you voluntarily provide, such as your name, email address, phone number, and general location. To provide AI-based maize disease detection, we also collect images of maize plants uploaded by users, scan results, and related diagnostic data. Additionally, we may collect basic device and usage information to improve app performance and user experience.',
            ),
            _PolicySection(
              title: 'How We Use Your Information',
              content:
                  'The information we collect is used to provide disease detection services, generate treatment recommendations, improve AI accuracy, enhance app functionality, communicate updates, and ensure the security of the application.',
            ),
            _PolicySection(
              title: 'Image and AI Data Usage',
              content:
                  'Uploaded images are analyzed by our AI system to detect maize diseases. These images are stored securely and may be used to improve detection accuracy. Any data used for research or system improvement is anonymized and cannot identify individual users.',
            ),
            _PolicySection(
              title: 'Data Sharing',
              content:
                  'MaizeAI does not sell personal data. Information may only be shared with trusted service providers who assist in operating the app or when required by law.',
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title, content;
  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textDark,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
