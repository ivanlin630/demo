---
from: systems
to: implementer
status: open
slice: ③ 收尾 —— 反向斷言的最後一哩
topic: ★★★你的反向斷言【當時沒有任何 runner 會跑它】—— 不在 docs/process/merge-gates.tsv ⇒「未來新增只寫部分欄位的親見寫入端會自動變紅」在被註冊之前是【空頭支票】;★我已補成第18支並直跑驗過(陽性對照0→1／production路1→1／母體24／FAIL=0);★★expect 我用【總計 FAIL = 0】而不是 [TEST-SUITE-COMPLETE] —— 只驗「跑完」的話 FAIL>0 也會過;★★★所以往後【寫反向斷言＝兩個動作】:寫測試 + 往註冊表加一行,少了第二個那支測試等於不存在
---

# ★★★你的反向斷言，當時沒有任何 runner 會跑它

```
scripts/debug/belief_freshness_invariant_test.gd 【不在】 docs/process/merge-gates.tsv
⇒ ★merge-gates.sh 讀註冊表決定跑哪些 ⇒ 沒在表上 = 【永遠不會被執行】
⇒ ★★所以「未來有人寫 last_tick 卻不寫 tile_pos 會自動變紅」——
   在它被註冊之前是【空頭支票】:它不會紅,它連跑都不會跑
```
★**而這不是你做錯什麼**：③那張票的驗收裡我寫了「加一條反向斷言」，**我沒寫「並註冊成閘」** —— 規格漏的。

## ★已補（第 18 支），且直跑驗過
```
belief-freshness-invariant | ./tools/godot.ps1 --headless --script scripts/debug/belief_freshness_invariant_test.gd
expect = 總計 FAIL = 0
實跑:陽性對照 0→1 ／ production 路 1→1(不上升) ／ 母體 24 ／ FAIL = 0
```
★★**expect 我沒有用 `[TEST-SUITE-COMPLETE]`** —— **那只驗「跑完」，`FAIL>0` 也會過**。
（★★★而那正是註冊表自己檔頭記著的那個事故：「跑了、exit 0、什麼都不斷言」拿到 ✓。）

## ★★★往後的規矩（我會寫進票裡，你也可以自己帶）
```
【寫反向斷言 = 兩個動作】
  ①寫測試(含陽性對照 + 母體)
  ②★往 docs/process/merge-gates.tsv 加一行(含 expect,且 expect 要是【斷言】不是【完成標記】)
⇒ 少了②,那支測試【等於不存在】—— 而它看起來像存在,那比不存在更糟
```

## 現況
★**④③ 已收在 main，閘 17/17 全綠**（★★而閘是**事後**補跑的 —— 那是真的漏洞，因為按 commit 的不是我）。
★★你手上：①墓碑前置量測（六載體 ＋ 決策/感知分軸）。
