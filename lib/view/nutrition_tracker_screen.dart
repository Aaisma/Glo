import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/nutrition_tracker_viewmodel.dart';
import '../app_colors.dart';
import 'nutrition_history_screen.dart';

class NutritionTrackerScreen extends StatefulWidget {
  const NutritionTrackerScreen({super.key});

  @override
  State<NutritionTrackerScreen> createState() => _NutritionTrackerScreenState();
}

class _NutritionTrackerScreenState extends State<NutritionTrackerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _itemsController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _fadeController;

  final List<String> _tagOptions = [
    "Sugar-Free",
    "Dairy-Free",
    "Gluten-Free",
    "High Protein",
    "Veggies",
    "Fruit",
    "Whole Grain",
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeController.forward();

    Future.microtask(() async {
      final vm = context.read<NutritionTrackerViewModel>();
      await vm.ensureUserId();
      if (mounted) {
        _noteController.text = vm.note;
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _itemsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showAddMealSheet(String type) {
    _itemsController.clear();
    List<String> selectedTags = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightPink,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _iconForMeal(type),
                            color: AppColors.pink,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add $type",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            const Text(
                              "Skin-loving nutrition ✨",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "What are you fueling with?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _itemsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "e.g. Berry smoothie, Almonds, Salmon bowl",
                        filled: true,
                        fillColor: AppColors.cardPink,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Nutrient Focus",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _tagOptions.map((tag) {
                        final isSelected = selectedTags.contains(tag);
                        return ChoiceChip(
                          label: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.pink,
                          backgroundColor: AppColors.lightPink.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                          onSelected: (_) {
                            setSheetState(() {
                              isSelected
                                  ? selectedTags.remove(tag)
                                  : selectedTags.add(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 35),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_itemsController.text.trim().isEmpty) return;
                        final items = _itemsController.text
                            .split(",")
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();
                        context.read<NutritionTrackerViewModel>().addMeal(
                          type,
                          items,
                          List<String>.from(selectedTags),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Log to Journey 🌸",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForMeal(String type) {
    switch (type) {
      case "Breakfast":
        return Icons.spa_outlined;
      case "Lunch":
        return Icons.restaurant_outlined;
      case "Dinner":
        return Icons.eco_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionTrackerViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Nutrition Tracker",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.pink,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NutritionHistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── TOP HEADER ──
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                decoration: const BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Eat for your Glow",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${vm.meals.length} items logged today",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily Timeline",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _mealCard("Breakfast", vm),
                    _mealCard("Lunch", vm),
                    _mealCard("Dinner", vm),
                    _mealCard("Snacks", vm),

                    const SizedBox(height: 30),
                    const Text(
                      "Journal & Reflections",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      onChanged: vm.updateNote,
                      decoration: InputDecoration(
                        hintText:
                        "How's your energy? Did you notice any skin triggers today?",
                        filled: true,
                        fillColor: AppColors.cardPink,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),

                    const SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: (vm.isLoading)
                          ? null
                          : () async {
                        await vm.saveToday();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                vm.errorMessage ??
                                    "Nutrition progress saved! 🌸",
                              ),
                              backgroundColor: vm.errorMessage != null
                                  ? Colors.red
                                  : AppColors.pink,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.pink.withOpacity(0.3),
                      ),
                      child: vm.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Save Today's Log",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mealCard(String type, NutritionTrackerViewModel vm) {
    final typedMeals = vm.meals.where((m) => m["type"] == type).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderPink.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lightPink,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _iconForMeal(type),
                  color: AppColors.pink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showAddMealSheet(type),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.pink,
                  size: 28,
                ),
              ),
            ],
          ),
          if (typedMeals.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(height: 1, color: AppColors.borderPink),
            ),
            ...typedMeals.map((meal) {
              final index = vm.meals.indexOf(meal);
              final items = List<String>.from(meal["items"] ?? []);
              final tags = List<String>.from(meal["tags"] ?? []);
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items.join(", "),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text,
                            ),
                          ),
                          if (tags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 6,
                                children: tags
                                    .map(
                                      (t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightPink,
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ),
                                    ),
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.pink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => vm.removeMeal(index),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                "Waiting for your logs... 🍽️",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
