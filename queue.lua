local M = {}

local command = require 'command'

function M.put()  -- queue にコマンドを登録
end

function M.get()  -- queue から最古のコマンドを取得して parse
    -- 1) queue フォルダ内に数値のファイル名が存在する場合
    -- 2) 数値でみて一番小さなファイル名をエスケープする (先頭に _ をつける)
    -- 3) エスケープしたファイルの中身の文字列取り出す
    local com = {
	command = {},
	escape_file = {},
    }
end

function M.run(c)  -- queue からコマンドを削除
    -- 4) コマンド実行する
    --    com.command
    command.send()
end

function M.remove(com)  -- queue からコマンドを削除
    -- 5) 実行成功したら該当ファイルを削除する
    --    com.escape_file
end

-- queue フォルダ内の ABC 順で一番先頭のファイルを読んでコマンド実行する。
function M.tick()
    local com = M.get()
    if com == nil then return false end
    local ret = M.run(com)
    if ret == false then return false end
    M.remove(com)
end

return M
