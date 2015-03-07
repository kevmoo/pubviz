import 'package:hop/hop.dart';
import 'package:hop_git/hop_git.dart';

void main(List<String> args) {
  addTask('pages', (ctx) => branchForDir(ctx, 'master', 'example', 'gh-pages'));

  runHop(args);
}
