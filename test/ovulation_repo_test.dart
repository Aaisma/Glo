import 'package:glo/model/ovulation_log_model.dart';
import 'package:glo/repo/ovulation_repo_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late OvulationRepoImpl repo;

  // Runs before EVERY test, so each test starts with a clean, empty database.
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = OvulationRepoImpl(firestore: fakeFirestore);
  });

  test('addLog saves the log and gives it an id', () async {
    final log = OvulationLogModel(
      id: '',
      userId: 'user1',
      date: DateTime(2023, 10, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repo.addLog(log);

    // The repo sets the id on the model after saving.
    final saved = await fakeFirestore.collection('ovulation').get();
    expect(saved.docs.length, 1);
    expect(saved.docs.first['userId'], 'user1');
  });

  test('getLogsForUser returns every log for the user', () async {
    await repo.addLog(OvulationLogModel(id: '', userId: 'user1', date: DateTime(2023, 10, 1), createdAt: DateTime.now(), updatedAt: DateTime.now()));
    await repo.addLog(OvulationLogModel(id: '', userId: 'user1', date: DateTime(2023, 10, 2), createdAt: DateTime.now(), updatedAt: DateTime.now()));

    final list = await repo.getLogsForUser('user1');

    expect(list.length, 2);
  });

  test('getLogsForUser returns an empty list when there is nothing', () async {
    final list = await repo.getLogsForUser('user1');
    expect(list, isEmpty);
  });

  test('getLogByDate returns the matching log', () async {
    final log = OvulationLogModel(
      id: 'log123',
      userId: 'user1',
      date: DateTime(2023, 10, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await fakeFirestore.collection('ovulation').doc(log.id).set(log.toMap());

    final found = await repo.getLogByDate('user1', DateTime(2023, 10, 1));

    expect(found, isA<OvulationLogModel>());
    expect(found?.id, 'log123');
  });

  test('updateLog changes the saved values', () async {
    final log = OvulationLogModel(
      id: 'log123',
      userId: 'user1',
      date: DateTime(2023, 10, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await fakeFirestore.collection('ovulation').doc(log.id).set(log.toMap());

    final updatedLog = log.copyWith(note: 'New note');
    await repo.updateLog(updatedLog);

    final found = await repo.getLogByDate('user1', DateTime(2023, 10, 1));
    expect(found?.note, 'New note');
  });

  test('deleteLog removes the log', () async {
    final log = OvulationLogModel(
      id: 'log123',
      userId: 'user1',
      date: DateTime(2023, 10, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await fakeFirestore.collection('ovulation').doc(log.id).set(log.toMap());

    await repo.deleteLog('log123');

    final list = await repo.getLogsForUser('user1');
    expect(list, isEmpty);
  });
}
