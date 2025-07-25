import 'package:auto_saver/models/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Saver'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Application:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              value: state.selectedProcess,
              hint: const Text('Select a running application'),
              items: state.processes
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                state.setSelectedProcess(value);
              },
            ),
            const SizedBox(height: 24),
            const Text('Save Interval (minutes):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 60,
                    divisions: 59,
                    value: state.interval.toDouble(),
                    label: '${state.interval} min',
                    onChanged: (value) {
                      state.setInterval(value);
                    },
                  ),
                ),
                Text('${state.interval} min'),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Only save when window is active'),
              value: state.onlyActiveWindow,
              onChanged: (value) {
                state.setOnlyActiveWindow(value);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.isRunning ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (state.isRunning) {
                    state.stopAutoSave();
                  } else {
                    state.startAutoSave();
                  }
                },
                child: Text(
                  state.isRunning ? 'Stop Auto-Save' : 'Start Auto-Save',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
