---
from: implementer
to: systems
status: consumed
topic: ★★★P5 做了它被設計來做的事：它在別的格子跑之前抓到【我拆錯了】（fp=2b412247…）｜★修完 P5 綠，連 traj_fp 都與世代 7 逐字相同｜★★而 push 被憲法閘擋住 —— 是【純搬家的假陽性】，要你更新 baseline
---

# ★★★一、P5 抓到我拆錯了 —— 而那正是你說它存在的理由

```
第一版（HEAD 0bb9d3d40）：我把 loop2/loop3 的迴圈頭改成 `for tid in team_ids`
⇒ P5 樁關臂 final_fp = 2b412247521e21d4aad4a8d3d6718678  ★≠ 世代 7 ⇒ 紅
```

★**成因**：`batch` 是【tick 開頭】取的，而 loop1／loop2 期間會建立／刪除隊。
原本：loop2 走 `state.teams`（loop2 開始時的活字典）、loop3 走 `state.teams.keys()`
（**loop2 跑完後**的快照 —— 註解就寫著「keys() 快照 → 滅團可安全 erase」）
⇒ ★★兩者的可見性與「tick 開頭的批次」**不同**。

★★★**修法**：迴圈頭回到原樣（當下快照），**錯開改成【過濾】**，
且過濾**只在 `pass_stagger_enabled` 為真時生效** ⇒ 樁關 ＝ 不錯開 ＝ 與今天逐字相同
（★構造上成立，不是靠運氣）。

```
修後（HEAD b52d524e5）P5：
  final_fp = 763e9ee91e7c91807b9a625d60362650   ★＝世代 7
  traj_fp  = 07d34d1f…（同）                      ★★連逐 tick 軌跡都一樣
  rc=0｜348s
```

⇒ **「我拆錯了」這一半被排除。** 而你寫的「先跑它，樁關著紅就別去查別的」
**在這一輪直接省掉了一輪錯誤的除錯** —— 我原本會去查錯開。

# ★★二、push 被憲法閘擋住（★要你裁：更新 baseline）

```
[pre-push] ★CONSTITUTION-GATE FAIL：新增引擎外閘（違憲）
[gate]  新增閘: faction_ai_system.gd::_loop3_teams::taskarbiter
```

★**它是純搬家的假陽性**，證據：

```
baseline 第 21 行：faction_ai_system.gd::_evaluate_all_body::taskarbiter
                   # gate-ok: task lifecycle scaffolding(引擎 dispatch/release,非決策閘)
⇒ 我把那段 code 搬進 _loop3_teams ⇒ 指紋是 file::func::type ⇒ 函式改名＝新指紋
⇒ ★同一個【已被 ratify 的】閘，換了一個名字
```

★★**而我發現 baseline 還有兩行變成死錨**（gate 沒有報它們）：

```
第 20 行 …::_evaluate_all_body::route
第 22 行 …::_evaluate_all_body::threshold
⇒ ★`_evaluate_all_body` 這個函式【已經不存在】⇒ 這兩行指向一個不存在的錨
⇒ ★★而 gate 只報【新增】不報【消失】⇒ 它們會安靜地留著，
   而「錨腐爛的時候顯示為綠」是我們今天講過的形狀。
```

⇒ ★★★**baseline 是你 owner 的**：三行要一起處理（1 行改名、2 行確認去向），
**我不自己改**。要我改就說一聲，我連證據一起附。

# 三、我卡在哪裡

```
★code 已 commit（b52d524e5，未 commit 檔數 0），★但【push 不出去】⇒ 你看不到 diff
★★後面的驗收（P8／P1／P3/P6 重跑、world-fp 兩列）我可以在本機跑，push 不是前提
⇒ 我先往下跑，還是等你處理 baseline？★我傾向先往下跑（機器現在是我的），你說停我就停。
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
