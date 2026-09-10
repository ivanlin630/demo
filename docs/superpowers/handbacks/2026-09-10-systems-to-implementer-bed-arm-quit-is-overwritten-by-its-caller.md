---
from: systems
to: implementer
status: open
slice: bed-arm 的 rc（★最後一支紅）
topic: ★★★找到了，而它是**兩個 bug 串在一起、外面那個把裡面那個藏起來**：`bed_arm_gate.gd:44 _initialize(): _run(); quit()` —— ★`_run()` 結尾的 `quit(1)`（`:201`）**執行了**，然後控制權**回到 `_initialize`**，那句無條件的 `quit()` 把 exit code **蓋回 0**｜★★你說「它本來就 quit(1)」是對的 —— **它確實呼叫了，只是被自己的呼叫端覆蓋**｜★而全套現在 **11 → 1 支紅**，只剩這一支
---

# ① 根因（★兩行，我讀過）

```gdscript
scripts/debug/bed_arm_gate.gd:43-44
    func _initialize() -> void:
        _run(); quit()          # ★★★這句無條件的 quit() ＝ quit(0)

scripts/debug/bed_arm_gate.gd:201
        quit(1)                 # ★ FAIL 路徑：呼叫了，然後【return 回上面那句】
```

```
⇒ ★實測：`[godot.ps1] child exit=0`，而輸出裡明明印著 `★FAIL：25 張床…`。
⇒ ★★而它為什麼今天才現形：**wrapper 本來就把所有 rc 吃掉** ——
  ★★★**外面那個 bug 讓裡面這個 bug 完全不可觀測**。修好外面，裡面立刻現形。
```

# ② 修法

```
`func _initialize() -> void: quit(_run())`，而 `_run()` 回傳 int（PASS 0／FAIL 1／`:138` 那條 3 保留）。
★不要改成「FAIL 路徑加 return」——那只修了這一條路，
  ★★而問題是**呼叫端無條件覆蓋**：下一個人新增第四條退出路徑時會再犯一次。
⇒ ★★★修的是【誰決定 exit code】這件事，不是那一行。
```

# ③ 驗收

```
①★FAIL 路徑 ⇒ `powershell -File ./tools/godot.ps1 --headless --script scripts/debug/bed_arm_gate.gd`
  的 **rc ＝ 1**（★★而輸出不變 —— 25 張床那個數字**仍然要印**）
②★成對對照：把那 25 張其中一張暫時加進白名單 ⇒ 數字變 24；**全部加進去 ⇒ rc ＝ 0**
  ⇒ ★★這一格證明 rc 真的跟著判準走，而不是被寫死
  ⇒ ★★★**驗完把白名單改回來**（那 25 張是床層債，本票不修它）
③`:138 quit(3)` 那條路仍然回 3（★別在重構時把它併成 1）
```

# ④ ★而全套現況（★給你下一輪的基準）

```
`main` HEAD=d7ebfc1b1：**56 支裡只剩 bed-arm 一支紅**（11 → 1）。
★main 基線紅數已經第一次被記下來：`d7ebfc1b1  1  2026-09-10T05:45Z`
  ⇒ ★★下一輪跑閘時 runner 會在開場印它 ⇒ **你不必再開 worktree 重跑才知道哪些是既有的**。
```
