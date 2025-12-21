import 'package:flutter/material.dart';
import '../main.dart';

class DumpView extends StatefulWidget {
  final List<DumpNote> notes;
  final Function(List<DumpNote>) onNotesChange;

  const DumpView({super.key, required this.notes, required this.onNotesChange});

  @override
  State<DumpView> createState() => _DumpViewState();
}

class _DumpViewState extends State<DumpView> {
  final TextEditingController _textController = TextEditingController();
  String _searchQuery = "";

  void _addNote() {
    if (_textController.text.trim().isNotEmpty) {
      final newNote = DumpNote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _textController.text,
        timestamp: DateTime.now(),
      );
      widget.onNotesChange([newNote, ...widget.notes]);
      _textController.clear();
    }
  }

  String _formatTimestamp(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "방금 전";
    if (diff.inMinutes < 60) return "${diff.inMinutes}분 전";
    if (diff.inHours < 24) return "${diff.inHours}시간 전";
    return "${d.month}/${d.day}";
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = widget.notes
        .where((n) => n.text.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 1. 아이콘 이미지
                Image.asset(
                  'assets/icon/trash.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                const Text(
                  "생각 쓰레기통",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Text(
              "머릿속 생각을 자유롭게 버려보세요.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "지금 떠오른 생각을 적어보세요...",
                      border: InputBorder.none,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addNote,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text("저장"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 검색
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "생각 검색하기...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[200]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 리스트
            if (filteredNotes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "결과가 없습니다.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredNotes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0FDF4), Color(0xFFEFF6FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimestamp(note.timestamp),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onPressed: () => widget.onNotesChange(
                                widget.notes
                                    .where((n) => n.id != note.id)
                                    .toList(),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(note.text),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
