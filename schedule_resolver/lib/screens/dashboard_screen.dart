import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/ai_schedule_service.dart';
import '../models/task_model.dart';
import 'task_input_screen.dart';
import 'recommendation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleResolve(BuildContext context, AiScheduleService aiService, List<TaskModel> tasks) async {
    await aiService.analyzeSchedule(tasks);
    
    if (context.mounted) {
      if (aiService.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(aiService.errorMessage!), backgroundColor: Colors.red),
        );
      } else if (aiService.currentAnalysis != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecommendationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiService = Provider.of<AiScheduleService>(context);

    final sortedTasks = List<TaskModel>.from(scheduleProvider.tasks);
    sortedTasks.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Resolver'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (aiService.currentAnalysis != null)
              Card(
                color: Colors.green.shade100,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎉 Recommendation Ready!', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('AI has optimized your schedule.', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RecommendationScreen()),
                        ),
                        child: const Text('VIEW'),
                      )
                    ],
                  ),
                ),
              ),
            Expanded(
              child: sortedTasks.isEmpty
                  ? const Center(child: Text('No tasks added yet!'))
                  : ListView.builder(
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        final startTimeStr = "${task.startTime.hour}:${task.startTime.minute.toString().padLeft(2, '0')}";
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${task.category} | $startTimeStr"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => scheduleProvider.removeTask(task.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            if (sortedTasks.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: aiService.isLoading 
                    ? null 
                    : () => _handleResolve(context, aiService, scheduleProvider.tasks),
                  icon: aiService.isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Icon(Icons.psychology),
                  label: Text(aiService.isLoading ? 'Analyzing...' : 'Resolve Conflicts With AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskInputScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
