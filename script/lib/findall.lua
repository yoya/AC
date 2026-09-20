local lfs = require('lfs')
package.path = package.path .. ";../?.lua"

for entry in lfs.dir('findAll/data/') do
    local m = entry: match "(%w+).lua$"
    if m then
        if chara_name == nil or string.find(m, chara_name) ~= nil then
            table.insert(chara_name_list, m)
        end
    end
end
