import 'package:flutter/material.dart';
import '../main.dart';

class BlockScheduleView extends StatefulWidget {
  final List<ScheduleBlock> blocks;
  final Function(List<ScheduleBlock>) onBlocksChange;

  const BlockScheduleView({
    super.key,
    required this.blocks,
    required this.onBlocksChange,
  });

  @override
  State<BlockScheduleView> createState() => _BlockScheduleViewState();
}

class _BlockScheduleViewState extends State<BlockScheduleView> {
  bool _showAddForm = false;
  bool _showSettings = false;
  int _startHour = 6;
  int _endHour = 23;

  String _newTitle = "";
  TimeOfDay _newStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _newEndTime = const TimeOfDay(hour: 10, minute: 0);
  Color _newColor = const Color(0xFFE9D5FF);

  final List<Color> _pastelColors = [
    const Color(0xFFE9D5FF),
    const Color(0xFFFBCFE8),
    const Color(0xFFBFDBFE),
    const Color(0xFFBBF7D0),
    const Color(0xFFFEF08A),
    const Color(0xFFFECACA),
  ];

  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  void _addBlock() {
    if (_newTitle.isNotEmpty) {
      final newBlock = ScheduleBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _newTitle,
        startTime: _formatTime(_newStartTime),
        endTime: _formatTime(_newEndTime),
        color: _newColor.toARGB32().toString(),
        completed: false,
      );

      final newBlocks = [...widget.blocks, newBlock]
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      widget.onBlocksChange(newBlocks);

      setState(() {
        _newTitle = "";
        _showAddForm = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double hourHeight = 60.0;
    final int hoursCount = _endHour - _startHour + 1;
    final double totalTimelineHeight = hoursCount * hourHeight + 50;

    int timeToMin(String t) {
      final p = t.split(":").map(int.parse).toList();
      return p[0] * 60 + p[1];
    }

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.pink[100]!),
        ),
        child: Column(
          children: [
            // 1. 헤더 (고정)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // [수정] 이모지 텍스트 대신 Row(이미지 + 텍스트) 사용
                Row(
                  children: [
                    Image.asset(
                      'assets/icon/clock.png', // 준비한 시계 아이콘 경로
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "타임 블록", // 이모지 제거됨
                      style: TextStyle(
                        color: Colors.pink,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.grey),
                      onPressed: () =>
                          setState(() => _showSettings = !_showSettings),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.pink),
                      onPressed: () =>
                          setState(() => _showAddForm = !_showAddForm),
                    ),
                  ],
                ),
              ],
            ),

            // 2. 설정 패널
            if (_showSettings)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        "시작 시간",
                        _startHour,
                        (v) => setState(() => _startHour = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        "종료 시간",
                        _endHour,
                        (v) => setState(() => _endHour = v!),
                      ),
                    ),
                  ],
                ),
              ),

            // 3. 추가 폼
            if (_showAddForm)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: "활동 제목",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _newTitle = v,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePickerButton(
                            "시작",
                            _newStartTime,
                            (t) => setState(() => _newStartTime = t),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTimePickerButton(
                            "종료",
                            _newEndTime,
                            (t) => setState(() => _newEndTime = t),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _pastelColors
                          .map(
                            (c) => GestureDetector(
                              onTap: () => setState(() => _newColor = c),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: _newColor == c
                                      ? Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _addBlock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("추가"),
                    ),
                  ],
                ),
              ),

            // 4. 타임라인
            SizedBox(
              height: totalTimelineHeight,
              child: Stack(
                children: [
                  ...List.generate(hoursCount, (index) {
                    final h = _startHour + index;
                    return Positioned(
                      top: index * hourHeight,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              "$h:00",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  ...widget.blocks.map((block) {
                    final startMin = timeToMin(block.startTime);
                    final endMin = timeToMin(block.endTime);
                    final offsetStart = startMin - (_startHour * 60);

                    if (offsetStart < 0 || startMin >= _endHour * 60 + 60) {
                      return const SizedBox();
                    }

                    final top = (offsetStart / 60) * hourHeight;
                    final height = ((endMin - startMin) / 60) * hourHeight;

                    Color blockColor;
                    try {
                      blockColor = Color(int.parse(block.color));
                    } catch (e) {
                      blockColor = Colors.purple[100]!;
                    }

                    return Positioned(
                      top: top,
                      left: 60,
                      right: 0,
                      height: height < 40 ? 40 : height,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: blockColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: block.completed
                                ? Colors.grey
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: block.completed,
                              onChanged: (_) {
                                final newBlocks = widget.blocks
                                    .map(
                                      (b) => b.id == block.id
                                          ? ScheduleBlock(
                                              id: b.id,
                                              title: b.title,
                                              startTime: b.startTime,
                                              endTime: b.endTime,
                                              color: b.color,
                                              completed: !b.completed,
                                            )
                                          : b,
                                    )
                                    .toList();
                                widget.onBlocksChange(newBlocks);
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    block.title,
                                    style: TextStyle(
                                      decoration: block.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    "${block.startTime} - ${block.endTime}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 16),
                              onPressed: () {
                                widget.onBlocksChange(
                                  widget.blocks
                                      .where((b) => b.id != block.id)
                                      .toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, int value, Function(int?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        DropdownButton<int>(
          value: value,
          isExpanded: true,
          items: List.generate(
            24,
            (i) => DropdownMenuItem(value: i, child: Text("$i:00")),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTimePickerButton(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onPicked,
  ) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) {
          onPicked(t);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.pink[200]!),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10)),
            Text(_formatTime(time)),
          ],
        ),
      ),
    );
  }
}
