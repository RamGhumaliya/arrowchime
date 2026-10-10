import 'package:arrowchime/core/assets.dart';

/// Every sound effect of `docs/07` §2. The id is the file name; the path comes
/// from the asset catalog so changing the format needs no code change.
enum Sfx {
  uiTap('ui_tap'),
  uiBack('ui_back'),
  arrowTouch('arrow_touch'),
  arrowWhoosh('arrow_whoosh'),
  arrowBlocked('arrow_blocked'),
  heartLost('heart_lost'),
  rotatorTurn('rotator_turn'),
  gateOpen('gate_open'),
  keyCollect('key_collect'),
  iceTick('ice_tick'),
  iceBreak('ice_break'),
  portalPass('portal_pass'),
  flowUp('flow_up'),
  boardClear('board_clear'),
  star1('star_1'),
  star2('star_2'),
  star3('star_3'),
  coin('coin'),
  levelFail('level_fail'),
  fragmentRestore('fragment_restore'),
  chestOpen('chest_open'),
  dailyComplete('daily_complete'),
  purchase('purchase');

  new(this.id);

  final String id;

  String get asset => AssetCatalog.sfxPath(id);

  /// The ding for the [n]th star (1-3).
  static Sfx star(int n) => switch (n) {
    1 => star1,
    2 => star2,
    _ => star3,
  };
}
