# TODO

[ARCHITECTURE.md](ARCHITECTURE.md) の決めごとに対して、まだそうなっていないところ。

位置は行番号で書かない。ファイル名と関数名で書く（行番号はすぐ腐る）。

---

## 手をつける順序

上ほど独立していて、単独でコミットでき、途中で止めても動く。

1. **実バグ** — 1 行〜数行で直り、回帰リスクがほぼない。目的ごとにコミットを分ける
2. **`event.lua` と `incoming/text.lua` の統合** — 2 ファイル → 1 ファイル
3. **`AC.lua` の分割** — 新規ファイルなので既存を壊さない
4. **逆参照の除去** — 3 が終われば `.AC` / `.parent` / `__AC` は引数渡しに置き換えられる
5. **sleep の分類とガードの一本化** — C の関数にコメントを付け、世代番号方式に揃える
6. **グローバル関数の local 化** — `.luacheckrc` の `legacy_globals` を空にする
7. **重複の統合**

---

## 実バグ・既知の穴

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
- ジョブ分類が `role.lua` / `job.lua` / `role/Sorcerer.lua` に三重定義され、内容も
  食い違っている（tank に DNC が居たり MNK が居たり）
- `battle.lua` は右指だけ独自に ID 直書きで付け替えていて、`attack_equip` に
  `right_ring` を持つジョブでは直後に上書きされる
- 参照ゼロの装備セット: `ac/equip.city_equip`、`ac/equip.walk_equip`
- **アクションの解釈が 2 箇所に割れている。** `ac/move.move_to_action` は移動前に効く系、
  `_auto_move_to` 内のインラインは移動後に効く系。どちらも `if p.a == "..." then` の
  連鎖で、`elseif` ですらないので全部評価される。**未知の名前は黙って無視される**
  （`f8toucb` という綴り違いが検出されずに残っていた）

---

## 依存の逆流を消す

`AC.lua` が下位モジュールに自分を注入している（`contents.AC` / `ac_move.AC` /
`io_ipc.AC` / `aczone.AC`）。`contents.lua` `zone.lua` `job.lua` `battle.lua` `pull.lua`
は下位に `m.parent = M` を注入している。さらにグローバル `__AC` があり、`zone/` の
10 ファイルほどが `__AC.contents` で読んでいる。

実行時の逆流の例:

```
contents/garden.lua      → M.parent.AC.idle_function_sell_junk_items(mob)
zone/256_WestAdoulin.lua → M.parent.AC.idle_function_sell_junk_items(mob)
io/ipc.lua               → M.AC.start() / M.AC.addon_command_handler()
zone/203_ClstFrost.lua   → __AC.contents.trial.bc_route
```

`AC.lua` の分割が終われば下向き require に直せる。引数で渡せば済むものは引数にする。

---

## `AC.lua` の分割

新設するのは以下。`X.lua` + `X/` 規約に従う。

```
loop.lua        tick / tick_serial / 再入ガード
lifecycle.lua   load / login / logout / job change / zone change の手続き
commands.lua    サブコマンドのディスパッチテーブルと help 生成
commands/       サブコマンドの実装（既存の command.lua は send のラッパなので名前を分ける）
vendor.lua      ジャンクの集約・売却・廃棄
trade.lua       NPC トレード
```

`commands.lua` は `addon_command_handler` の if-elseif をテーブルに置き換える。
1 エントリ = `{ names = {...}, help = "...", run = function(args) end }`。
help は今ハンドラ内に散っている文字列から自動生成する。

キーバインドの送信もデータとして分離する。

---

## sleep とガード

- `tick_serial` が例外で落ちると、tick を回している coroutine ごと死んでアドオンが
  リロードまで沈黙する。`AC.lua` の `tick_running` + `TICK_STUCK_SEC` はこれを直す
  つもりで入っているが、tick は while ループひとつから逐次に呼ばれるだけなので
  ガードには到達せず、働いていない。直すなら tick を毎回別の coroutine として起こし、
  時刻ベースのガードで見張る形にする
- 二重起動ガードが 4 系統ある。世代番号方式に 1 本化する

| 場所 | 今の手法 |
|---|---|
| `AC.lua` の tick | `tick_running` + `TICK_STUCK_SEC` で強制解除 |
| `ac/move.lua` | `M.auto` シングルトン + `M.auto_seq` 世代番号 |
| `zone/change.lua` | `M.auto_move_seq` 世代番号 + `is_current()` |
| `zone/256_WestAdoulin.lua` | `selljunk_running` フラグ |

- C の関数にコメント 1 行目の最大ブロック時間を付けて回る

---

## 共通フックの統一

- フック名を `init` / `enter` / `leave` / `tick` / `listeners` に揃える
- `if x.f ~= nil then x.f(...) end` が `job/*.lua` から `role/Melee` `role/Healer`
  `role/Sorcerer` を呼ぶところで多数コピーされている。`utils` に「あれば呼ぶ」
  1 関数を置いて潰す。registry は作らない
- `event.lua` と `incoming/text.lua` が同じ構造のリスナ登録簿を 2 つ持っている
  （`add_listener` / `remove_listener` / `show_listener` / `caller_info` 保持まで同型）。
  キーワード一致は「フィルタ付き購読」として一般化して 1 つにする

---

## データとロジックの分離

データ定義に副作用が入っているもの:

- `item/junk.lua` — 大きな ID 表なのに、末尾で `char update` を購読して
  `JunkItems` / `SellItemIdSet` / `JunkItemIdSet` を実行時に書き換える
- `zone/256_WestAdoulin.lua` — 座標データのはずが、着替え（カウンセラーガーブ）と
  売却の状態機械を持つ
- `zone/203_ClstFrost.lua` ほか 6 ファイル — `M.init()` で
  `__AC.contents.trial.bc_route` を自分の routes に代入する
- `contents/trial.lua` — contents 側にゾーン座標がある

ロジックに埋まっている定数:

| 場所 | 中身 |
|---|---|
| `AC.lua` | シルト / ビーズ / フェイス手引書の ID、moolah / insne の表、NPC 名、ゾーン ID |
| `battle.lua` | シュネデックリング 27590（`ac/equip` にも同じ ID がある） |
| `job.lua` | 食事名、リング名のコマンド文字列 |
| `ac/move.lua` | スニーク / インビジ / マウントのコマンド文字列、インビジのバフ ID 69 |
| `role/Leader.lua` と `mob.lua` | 敵名リスト。3 件重複している |

装備セットは `attack_equip` 系を 1 箇所に集める（今は 6 箇所に分散）。

---

## グローバル関数の local 化

`.luacheckrc` の `legacy_globals` を空にする。

---

## 重複の統合

- 距離計算 4 実装
- 指輪ワープ 2 実装
- アライアンス走査 4 箇所
- `ac/move.turn_to_front` と `ac/move.look_forward`（1 バイトも違わない）
- equip bank 取り出し 2 箇所
