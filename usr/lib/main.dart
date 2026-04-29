import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  static _ChatAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_ChatAppState>()!;

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  void changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void changeSeedColor(Color color) {
    setState(() {
      _seedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ContactListScreen(),
    );
  }
}

class Contact {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final Color avatarColor;

  Contact({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarColor,
  });
}

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Contact> contacts = [
      Contact(
        id: '1',
        name: '张三',
        lastMessage: '好的，我们明天讨论项目细节。晚安！',
        time: '10:42',
        avatarColor: Colors.blue,
      ),
      Contact(
        id: '2',
        name: '李四',
        lastMessage: '项目进展如何？',
        time: '昨天',
        avatarColor: Colors.green,
      ),
      Contact(
        id: '3',
        name: '王五',
        lastMessage: '发票已经开好了，请查收。',
        time: '星期一',
        avatarColor: Colors.orange,
      ),
      Contact(
        id: '4',
        name: '赵六',
        lastMessage: '周末去打球吗？',
        time: '上周',
        avatarColor: Colors.purple,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: contact.avatarColor,
              foregroundColor: Colors.white,
              child: Text(contact.name[0]),
            ),
            title: Text(contact.name),
            subtitle: Text(
              contact.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              contact.time,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(contact: contact),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  final Contact contact;
  
  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<Message> _messages;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 使用联系人的最后一条消息作为对话列表的初始数据
    _messages = [
      Message(
        text: widget.contact.lastMessage,
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      Message(
        text: "没问题！",
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Message(
        text: "你好，${widget.contact.name}！",
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    setState(() {
      _messages.insert(
        0,
        Message(
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    
    // 模拟对方在短暂停顿后的回复
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.insert(
            0,
            Message(
              text: '${widget.contact.name} 的自动回复: "$text"',
              isMe: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              backgroundColor: widget.contact.avatarColor,
              foregroundColor: Colors.white,
              child: Text(widget.contact.name[0]),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: message.isMe
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isMe
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8.0),
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.primary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('语音功能开发中...')),
                );
              },
            ),
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: '发送消息',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = ChatApp.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('主题模式'),
            subtitle: Text(
              appState.themeMode == ThemeMode.system
                  ? '跟随系统'
                  : appState.themeMode == ThemeMode.light
                      ? '浅色模式'
                      : '深色模式',
            ),
            trailing: DropdownButton<ThemeMode>(
              value: appState.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  appState.changeThemeMode(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('跟随系统')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('浅色模式')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('深色模式')),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('主题颜色', style: TextStyle(fontSize: 16)),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              Colors.blue,
              Colors.green,
              Colors.purple,
              Colors.orange,
              Colors.red,
              Colors.teal,
            ].map((color) {
              return GestureDetector(
                onTap: () => appState.changeSeedColor(color),
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(left: 16.0),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: appState.seedColor == color
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
