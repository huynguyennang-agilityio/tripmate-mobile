// Helpers for the MF2 tests of `dart run tool/contracts.dart check`
// (test/INTERFACE.md, "The generate and check tool").
//
// Each test copies the repository into a temporary directory, changes one
// thing, and runs the check against it with `--root` and `--source`. The
// source is a temporary copy of the pinned tag's files from
// test/fixtures/<tag>/, so no test needs the network for the contract.
//
// The check generates the client with OpenAPI Generator, which needs Java.
// When neither JAVA_HOME nor a working `java` is set, the JDK bundled with
// Android Studio on macOS is used.

import 'dart:io';

import 'contracts.dart';

/// Directory names never copied: build output, tool caches, and Git.
const _skipped = {'build', '.dart_tool', '.git'};

/// Copies [from] into [to], leaving out the directories of [_skipped].
void copyTree(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final entity in from.listSync(followLinks: false)) {
    final name = entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    final target = '${to.path}/$name';
    if (entity is Directory) {
      if (_skipped.contains(name)) {
        continue;
      }
      copyTree(entity, Directory(target));
    } else if (entity is File) {
      entity.copySync(target);
    } else if (entity is Link) {
      Link(target).createSync(entity.targetSync());
    }
  }
}

/// A new temporary directory; each test deletes its own.
Directory tempDir(String prefix) => Directory.systemTemp.createTempSync(prefix);

/// A temporary copy of the repository.
Directory copyRepo() {
  final dir = tempDir('mf2_repo_');
  copyTree(repoRoot, dir);
  return dir;
}

/// A temporary copy of the pinned tag's files, laid out like
/// `tripmate-contracts`.
Directory copyPinnedSource() {
  final dir = tempDir('mf2_source_');
  copyTree(pinnedFixtureDir(), dir);
  return dir;
}

/// The environment for the check, with a JDK.
Map<String, String> _environment() {
  final env = Map<String, String>.of(Platform.environment);
  if ((env['JAVA_HOME'] ?? '').isNotEmpty) {
    return env;
  }
  var javaWorks = false;
  try {
    javaWorks = Process.runSync('java', ['-version']).exitCode == 0;
  } on ProcessException {
    javaWorks = false;
  }
  const studioJdk =
      '/Applications/Android Studio.app/Contents/jbr/Contents/Home';
  if (!javaWorks && Directory(studioJdk).existsSync()) {
    env['JAVA_HOME'] = studioJdk;
    env['PATH'] = '$studioJdk/bin:${env['PATH'] ?? ''}';
  }
  return env;
}

/// The `dart` of the Flutter SDK that runs the tests, else `dart` on PATH.
String _dart() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    final dart = File('$flutterRoot/bin/dart');
    if (dart.existsSync()) {
      return dart.path;
    }
  }
  return 'dart';
}

/// The result of one run of the check.
class CheckRun {
  CheckRun(this.exitCode, this.output);

  final int exitCode;

  /// Standard output and standard error together.
  final String output;

  @override
  String toString() => 'exit $exitCode\n$output';
}

/// Runs `dart run tool/contracts.dart check --root <root> --source <source>`
/// from the repository.
Future<CheckRun> runCheck({
  required Directory root,
  required Directory source,
}) async {
  final result = await Process.run(
    _dart(),
    [
      'run',
      'tool/contracts.dart',
      'check',
      '--root',
      root.path,
      '--source',
      source.path,
    ],
    workingDirectory: repoRoot.path,
    environment: _environment(),
  );
  return CheckRun(result.exitCode, '${result.stdout}\n${result.stderr}');
}

/// The path of [file] relative to [root], with `/` separators.
String relativePath(Directory root, File file) {
  final rootPath = root.absolute.path.replaceAll(r'\', '/');
  final filePath = file.absolute.path.replaceAll(r'\', '/');
  final prefix = rootPath.endsWith('/') ? rootPath : '$rootPath/';
  if (!filePath.startsWith(prefix)) {
    throw StateError('${file.path} is not under ${root.path}');
  }
  return filePath.substring(prefix.length);
}

/// Appends a line to [file], so it no longer matches what the check
/// generates.
void tamper(File file) {
  file.writeAsStringSync(
    '${file.readAsStringSync()}\n// tampered by an MF2 test\n',
  );
}
