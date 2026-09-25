import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

class AgentChatScreen extends StatefulWidget {
  const AgentChatScreen({super.key});

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _send(AgentProvider agent) async {
    final text = _controller.text;
    _controller.clear();
    await agent.sendQuestion(text);
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
  Widget build(BuildContext context) {
    final agent = context.watch<AgentProvider>();
    final textSecondary = ThemeColors.textSecondary(context);
    final textPrimary = ThemeColors.textPrimary(context);
    final surfaceLight = ThemeColors.surfaceLight(context);

    return Column(
      children: [
        Expanded(
          child: agent.messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Ask about any stock or crypto — e.g. \"Is BTC risky right now?\"",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: agent.messages.length,
                  itemBuilder: (context, index) {
                    final msg = agent.messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isUser ? AppColors.accent : surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.black : textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (agent.isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask the market agent...",
                    ),
                    onSubmitted: (_) => _send(agent),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.accent),
                  onPressed: agent.isLoading ? null : () => _send(agent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}