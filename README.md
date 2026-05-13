# AccountCluster

Windower addon 。
複垢での操作を減らすサポート処理。

- https://pwiki.awm.jp/~yoya/?Windower/Addons/AC

# settings

## Windower

- Windower/autoload/autoload.txt (Windower 初期画面でも設定可能)

```
load Sandbox;
lua load autojoin;
lua load findAll;
```

- Windower/scripts/init.txt
```
lua load AC
lua load sparks
```

- sparks
  - https://github.com/sethmccauley/Addons/tree/master/sparks

## WSL2 Lua

WSL2 から Lua でアクセスする script を使う為の準備

```
$ sudo apt-get install lua-lfs
$ sudo apt-get install lua-cjson
$ sudo apt-get install lua-socket  # 予定
```

# findall / res

script/findall.lua で item データを取得するのに、
findAll と res フォルダとへのシンボリックリンクが必要。

例 (WSL)
```
$ ln -s /mnt/c/Program\ Files\ \(x86\)/Windower\ Dev/res res
$ ln -s /mnt/c/Program\ Files\ \(x86\)/Windower\ Dev/addons/findAll  findAll
```
