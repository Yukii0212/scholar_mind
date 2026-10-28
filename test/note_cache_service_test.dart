import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/notes/services/file_cache_service.dart';

void main() {
  late Directory cacheDirectory;

  setUp(() async {
    cacheDirectory = await Directory.systemTemp.createTemp(
      'scholar_mind_note_cache_',
    );
    FileCacheService.setCacheDirectoryForTesting(cacheDirectory);
  });

  tearDown(() async {
    FileCacheService.setCacheDirectoryForTesting(null);

    if (await cacheDirectory.exists()) {
      await cacheDirectory.delete(recursive: true);
    }
  });

  test('cache filenames cannot escape the note cache directory', () async {
    final outsideDirectory = await Directory.systemTemp.createTemp(
      'scholar_mind_note_cache_outside_',
    );
    addTearDown(() async {
      if (await outsideDirectory.exists()) {
        await outsideDirectory.delete(recursive: true);
      }
    });
    final outsideFile = File('${outsideDirectory.path}/escaped.txt');

    final cachedFile = await FileCacheService.saveBytes(
      storagePath: 'users/account-a/notes/note-a/source.txt',
      fileName: outsideFile.path,
      bytes: const [1, 2, 3],
    );

    expect(await cachedFile.exists(), isTrue);
    expect(
      cachedFile.absolute.path.startsWith('${cacheDirectory.absolute.path}/'),
      isTrue,
    );
    expect(await outsideFile.exists(), isFalse);
  });

  test('relative traversal and Windows separators are sanitized', () async {
    final cachedFile = await FileCacheService.saveBytes(
      storagePath: 'users/account-a/notes/note-a/source.txt',
      fileName: r'..\..\private/secret.txt',
      bytes: const [4, 5, 6],
    );

    expect(await cachedFile.exists(), isTrue);
    expect(cachedFile.path, isNot(contains('/../')));
    expect(cachedFile.path, isNot(contains(r'\')));
    expect(
      cachedFile.absolute.path.startsWith('${cacheDirectory.absolute.path}/'),
      isTrue,
    );
  });

  test('non-success HTTP responses are rejected without caching', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      request.response.statusCode = HttpStatus.forbidden;
      request.response.write('permission denied');
      await request.response.close();
    });

    final download = FileCacheService.downloadFromUrl(
      storagePath: 'users/account-a/notes/note-a/source.txt',
      fileName: 'source.txt',
      url: Uri.parse('http://${server.address.host}:${server.port}/note'),
    );

    await expectLater(download, throwsA(isA<HttpException>()));
    expect(
      await FileCacheService.exists(
        'users/account-a/notes/note-a/source.txt',
        'source.txt',
      ),
      isFalse,
    );
  });

  test('successful HTTP responses are cached', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      request.response.statusCode = HttpStatus.ok;
      request.response.add(const [7, 8, 9]);
      await request.response.close();
    });

    final file = await FileCacheService.downloadFromUrl(
      storagePath: 'users/account-a/notes/note-a/source.txt',
      fileName: 'source.txt',
      url: Uri.parse('http://${server.address.host}:${server.port}/note'),
    );

    expect(await file.readAsBytes(), const [7, 8, 9]);
  });

  test('clearing one account preserves another account cache', () async {
    final accountAFile = await FileCacheService.saveBytes(
      storagePath: 'users/account-a/notes/note-a/source.txt',
      fileName: 'source.txt',
      bytes: const [1],
    );
    final accountBFile = await FileCacheService.saveBytes(
      storagePath: 'users/account-b/notes/note-b/source.txt',
      fileName: 'source.txt',
      bytes: const [2],
    );
    final legacyA = Directory(
      '${cacheDirectory.path}/users_account-a_notes_legacy',
    );
    final legacyB = Directory(
      '${cacheDirectory.path}/users_account-b_notes_legacy',
    );
    await legacyA.create(recursive: true);
    await legacyB.create(recursive: true);

    await FileCacheService.clearUserCache('account-a');

    expect(await accountAFile.exists(), isFalse);
    expect(await accountBFile.exists(), isTrue);
    expect(await legacyA.exists(), isFalse);
    expect(await legacyB.exists(), isTrue);
  });
}
