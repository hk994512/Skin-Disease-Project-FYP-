import 'dart:convert';
import 'package:clearskin_ai/core/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DiseaseChatSheet – Groq AI chat about the detected skin condition
// ─────────────────────────────────────────────────────────────────────────────

const _kGroqApiKey = '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';
const _kEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
const _kModel = 'llama-3.3-70b-versatile';

void showDiseaseChatSheet(BuildContext context, ScanResult scanResult) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DiseaseChatSheet(scanResult: scanResult),
  );
}

class DiseaseChatSheet extends StatefulWidget {
  final ScanResult scanResult;
  const DiseaseChatSheet({super.key, required this.scanResult});

  @override
  State<DiseaseChatSheet> createState() => _DiseaseChatSheetState();
}

class _DiseaseChatSheetState extends State<DiseaseChatSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  // OpenAI-compatible message list (role: system / user / assistant)
  late List<Map<String, String>> _history;
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initHistory();
  }

  Future<void> _initHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_history_${widget.scanResult.id}';
    final savedData = prefs.getString(key);

    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);
      _history = decoded.map((e) => Map<String, String>.from(e)).toList();

      // Rebuild UI messages from history (skip system prompt)
      setState(() {
        for (var msg in _history) {
          if (msg['role'] == 'user') {
            _messages.add(_ChatMessage(text: msg['content']!, isUser: true));
          } else if (msg['role'] == 'assistant') {
            _messages.add(_ChatMessage(text: msg['content']!, isUser: false));
          }
        }
      });
      _scrollToBottom();
    } else {
      // System prompt — sets Groq's persona (sent once, stays in history)
      _history = [
        {
          'role': 'system',
          'content':
              'You are a knowledgeable medical assistant specializing in dermatology. '
              'The user has been diagnosed by an AI skin scanner with: '
              '"${widget.scanResult.diseaseName}" '
              '(Risk level: ${widget.scanResult.riskLevel}). '
              'Answer their questions clearly, compassionately, and accurately. '
              'Always remind the user to consult a real dermatologist for professional advice. '
              'Keep your answers concise and easy to understand.',
        },
      ];

      // Welcome message (local only, not sent to API, not saved in history)
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'Hi! I\'m your AI health assistant 🩺\n\n'
                'I can help you learn more about ${widget.scanResult.diseaseName}.\n'
                'Ask me anything — symptoms, causes, treatments, or prevention tips!',
            isUser: false,
          ),
        );
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_history_${widget.scanResult.id}';
    await prefs.setString(key, jsonEncode(_history));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Add user message to history
    _history.add({'role': 'user', 'content': text});

    try {
      final response = await http.post(
        Uri.parse(_kEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_kGroqApiKey',
        },
        body: jsonEncode({
          'model': _kModel,
          'messages': _history,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply =
            (data['choices'] as List?)?.firstOrNull?['message']?['content']
                as String? ??
            'Sorry, I couldn\'t generate a response.';

        // Add assistant reply to history for context
        _history.add({'role': 'assistant', 'content': reply});
        _saveHistory();

        setState(() => _messages.add(_ChatMessage(text: reply, isUser: false)));
      } else if (response.statusCode == 429) {
        setState(
          () => _messages.add(
            _ChatMessage(
              text: 'Rate limit reached. Please wait a moment and try again.',
              isUser: false,
              isError: true,
            ),
          ),
        );
        // Remove the user message from history since it failed
        _history.removeLast();
      } else {
        final err = jsonDecode(response.body);
        final errMsg =
            err['error']?['message'] as String? ??
            'HTTP ${response.statusCode}';
        setState(
          () => _messages.add(
            _ChatMessage(text: 'Error: $errMsg', isUser: false, isError: true),
          ),
        );
        _history.removeLast();
      }
    } catch (e) {
      setState(
        () => _messages.add(
          _ChatMessage(
            text: 'Network error: ${e.toString()}',
            isUser: false,
            isError: true,
          ),
        ),
      );
      _history.removeLast();
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Drag handle ────────────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.smart_toy_outlined,
                      color: cs.primary,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Health Assistant',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.scanResult.diseaseName,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: cs.outlineVariant),

            // ── Messages ───────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) return _TypingIndicator();
                  return _MessageBubble(message: _messages[i]);
                },
              ),
            ),

            // ── Input bar ──────────────────────────────────────────
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(top: BorderSide(color: cs.outlineVariant)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText:
                              'Ask about ${widget.scanResult.diseaseName}…',
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton.filled(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: _isLoading
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        minimumSize: Size(48.r, 48.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Message model
// ─────────────────────────────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Message bubble
// ─────────────────────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6.h,
          bottom: 6.h,
          left: isUser ? 48.w : 0,
          right: isUser ? 0 : 48.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: message.isError
              ? cs.errorContainer
              : isUser
              ? cs.primary
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: message.isError
                ? cs.onErrorContainer
                : isUser
                ? cs.onPrimary
                : cs.onSurface,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Typing indicator
// ─────────────────────────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _ac,
              builder: (_, __) {
                final delay = i * 0.2;
                final value = (_ac.value - delay).clamp(0.0, 1.0);
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.4 + value * 0.6),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
