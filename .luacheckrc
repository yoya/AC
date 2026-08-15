-- luacheck 設定 (Windower4 addon "AC")
--
--   $ luarocks install luacheck
--   $ luacheck .
--
-- Windower4 は Lua 5.1 (LuaJIT) 相当。

std = "lua51+windower"

--------------------------------------------------------------------
-- Windower が提供するグローバル / 標準ライブラリ拡張
--------------------------------------------------------------------
stds.windower = {
    read_globals = {
	windower = { other_fields = true },  -- windower.ffxi.* / windower.packets.* 等
	_libs    = { other_fields = true },
	-- Windower の libs が標準ライブラリに生やす拡張メソッド
	math      = { fields = { "round" } },
	string    = { fields = { "contains", "split" } },
	coroutine = { fields = { "sleep", "schedule" } },  -- Windower の拡張
	-- lists/sets/tables/classes を require した時に生えるもの
	"T", "L", "S", "class",
    },
}

--------------------------------------------------------------------
-- AC 自身が意図的に定義するグローバル
--------------------------------------------------------------------
globals = {
    "_addon",  -- addon メタ情報 (AC.lua)
    "__AC",    -- AC 本体への参照 (AC.lua)
}

--------------------------------------------------------------------
-- 【暫定】本来 local / M.* にすべきグローバル関数群
--
-- 現状これらは `function foo()` と local なしで定義されており、
-- 全ファイルが同一の Lua state を共有するため衝突リスクがある。
-- (実例: is_defensive は job/{BRD,COR,DNC,GEO}.lua で 4 重定義されており、
--        最後に require された GEO の定義だけが生き残っていた。
--        4 つとも本体が同一だった為に偶然無害だっただけ。修正済み)
--
-- ここに載せているのは既存コードの警告を黙らせる為の暫定措置。
-- local 化したらこの行から削除すること。新しい名前を足さないこと。
-- このリストを空にする事が、構成の片付けが終わった印。ARCHITECTURE.md を参照。
--------------------------------------------------------------------
local legacy_globals = {
    -- AC.lua
    "tick", "tick_serial", "drop_junk_items_in_inventory", "argument_means_on",
    -- task.lua
    "assert_task", "assert_level", "task_equal", "task_index", "task_contain",
    -- mob.lua
    "is_mob_linked", "is_mob_touchable", "is_mob_attackable",
    -- inspect.lua / zone / utils
    "is_alliance_joined", "pos_str", "_table_to_string", "norm", "numsign",
    -- ac/
    "nearest_idx", "relay_idx", "stop", "contain_pos", "move_to", "move_to_action",
    "move_to_action_faith", "auto_move_to", "_auto_move_to", "create_member_info",
    "target_pos", "target_distance", "current_pos", "distance", "distance2",
    "distance_x", "distance_y", "is_near", "table_has_data",
    -- contents/
    "BurningCircleFunction", "GreysonFunction", "target_and_lockon", "forward",
    "SynergyFurnaceFunction", "SynergyEngineerFunction",
    "SynergyFurnaceFunction_old", "SynergyEngineerFunction_old",
    "setup", "start", "add", "operate", "finish", "common",
    "wind", "thunder", "dark", "search_prefer_enemy", "search_enemy",
    -- role/
    "get_lower_hp_target", "within_time", "invoke_magic",
    -- job/
    "invoke_ninjutsu", "toolbag_proc", "has_shika",
    "phantom_roll", "roll_tick", "phantom_roll_double_up", "COR_phantom_roll_up",
    "invoke_shoot", "provoke", "attacker", "defender",
    "inde_setup", "geo_setup", "geo_release", "geo_release_with_contexte",
}
for _, name in ipairs(legacy_globals) do
    table.insert(globals, name)
end

--------------------------------------------------------------------
-- 警告の取捨選択
--------------------------------------------------------------------
ignore = {
    "212",  -- 未使用の引数 (コールバックシグネチャ都合で多数ある)
    "213",  -- 未使用のループ変数 (for i, v in ipairs() の i など)
    -- 541/542: 中身が空のブロック。このコードでは
    --   ・そのケースは何もしない、と明示する分岐 (status の DEAD/EVENT など)
    --   ・デバッグ表示をコメントアウトして残してある分岐
    -- として意図的に使っているので、警告しない
    "541",  -- 空の do..end
    "542",  -- 中身が空の if 分岐
    "611",  -- 空行の空白
    "612",  -- 行末の空白
    "614",  -- コメント行末の空白
}

max_line_length = false  -- 既存コードに長い行が多い

--------------------------------------------------------------------
-- ディレクトリ個別設定
--------------------------------------------------------------------
files["script/"] = {
    -- WSL から単体実行する CLI スクリプト群。addon とは別プロセス。
    std = "lua51",
    globals = { "usage", "parse_args", "print_color", "array_slice",
		"comp_point", "comp_ambus", "comp_domain",
		"item_match", "own_item_count", "strspacepad",
		"show_item_and_bag", "show_lacking_item",
		"table_union", "table_count", "table_diff",
		"get_ordered_key_array" },
}

files["tests/"] = {
    std = "lua51",
    allow_defined_top = true,
}

exclude_files = {
    "res/**/*.lua",      -- Windower res へのシンボリックリンク
    "findAll/**/*.lua",  -- findAll addon へのシンボリックリンク
    "data/**/*.lua",     -- 生成データ
    "saved/**/*.lua",
}
