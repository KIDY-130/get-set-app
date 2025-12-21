import 'package:flutter/material.dart';
import '../main.dart';
import '../services/ai_service.dart';

class TodoCalendarView extends StatefulWidget {
  final List<Todo> todos;
  final Function(List<Todo>) onTodosChange;
  final Function(Todo) onStartFocus;

  const TodoCalendarView({
    super.key,
    required this.todos,
    required this.onTodosChange,
    required this.onStartFocus,
  });

  @override
  State<TodoCalendarView> createState() => _TodoCalendarViewState();
}

class _TodoCalendarViewState extends State<TodoCalendarView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String get _formattedDate =>
      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _TodoList(
            todos: widget.todos,
            onTodosChange: widget.onTodosChange,
            onStartFocus: widget.onStartFocus,
            selectedDate: _formattedDate,
          ),
          const SizedBox(height: 24),
          _Calendar(
            todos: widget.todos,
            selectedDate: _formattedDate,
            onDateSelect: (dateString) {
              setState(() {
                _selectedDate = DateTime.parse(dateString);
              });
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _TodoList extends StatefulWidget {
  final List<Todo> todos;
  final Function(List<Todo>) onTodosChange;
  final Function(Todo) onStartFocus;
  final String selectedDate;

  const _TodoList({
    required this.todos,
    required this.onTodosChange,
    required this.onStartFocus,
    required this.selectedDate,
  });

  @override
  State<_TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<_TodoList> {
  final TextEditingController _controller = TextEditingController();
  bool _isAiLoading = false;

  void _addTodo() {
    if (_controller.text.trim().isNotEmpty) {
      final newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _controller.text,
        date: widget.selectedDate,
      );
      widget.onTodosChange([...widget.todos, newTodo]);
      _controller.clear();
    }
  }

  void _handleAiSort() async {
    final todosForDate = widget.todos
        .where((t) => t.date == widget.selectedDate)
        .toList();

    if (todosForDate.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("분석할 할 일이 부족해요! (2개 이상 필요)")),
      );
      return;
    }

    setState(() => _isAiLoading = true);

    try {
      List<Todo> aiSortedTodos = await AIService.sortTodosWithAI(todosForDate);

      List<Todo> otherTodos = widget.todos
          .where((t) => t.date != widget.selectedDate)
          .toList();

      widget.onTodosChange([...otherTodos, ...aiSortedTodos]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("AI가 가장 중요한 일에 별을 달고 정렬했습니다! ✨")),
        );
      }
    } finally {
      if (mounted) setState(() => _isAiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosForDate = widget.todos
        .where((t) => t.date == widget.selectedDate)
        .toList();

    final realPriorityTodo =
        todosForDate.any((t) => t.isPriority && !t.completed)
        ? todosForDate.firstWhere((t) => t.isPriority && !t.completed)
        : null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.purple[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icon/checklist.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "할 일 목록",
                    style: TextStyle(
                      color: Colors.purple[600],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (todosForDate.isNotEmpty)
                TextButton.icon(
                  onPressed: _isAiLoading ? null : _handleAiSort,
                  icon: _isAiLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFC084FC),
                          ),
                        )
                      : const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Color(0xFFC084FC),
                        ),
                  label: Text(
                    _isAiLoading ? "분석 중..." : "AI 정렬",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFC084FC),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFC084FC).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),

          Text(
            widget.selectedDate,
            style: TextStyle(color: Colors.purple[300], fontSize: 17),
          ),
          const SizedBox(height: 16),

          if (realPriorityTodo != null) _buildPriorityCard(realPriorityTodo),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "새 할 일 추가...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple[200]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _addTodo,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC084FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (todosForDate.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "이 날짜에 할 일이 없어요",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todosForDate.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final todo = todosForDate[index];
                return _buildTodoItem(todo);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard(Todo realPriorityTodo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(80, 233, 219, 255),
            Color.fromARGB(255, 233, 219, 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 164, 81, 241)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                "가장 중요한 할 일",
                style: TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(realPriorityTodo.text, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => widget.onStartFocus(realPriorityTodo),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text("집중 모드 시작"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC084FC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: todo.isPriority
            ? Colors.yellow[50]
            : (todo.completed ? Colors.grey[50] : Colors.purple[50]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: todo.isPriority
              ? const Color(0xFFfad0c4)
              : const Color(0xFFffd1ff),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: todo.completed,
            activeColor: Colors.purple[400],
            onChanged: (_) {
              final newTodos = widget.todos
                  .map(
                    (t) => t.id == todo.id
                        ? Todo(
                            id: t.id,
                            text: t.text,
                            date: t.date,
                            completed: !t.completed,
                            isPriority: t.isPriority,
                          )
                        : t,
                  )
                  .toList();
              widget.onTodosChange(newTodos);
            },
          ),
          Expanded(
            child: Text(
              todo.text,
              style: TextStyle(
                decoration: todo.completed ? TextDecoration.lineThrough : null,
                color: todo.completed ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.star,
              color: todo.isPriority ? Colors.amber : Colors.grey[300],
            ),
            onPressed: todo.completed
                ? null
                : () {
                    final newTodos = widget.todos
                        .map(
                          (t) => t.id == todo.id
                              ? Todo(
                                  id: t.id,
                                  text: t.text,
                                  date: t.date,
                                  completed: t.completed,
                                  isPriority: !t.isPriority,
                                )
                              : t,
                        )
                        .toList();
                    widget.onTodosChange(newTodos);
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () => widget.onTodosChange(
              widget.todos.where((t) => t.id != todo.id).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Calendar extends StatefulWidget {
  final List<Todo> todos;
  final String selectedDate;
  final Function(String) onDateSelect;

  const _Calendar({
    required this.todos,
    required this.selectedDate,
    required this.onDateSelect,
  });

  @override
  State<_Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.parse(widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.blue),
                onPressed: () =>
                    setState(() => _currentMonth = DateTime(year, month - 1)),
              ),
              Text(
                "$year년 $month월",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: Color.fromARGB(255, 160, 212, 255),
                ),
                onPressed: () =>
                    setState(() => _currentMonth = DateTime(year, month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["일", "월", "화", "수", "목", "금", "토"]
                .map(
                  (d) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: startingWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startingWeekday) return const SizedBox();

              final day = index - startingWeekday + 1;
              final dateString =
                  "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
              final isSelected = dateString == widget.selectedDate;
              final isToday =
                  dateString == DateTime.now().toString().split(' ')[0];
              final todoCount = widget.todos
                  .where((t) => t.date == dateString && !t.completed)
                  .length;

              return GestureDetector(
                onTap: () => widget.onDateSelect(dateString),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.pink[400]
                        : (isSelected
                              ? const Color.fromARGB(255, 189, 226, 255)
                              : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    gradient: isToday
                        ? const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 234, 213, 255),
                              Color.fromARGB(255, 255, 199, 228),
                            ],
                          )
                        : null,
                    border: isSelected && !isToday
                        ? Border.all(
                            color: const Color.fromARGB(255, 181, 220, 255),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$day",
                        style: TextStyle(
                          color: (isToday || isSelected)
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: (isToday || isSelected)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (todoCount > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            todoCount > 3 ? 3 : todoCount,
                            (index) => Container(
                              margin: const EdgeInsets.only(top: 2, right: 1),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: (isToday || isSelected)
                                    ? Colors.white
                                    : Colors.purple[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
