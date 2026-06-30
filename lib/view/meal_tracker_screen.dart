import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/meal_tracker_viewmodel.dart';
import '../app_colors.dart';

class MealTrackerScreen extends StatefulWidget {
  const MealTrackerScreen({super.key});

  @override
  State<MealTrackerScreen> createState() => _MealTrackerScreenState();
}

class _MealTrackerScreenState extends State<MealTrackerScreen> {
  late String userId;
  final TextEditingController _itemsController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedMealType = "Breakfast";
  final List<String> _selectedTags = [];

  final List<String> _mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];
  final List<String> _tagOptions = ["Sugar", "Dairy", "Gluten", "Processed", "Home-cooked"];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? "demo_user";
    Future.microtask(() async {
      final vm = context.read<MealTrackerViewModel>();
      await vm.loadToday(userId);
      _noteController.text = vm.note;
    });
  }

  void _showAddMealSheet() {
    _itemsController.clear();
    _selectedMealType = "Breakfast";
    _selectedTags.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add a meal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _mealTypes.map((type) {
                      final selected = _selectedMealType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        selectedColor: AppColors.pink,
                        onSelected: (_) => setSheetState(() => _selectedMealType = type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _itemsController,
                    decoration: const InputDecoration(
                      hintText: "What did you eat? e.g. Rice, dal, vegetables",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text("Tags (optional)", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _tagOptions.map((tag) {
                      final selected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: selected,
                        selectedColor: AppColors.lightPink,
                        onSelected: (_) {
                          setSheetState(() {
                            selected ? _selectedTags.remove(tag) : _selectedTags.add(tag);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pink,
                      minimumSize: const Size.fromHeight(46),
                    ),
                    onPressed: () {
                      if (_itemsController.text.trim().isEmpty) return;
                      final items = _itemsController.text.split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                      context.read<MealTrackerViewModel>().addMeal(_selectedMealType, items, List<String>.from(_selectedTags));
                      Navigator.pop(context);
                    },
                    child: const Text("Add meal", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForMeal(String type) {
    switch (type) {
      case "Breakfast": return Icons.free_breakfast;
      case "Lunch": return Icons.lunch_dining;
      case "Dinner": return Icons.dinner_dining;
      default: return Icons.cookie;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MealTrackerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Tracker"),
        backgroundColor: AppColors.pink,
        centerTitle: true,
      ),
      backgroundColor: AppColors.lightPink,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardPink,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderPink),
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant_menu, color: AppColors.pink, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${vm.meals.length} meal${vm.meals.length == 1 ? '' : 's'} logged today",
                      style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _showAddMealSheet,
              icon: const Icon(Icons.add),
              label: const Text("Add a meal"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pink,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
              ),
            ),

            const SizedBox(height: 16),

            if (vm.meals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(child: Text("No meals logged yet today", style: TextStyle(color: AppColors.grey))),
              )
            else
              Column(
                children: List.generate(vm.meals.length, (index) {
                  final meal = vm.meals[index];
                  final items = List<String>.from(meal["items"] ?? []);
                  final tags = List<String>.from(meal["tags"] ?? []);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderPink),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_iconForMeal(meal["type"]), color: AppColors.purple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meal["type"], style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                              const SizedBox(height: 4),
                              Text(items.join(", "), style: TextStyle(color: AppColors.grey, fontSize: 13)),
                              if (tags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: tags.map((t) => Chip(
                                    label: Text(t, style: const TextStyle(fontSize: 10)),
                                    backgroundColor: AppColors.lightPink,
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                          onPressed: () => vm.removeMeal(index),
                        ),
                      ],
                    ),
                  );
                }),
              ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pink)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(hintText: "Any cravings, bloating, energy levels..."),
                    maxLines: 3,
                    onChanged: vm.updateNote,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                await vm.saveToday(userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(vm.errorMessage ?? "Today's meals saved!"),
                      backgroundColor: vm.errorMessage != null ? Colors.red : null,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pink,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("Save today's entry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}