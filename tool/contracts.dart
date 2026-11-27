// Generates and checks everything that comes from the pinned `tripmate-contracts`
// version (EPIC-11 spec, sections 2.9 and 2.11; task MF2).
//
//   dart run tool/contracts.dart generate [--root <dir>] [--source <dir>] [--update-lock]
//   dart run tool/contracts.dart check    [--root <dir>] [--source <dir>]
//
// The pinned version is the tag in `CONTRACTS_VERSION`; `CONTRACTS_SHA` holds
// the commit the tag must resolve to (checked after fetching it). The tool builds, in a
// temporary folder, every file that comes from it:
//
//   contracts/              byte-for-byte copy of openapi.json and translations/
//   packages/tripmate_api/  the `dart-dio` client (OpenAPI Generator, then build_runner)
//   lib/l10n/*.arb          ARB files from translations/<lang>/*.json
//   lib/l10n/app_localizations*.dart, l10n.yaml   `flutter gen-l10n` and its config
//
// `generate` replaces those files in the repository. `check` compares them
// with the repository and prints every path that differs, is missing, or is
// extra; it exits 1 when there is any.
//
// --root    the repository (default: the current directory).
// --source  a local folder laid out like `tripmate-contracts` (openapi.json,
//           translations/<lang>/*.json), used instead of fetching the tag.
// --update-lock  (generate only) resolve the generated client's build tools
//           afresh and write `tool/generator.pubspec.lock`. Otherwise that
//           committed lock is used with `--enforce-lockfile`, so the build
//           tools never float.
//
// Needs Java 17 or later (JAVA_HOME or `java` on PATH) for OpenAPI Generator,
// `git` to fetch the tag, and network access to pub.dev for build_runner.
// Nothing here depends on the time or the machine: the same inputs give the
// same files.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// The OpenAPI Generator release, released 2025-10-29. Change the three
/// values together; the SHA-256 is of the jar at [_generatorUrl].
const _generatorVersion = '7.17.0';
const _generatorUrl =
    'https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/'
    '$_generatorVersion/openapi-generator-cli-$_generatorVersion.jar';
const _generatorSha256 =
    '25d6bd8273dd2be99979d544b62ea43f0ce1975f1aa582678b5093d1e7fcfce8';

const _contractsRepository =
    'https://github.com/huynguyennang-agilityio/tripmate-contracts.git';

/// Exact versions of the build tools of the generated package, so a new
/// release of them never changes the generated code by itself.
const _pinnedBuildTools = {
  'build_runner': '2.7.1',
  'copy_with_extension_gen': '7.1.0',
  'json_serializable': '6.11.2',
};

/// The committed lock of the generated client's workspace, relative to the
/// root. It pins the transitive build tools that [_pinnedBuildTools] do not.
const _generatorLockPath = 'tool/generator.pubspec.lock';

const _clientPath = 'packages/tripmate_api';
const _l10nDir = 'lib/l10n';

/// The files the tool owns in a repository, relative to its root. A folder
/// ends with `/`.
const _owned = ['contracts/', '$_clientPath/', '$_l10nDir/', 'l10n.yaml'];

/// Never compared: made by `dart pub get` in a folder of the client.
const _ignoredNames = {'.dart_tool', 'pubspec.lock', 'build'};

Future<void> main(List<String> args) async {
  try {
    exitCode = await _run(args);
  } on _ToolError catch (error) {
    stderr.writeln('contracts: ${error.message}');
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln(
      'contracts: file error: ${error.message} ${error.path ?? ''} '
      '(${error.osError?.message ?? 'no details'}).',
    );
    exitCode = 2;
  } on IOException catch (error) {
    stderr.writeln('contracts: network or I/O error: $error');
    exitCode = 2;
  } on FormatException catch (error) {
    stderr.writeln('contracts: malformed input: ${error.message}');
    exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('contracts: unexpected failure: $error');
    exitCode = 2;
  }
  // Exit explicitly: an open socket or a stray timer must never keep the
  // process (and the CI job) alive after the tool is done.
  await stdout.flush();
  await stderr.flush();
  exit(exitCode);
}

class _ToolError implements Exception {
  _ToolError(this.message);
  final String message;
}

Future<int> _run(List<String> args) async {
  if (args.isEmpty || args.first == '--help' || args.first == '-h') {
    stdout.writeln(
      'Usage: dart run tool/contracts.dart <generate|check> '
      '[--root <dir>] [--source <dir>]',
    );
    return args.isEmpty ? 2 : 0;
  }
  final command = args.first;
  if (command != 'generate' && command != 'check') {
    throw _ToolError('Unknown command "$command" (use generate or check).');
  }
  String? root;
  String? source;
  var updateLock = false;
  for (var i = 1; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--update-lock' && command == 'generate') {
      updateLock = true;
    } else if ((arg == '--root' || arg == '--source') && i + 1 < args.length) {
      if (arg == '--root') {
        root = args[++i];
      } else {
        source = args[++i];
      }
    } else {
      throw _ToolError('Unknown or incomplete option "$arg".');
    }
  }

  final rootDir = Directory(root ?? '.').absolute;
  final versionFile = File('${rootDir.path}/CONTRACTS_VERSION');
  if (!versionFile.existsSync()) {
    throw _ToolError('${versionFile.path} does not exist.');
  }
  final version = versionFile.readAsStringSync().trim();
  final lockFile = File('${rootDir.path}/$_generatorLockPath');
  if (!updateLock && !lockFile.existsSync()) {
    throw _ToolError(
      '${lockFile.path} does not exist. Run '
      '"dart run tool/contracts.dart generate --update-lock" and commit it.',
    );
  }

  final temp = Directory.systemTemp.createTempSync('tripmate_contracts_');
  try {
    final sourceDir = source != null
        ? Directory(source).absolute
        : await _fetchTag(
            version,
            _readSha(rootDir),
            Directory('${temp.path}/source'),
          );
    final out = Directory('${temp.path}/out')..createSync();
    final work = Directory('${temp.path}/work');
    await _generateAll(sourceDir, out, work, lockFile, updateLock);

    if (command == 'generate') {
      _install(out, rootDir);
      if (updateLock) {
        File('${work.path}/client.pubspec.lock').copySync(lockFile.path);
      }
      stdout.writeln('Generated from $version into ${rootDir.path}.');
      return 0;
    }
    final problems = _compare(out, rootDir);
    if (problems.isEmpty) {
      stdout.writeln('The generated files match $version.');
      return 0;
    }
    for (final problem in problems) {
      stdout.writeln(problem);
    }
    stdout.writeln(
      'Generated files do not match $version. Run '
      '"dart run tool/contracts.dart generate" and commit the result.',
    );
    return 1;
  } finally {
    temp.deleteSync(recursive: true);
  }
}

// ---------------------------------------------------------------------------
// Fetching the pinned tag
// ---------------------------------------------------------------------------

/// The commit `CONTRACTS_SHA` pins: 40 hex digits on one line.
String _readSha(Directory root) {
  final file = File('${root.path}/CONTRACTS_SHA');
  if (!file.existsSync()) {
    throw _ToolError('${file.path} does not exist (the commit of the tag).');
  }
  final sha = file.readAsStringSync().trim();
  if (!RegExp(r'^[0-9a-f]{40}$').hasMatch(sha)) {
    throw _ToolError('${file.path} must hold a full 40-digit commit SHA.');
  }
  return sha;
}

Future<Directory> _fetchTag(String tag, String sha, Directory into) async {
  await _exec('git', [
    'clone',
    '--quiet',
    '--depth',
    '1',
    '--branch',
    tag,
    _contractsRepository,
    into.path,
  ], what: 'fetching $tag of tripmate-contracts');
  final head = await Process.run('git', ['-C', into.path, 'rev-parse', 'HEAD']);
  final actual = '${head.stdout}'.trim();
  if (head.exitCode != 0 || actual != sha) {
    throw _ToolError(
      'The tag $tag resolves to ${actual.isEmpty ? 'an unknown commit' : actual}, '
      'but CONTRACTS_SHA pins $sha. The tag was moved or CONTRACTS_SHA is '
      'wrong; nothing was generated.',
    );
  }
  return into;
}

// ---------------------------------------------------------------------------
// Generating
// ---------------------------------------------------------------------------

Future<void> _generateAll(
  Directory source,
  Directory out,
  Directory work,
  File lockFile,
  bool updateLock,
) async {
  work.createSync(recursive: true);
  _copyContracts(source, out);
  _writeArb(out);
  await _generateLocalizations(out, work);
  await _generateClient(out, work, lockFile, updateLock);
}

/// A byte-for-byte copy of `openapi.json` and `translations/`.
void _copyContracts(Directory source, Directory out) {
  final openapi = File('${source.path}/openapi.json');
  if (!openapi.existsSync()) {
    throw _ToolError('${openapi.path} does not exist.');
  }
  Directory('${out.path}/contracts').createSync(recursive: true);
  openapi.copySync('${out.path}/contracts/openapi.json');
  final translations = Directory('${source.path}/translations');
  if (!translations.existsSync()) {
    throw _ToolError('${translations.path} does not exist.');
  }
  for (final file in _filesUnder(translations)) {
    final relative = _relative(translations, file);
    if (!relative.endsWith('.json')) {
      continue;
    }
    final target = File('${out.path}/contracts/translations/$relative');
    target.parent.createSync(recursive: true);
    file.copySync(target.path);
  }
}

/// `app_<lang>.arb` from `contracts/translations/<lang>/*.json`: a key
/// `area.snake_name` becomes `areaSnakeName`; values are copied unchanged.
void _writeArb(Directory out) {
  final translations = Directory('${out.path}/contracts/translations');
  final languages =
      translations
          .listSync()
          .whereType<Directory>()
          .map((dir) => dir.uri.pathSegments.lastWhere((s) => s.isNotEmpty))
          .toList()
        ..sort();
  if (!languages.contains('en')) {
    throw _ToolError('translations/en is missing (it is the ARB template).');
  }
  Directory('${out.path}/$_l10nDir').createSync(recursive: true);
  for (final lang in languages) {
    final files =
        Directory('${translations.path}/$lang')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    final arb = <String, String>{};
    final sourceOf = <String, String>{};
    for (final file in files) {
      final Object? messages;
      try {
        messages = jsonDecode(file.readAsStringSync());
      } on FormatException catch (error) {
        throw _ToolError('${file.path} is not valid JSON: ${error.message}');
      }
      if (messages is! Map<String, dynamic>) {
        throw _ToolError('${file.path} is not a JSON object.');
      }
      for (final entry in messages.entries) {
        final key = _arbKey(entry.key);
        if (sourceOf.containsKey(key)) {
          throw _ToolError(
            'Keys "${sourceOf[key]}" and "${entry.key}" both become the ARB '
            'key "$key" in $lang.',
          );
        }
        sourceOf[key] = entry.key;
        final value = entry.value;
        if (value is! String) {
          throw _ToolError(
            'The translation "${entry.key}" in ${file.path} is not a string '
            '(${value.runtimeType}).',
          );
        }
        arb[key] = value;
      }
    }
    File(
      '${out.path}/$_l10nDir/app_$lang.arb',
    ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(arb)}\n');
  }
}

/// `auth.not_signed_in` -> `authNotSignedIn`.
String _arbKey(String key) {
  final parts = key.split(RegExp(r'[._]')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) {
    throw _ToolError('The translation key "$key" has no name.');
  }
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

Future<void> _generateLocalizations(Directory out, Directory work) async {
  const config = '''
# Generated by tool/contracts.dart. Do not edit.
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n
nullable-getter: false
format: true
''';
  File('${out.path}/l10n.yaml').writeAsStringSync(config);

  // gen-l10n runs in its own folder, so nothing else of `out` is touched.
  final project = Directory('${work.path}/l10n')..createSync();
  File('${project.path}/pubspec.yaml').writeAsStringSync(
    'name: tripmate_mobile\nenvironment:\n  sdk: ^3.10.0\nflutter:\n  generate: true\n',
  );
  File('${out.path}/l10n.yaml').copySync('${project.path}/l10n.yaml');
  copyDirectory(
    Directory('${out.path}/$_l10nDir'),
    Directory('${project.path}/$_l10nDir'),
  );
  await _exec(
    _flutter(),
    ['gen-l10n'],
    workingDirectory: project.path,
    what: 'flutter gen-l10n',
  );
  for (final file in _filesUnder(Directory('${project.path}/$_l10nDir'))) {
    final relative = _relative(Directory('${project.path}/$_l10nDir'), file);
    final target = File('${out.path}/$_l10nDir/$relative');
    target.parent.createSync(recursive: true);
    file.copySync(target.path);
  }
}

Future<void> _generateClient(
  Directory out,
  Directory work,
  File lockFile,
  bool updateLock,
) async {
  final jar = await _generatorJar();
  final generated = Directory('${work.path}/client');
  await _exec(
    _java(),
    [
      '-jar',
      jar.path,
      'generate',
      '--generator-name',
      'dart-dio',
      '--input-spec',
      '${out.path}/contracts/openapi.json',
      '--output',
      generated.path,
      '--global-property',
      'apis,models,supportingFiles,apiTests=false,apiDocs=false,'
          'modelTests=false,modelDocs=false',
      '--additional-properties',
      'pubName=tripmate_api,pubVersion=0.0.0,serializationLibrary=json_serializable,'
          'pubDescription=The TripMate API client generated from tripmate-contracts,'
          'pubHomepage=https://github.com/huynguyennang-agilityio/tripmate-contracts',
    ],
    what: 'OpenAPI Generator',
    environment: const {'JAVA_TOOL_OPTIONS': '-Duser.language=en'},
  );

  _pinBuildTools(File('${generated.path}/pubspec.yaml'));
  final dart = Platform.resolvedExecutable;
  if (!updateLock) {
    lockFile.copySync('${generated.path}/pubspec.lock');
  }
  await _exec(
    dart,
    ['pub', 'get', if (!updateLock) '--enforce-lockfile'],
    workingDirectory: generated.path,
    what: 'dart pub get (client)',
  );
  await _exec(
    dart,
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: generated.path,
    what: 'build_runner (client)',
  );
  // One formatter for every generated file, whatever dart_style build_runner
  // resolved to.
  await _exec(
    dart,
    ['format', 'lib'],
    workingDirectory: generated.path,
    what: 'dart format (client)',
  );

  if (updateLock) {
    // Kept for `generate --update-lock`, which copies it to the repository.
    File(
      '${generated.path}/pubspec.lock',
    ).copySync('${work.path}/client.pubspec.lock');
  }
  for (final name in _ignoredNames) {
    final entity = FileSystemEntity.typeSync('${generated.path}/$name');
    if (entity == FileSystemEntityType.directory) {
      Directory('${generated.path}/$name').deleteSync(recursive: true);
    } else if (entity == FileSystemEntityType.file) {
      File('${generated.path}/$name').deleteSync();
    }
  }
  copyDirectory(generated, Directory('${out.path}/$_clientPath'));
}

/// Pins the build tools of the generated pubspec.yaml to exact versions and
/// raises its Dart language version.
void _pinBuildTools(File pubspec) {
  var text = pubspec.readAsStringSync();
  _pinnedBuildTools.forEach((name, version) {
    final pattern = RegExp('^  $name:.*\$', multiLine: true);
    if (!pattern.hasMatch(text)) {
      throw _ToolError('The generated pubspec.yaml has no $name to pin.');
    }
    text = text.replaceFirst(pattern, '  $name: $version');
  });
  // json_serializable writes null-aware elements (`'a': ?instance.a`), which
  // need language version 3.8 or later; the app is on Dart 3.10.
  const sdkLine = "  sdk: '>=3.10.0 <4.0.0'";
  final sdk = RegExp(r'^  sdk: .*$', multiLine: true);
  if (!sdk.hasMatch(text)) {
    throw _ToolError('The generated pubspec.yaml has no sdk constraint.');
  }
  text = text.replaceFirst(sdk, sdkLine);
  pubspec.writeAsStringSync(text);
}

// ---------------------------------------------------------------------------
// The OpenAPI Generator jar
// ---------------------------------------------------------------------------

/// The jar, downloaded once into a cache outside the repository and checked
/// against [_generatorSha256] every time.
Future<File> _generatorJar() async {
  final cache = Directory(_cacheDir())..createSync(recursive: true);
  final jar = File(
    '${cache.path}/openapi-generator-cli-$_generatorVersion.jar',
  );
  if (jar.existsSync() && _sha256(jar) == _generatorSha256) {
    return jar;
  }
  stdout.writeln('Downloading OpenAPI Generator $_generatorVersion ...');
  // A file of its own per run, so parallel runs (the test files run in
  // parallel) never write the same file; the rename below is atomic.
  final partial = File(
    '${jar.path}.$pid.${DateTime.now().microsecondsSinceEpoch}.part',
  );
  try {
    await _download(partial);
    final actual = _sha256(partial);
    if (actual != _generatorSha256) {
      throw _ToolError(
        'The OpenAPI Generator jar has SHA-256 $actual, expected '
        '$_generatorSha256. It was not used.',
      );
    }
    try {
      partial.renameSync(jar.path);
    } on FileSystemException {
      // Another run may have put the same, checked jar there first.
      if (!(jar.existsSync() && _sha256(jar) == _generatorSha256)) {
        rethrow;
      }
    }
  } finally {
    if (partial.existsSync()) {
      partial.deleteSync();
    }
  }
  return jar;
}

const _downloadAttempts = 4;

/// Downloads [_generatorUrl] into [target]. Retries on HTTP 429, HTTP 5xx,
/// and socket or timeout errors, waiting 2, 4, and 8 seconds (or the
/// `Retry-After` of the answer when it is at most 30 seconds); any other
/// answer fails at once. The body of an answer that is not used is drained
/// and the client is closed with `force`, so no socket keeps the process
/// alive.
Future<void> _download(File target) async {
  String? lastFailure;
  for (var attempt = 1; attempt <= _downloadAttempts; attempt++) {
    var wait = Duration(seconds: 1 << attempt);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.getUrl(Uri.parse(_generatorUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final sink = target.openWrite();
        try {
          await response.timeout(const Duration(minutes: 5)).pipe(sink);
        } finally {
          await sink.close().catchError((Object _) {});
        }
        return;
      }
      await response.drain<void>();
      final status = response.statusCode;
      if (status != 429 && status < 500) {
        throw _ToolError('Downloading $_generatorUrl failed: HTTP $status.');
      }
      lastFailure = 'HTTP $status';
      final seconds = int.tryParse(response.headers.value('retry-after') ?? '');
      if (seconds != null && seconds >= 0 && seconds <= 30) {
        wait = Duration(seconds: seconds);
      }
    } on IOException catch (error) {
      lastFailure = '$error';
    } on TimeoutException catch (error) {
      lastFailure = '$error';
    } finally {
      client.close(force: true);
    }
    if (attempt < _downloadAttempts) {
      stderr.writeln(
        'contracts: download attempt $attempt failed ($lastFailure); '
        'retrying in ${wait.inSeconds} s.',
      );
      await Future<void>.delayed(wait);
    }
  }
  throw _ToolError(
    'Downloading $_generatorUrl failed after $_downloadAttempts attempts '
    '(last: $lastFailure). Try again later, or put the jar with SHA-256 '
    '$_generatorSha256 into the cache folder (TRIPMATE_CACHE_DIR).',
  );
}

String _sha256(File file) => sha256.convert(file.readAsBytesSync()).toString();

String _cacheDir() {
  final env = Platform.environment;
  final explicit = env['TRIPMATE_CACHE_DIR'];
  if (explicit != null && explicit.isNotEmpty) {
    return explicit;
  }
  if (Platform.isWindows) {
    final base = env['LOCALAPPDATA'] ?? env['USERPROFILE'] ?? '.';
    return '$base\\tripmate\\cache';
  }
  final xdg = env['XDG_CACHE_HOME'];
  if (xdg != null && xdg.isNotEmpty) {
    return '$xdg/tripmate';
  }
  return '${env['HOME'] ?? '.'}/.cache/tripmate';
}

// ---------------------------------------------------------------------------
// Programs
// ---------------------------------------------------------------------------

String _java() {
  final home = Platform.environment['JAVA_HOME'];
  if (home != null && home.isNotEmpty) {
    final java = File('$home/bin/java${Platform.isWindows ? '.exe' : ''}');
    if (java.existsSync()) {
      return java.path;
    }
  }
  return 'java';
}

/// The `flutter` that matches the running `dart`: the SDK of `dart run`
/// lives at `<flutter>/bin/cache/dart-sdk/bin/dart`.
String _flutter() {
  final suffix = Platform.isWindows ? '.bat' : '';
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6; i++) {
    final candidate = File('${dir.path}/flutter$suffix');
    if (candidate.existsSync() && dir.path.endsWith('bin')) {
      return candidate.path;
    }
    dir = dir.parent;
  }
  return 'flutter$suffix';
}

Future<void> _exec(
  String executable,
  List<String> arguments, {
  required String what,
  String? workingDirectory,
  Map<String, String> environment = const {},
}) async {
  final ProcessResult result;
  try {
    result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: Platform.isWindows,
    );
  } on ProcessException catch (error) {
    final hint = executable.endsWith('java') || executable.contains('java')
        ? ' Java 17 or later is needed: set JAVA_HOME or put java on PATH.'
        : '';
    throw _ToolError('Cannot run $what ($executable): ${error.message}.$hint');
  }
  if (result.exitCode != 0) {
    stderr
      ..writeln(result.stdout)
      ..writeln(result.stderr);
    throw _ToolError('$what failed with exit code ${result.exitCode}.');
  }
}

// ---------------------------------------------------------------------------
// Files
// ---------------------------------------------------------------------------

/// Every file under [dir], sorted, skipping [_ignoredNames].
List<File> _filesUnder(Directory dir) {
  final files = <File>[];
  void walk(Directory current) {
    for (final entity in current.listSync(followLinks: false)) {
      final name = entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
      if (_ignoredNames.contains(name)) {
        continue;
      }
      if (entity is Directory) {
        walk(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }
  }

  if (dir.existsSync()) {
    walk(dir);
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

String _relative(Directory base, File file) {
  final basePath = base.absolute.path.replaceAll(r'\', '/');
  final filePath = file.absolute.path.replaceAll(r'\', '/');
  final prefix = basePath.endsWith('/') ? basePath : '$basePath/';
  return filePath.substring(prefix.length);
}

void copyDirectory(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final file in _filesUnder(from)) {
    final target = File('${to.path}/${_relative(from, file)}');
    target.parent.createSync(recursive: true);
    file.copySync(target.path);
  }
}

/// The paths (relative to the root, `/` separators) of every owned file in
/// [dir].
Map<String, File> _ownedFiles(Directory dir) {
  final files = <String, File>{};
  for (final owned in _owned) {
    if (owned.endsWith('/')) {
      for (final file in _filesUnder(Directory('${dir.path}/$owned'))) {
        files[_relative(dir, file)] = file;
      }
    } else {
      final file = File('${dir.path}/$owned');
      if (file.existsSync()) {
        files[owned] = file;
      }
    }
  }
  return files;
}

List<String> _compare(Directory generated, Directory root) {
  final expected = _ownedFiles(generated);
  final actual = _ownedFiles(root);
  final problems = <String>[];
  for (final path in expected.keys.toList()..sort()) {
    final file = actual[path];
    if (file == null) {
      problems.add('missing: $path');
    } else if (!_sameBytes(expected[path]!, file)) {
      problems.add('differs: $path');
    }
  }
  for (final path in actual.keys.toList()..sort()) {
    if (!expected.containsKey(path)) {
      problems.add('extra: $path');
    }
  }
  return problems;
}

bool _sameBytes(File a, File b) {
  final x = a.readAsBytesSync();
  final y = b.readAsBytesSync();
  if (x.length != y.length) {
    return false;
  }
  for (var i = 0; i < x.length; i++) {
    if (x[i] != y[i]) {
      return false;
    }
  }
  return true;
}

/// Replaces the owned files of [root] with those of [generated].
void _install(Directory generated, Directory root) {
  for (final owned in _owned) {
    if (owned.endsWith('/')) {
      final dir = Directory('${root.path}/$owned');
      if (dir.existsSync()) {
        for (final file in _filesUnder(dir)) {
          file.deleteSync();
        }
      }
    } else {
      final file = File('${root.path}/$owned');
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
  for (final entry in _ownedFiles(generated).entries) {
    final target = File('${root.path}/${entry.key}');
    target.parent.createSync(recursive: true);
    entry.value.copySync(target.path);
  }
}
