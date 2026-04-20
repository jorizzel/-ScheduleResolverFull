import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  final String _apikey = 'AIzaSyAugVjZJ0RYtwhMRkmz_RtaXEk4NpohaEg';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apikey.isEmpty || tasks.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: _apikey);
      final taskJson = jsonEncode(tasks.map((t) => t.toJson()).toList());

      final prompt = '''
    
     You are an expert student scheduling assistant. The user has provided the following task for their day in JSON format:
    
     $taskJson
    
     Please provide exactly 4 section of markdown text:
     IMPORTANT: Do NOT use markdown bolding (double asterisks **), and do NOT use bullet points (single asterisks *) in your response. 
      Use plain text for all descriptions and lists.
     1. ### Detected Conflicts
     List any scheduling conflicts or state that there are none.
     2. ### Ranked Tasks
     Ranks which tasks needed attention first.
     3. ### Recommended Schedule
     Provide a revised daily timeline view adjusting the task times. Format it like "07:30 AM - 10:30 AM: Task Name" without any asterisks.
     4. ### Explanation
     Explain why this recommendation was made.
    
     ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      _currentAnalysis = _parseResponse(response.text ?? '');
    } catch (e) {
      _errorMessage = 'Failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    String conflicts = "";
    String rankedTasks = "";
    String recommendedSchedule = "";
    String explanation = "";

    final sections = fullText.split('###');
    for (var section in sections) {
      final trimmedSection = section.trim();
      if (trimmedSection.startsWith('Detected Conflicts')) {
        conflicts = trimmedSection.replaceFirst('Detected Conflicts', '').trim();
      } else if (trimmedSection.startsWith('Ranked Tasks')) {
        rankedTasks = trimmedSection.replaceFirst('Ranked Tasks', '').trim();
      } else if (trimmedSection.startsWith('Recommended Schedule')) {
        recommendedSchedule = trimmedSection.replaceFirst('Recommended Schedule', '').trim();
      } else if (trimmedSection.startsWith('Explanation')) {
        explanation = trimmedSection.replaceFirst('Explanation', '').trim();
      }
    }
    return ScheduleAnalysis(
      conflicts: conflicts,
      rankedTasks: rankedTasks,
      recommendedSchedule: recommendedSchedule,
      explanation: explanation,
    );
  }
}
