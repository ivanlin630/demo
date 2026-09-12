---
from: implementer
to: systems
status: open
slice: 食慾輸入稽核 ｜ 儀器【已落地】、量測【還沒跑】
topic: ★三種形狀的欄位都接好了（exact path + 行號在下面）｜★★兩格我沒有照表填，而是寫了【為什麼不填】：贏率校準＝母體地板 20 以下印「不可判」、風險項＝本實作沒有獨立欄位所以【不適用】而不是 0｜★★★而最重要的一句：**這封信報的是【儀器落地】，不是【數字】** —— 機器上還有一個 godot 在跑，照「一次只跑一趟」我沒開第二趟
---

# ① 落地位置（★exact path，別信「在我手上」）

worktree `A:/GDS/demo/.worktrees/herald`（`feat/herald-journey-segments`），
commit `c3696b0d3` ＋ `e15c5227b`。

```
scripts/simulation/decision/decision_context.gd:906-916
   `appetite.input` 逐筆樣本 {est, true, tier, odds}（上限 400）
   `appetite.est_sum` / `appetite.true_sum` / `appetite.n`
   `appetite.dir.{E|e}{T|t}` 同向／反向粗桶
scripts/debug/attack_opportunity_bed.gd:128-166   三形狀的報表段
scripts/debug/registry_anchor_bed.gd:52-53, 65-66  ④ 的 team_id 逐筆 ＋ 母體/樣本雙報
```

# ② ★★那一條界線我有守（你 §③ 立的）

```
★`appetite.*` 讀了目標的【真實】coin+food+material ⇒ 它是 god-view。
★★所以它只進 Probe，**不進 ctx、不回頭餵秤** —— code 上的證據是：
  這五行全在 `if Probe.enabled:` 裡，且沒有任何一行 assign 給 `c.*`。
★★★交件也照你說的分兩段：床的報表段標題就寫「這一段全部是【分析欄】」。
```

# ③ ★★★兩格我沒有照表填，而是寫了為什麼

```
★【贏率估 vs 實戰】：我照你「先報母體」做了 —— 而且把地板寫成 const：
   `attack_opportunity_bed.gd` `CALIB_MIN_N = 20`。
   母體 < 20 ⇒ 印【不可判】，★並且**逐場配對接線刻意沒接**。
   ★★理由寫在輸出裡（不是只寫在信裡）：「接了也只能拿 N 筆畫校準曲線，
     而那條曲線會比沒有更誤導人」。母體上到 20 那天，配對才是下一張票。
★【風險項】：本實作**沒有獨立的風險欄位** —— 風險折在 `attack_win_odds` 裡。
   ⇒ 所以「風險恆大把胃口壓平」這一格是 **不適用**，不是 0。
   ★★我不編一個欄位來填表；若你要它成為獨立軸，那是【設計變更】，要你先裁。
```

# ④ ★還沒跑（★這是本信最容易被讀錯的一句）

```
★上面全部是【儀器】。**數字一個都還沒有。**
★★機器現況：一個 godot 正在跑（09:13 起、464MB）—— 照你的規矩【一次只跑一趟】，
   我沒有開第二趟，也沒有去動它。
★★★排隊順序照你 §⑤：多 seed 六趟 → 然後「戰爭第二層 rank dump／市場靜音／本卷」同批。
```

# ⑤ 順手回報兩件（★都不是我的，只報不動）

```
① `bed-kind-gate.sh` 本次紅一支：`scripts/debug/homeless_producer_bed.gd` 沒有 @bed-kind。
   ★它在 **main dir 裡是 untracked**（Sep 11 08:36），**不在我的 branch diff 裡**
   ⇒ 判定是別的角色的 WIP ⇒ ★★我不掃、不加、不 commit（共 main dir 那條教訓）。
② `tools/godot.ps1` 從 **Bash tool** 呼叫會 `/usr/bin/env: 'pwsh': No such file or directory`
   ★★而 **rc 仍然是 0** ⇒ 它會安靜地假裝「檢查過了」。
   ⇒ 我改走 PowerShell tool，並補了**陽性對照**（故意塞壞檔 ⇒ `child exit=1` ＋ Parse Error）
     才敢說三支檔的「解析綠」是真綠。
```
