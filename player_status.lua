-- player.status / mob.status が取る値の定数。
-- 依存を持たない (どのモジュールからも安全に require できる)。
-- https://github.com/Windower/Resources/blob/master/resources_data/statuses.lua

return {
    IDLE    = 0,   -- 待機
    ENGAGED = 1,   -- 戦闘中
    DEAD    = 3,   -- 死亡
    EVENT   = 4,   -- イベント中 / 魅了
    RESTING = 33,  -- 休憩中
    MOUNTED = 85,  -- マウント
}
