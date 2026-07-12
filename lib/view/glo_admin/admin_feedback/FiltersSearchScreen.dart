import 'package:flutter/material.dart';
import 'package:glo/view/glo_admin/admin_feedback/ActivityLogScreen.dart';

class FiltersSearchScreen extends StatefulWidget {
  const FiltersSearchScreen({Key? key}) : super(key: key);

  @override
  State<FiltersSearchScreen> createState() => _FiltersSearchScreenState();
}

class _FiltersSearchScreenState extends State<FiltersSearchScreen> {
  String selectedCategory = 'All Categories';
  String selectedStatus = 'All Statuses';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Filters & Refining', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Refine by Context', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Category',
              value: selectedCategory,
              items: ['All Categories', 'Period Tracker', 'Mood Tracker', 'App Experience', 'Bug Report'],
              onChanged: (v) => setState(() => selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Pipeline Status',
              value: selectedStatus,
              items: ['All Statuses', 'New', 'In Review', 'Done'],
              onChanged: (v) => setState(() => selectedStatus = v!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D75), 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // In a real app, you would pass these filters back to the ViewModel
                  // or to the previous screen via Navigator.pop(context, filters)
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityLogScreen()));
                },
                child: const Text('Apply Processing Filters', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
