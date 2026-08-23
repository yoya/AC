# AC の構成

このアドオンをどう組み立てるかの決めごと。まだそうなっていないところは
[TODO.md](TODO.md) に分けた。

開発環境の制約（Lua 5.1、luacheck、パケット定義の場所など）は [CLAUDE.md](CLAUDE.md) にある。

位置を指すときは行番号を書かない。ファイル名と関数名で書く。

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

- 重複解消で実際に消せる行はごくわずかで、そのために全ファイルの require パスを
  書き換えることになる
- 回帰を検出する手段が乏しい。`tests/` は windower に触らないコードしか動かせない
- `.luacheckrc` の `legacy_globals` に並ぶグローバル関数は、どのディレクトリに移しても
  1 つも直らない。価値があるのは local 化であって、移動ではない
- 「新しいジョブを足す」「新しいゾーンを足す」が主な作業なので、ドメインで割れている
  今の形の方が探しやすい

配置が気持ち悪いところ（`ac/` に状態・行為・純関数・静的データ・ファイル永続化が
同居している、`io/` と `incoming/` `outgoing/` で軸が交差している）は事実だが、
それは下記 2〜5 を片付けた後に、必要なら個別に判断する。

---

## 2. 依存の向き

**require は一方向。上位モジュールへの参照を下位に注入しない。**

`contents.AC = M` のような上位の注入、`m.parent = M` の注入ループ、グローバル `__AC` が
これに反している。require グラフは非循環なのに、実行時の呼び出しだけが逆流している。

逆流の実体は「`AC.lua` が持っている業務ロジックを下から呼びたい」なので、そのロジックを
`AC.lua` から出す（下記 4）。出せば普通の下向き require になる。`job.lua` の
`M.parent.need_safety()` のように引数で渡せば済むものは引数にする。

---

## 3. 誰が `coroutine.sleep` してよいか

**これがこのアドオンの一番大きな構造的問題。**

tick は単一の coroutine で回っている（`AC.lua` の `load` で `coroutine.schedule`）。
`coroutine.sleep` はコード全体に散らばっていて、そのどれもが**アドオン全体を止める**。
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
| `io/net.target_by_mob_ex` | 14 秒（`TARGET_RETRY_MAX` × 0.7 秒） |
| `item.use_equip_item` | delay + 4 秒（指輪ワープは delay=10 なので 14 秒） |
| `io/ipc.send_party` | 0.2 秒 × アライアンス人数（最大 18）= 3.6 秒 |
| `item.safes_to_inventory_by_set` / `bags_to_inventory_by_set` | 件数 × 0.5〜1 秒 |
| `ac/move` の 1 ウェイポイント | 60 秒（到達待ちのデッドライン） |
| `zone/change` の自動移動判定 | 11 秒（判定の前の待ち合計） |
| `AC.lua` の売却ループ | 数分 |

`keyboard.push_keys` は通常 0.4 秒 × キー数で B だが、`{"enter", 5}` のように
数値の待ちを混ぜられるので上限がない。呼び出し側が決めることになる。

---

## 4. `AC.lua` に置いてよいもの

**置いてよいのは、windower のイベント登録と起動手続きだけ。**

業務ロジック（NPC トレード、ジャンクの集約・売却・廃棄、ゾーン別の idle 処理）、
tick の中身、サブコマンドの実装は `AC.lua` の外に出す。新設するモジュールと分担は
[TODO.md](TODO.md) に書いた。

### リセットは registry にしない

`M.reset()` を集めて `reset_all()` で片付ける形は取らない。実際のリセットは
5 イベントで内容も順序も違い、スコープ表を持たせると `lifecycle.lua` と同じ知識の
二重持ちになる。

| イベント | リセットするもの |
|---|---|
| load | seed, ws, zone_in, task 3 件 |
| login | seed, stat, equip |
| logout | zone_change, equip, contents の zone_override, party ×2, inspect, battle, prob, buff, task |
| job change | ws, stat, equip, task 3 件 |
| zone change | record ×2, stat, task, control.auto（リーダーのみ）, move.auto, use_* ×3, point_cheer, zone_change_handler, ws, task ×3, control の INIT_VALUES ×4, base_pos |

`lifecycle.lua` に手続きとして明示列挙する。ただし**他モジュールの内部フィールドを
外から `nil` / `{}` に戻すのはやめる**（現状 `AC.lua` の logout がやっている）。
各モジュールが自分の初期化関数を公開し、`lifecycle.lua` はそれを呼ぶ。

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

`contents.lua` の `apply` / `refresh` / `set_zone_override` が一番よくできている。

- `contents_in` / `contents_out` で enter / leave
- 有効な間だけ `incoming_text_handler` を登録し、抜ける時に外す
- ユーザ指定（`user_type`）とゾーン由来の上書き（`zone_override`）を分けて持ち、
  実効値は `refresh()` が決める

### 揃える先のフック名

```lua
M.init(ctx)     -- 登録時に 1 回
M.enter()       -- 有効化   (contents_in / zone_in)
M.leave()       -- 無効化   (contents_out / zone_out)
M.tick(player)  -- 有効な間、毎 tick
M.listeners     -- enter 中だけ自動で付け外しされるリスナ表
```

リスナ登録簿は 1 つにする。`event.lua` の「今後、イベントリスナーはここに集約する」
というコメントの通りにする。

---

## 6. データとロジックの分離

**データ定義のファイルに副作用を持たせない。** ID 表・座標データに、購読・着替え・
状態機械を持たせない。逆に、ロジック側にアイテム ID や NPC 名を直書きしない。

### 装備セット

形式が 2 系統あり、互いに変換されない。

- **item_id の優先順ツリー** — `job/*.attack_equip`。`ac/equip.equip_item_by_priority_tree` が使う
- **装備位置のスナップショット** — `ac/equip` の `equip_set` / `equip_set_bank`。
  脱衣攻撃対策で「今の装備をそのまま戻す」ためのもの

前者は 1 箇所に集める。後者は脱衣対策専用だと明記する。

### ルートデータの語彙

`zone/*.lua` の `M.routes` は要素配列。1 要素は座標か、`a="..."` のアクションか、副作用。

- 座標: `x` `y` `z` `d`（ゆらぎ半径）`desc`
- `{}`（空テーブル）= オートラン
- `a="..."`: `f8touch` `touch` `mount` `dismount` `enter` `opendoor` `f8` `esc` `wait`
  `up` `down` `tab` `insne` `sneak` `invisi` `invisi_cancel` `rmstatus` `faith`
- 副作用: `auto` `target` `t` `keys` `puller` `enemy_filter` `enemy_range`
  `faith`/`faith_list` `show` `stop` `route`

アクション名の定義は 1 箇所に置き、未知の名前は警告する。

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
- **グローバル関数を定義しない。** `.luacheckrc` の `legacy_globals` に暫定登録してある。
  `is_defensive` が `job/{BRD,COR,DNC,GEO}.lua` で 4 重定義され、最後に require された
  定義だけが生き残っていた事故がある。
  **このリストを空にすることが、構成の片付けが終わった印になる**

---

## 8. やらないと決めたこと

`io/chat.lua` と `io/console.lua` は**統合しない**。`io/console` はアドオン本体から
一度も呼ばれておらず、利用者は `tests/` と別プロセスの `script/findall.lua` だけ。
わずかな重複を消すために、本体の出力経路をテスト専用モジュールと結合させる必要はない。

「tick 毎の `get_player()` / `get_mob_by_target()` を 1 箇所にキャッシュする」
（`botsh/state.lua` がその書きかけ）も**しない**。`AC.lua` は既に `player` / `me` を
引数で明示的に渡していて、キャッシュはそれを暗黙の共有テーブルに戻す方向になる。
その上 sleep をあちこちでまたぐので、キャッシュした `target` や `me` は
sleep の後には嘘になる。

ディレクトリの層別再編（1）とリセットの registry 化（4）も同じく取らない。

---

## 9. 検証

```
$ ~/.luarocks/bin/luacheck .        # errors 0 を保つ
$ cd tests && lua run.lua           # failed 0 を保つ
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
