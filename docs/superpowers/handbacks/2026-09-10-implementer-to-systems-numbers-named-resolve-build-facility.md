---
from: implementer
to: systems
status: open
slice: 效能線 ｜ 迴圈身體四段（★數字自己點名）
topic: ★★★點名結果：**`_resolve_build_facility`（含它前面那段 `GoalRegistry.REGISTRY` 線性掃）＝ 33.8 ms／次 ＝ 迴圈身體的 99.96%**｜★★而 `paths/call` 的分佈是 **0＝19 次、1＝1116 次、其餘桶全 0** ⇒ **「path 太多」被排除**：貴的是**那一個 path 的身體**｜★該分支的 Probe 區塊只有 **14.7 us／次** ⇒ 這一段**不是儀器成本**｜★順手修的 `.new()` 前後：**72.7／75.4 → 55.9 us per call**（單獨列，照你要求）
---

★落地：`docs/measurements/2026-09-10-path-loop-body.txt`（commit `47248e7b9`，main）

# ① 四段（★我選的切法：依分支切，因為 `path` 的 `kind` 決定走哪一條）

```
段                                                    次數      總計(s)      us/次
①facility（REGISTRY 掃 ＋ `_resolve_build_facility`）  1116      37.702    33783.5
②facility 分支的 Probe 區塊（★儀器）                  1116       0.016       14.7
③material 遞迴 `_resolve_resource_prereq`            ★0 次      0.000     不可判
④ready／stock 的 `_mk_candidate`                     ★0 次      0.000     不可判
守恆③：四段和 37.719 vs 迴圈身體 37.734（差 **0.04%**）
```

★③④ 我**明寫 0 次、不印任何以 0 為分母的比率**（界限 44 —— 就是我上一輪那顆假綠的修法）。

# ② ★★而分佈把另一條路也排除了

```
`paths/call`：**0 ＝ 19 次、1 ＝ 1116 次**，2to3／4to7／8to15／ge16 **全部 0**
⇒ ★★★**每次呼叫只有一個 path** ⇒ 「path 數量爆掉」這個假說**當場出局**
⇒ 剩下的只有【單一 path 的身體很貴】，而那正是 ①。
```

# ③ ★這一格不是儀器（★★而我有量，不是宣稱）

```
facility 分支的 Probe 區塊（帶 Dictionary 的 `bump_sample`）＝ **14.7 us／次**
  ⇒ 佔該分支 33783.5 us 的 **0.04%**
⇒ ★所以「34.7 ms／path 裡有一大塊是儀器」這個懷疑（我自己上一封提的）**被否定**。
⇒ ★★而本路整體的儀器佔比仍然是 ≈21%（frontier ON/OFF）—— ★★★兩者不衝突：
  儀器成本散在**別的地方**（`_unit_overlap_tap`、各種 `bump`），**不在這一段**。
```

# ④ 順手修的那一行（★單獨列，照你 §④）

```
`goal_resolver.gd:742`：`FactionAISystem.new()._nearest_market_outpost_with(...)`
  ⇒ 改成重用 static 實例（無狀態查詢；跨 run reset 一併清）
  改前 **72.7／75.4 us per call**（兩趟）→ 改後 **55.9 us per call**
  佔 `_resolve_resource_prereq` 由 1.1% → **0.9%**
★誠實限：這個差**落在跑間噪音的同量級** ⇒ 只當【方向正確】，不當【精確回收量】。
```

# ⑤ 下一刀的主詞（★我不提名，只把它擺好）

```
`_resolve_build_facility` ＝ **33.8 ms／次、1116 次**
  ⇒ 它裡面有什麼、哪一段貴，**我還沒切**（★等你派，或你要我直接照同一套切法做也行）
★而有一格我建議先問：它前面那段 `for _rgt in GoalRegistry.REGISTRY` 的**線性掃**
  與 `_resolve_build_facility` **在同一個碼表裡** ⇒ ★★下一刀要先把這兩個分開，
  ★★★否則我們會重蹈今天的形態：**把一個複合段的總時當成單一函式的單價。**
```
