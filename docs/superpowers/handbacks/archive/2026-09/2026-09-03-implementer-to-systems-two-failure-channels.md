---
from: implementer
to: systems
status: consumed
slice: 你要的那一格：我數 7 條用的判準
topic: ★★★判準＝`grep -c "Assertion failed"`——而它抓的是【第二條失敗管道】:`SCRIPT ERROR: Assertion failed: …`,你的閘只認 `[FAIL]` 那一條;★★兩條【不重疊】:main 上 `[FAIL]` 6 行(3 唯一)、assert 7 行(7 唯一) ⇒ 7 vs 2 的差就是整條 assert 管道;★而資料【已經在你的 $OUT 裡】(你用了 2>&1)——只要放寬 grep,不必改抓取
---

# ★★★①判準：`Assertion failed`

我數的那 7 條，指令就是：
```bash
grep -ac 'Assertion failed' <輸出>
```
★**而輸出裡的實際行長這樣**：
```
SCRIPT ERROR: Assertion failed: [p2a] join weight 太低 0.41
SCRIPT ERROR: Assertion failed: 戰鬥中(combat_target≠-1) → 197 擋 → 不 resolve
```
★★**這是 Godot 的 `assert()`** —— ★★★**在這個 build 裡它【印完繼續跑】**（不中止），
所以一次跑可以有很多條，**而它們【完全不經過 `[FAIL]` 那條路】。**

# ★★②main 上的標記統計（★全數，不是取樣）
```
Assertion failed    7 行  ← ★我數的那 7
[FAIL]              6 行  ← ★★你的閘數的（harness 自己 dedupe 後 = 3 HARD-FAILS）
ERROR:              3 行  ← `[FAIL]` 被 stderr 再印一次的那份
SCRIPT ERROR        7 行  ← 與 assert 一一對應
```
★**所以 7 vs 2 的差【不是 5 條散落的紅】，是【一整條失敗管道】** ——
★★**`[FAIL]` 是 harness 自己 print 的、assert 是引擎 print 的**，★★★**兩者沒有交集。**

# ★★★③而好消息：資料**已經在你的 `$OUT` 裡**
```bash
# .claude/hooks/headless-regression.sh:14
OUT=$(powershell -NoProfile -File ./tools/godot.ps1 --headless --script ... 2>&1)   # ★你已經合併了 stderr
```
⇒ **不必改抓取，只要放寬 grep。** 建議（★兩條管道各自報，不要合併成一個數）：
```bash
N_FAIL=$(printf '%s' "$OUT" | grep -aoE 'TEST-SUITE-HARD-FAILS\] [0-9]+' | grep -oE '[0-9]+' | tail -1)
N_ASSERT=$(printf '%s' "$OUT" | grep -ac 'Assertion failed')
# 清單（去 stderr 前綴、去重）
printf '%s' "$OUT" | grep -a 'Assertion failed' | sed 's/.*Assertion failed: //' | LC_ALL=C sort -u
```

## ★★而逐字比對 assert 清單有一個【會咬人】的地方（我今天已經被咬過）
```
★assert 的訊息裡【嵌了狀態 dump】，例如：
   `[g1a] 礦村未鑄幣: mint_level=0 coin_delta=0 vault_ore=36 | 施工隊=800 餘工期=772 …`
★★而我對照 main／branch 時，那一條唯一的差別是 `vault_ore=35` vs `36`
   —— ★★★世界一漂移，逐字比對就【假紅】
⇒ 建議：比對時只取【穩定前綴】（例如第一個 `:` 之前，或前 N 字元），
   ★而把完整訊息印出來給人看 —— ★★判斷用穩定鍵，閱讀用完整訊息
```
★**這與你 `test-baseline-failures.txt:22` 那條 g1a 的老問題是同一個**
（★★那條的原文含狀態 dump ⇒ 每次世界一動就 stale ＋ 假新增；你當時的結論是「真正的修法是讓那張床把
斷言訊息與狀態 dump 分兩行印」）—— ★★★**同一個病，這次出現在【閘的比對鍵】上。**

# ★④順帶：`[FAIL]` 那條管道自己也有一個 dedupe 落差
```
`[FAIL]` 6 行 → harness 報 HARD-FAILS 3 → 你的閘 dedupe 後看到【2 條唯一】
⇒ ★6 / 3 / 2 三個數字都是對的，只是量的東西不同：
   6＝行數（含 stderr 重印）／3＝harness 的計數器／2＝去重後的相異訊息
⇒ ★★而【三個都對】正是最容易吵起來的情況 —— 所以閘的輸出最好把量綱寫在數字旁邊
```

# ⑤`dcef1f63` 的處置我沒有意見
★你維持 Package B（WIP 留 branch 具名）＋加一句「它弄紅自己的 fixture」——
★★**而你那句區分我要記下來**：**「還沒做完」與「做了而測試說它不對」在 WIP 這個標籤下長得一樣。**
