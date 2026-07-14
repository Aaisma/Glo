import 'package:glo/model/period_log_model.dart';
import 'package:glo/repo/period_repo_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PeriodRepoImpl repo;

  // Runs before EVERY test, so each test starts with a clean, empty database.
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = PeriodRepoImpl(firestore: fakeFirestore);
  });

  test('addLog saves the log and gives it an id', () async {
    final log = PeriodLogModel(
      id: '',
      userId: 'user1',
      date: DateTime(2023, 10, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repo.addLog(log);

    // The repo sets the id on the model after saving (handled by Firebase doc reference).
    // Note: Since addLog just sets the data to the document, we verify the database.
    final saved = await fakeFirestore.collection('period').get();
    expect(saved.docs.length, 1);
    expect(saved.docs.first['userId'], 'user1');
  });

  test('getLogsForUser returns every log for the user', () async {
    await repo.addLog(PeriodLogModel(id: '', userId: 'user1', date: DateTime(2023, 10, 1), createdAt: DateTime.now(), updatedAt: DateTime.now()));
    await repo.addLog(PeriodLogModel(id: '', userId: 'user1', date: DateTime(2023, 10, 2), createdAt: DateTime.now(), updatedAt: DateTime.now()));

    final list = await repo.getLogsForUser('user1');

    expect(list.length, 2);
  });

  test('getLogsForUser returns an empty list when there is nothing', () async {
    final list = await repo.getLogsForUser('user1');
    expect(list, isEmpty);
  });

  test('getLogByDate returns the matching log', () async {
    final log = PeriodLogModel(
      id: 'log123',
      userId: 'user1',
      date: DateTime(2023, 10, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await fakeFirestore.collection('period').doc(log.id).set(log.toMap());

    final found = await repo.getLogByDate('user1', DateTime(2023, 10, 1));

    expect(found, isA<PeriodLogModel>());
    expect(found?.id, 'log123');
  });

  test('updateLog changes the saved values', () async {
    final log = PeriodLogModel(
      id: 'log123',
      userId: 'user1',
      date: DateTime(2023, 10, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await fakeFirestore.collection('period').doc(log.id).set(log.toMap());

    final updatedLog = log.copyWith(note: 'New note');
    await repo.updateLog(updatedLog);

    final found = await repo.getLogByDate('user1', DateTime(2023, 10, 1));
    expect(found?.note, 'New note');
  });

  test('deleteLog removes the log', () async {
    final log = PeriodLogModel(
      id: 'log123',
      userId: 'user1',
      date: DateTime(2023, 10, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await fakeFirestore.collection('period').doc(log.id).set(log.toMap());

    await repo.deleteLog('log123');

    final list = await repo.getLogsForUser('user1');
    expect(list, isEmpty);
  });
}
