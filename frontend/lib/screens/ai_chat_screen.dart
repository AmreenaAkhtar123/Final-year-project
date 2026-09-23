import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
      'Hi! I’m MindMate. I’m here to listen and support you. How are you feeling today?',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _messageController.clear();
    });

    // Temporary response.
    // Later this will be replaced with the backend AI API.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        _messages.add(
          const _ChatMessage(
            text:
            'Thank you for sharing that with me. I’m listening. Tell me a little more about what’s on your mind.',
            isUser: false,
          ),
        );
      });
    });
  }

  void _useSuggestion(String text) {
    _messageController.text = text;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: _messageController.text.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          padding: const EdgeInsets.only(left: 8),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          style: IconButton.styleFrom(
            fixedSize: const Size(40, 40),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.navy,
            size: 18,
          ),
        ),

        titleSpacing: 0,

        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.mint,
                size: 21,
              ),
            ),

            const SizedBox(width: 10),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MindMate',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 1),

                Text(
                  'AI Companion',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              _showInfo();
            },
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.navy,
              size: 22,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                return _buildMessageBubble(message);
              },
            ),
          ),

          _buildSuggestions(),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Align(
      alignment:
      message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
          message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.mint,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
            ],

            Flexible(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? AppColors.navy
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(
                      message.isUser ? 18 : 5,
                    ),
                    bottomRight: Radius.circular(
                      message.isUser ? 5 : 18,
                    ),
                  ),
                  border: message.isUser
                      ? null
                      : Border.all(
                    color: AppColors.borderMint,
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser
                        ? Colors.white
                        : AppColors.navy,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.mint,
                size: 36,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'What’s on your mind?',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You can talk to MindMate about how you’re feeling.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.55),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      'I feel stressed',
      'I feel anxious',
      'I need someone to talk to',
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return OutlinedButton(
            onPressed: () {
              _useSuggestion(suggestions[index]);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              backgroundColor: Colors.white,
              side: const BorderSide(
                color: AppColors.borderMint,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
              ),
            ),
            child: Text(
              suggestions[index],
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  hintStyle: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.40),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.borderMint,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.borderMint,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.mint,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'About MindMate AI',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'MindMate is designed to provide supportive conversations '
                'and wellbeing guidance. It is not a replacement for a '
                'qualified mental health professional or emergency service.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}