# AC の構成

このアドオンをどう組み立てるかの決めごと。**今そうなっている**話と、
**そうしたい**話を分けて書く。後者には「宿題」と付けた。

開発環境の制約（Lua 5.1、luacheck、パケット定義の場所など）は [CLAUDE.md](CLAUDE.md) にある。

規模の目安（zone データ 187 ファイルと `item/junk.lua` `item/empyrean.lua` の大きな ID 表を除く）:
実コード約 12600 行、モジュール約 110。うち `AC.lua` が 1419 行。

---

## 1. ファイルの置き方

**`X.lua` + `X/` を使う。** 親モジュールが `X.lua`、その下位が `X/`。

```
contents.lua + contents/    job.lua + job/       item.lua + item/
zone.lua     + zone/        battle.lua + battle/ role.lua + role/
pull.lua     + pull/        works.lua + works/   utils.lua + utils/
```

この規約は動作実績がある。`init.lua` は使わない（Windower の `package.path` に
`?/init.lua` が入っている保証がない）。

**層（core/ platform/ domain/ …）でのディレクトリ再編はしない。** 検討した結果、
このリポジトリでは割に合わないと判断した:

- 重複解消で実際に消せるのは 200 行弱（全体の 1〜2%）。そのために 294 ファイルの
  require パスを書き換えることになる
- 回帰を検出する手段が乏しい。`tests/` は windower に触らないコードしか動かせない
- `.luacheckrc` に並ぶ 70 個のグローバル関数は、どのディレクトリに移しても 1 つも直らない。
  価値があるのは local 化であって、移動ではない
- 「新しいジョブを足す」「新しいゾーンを足す」が主な作業なので、ドメインで割れている
  今の形の方が探しやすい

配置が気持ち悪いところ（`ac/` に状態・行為・純関数・静的データ・ファイル永続化が
同居している、`io/` と `incoming/` `outgoing/` で軸が交差している）は事実だが、
それは下記 2〜5 を片付けた後に、必要なら個別に判断する。

---

## 2. 依存の向き

**require は一方向。上位モジュールへの参照を下位に注入しない。**

現状これに反しているもの:

| 場所 | 形 |
|---|---|
| `AC.lua:19,63,75,85` | `contents.AC = M` / `ac_move.AC = M` / `io_ipc.AC = M` / `aczone.AC = M` |
| `contents.lua:57` `zone.lua:238` `job.lua:43` `battle.lua:30` `pull.lua:18` | `m.parent = M` の注入ループ |
| `AC.lua:6` `contents.lua:2` `zone.lua:9` | グローバル `__AC`。`zone/` の 10 ファイルが `__AC.contents` で読む |

これによって、require グラフは非循環なのに実行時の呼び出しが逆流している:

```
contents/garden.lua:29  → M.parent.AC.idle_function_sell_junk_items(mob)
zone/256_WestAdoulin    → M.parent.AC.idle_function_sell_junk_items(mob)
io/ipc.lua:105,170,196  → M.AC.start() / M.AC.addon_command_handler()
zone/203_ClstFrost.lua  → __AC.contents.trial.bc_route
```

**宿題**: 逆流の実体は「`AC.lua` が持っている業務ロジックを下から呼びたい」なので、
そのロジックを `AC.lua` から出す（下記 4）。出せば普通の下向き require になる。
`job.lua` の `M.parent.need_safety()` のように引数で渡せば済むものは引数にする。

---

## 3. 誰が `coroutine.sleep` してよいか

**これがこのアドオンの一番大きな構造的問題。**

tick は単一の coroutine で回っている（`AC.lua` の `load` で `coroutine.schedule`）。
`coroutine.sleep` は全体で 199 箇所あり、そのどれもが**アドオン全体を止める**。
tick 周期は名目値でしかない。

`pcall` で囲めない。Lua 5.1 では pcall（C 関数）の内側から `coroutine.sleep` の
yield ができず `attempt to yield across metamethod/C-call boundary` になる。
`AC.lua` の tick 再入ガードが「経過時間で強制解除」という形なのはこの為。

### 3 つに分ける

| | 定義 | tick から直接呼んでよいか |
|---|---|---|
| **A. 即時** | sleep しない。問い合わせ・判定・状態の読み書き | よい |
| **B. 短時間** | sleep するが上限 1 秒 | よい。ただし 1 tick の合計が `control.period` を超えないよう呼ぶ側が見る |
| **C. 長時間** | 1 秒を超える。上限なし | **いけない**。「起動して抜ける」形にする |

**C を呼ぶ関数は C になる。** 伝播するので、A/B のつもりの関数に C を混ぜない。

### C の呼び方

`ac/move` と `zone/change` が既にやっている形に揃える:

1. 起動側が世代番号を進め、実行中フラグを立てる（`ac_move.auto` / `M.auto_seq`）
2. 実行中は tick の該当分岐を丸ごと飛ばす（`AC.lua` の `if ac_move.auto then` がこれ）
3. 中断は世代番号の不一致で判定する（`zone/change.lua` の `is_current()` クロージャが
   一番よくできている。これを手本にする）

**宿題**: `tick_serial` が例外で落ちると、tick を回している coroutine ごと死んで
アドオンがリロードまで沈黙する。`AC.lua` の `tick_running` + `TICK_STUCK_SEC` は
これを直すつもりで入っているが、tick は while ループひとつから逐次に呼ばれるだけなので
ガードには到達せず、働いていない。直すなら tick を毎回別の coroutine として起こし、
時刻ベースのガードで見張る形にする。

**宿題**: 二重起動ガードが 4 系統ある。世代番号方式に 1 本化する。

| 場所 | 今の手法 |
|---|---|
| `AC.lua` の tick | `tick_running` + 300 秒で強制解除 |
| `ac/move.lua` | `M.auto` シングルトン + `M.auto_seq` 世代番号 |
| `zone/change.lua` | `M.auto_move_seq` 世代番号 + `is_current()` |
| `zone/256_WestAdoulin.lua` | `selljunk_running` フラグ |

### 書き方の規約

**C の関数は、コメントの 1 行目に最大ブロック時間を書く。** grep できる形にしておく。

```lua
-- 最大 14 秒ブロックする。tick から直接呼ばない
M.target_by_mob_ex = function(mob)
```

### 現状 C なのに低レイヤに置かれているもの

名前からは即時に見えるが、実際は長時間止まる:

| 関数 | 最大 |
|---|---|
| `io/net.target_by_mob_ex` | 14 秒（`TARGET_RETRY_MAX = 20` × 0.7 秒） |
| `item.use_equip_item` | delay + 4 秒（指輪ワープは delay=10 なので 14 秒） |
| `io/ipc.send_party` | 0.2 秒 × アライアンス人数（最大 18）= 3.6 秒 |
| `item.safes_to_inventory_by_set` / `bags_to_inventory_by_set` | 件数 × 0.5〜1 秒 |
| `ac/move` の 1 ウェイポイント | 60 秒（到達待ちのデッドライン） |
| `zone/change` の自動移動判定 | 11 秒（判定の前の待ち合計） |
| `AC.lua` の売却ループ | 数分（最大 80 周） |

`keyboard.push_keys` は通常 0.4 秒 × キー数で B だが、`{"enter", 5}` のように
数値の待ちを混ぜられるので上限がない。呼び出し側が決めることになる。

---

## 4. `AC.lua` に置いてよいもの

**置いてよいのは、windower のイベント登録と起動手続きだけ。**

現状 1419 行の内訳:

| 行 | 中身 | 宿題 |
|---|---|---|
| 8-102 | 33 個の require、`config.load` | 分割後は減る |
| 50-56 | キーバインド送信 | データとして分離 |
| 108-345 | NPC トレード、ジャンクの集約・売却・廃棄、ゾーン別の idle 処理 | `trade.lua` / `vendor.lua` へ |
| 347-423 | tick 再入ガードと `tick_serial` | `loop.lua` へ |
| 425-468 | `start` / `stop` / `start_party` / `stop_party` | |
| 558-807 | `cmd_garden` / `cmd_patrol` / `cmd_use` / `cmd_timer` | `commands/` へ |
| 809-1256 | `addon_command_handler`。47 サブコマンドの if-elseif 447 行 | `commands/` へ |
| 1279-1392 | 13 個の `register_event` | ここに残す |

**宿題**: 新設するのは以下。`X.lua` + `X/` 規約に従う。ファイル移動は伴わない。

```
loop.lua        tick / tick_serial / 再入ガード
lifecycle.lua   load / login / logout / job change / zone change の手続き
commands.lua    サブコマンドのディスパッチテーブルと help 生成
commands/       サブコマンドの実装（既存の command.lua は send のラッパなので名前を分ける）
vendor.lua      ジャンクの集約・売却・廃棄
trade.lua       NPC トレード
```

`commands.lua` は if-elseif をテーブルに置き換える。1 エントリ =
`{ names = {...}, help = "...", run = function(args) end }`。help は今ハンドラ内に
散っている文字列から自動生成する。

### リセットは registry にしない

`M.reset()` を集めて `reset_all()` で片付ける形は取らない。実際のリセットは
5 イベントで内容も順序も違い、スコープ表を持たせると `lifecycle.lua` と同じ知識の
二重持ちになる。

| イベント | リセットするもの |
|---|---|
| load | seed, focus, ws, zone_in, task 3 件 |
| login | seed, stat, equip, focus |
| logout | zone_change, equip, contents の zone_override, party ×2, inspect, battle, prob, task |
| job change | ws, stat, equip, task 3 件 |
| zone change | record ×2, stat, task, control.auto（リーダーのみ）, move.auto, use_* ×3, point_cheer, zone_change_handler, ws, task ×3, control の INIT_VALUES ×4, base_pos |

`lifecycle.lua` に手続きとして明示列挙する。ただし**他モジュールの内部フィールドを
外から `nil` / `{}` に戻すのはやめる**（現状 `AC.lua` の logout が 5 モジュールに対して
やっている）。各モジュールが自分の初期化関数を公開し、`lifecycle.lua` はそれを呼ぶ。

---

## 5. モジュールの共通フック

`contents.lua` / `zone.lua` / `job.lua` / `battle.lua` / `pull.lua` / `works.lua` が、
それぞれ違う規約で下位モジュールを束ねている。

| | 登録 | parent 注入 | init 呼び出し | tick 委譲 |
|---|---|---|---|---|
| `contents.lua` | `contents_table` | あり | なし | あり |
| `zone.lua` | `zone_table` | あり | `m.init(M)` | あり |
| `job.lua` | `job_table` | あり | なし | あり |
| `battle.lua` `pull.lua` | dispatch table | あり | なし | あり |
| `works.lua` | 直プロパティ | なし | なし | なし |
| `role.lua` | していない | — | — | 空 |

### 手本は `contents.lua`

`contents.lua` の `apply` / `refresh` / `set_zone_override`（94-145 行）が一番よくできている。

- `contents_in` / `contents_out` で enter / leave
- 有効な間だけ `incoming_text_handler` を登録し、抜ける時に外す
- ユーザ指定（`user_type`）とゾーン由来の上書き（`zone_override`）を分けて持ち、
  実効値は `refresh()` が決める

**宿題**: フック名を揃える。

```lua
M.init(ctx)     -- 登録時に 1 回
M.enter()       -- 有効化   (contents_in / zone_in)
M.leave()       -- 無効化   (contents_out / zone_out)
M.tick(player)  -- 有効な間、毎 tick
M.listeners     -- enter 中だけ自動で付け外しされるリスナ表
```

**宿題**: `if x.f ~= nil then x.f(...) end` が 14 箇所コピーされている
（`job/*.lua` から `role/Melee` `role/Healer` `role/Sorcerer` を呼ぶところ）。
`utils` に「あれば呼ぶ」1 関数を置いて潰す。registry は作らない。

**宿題**: `event.lua` と `incoming/text.lua` が同じ構造のリスナ登録簿を 2 つ持っている
（`add_listener` / `remove_listener` / `show_listener` / `caller_info` 保持まで同型）。
キーワード一致は「フィルタ付き購読」として一般化して 1 つにする。
`event.lua` の「今後、イベントリスナーはここに集約する」というコメントの通りにする。

### 既知の穴

- `contents_out` を実装しているモジュールが 1 つもない。`apply()` に分岐だけある
- `contents/synergy.lua` と `contents/trove.lua` の `M.zone_in` はどこからも呼ばれない
  （`contents.zone_out()` はあるが対になる `zone_in` がない）
- `npc_action_handlers` だけが現在の contents と無関係に全 contents を走査する。
  Trove のハンドラが Synergy 中でも発火する
- `role.lua` はどこからも require されていない。`role/` には呼ばれ方が真逆の 2 種類が
  同居している（`AC.lua` から直接呼ばれる `tick_idle` の Leader/Follower と、
  job から呼ばれる `main_tick`/`sub_tick` の Melee/Healer/Sorcerer）
- `pull.tick()` はどこからも呼ばれない。釣りの実体は `role/Leader.tick_idle` にある。
  `pull.lua` は `base_pos` の置き場としてのみ生きている
- ジョブ分類が `role.lua:7-11` / `job.lua:46-60` / `role/Sorcerer.lua:179-187` に
  三重定義され、内容も食い違っている（tank に DNC が居たり MNK が居たり）

---

## 6. データとロジックの分離

**データ定義のファイルに副作用を持たせない。**

破っているもの:

- `item/junk.lua` — 1081 行の ID 表なのに、末尾で `char update` を購読して
  `JunkItems` / `SellItemIdSet` / `JunkItemIdSet` を実行時に書き換える
- `zone/256_WestAdoulin.lua` — 座標データのはずが、着替え（カウンセラーガーブ 27923）と
  売却の状態機械を持つ
- `zone/203_ClstFrost.lua` ほか 6 ファイル — `M.init()` で
  `__AC.contents.trial.bc_route` を自分の routes に代入する
- `contents/trial.lua` — contents 側にゾーン座標がある

逆に、ロジックに埋まっている定数:

| 場所 | 中身 |
|---|---|
| `AC.lua` | シルト / ビーズ / フェイス手引書の ID、moolah / insne の表、NPC 名 10 種、ゾーン ID 5 種 |
| `battle.lua` | シュネデックリング 27590（`ac/equip` にも同じ ID がある） |
| `job.lua` | 食事名、リング名のコマンド文字列 |
| `ac/move.lua` | スニーク / インビジ / マウントのコマンド文字列、インビジのバフ ID 69 |
| `role/Leader.lua` と `mob.lua` | 敵名リスト。3 件重複している |

### 装備セット

形式が 2 系統あり、互いに変換されない。

- **item_id の優先順ツリー** — `job/*.battle_equip`。`ac/equip.equip_item_by_priority_tree` が使う
- **装備位置のスナップショット** — `ac/equip` の `equip_set` / `equip_set_bank`。
  脱衣攻撃対策で「今の装備をそのまま戻す」ためのもの

置き場所が 6 箇所に分散している。うち `job/COR.roll_equip`、`ac/equip.city_equip`、
`ac/equip.walk_equip` は参照ゼロ。`battle.lua` は右指だけ独自に ID 直書きで付け替えていて、
`battle_equip` に `right_ring` を持つ 14 ジョブでは直後に上書きされる。

**宿題**: 前者を 1 箇所に集め、後者は脱衣対策専用だと明記する。

### ルートデータの語彙

`zone/*.lua` の `M.routes` は要素配列。1 要素は座標か、`a="..."` のアクションか、副作用。

- 座標: `x` `y` `z` `d`（ゆらぎ半径）`desc`
- `{}`（空テーブル）= オートラン
- `a="..."`: `f8touch` `touch` `mount` `dismount` `enter` `opendoor` `f8` `esc` `wait`
  `up` `down` `tab` `insne` `sneak` `invisi` `invisi_cancel` `rmstatus` `faith`
- 副作用: `auto` `target` `t` `keys` `puller` `enemy_filter` `enemy_range`
  `faith`/`faith_list` `show` `stop` `route`

**アクションの解釈が 2 箇所に割れている。** `ac/move.move_to_action` は移動前に効く系、
`_auto_move_to` 内のインラインは移動後に効く系。どちらも `if p.a == "..." then` の連鎖で、
`elseif` ですらないので全部評価される。**未知の名前は黙って無視される**
（`f8toucb` という綴り違いが検出されずに残っていた）。

**宿題**: アクション名の定義を 1 箇所に置き、未知の名前は警告する。

`automatic_routes` のエントリは `route` 単体かその配列。条件は
`contents` / `item` / `zone_from`（正=そこから来た時のみ、負=そこから来た時は無効）/
`leader_only` / `need_level` / `disabled`。条件付きの一致を条件なしより優先する
（`zone/change.pick_route`）。

---

## 7. 命名と記法

- ファイル名・関数名・フィールド名は snake_case。`setRoleWS1` / `destTable` のような
  camelCase を新しく作らない
- `require` の別名はモジュール名と一致させる。`acitem` / `aczone` / `actask` / `acmob` の
  `ac` 接頭辞は付けない
- **グローバル関数を定義しない。** `.luacheckrc` の `legacy_globals` に 70 個ほど
  暫定登録されている。`is_defensive` が `job/{BRD,COR,DNC,GEO}.lua` で 4 重定義され、
  最後に require された定義だけが生き残っていた事故がある。
  **このリストを空にすることが、構成の片付けが終わった印になる**

---

## 8. 手をつける順序

上ほど独立していて、単独でコミットでき、途中で止めても動く。

1. **実バグ** — 1 行〜数行で直り、回帰リスクがほぼない。目的ごとにコミットを分ける
2. **`event.lua` と `incoming/text.lua` の統合** — 2 ファイル → 1 ファイル
3. **`AC.lua` の分割** — `vendor.lua` / `trade.lua` / `loop.lua` / `lifecycle.lua` /
   `commands.lua` + `commands/`。新規ファイルなので既存を壊さない
4. **逆参照の除去** — 3 が終われば `.AC` / `.parent` / `__AC` は引数渡しに置き換えられる
5. **sleep の分類とガードの一本化** — C の関数にコメントを付け、世代番号方式に揃える
6. **グローバル関数の local 化** — `.luacheckrc` の `legacy_globals` を空にする
7. **重複の統合** — 距離計算 4 実装、指輪ワープ 2 実装、アライアンス走査 4 箇所、
   `turn_to_front` と `look_forward`（1 バイトも違わない）、equip bank 取り出し 2 箇所

`io/chat.lua` と `io/console.lua` は**統合しない**。`io/console` はアドオン本体から
一度も呼ばれておらず、利用者は `tests/` 5 本と別プロセスの `script/findall.lua` だけ。
15 行の重複を消すために、本体の出力経路をテスト専用モジュールと結合させる必要はない。

「tick 毎の `get_player()` / `get_mob_by_target()` を 1 箇所にキャッシュする」
（`botsh/state.lua` がその書きかけ）も**しない**。`AC.lua` は既に `player` / `me` を
引数で明示的に渡していて、キャッシュはそれを暗黙の共有テーブルに戻す方向になる。
その上 sleep を 199 箇所でまたぐので、キャッシュした `target` や `me` は
sleep の後には嘘になる。

---

## 9. 検証

```
$ ~/.luarocks/bin/luacheck .        # 現状 34 warnings / 0 errors
$ cd tests && lua run.lua           # 5 ok / 0 failed / 3 skipped
```

`tests/run.lua` の skip リストが、そのまま「単体テストできないコード」の境界になっている。
`windower.*` を呼ぶものは WSL の lua では動かない。今テストが書けているのは
`utils/*` `io/console` `task` `prob` `ac/data` `item/junk` のような、
windower に触らない部分だけ。

ゲーム内では最低限これを通す:

- `ac start` / `ac stop`（リーダー / フォロワー両方）
- 戦闘 1 周
- `ac move` と自動移動でのゾーン遷移
- モグガーデンと西 / 東アドゥリンでの売却
- サポ無しでの `ac start`
