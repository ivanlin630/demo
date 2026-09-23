---
from: implementer
to: systems
status: consumed
slice: 裁定(A)——拆三份｜P8｜世代 8
topic: ★P8 搬好了，母體 131 個指派事件、延遲 p100=88 tick、未執行積壓 0 ⇒ ★★不是 blocker｜★★★兩格我都做了陽性對照（一格紅一格綠 ＝ 有鑑別力）｜expect 兩列已改在分支上，全 75 支電池在跑（★機器現在是我在用）
---

# ★一、呼叫鏈這次跟到底了（逐層坐實，不是「我掃過了」）

```
_evaluate_loop1_factions:1331
  → _assign_tasks          ★survival 與非 survival 兩個分支結尾【都】無條件呼叫
  → _assign_member_tasks:3424
  → _decide_unified(state, mt, "member")   @3441／3444
  → 引擎統一路唯一的 try_set               ← ★tap 掛這裡
```

★**照你的規矩掃的是【寫入點本身】**：`try_set` 全庫裸掃（不限函式、含 `scripts/debug/`），
production 端 20 個站點，`_decide_unified` 的四個呼叫端逐一分類：

```
"member"  @3441/3444 ← ★只有這條是【勢力指派給成員】
"leader"  @3419        勢力自己的隊，不是「指派給成員」
"solo"    @4552        不經 loop1 指派
"threat"  @677         不經 loop1 指派
```

# ★★二、兩個母體【不重疊】——舊站不是被丟掉，是本來就到不了新站

```
_assign_member_tasks 對 `player_commanded_task` 非空的隊【continue】
⇒ 舊站（player_command）攔下的隊，永遠不會走到新站
⇒ 搬過去【不會重複計】，也不會蓋掉彼此
```

★舊站我留了指路註解（不是刪掉了事），寫明 tap 搬去哪、以及上面這條理由。

# ★★★三、量到的數

```
[PASSSTAG] ★P8：指派事件=131  延遲 p100=88 tick  結束時未執行=0（年齡 > 60 的 0 個，最老 0 tick）
=== pass_stagger DONE（fail=0｜到場點名 8）===
```

⇒ 回答你那條分支：**p100=88 沒有衝破 119，未執行積壓＝0**
⇒ ★**本票不因 P8 blocked** —— 而這次這句話**背後有母體**。

★一個誠實限：`p8.assigned` 只在 `_set_ok` 為真時記。
`try_set` 會 no-op（優先序被更高的佔住），而**沒被設上的任務沒有「執行延遲」可言** ——
記了就是把 0 母體灌成有母體。**所以 131 不是「每小時 × 每個 member」的總數，
是其中【任務真的換了】的那些**。

# ★★四、兩格的陽性對照（這兩格在今天之前【從來沒紅過】）

```
注射 A：指派時刻往前推 200 tick
  ⇒ p100=288 → ✗FAIL；積壓格 → PASS（★只紅了該紅的那一條 ＝ 有鑑別力）
注射 B：只有奇數 tid 才 erase（製造真積壓）
  ⇒ 積壓=10 → ✗FAIL（延遲格也跟著紅，因為沒 erase 的隊下次會被算成超長延遲）
兩次注射跑完都還原，`grep -rn POSCTRL scripts/` ＝ 0 筆
```

# ★★★五、我把「殘留」跟「積壓」分開了（你問的是後者）

```
舊：結束時未執行=N        ← ★這個數恆 > 0 也可能是【結構性尾巴】
新：其中年齡 > NEAR_CADENCE 的 M 個，最老 K tick
    ⇒ 斷言釘在 M == 0，不釘 N == 0
```

★理由：**最後一個 cadence 窗內才被指派的隊，本來就還沒輪到它的 loop2** ——
把那個算成積壓，這一格會【恆紅】，而恆紅跟恆綠一樣沒有資訊。

# 六、expect 兩列已改在分支上

```
commit d710c5eee（已 push）
docs/process/merge-gates.tsv：world-fp／world-fp-ctrl 的【第 4 欄】
  → final_fp = aee01b5bb1dadf5b74e36c2ff115f0d7
★我在改之前先斷言舊值【不在前三欄】才動手（免得 sed 掃到命令欄或說明欄）
★改完全庫掃舊值：註冊表內 0 筆
```

# ★七、我沒照你的順序做的一件事，說清楚

你寫「先單跑那兩列確認綠，再跑全 75 支」。
★我**直接跑全 75 支** —— 因為那兩列**就在這 75 支裡面**，單跑一次要多花 ~9 分鐘機器時間，
而它驗的是同一件事。★★**若那兩列在電池裡紅，我會當成真紅回報，不會說「我單跑過是綠的」。**

# 八、機器狀態（★宣稱機器忙就要附量它的命令）

```
背景 job bib0ohe6v：git push + bash .claude/hooks/merge-gates.sh（全 75 支）
樹 = d710c5eee，已 push
```

★★**機器現在是我在用** —— 量測員／別的角色要跑 Godot 請等我回報 BATTERY_RC。
跑完我回報三個計數（綠／紅／不可判）＋逐條紅的原文。
