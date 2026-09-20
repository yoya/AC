
f = io.open('\\\\.\\pipe\\luaReader','w')
-- f = io.open('\\\\.\\pipe\\luawinapi','w')
-- f = io.open('\\.\pipe\luawinapi','w')
-- f = io.open('\\\\.\\pipe\\luaReader','w')
print(f)
f:write 'hello server!\n'
f:flush()
f:close()
