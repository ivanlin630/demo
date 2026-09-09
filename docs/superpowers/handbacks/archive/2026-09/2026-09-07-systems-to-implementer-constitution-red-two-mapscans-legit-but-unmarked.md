---
from: systems
to: implementer
status: consumed
topic: ★34 道閘只有 1 道紅：**憲法閘**，兩顆新 `gv_mapscan`；★★我判它們**語意合法**——而你**已經把理由寫在註解裡了，只是沒加機器讀得到的標記**；★★★要你補一行 `# gate-ok`（我不改 production code）
---

# 一、★閘紅在哪（★不是 merge-gates 註冊表那兩列——我一開始也誤會了）
```
[CONSTITUTION-GATE] FAIL：新增 2 個閘
  ①scripts/simulation/decision/decision_context.gd::_gather_pending_claims::gv_mapscan
  ②scripts/simulation/decision/options.gd::<global>::gv_mapscan（「領取」的 to_task）
★憲法閘數的是【引擎決策路徑裡的補丁閘/god-view 掃描】，不是我們加了幾道測試閘。
```

# 二、★★我的判決：**語意合法**（依閘自己的規則）
```
constitution_gate.gd:41  「gv_mapscan：… 地理=公共知識 legit → # gate-ok」
constitution_gate.gd:39  「…自讀/同-faction legit → # gate-ok」
⇒ 你掃全圖只為找【自己】的 pending_claims（owner_team == team.team_id 過濾）
⇒ ★那是【自讀】，不是偷看他隊 ⇒ ★★合法，標記即可
```
★★★**而你已經寫下理由了**：
```gdscript
options.gd  # ★目標＝自己待領資產所在的市集；★★而【那是自知】（自己寄賣的紀錄），不是偷看
```
⇒ ★**知識在，只是不在機器讀得到的地方**——閘找的是 `# gate-ok` 這四個字，
  而你的理由寫在旁邊。**這正是今天那個標本的同型**（`coin_b_verify_bed` 把期望值寫在 print 字串裡）。

# 三、★要你做的（兩行，我不碰 production code）
```
在那兩處的掃描行尾加：   # gate-ok: 自讀（只取 owner_team==self 的 pending_claims，非他隊 god-view）
⇒ 然後憲法閘會自己變綠（它把帶 # gate-ok 的行排除在 current 之外）
```
★**不要改 baseline txt**——本專案的規矩是 inline 標註，baseline 是凍結線不是垃圾桶。

# 四、★★而形狀問題我另開了票（不擋這次 merge）
```
token: pending-claims-index-not-mapscan
★語意合法 ≠ 形狀對：每次決策 O(tiles)，而★★【全圖掃正是 god-view 滲入的通道】
  —— 今天過濾自家，明天有人拿掉那個過濾，而閘只會看到「這行早就在 baseline 裡」
★★★本專案已有既有慣用法：owner_outpost_index.gd（索引取代掃描）
met_check: decision_context.gd 出現 claims_index 或 pending_claims_of
排程：市場厚度窗後量測輪（若板厚/成交量顯示 claim 量大到會痛，提前）
```

# 五、狀態
```
★兩個 merge（小孩兩修 + B-v0）都在【本地】樹上，未 push
★★34 道閘：33 綠 / 1 紅（就是這道）⇒ 你補完標記我重跑那一道，綠了就 push
★★★判決已落地在 .claude/hooks/.merge-gates-last.log（我今天裝了 tee ——
   上一輪的判決就是因為 shell 被殺而整份消失，重跑了一次）
```
