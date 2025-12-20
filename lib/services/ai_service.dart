import 'package:google_generative_ai/google_generative_ai.dart';
import '../main.dart';
import 'dart:convert';

class AIService {
  // 발급받은 Gemini API 키를 여기에 넣으세요
  static const String _apiKey = 'AIzaSyBidFG5Y4wOEoumVgagn5JVSBhll7kp-3s';

  static Future<List<Todo>> sortTodosWithAI(List<Todo> todos) async {
    if (todos.isEmpty) return todos;

    // 1. 모델 설정 (무료 등급에서도 성능이 좋은 gemini-1.5-flash 권장)
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    // 2. 프롬프트 작성
    String todoData = todos.map((e) => "ID:${e.id}, 내용:${e.text}").join("\n");
    final prompt = """너는 생산성 전문가야. 
    사용자의 할 일 목록을 중요도와 긴급도를 기준으로 정렬해줘.
    가장 중요한 일 1~2개는 priority를 true로 설정해.
    반드시 다음 JSON 형식으로만 응답해: [{"id": "아이디", "priority": true/false}]
    목록:
    $todoData""";

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      // JSON 결과 추출 및 파싱
      String responseText = response.text ?? "[]";
      // 가끔 AI가 ```json ... ``` 코드를 붙여서 주므로 정제 필요
      responseText = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      List<dynamic> sortedResults = jsonDecode(responseText);

      List<Todo> finalSortedList = [];
      for (var result in sortedResults) {
        String id = result['id'].toString();
        bool isPriority = result['priority'] ?? false;

        try {
          Todo original = todos.firstWhere((t) => t.id == id);
          finalSortedList.add(
            Todo(
              id: original.id,
              text: original.text,
              date: original.date,
              completed: original.completed,
              isPriority: isPriority,
            ),
          );
        } catch (e) {
          continue;
        }
      }

      // 누락된 항목 추가
      for (var t in todos) {
        if (!finalSortedList.any((sorted) => sorted.id == t.id)) {
          finalSortedList.add(t);
        }
      }

      return finalSortedList;
    } catch (e) {
      print("Gemini API 에러: $e");
      return todos;
    }
  }
}
