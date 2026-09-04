---
from: implementer
to: systems
status: open
slice: ★★★funnel 那顆「未定」的成因【抓到了，可重現】—— 而我先前的假說被自己的探針否掉
touches: `.worktrees/donor-ladder`：`scripts/debug/stdout_integrity_probe.gd`（加 `giant` 形狀）／三支床改逐行印
topic: ★★★根因＝**Godot 單次 `print()` 被截在 16383 字元（2^14−1）**;★而我第一版探針【測錯了形狀】:它用 20000 次獨立 print(缺號 0),而出事的床是【join 成一包只 print 一次】—— 加上 `giant` 模式後一次重現:只活 191 行、19809 行消失、下一個 print 黏在被切斷那行後面;★★所以我先前寫的「並跑造成」也被否掉了:3×20000 行在並跑下【零缺號】;★★★全庫只有三支床是這個形狀,已全部改成逐行印(exact path 在下面)
---

# ★★★①重現（★決定性，兩種形狀同機同參數）
```
mode=many   行數=20000  缺號=0       ← ★逐行 print，一行不少
mode=giant  行數=  191  缺號=19809   ← ★★join 成一包只 print 一次
黏連樣本：[SOI] 000190 0123456789abcdefghijklmnopqrst[SOI] END lines=20000 mode=giant
★★★存活區段 ＝ **16383 字元 ＝ 2^14 − 1**
```
⇒ ★**單次 `print()` 有 16KB 上限**，超出的部分【靜默丟掉】，而【下一個 `print` 接在斷點後面】
⇒ ★★這解釋 funnel 實物的【全部特徵】：有開頭、有結尾、格式對、中間少一段、DONE 黏在半行後
⇒ ★★★而「尾標記存在」為什麼不夠也一併說死了：**丟失發生在它之前，而它自己是另一個 `print`**

# ★★②我先前兩個說法【都被自己的探針否掉】
```
①「並跑造成」：★3 支探針在【有一支 30 日床同時跑】的情況下各 20000 行 ⇒ ★★零缺號
   ⇒ 併發不是變因
②「量太大造成」：★★★同樣 20000 行、同樣總位元組，★逐行印一行不少
   ⇒ 總量不是變因 —— ★★變因是【單次呼叫的大小】
★而我第一版探針之所以測不出來：★★它用了【N 次 print】，而出事的床用【1 次 print】
   ⇒ ★★★我測的是「同一個量」的【不同形狀】—— 形狀不同，測到的是另一件事
```

# ★★★③修法與 exact path（★三支，全庫只有這三支是這個形狀）
```
A:\GDS\demo\.worktrees\donor-ladder\scripts\debug\construction_funnel_bed.gd:559
A:\GDS\demo\.worktrees\donor-ladder\scripts\debug\perf_scaling_curve_bed.gd:97
A:\GDS\demo\.worktrees\donor-ladder\scripts\debug\s2_before_invariants_bed.gd:103
   舊：`print("\n" + text)` ／ `print(text)`（text ＝ lines join 成一包）
   新：`for _l in lines: print(_l)`
★修法【不是】加大 buffer、★★也不是分段猜一個安全大小 —— ⇒ 逐行印在 20000 行上已實測乾淨
★★★其餘用 `store_string` 寫檔的床【不受影響】（我逐支掃過，不是抽樣）
```
探針（可重跑）：`A:\GDS\demo\.worktrees\donor-ladder\scripts\debug\stdout_integrity_probe.gd`
```
PROBE_MODE=many|giant  PROBE_LINES=N  ⇒ ★陽性對照就是 `giant`：它【必須】缺號，否則探針自己壞了
```

# ④我做了什麼、沒做什麼
```
★做了：三支床改逐行印（★★obvious bug、修法無設計選擇 ⇒ 照「不 false-stop」直接修並告知）
★★正在跑：修後的 funnel 30 日完整性驗證（★預期第四張表回到完整天數、無黏連行）
★★★沒做：①沒改 wrapper（它沒有錯 —— 錯在呼叫端一次丟 16KB 進去）
   ②沒去查 Godot 是否有辦法調那個上限 —— ★逐行印已經解決，調上限是把同一顆炸彈往後挪
```

# ★⑤而這顆回頭影響一件事，我要標出來
```
★`construction_funnel_bed` 的第四張表，我先前【只用前三張、標了第四張不引用】
⇒ ★★那個處置現在看是對的，★★★但理由變了：不是「它被截斷所以不可信」，
   而是【它從 16383 字元之後就整段不存在】—— 而前三張正好落在上限之內
⇒ ★所以我當時的結論不受影響；★★但若當時前三張也超過 16383，我會【毫無察覺地】拿殘缺資料下結論
```
