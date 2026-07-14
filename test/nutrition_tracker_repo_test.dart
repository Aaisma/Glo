import 'package:glo/model/nutrition_entry_model.dart';
import 'package:glo/repo/nutrition_repo_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late NutritionRepoImpl repo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = NutritionRepoImpl(firestore: fakeFirestore);
  });

  test(
    'saveEntry stores the nutrition entry under the user document',
        () async {
      final entry = NutritionEntryModel(
        userId: 'user1',
        date: '2024-06-01',
        meals: [
          {
            'type': 'Breakfast',
            'items': ['Oats'],
            'tags': ['High Protein'],
          },
        ],
        note: 'Felt great',
      );

      await repo.saveEntry(entry);

      final saved = await fakeFirestore
          .collection('users')
          .doc('user1')
          .collection('meal_tracker')
          .get();

      expect(saved.docs.length, 1);
      expect(saved.docs.first.data()['note'], 'Felt great');
      expect(saved.docs.first.data()['meals'], isNotEmpty);
    },
  );

  test('getEntry returns the entry for the matching date', () async {
    final entry = NutritionEntryModel(
      userId: 'user1',
      date: '2024-06-01',
      meals: [
        {
          'type': 'Dinner',
          'items': ['Salmon'],
          'tags': ['Whole Grain'],
        },
      ],
      note: 'Balanced dinner',
    );

    await fakeFirestore
        .collection('users')
        .doc('user1')
        .collection('meal_tracker')
        .doc('2024-06-01')
        .set(entry.toMap());

    final found = await repo.getEntry('user1', '2024-06-01');

    expect(found, isNotNull);
    expect(found?.note, 'Balanced dinner');
    expect(found?.meals.first['type'], 'Dinner');
  });

  test(
    'getAllEntries returns all entries for a user in reverse chronological order',
        () async {
      await fakeFirestore
          .collection('users')
          .doc('user1')
          .collection('meal_tracker')
          .doc('2024-06-01')
          .set(
        NutritionEntryModel(
          userId: 'user1',
          date: '2024-06-01',
          meals: [],
          note: 'old',
        ).toMap(),
      );
      await fakeFirestore
          .collection('users')
          .doc('user1')
          .collection('meal_tracker')
          .doc('2024-06-02')
          .set(
        NutritionEntryModel(
          userId: 'user1',
          date: '2024-06-02',
          meals: [],
          note: 'new',
        ).toMap(),
      );

      final entries = await repo.getAllEntries('user1');

      expect(entries.length, 2);
      expect(entries.first.date, '2024-06-02');
      expect(entries.first.note, 'new');
    },
  );
}
