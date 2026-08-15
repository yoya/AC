-- テストランナー
--
--   $ cd tests && lua run.lua
--
-- 各テストは assert を持たず print するだけなので、ここで見ているのは
-- 「エラーを出さずに最後まで走るか」だけ。
--
-- windower のライブラリ (chat など) や Windows の名前付きパイプに依存する
-- ものは WSL の lua では動かないので、理由を書いて飛ばす。ここに並ぶ名前が
-- そのまま「単体テストできないコード」の境界になっている。

package.path = package.path .. ";../?.lua"

local skip = {
    ["run.lua"] = "ランナー自身",
    ["task_test.lua"] = "io/chat 経由で windower の chat ライブラリが要る",
    ["prob_test.lua"] = "io/chat 経由で windower の chat ライブラリが要る",
    ["pipe_test.lua"] = "Windows の名前付きパイプに書く",
    ["pipe_message.lua"] = "空ファイル",
}

-- lfs が無い環境でも動くように、テストは決め打ちで並べる
local tests = {
    "utils_test.lua",
    "io_console_test.lua",
    "os_test.lua",
    "exem_test.lua",
    "junkitem_test.lua",
    "brd_test.lua",
    "task_test.lua",
    "prob_test.lua",
    "pipe_test.lua",
}

local ok_count, ng_count, skip_count = 0, 0, 0
local failed = {}

for _, name in ipairs(tests) do
    if skip[name] ~= nil then
	print(("[SKIP] %s (%s)"):format(name, skip[name]))
	skip_count = skip_count + 1
    else
	print(("[RUN ] %s"):format(name))
	local ok, err = pcall(dofile, name)
	if ok then
	    print(("[ OK ] %s"):format(name))
	    ok_count = ok_count + 1
	else
	    print(("[FAIL] %s: %s"):format(name, tostring(err)))
	    ng_count = ng_count + 1
	    table.insert(failed, name)
	end
    end
end

print(("=== %d ok / %d failed / %d skipped"):format(ok_count, ng_count, skip_count))
for _, name in ipairs(failed) do
    print("  failed: " .. name)
end
os.exit(ng_count == 0 and 0 or 1)
