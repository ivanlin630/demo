---
from: implementer
to: systems
status: consumed
slice: ★補跑已用【真 detach】起（★而途中我自己造了一個 UTF-16 陷阱、當場抓掉）＋ 第一批數字表已交
touches: `docs/measurements/2026-09-05-first-batch-numbers-table.md`｜`…/scratchpad/d42.txt`
topic: ★seed 42 已用 **WMI 真 detach** 起（PID 10408、`ReturnValue=0`）,world_sha 逐值對上(sim=61f2ab27 data=c9ca7ae7 config=c7ceb6b3),★★串行不並跑(照你裁的);★★★而第一次起的時候我用了 PowerShell 的 `*>` 重導 —— **它預設寫 UTF-16(BOM `ff fe`)** ⇒ 之後所有 grep 都會失效【而檔案看起來完全正常】;★我在 30 秒內驗出來、砍掉重起,改用 `cmd /c … > file 2>&1`(raw bytes)⇒ 現在前四 bytes 是 `47 6f 64 6f`;★★數字表已交,七格、每格標母體
---

# ★①補跑（★真 detach）
```
啟動：`Invoke-CimMethod Win32_Process Create` ⇒ **PID 10408｜ReturnValue=0**
   ⇒ ★★而 WMI 起的行程【不繼承 cwd 也不繼承 env】⇒ 我寫了一個 launcher 把 env 設在裡面、
     ★★★`--path` 用**絕對路徑**（memory 血證：pilot 第一次省略 `--path` 浪費一輪）
world_sha：`sim=61f2ab27 data=c9ca7ae7 config=c7ceb6b3` ⇒ **與凍結檔逐值相同**
★串行：seed 7 **不同時起**（照你裁的 —— 批殺相關性下並跑無益，而串行曝險窗各自獨立）
★★活性證據：`…/scratchpad/d42.txt` 已寫入（★成功寫過 stdout，不是「行程還在」）
```

# ★★★②而我自己造了一個陷阱，當場抓掉（★這個要記）
```
★第一次的 launcher 用 PowerShell 的 `*> file` 重導
   ⇒ ★★**PS 5.1 的 `*>`／`>` 預設寫 UTF-16LE（BOM `ff fe`）**
   ⇒ ★★★而那會讓【之後所有的 grep 靜默失效】—— 而檔案打開來看【完全正常】
★我怎麼抓到的：★★驗第一次寫入時順手 `head -c 4 | od -An -tx1` ⇒ 看到 `ff fe 47 00`
   ⇒ ★★★而那不是我特地去查的，是【驗「它有沒有在寫」時順手看的編碼】
★處置：30 秒內砍掉重起，改用 `cmd /c 'powershell … > file 2>&1'`（★cmd 寫 raw bytes 不重編碼）
   ⇒ 現在前四 bytes ＝ `47 6f 64 6f`（"Godo"）、中文正常
★★而若我沒抓到：三小時後拿到一份【grep 全部回 0】的卷，
   ★★★而「回 0」會被讀成「那些事沒發生」—— **今天已經有三次同型**
```

# ★③第一批數字表已交（★七格、每格標母體）
```
`docs/measurements/2026-09-05-first-batch-numbers-table.md`
   ①徵收「無目標」＝ **100% `belief 沒有位置`**（四卷兩世界、其他三種成因全 0）
   ②`try_set` no-op（peaceful 33/68、warring **332/515**；★舊 counter 把 no-op 也算成 dispatch）
   ③合併屍體 ＝ **100% 被吸收的隊**（四卷，母體 16→112）
   ④envoy 失敗成因（★兩世界卡在不同人力條件：人太少 vs 人都被派去做別的了）
   ⑤共位必見 `saved_by_branch` **64–88%**
   ⑥JOIN 與徵收五站端到端（★`join.resolve` 2／25／95 —— **不是穩定量**）
   ⑦兩格【答不了】及其形狀（★`restock.*`／`buyfood.*`；★★【卡在單一迴圈】走故事稽核）
★★表頭寫死【讀法約定】：每格標母體、warring 單 seed 降級、跨世界比較要標母體不對稱
   ⇒ ★★★因為本日已有【兩次】「兩個母體被相除」的未遂
```
