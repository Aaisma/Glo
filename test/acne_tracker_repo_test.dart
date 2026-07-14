import 'package:glo/model/acne_tracker_model.dart';
import 'package:glo/repo/acne_repo_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AcneRepoImpl repo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = AcneRepoImpl(firestore: fakeFirestore);
  });

  test('saveEntry saves data to Firestore', () async {
    final entry = AcneTrackerModel(
      userId: 'user1',
      date: '2024-06-01',
      severity: 'Mild',
      checklist: ['Washed Face Twice', 'Stayed Hydrated'],
      products: [{'name': 'Niacinamide', 'rating': 4}],
      note: 'Skin felt better today',
      imagePath: '',
    );

    await repo.saveEntry(entry);

    final saved = await fakeFirestore
        .collection('users')
        .doc('user1')
        .collection('acne_tracker')
        .get();

    expect(saved.docs.length, 1);
    expect(saved.docs.first['userId'], 'user1');
    expect(saved.docs.first['severity'], 'Mild');
  });

  test('getEntry returns the matching entry by date', () async {
    final entry = AcneTrackerModel(
      userId: 'user1',
      date: '2024-06-01',
      severity: 'Moderate',
      checklist: [],
      products: [],
      note: 'Breakout today',
      imagePath: '',
    );

    await fakeFirestore
        .collection('users')
        .doc('user1')
        .collection('acne_tracker')
        .doc('2024-06-01')
        .set(entry.toMap());

    final found = await repo.getEntry('user1', '2024-06-01');

    expect(found, isA<AcneTrackerModel>());
    expect(found?.severity, 'Moderate');
    expect(found?.note, 'Breakout today');
  });

  test('getEntry returns null when no entry exists for that date', () async {
    final found = await repo.getEntry('user1', '2024-06-01');
    expect(found, isNull);
  });

  test('getAllEntries returns every entry for the user', () async {
    final entry1 = AcneTrackerModel(userId: 'user1', date: '2024-06-01', severity: 'Clear', checklist: [], products: [], note: '', imagePath: '');
    final entry2 = AcneTrackerModel(userId: 'user1', date: '2024-06-02', severity: 'Mild', checklist: [], products: [], note: '', imagePath: '');

    await repo.saveEntry(entry1);
    await repo.saveEntry(entry2);

    final list = await repo.getAllEntries('user1');

    expect(list.length, 2);
  });

  test('getAllEntries returns empty list when nothing exists', () async {
    final list = await repo.getAllEntries('user1');
    expect(list, isEmpty);
  });

  test('saveEntry overwrites an existing entry on the same date', () async {
    final entry = AcneTrackerModel(userId: 'user1', date: '2024-06-01', severity: 'Clear', checklist: [], products: [], note: 'Original', imagePath: '');
    await repo.saveEntry(entry);

    final updated = AcneTrackerModel(userId: 'user1', date: '2024-06-01', severity: 'Severe', checklist: [], products: [], note: 'Updated note', imagePath: '');
    await repo.saveEntry(updated);

    final found = await repo.getEntry('user1', '2024-06-01');
    expect(found?.severity, 'Severe');
    expect(found?.note, 'Updated note');
  });

  test('deleteEntry removes the entry', () async {
    final entry = AcneTrackerModel(userId: 'user1', date: '2024-06-01', severity: 'Mild', checklist: [], products: [], note: '', imagePath: '');
    await repo.saveEntry(entry);

    await repo.deleteEntry('user1', '2024-06-01');

    final list = await repo.getAllEntries('user1');
    expect(list, isEmpty);
  });

  test('saveEntry saves checklist items correctly', () async {
    final checklist = ['Washed Face Twice', 'Applied Moisturizer', 'Stayed Hydrated'];
    final entry = AcneTrackerModel(userId: 'user1', date: '2024-06-01', severity: 'Clear', checklist: checklist, products: [], note: '', imagePath: '');
    await repo.saveEntry(entry);

    final found = await repo.getEntry('user1', '2024-06-01');
    expect(found?.checklist.length, 3);
    expect(found?.checklist, contains('Applied Moisturizer'));
  });

  test('saveEntry saves products with ratings correctly', () async {
    final products = [
      {'name': 'Salicylic Acid', 'rating': 5},
      {'name': 'Niacinamide', 'rating': 4},
    ];
    final entry = AcneTrackerModel(userId: 'user1', date: '2024-06-01', severity: 'Mild', checklist: [], products: products, note: '', imagePath: '');
    await repo.saveEntry(entry);

    final found = await repo.getEntry('user1', '2024-06-01');
    expect(found?.products.length, 2);
    expect(found?.products.first['name'], 'Salicylic Acid');
    expect(found?.products.first['rating'], 5);
  });
}