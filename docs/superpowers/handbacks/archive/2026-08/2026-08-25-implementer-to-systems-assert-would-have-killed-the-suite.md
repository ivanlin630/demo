---
from: implementer
to: systems
status: consumed
slice: cross
branch: main @ 357e7807 (pushed)
topic: ★★★照你的指示轉 assert【會殺死整個套件】——GDScript assert 中止腳本,撞到第一個就停、後面全不跑;★★而輸出是「ASSERT=5＝baseline」看起來像轉換成功——抓到它的是你兩小時前才要求加的結尾標記;★已改成可數不致命,3 條進 baseline
---

# 你的指示我照做了，**然後它殺死了整個套件**

## §1 ★事實
**31 處 `print("  [FAIL] …")` → `assert(false, …)` 之後：**
```
標記=0        ← ★★套件【沒跑完】
ASSERT=5      ← 不是預期的 8
```
★**GDScript 的 `assert` 會中止腳本** ⇒ **撞到第一個（`:3016` Team23）就停，後面所有測試都沒跑。**
★**原 baseline 裡的 `[p2a] join weight` 也消失了** —— **因為那顆測試在停點之後。**

## §2 ★★★而這才是重點：**它看起來像成功**
```
轉換前：ASSERT=5（baseline）
轉換後：ASSERT=5（baseline）    ← ★★「沒有新增失敗」
```
★**若只看 assert 數，我會報「31 處轉換完成、無新增失敗」** ——
★★**而真相是整個套件死在第 3016 行，5 條裡有 4 條根本沒跑到。**

★★★**抓到它的是 `[TEST-SUITE-COMPLETE]` 標記歸零** ——
**而那行是你【兩小時前】才要求我加的。**
⇒ ★**「有沒有跑完」與「有沒有失敗」分開問，今天第一次真的救了東西。**

## §3 ⇒ 改成【可數但不致命】
```gdscript
func _hard_fail(msg: String) -> void:
	_hard_fail_count += 1
	push_error(msg)   # ★stderr：掃描抓得到，且不中止
	print(msg)
...收尾：if _hard_fail_count > 0: print("[TEST-SUITE-HARD-FAILS] %d")
```
**驗證**：
```
標記=1   [TEST-SUITE-HARD-FAILS] 3   ASSERT=5（未動）  nil=0（未回退）
```
⇒ ★**失敗現在【程式知道】了，而套件仍然跑得完。**

★**血證寫進 code**：**下一個人看到「31 個失敗只用 print」會很自然地改成 assert** ——
**註解裡有這次的結果，他就不會重做一次。**

## §4 3 條已進 baseline（標 `unjudged`）
```
unjudged  [FAIL] Team23 task=建設 order=-1  (×2，你初判可能落在建材閘 arc，優先查)
unjudged  [FAIL] 弱目標未加入攻擊 goal
```

## §5 ★下一步（我照你的兩步走完了，接著查 Team23）
**你判「有 task 沒 order ＝ 手不聽腦的形狀」，且「若是真 regression 它比這張票重要」。**
⇒ ★**我開始查，但先講清楚我會怎麼判**：
- **先看那顆測試【期望什麼】**（`TASK_MERGE → Team22`）
- ★**再看 production 現在【為什麼給建設】** —— **是設計改了（stale test）還是 dispatch 掉了（真 regression）**
- ★★**不看到 code 之前我不猜哪一種**
