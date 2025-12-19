import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/todo_calendar_view.dart';
import 'components/block_schedule_view.dart';
import 'components/dump_view.dart';
import 'components/pomodoro_timer.dart';

class Todo {
  String id;
  String text;
  bool completed;
  bool isPriority;
  String date;

  Todo({
    required this.id,
    required this.text,
    this.completed = false,
    this.isPriority = false,
    required this.date,
  });
}

class ScheduleBlock {
  String id;
  String title;
  String startTime;
  String endTime;
  String color;
  bool completed;

  ScheduleBlock({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.completed = false,
  });
}

class DumpNote {
  String id;
  String text;
  DateTime timestamp;

  DumpNote({required this.id, required this.text, required this.timestamp});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return MaterialApp(
      title: 'GET SET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF030213),
          primary: const Color(0xFF030213),
          secondary: const Color(0xFFC084FC),
          surface: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentViewIndex = 0;
  List<Todo> _todos = [];
  List<ScheduleBlock> _scheduleBlocks = [];
  List<DumpNote> _dumpNotes = [];
  bool _focusMode = false;
  Todo? _focusTask;

  void _handleStartFocus(Todo todo) {
    setState(() {
      _focusTask = todo;
      _focusMode = true;
    });
  }

  void _handleExitFocus() {
    setState(() {
      _focusMode = false;
      _focusTask = null;
    });
  }

  void _handleCompleteTask() {
    if (_focusTask != null) {
      setState(() {
        _todos = _todos.map((t) {
          if (t.id == _focusTask!.id) {
            return Todo(
              id: t.id,
              text: t.text,
              completed: true,
              isPriority: t.isPriority,
              date: t.date,
            );
          }
          return t;
        }).toList();

        _focusMode = false;
        _focusTask = null;
      });
    }
  }

  void _addQuickDumpNote(String text) {
    if (text.trim().isNotEmpty) {
      setState(() {
        _dumpNotes = [
          DumpNote(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: text,
            timestamp: DateTime.now(),
          ),
          ..._dumpNotes,
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_focusMode && _focusTask != null) {
      return PomodoroTimer(
        taskName: _focusTask!.text,
        onExit: _handleExitFocus,
        onComplete: _handleCompleteTask,
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAF5FF), Color(0xFFFDF2F8), Color(0xFFEFF6FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                child: Column(
                  children: [
                    const Text(
                      'GET SET',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC084FC),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // [수정] 이모지 텍스트를 Row로 변경하여 이미지와 함께 배치
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                      children: [
                        Text(
                          '우주로 날아간 집중력을 지구로 소환 중...',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(
                              0xFFC084FC,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 6), // 텍스트와 이미지 사이 간격
                        Image.asset(
                          'assets/icon/ufo1.png', // 안테나 아이콘 경로
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                          color: const Color(0xFFC084FC).withValues(
                            alpha: 0.7,
                          ), // (선택사항) 텍스트 색상과 깔맞춤 하려면 이 줄을 유지, 원본 색상을 쓰려면 이 줄 삭제
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildCurrentView()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickDumpDialog(context),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4ADE80), Color(0xFF60A5FA)],
          ).createShader(bounds),
          child: const Icon(Icons.lightbulb, color: Colors.white),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: _getIndicatorColor(),
          selectedIndex: _currentViewIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentViewIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.check_box_outlined),
              selectedIcon: Icon(Icons.check_box),
              label: '할 일',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: '타임블록',
            ),
            NavigationDestination(
              icon: Icon(Icons.delete_outline),
              selectedIcon: Icon(Icons.delete),
              label: 'Dump',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentViewIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TodoCalendarView(
            todos: _todos,
            onTodosChange: (newTodos) => setState(() => _todos = newTodos),
            onStartFocus: _handleStartFocus,
          ),
        );
      case 1:
        return BlockScheduleView(
          blocks: _scheduleBlocks,
          onBlocksChange: (newBlocks) =>
              setState(() => _scheduleBlocks = newBlocks),
        );
      case 2:
        return DumpView(
          notes: _dumpNotes,
          onNotesChange: (newNotes) => setState(() => _dumpNotes = newNotes),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getIndicatorColor() {
    switch (_currentViewIndex) {
      case 0:
        return Colors.purple[100]!;
      case 1:
        return Colors.pink[100]!;
      case 2:
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  void _showQuickDumpDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("💭 빠른 생각 메모", style: TextStyle(color: Colors.green)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "지금 떠오른 생각을 적어보세요...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _addQuickDumpNote(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("생각이 저장되었습니다! 🗑️"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text("저장"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
