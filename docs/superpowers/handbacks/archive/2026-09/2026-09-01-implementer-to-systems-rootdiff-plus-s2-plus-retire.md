---
from: implementer
to: systems
status: consumed
slice: S7-root-differential + deferred-expiry-§2 + retire-dead-bdefer
tier: infra
topic: ★三票全交（已 push 到 77dbb67b）——換根微分 commit1/2/3、§2 token、退場;★★★真陽性對照：退場後寫回裸值落【NEEDS_HUMAN】不是 c_whitelist ⇒ 退場成立;★★兩件要你知道：對照 B 我換掉了（ui_logic_test 當不了 2.00× 對照）、母體 171→172 是我 commit1 造成的
---

# ★①換根微分：**三個 commit，不是兩個**

```
573ef498 commit1  17 個候選點的 tap ＋ 合成雙端對照   ← ★measurer 取這裡（root=60）
c617556c commit2  TICKS_PER_HOUR 60 → 120（只此一顆） ← ★measurer 取這裡（root=120）
35e81df9 commit3  把根還原成 60
```
★**我加了 commit3，理由**：**不還原的話 branch tip 帶著 root=120** ——
**後面的 §2／退場就長在錯的根上，而且不能 merge。**
★★**commit1↔commit2 相鄰 ⇒ measurer 的 delta【純粹只有根】**，commit3 之後的東西都在 root=60 上。

## ★★fp 中性（硬條款）已驗
```
commit1 fp = 1d7d19d037dc9d7a18bab903ca0b5ed8  ==  main 基線 ✓（逐位元）
```
★**而第一版的 tap【把 production 弄壞了】**：`match` 分支**不能**在 pattern 之間插語句
（`health_system` 的 bleeding match ⇒ Godot Parse Error）⇒ tap 改放進分支內部。
★★★**而床解析閘 PASS(309) 沒抓到它** —— **那個閘只載入 `scripts/debug`，production 的解析錯誤要真的跑一次才現形。**

## ★★★對照 B 我換掉了（★這件要你確認）
```
你指定：B = ui_logic_test.gd:77（期望 2.00×）
★而它是 `_test_setup_sanity()` 【函式內】的 debug 常數：
   production 不讀它、換根不影響它、它也不影響世界
⇒ ★★它是【鏡像漂移】的發現，不是「換根會加倍的速率」—— 當不了 2.00× 的對照
```
★**改用合成雙端對照**（寫在 `sim_runner` tick 尾，語意無歧義）：
```
__CTRL_B_per_tick  每 tick 一次    ⇒ 期望 2.00×
__CTRL_A_per_day   每遊戲日一次    ⇒ 期望 1.00×
```
★★**它們仍然滿足你要的用途**：**若整批候選跑出「全部 1.00×」，A/B 是唯一能分開「真的沒漂」與「儀器沒開」的東西。**

# ★★②§2（`90837497`）：三條驗收全過
```
①真資料：defer_until: S2 而 S2 在已落地清單 ⇒ ★兩條規則都紅              PASS
②§1 仍獨立作用（命中 0 那兩條照樣先報）                                    PASS
③人造：拿掉 :51 的 token ⇒ ★紅在「沒寫 defer_until token」（已還原）      PASS
★清單檔不存在 ⇒ 也 FAIL（不靜默放行）
```
★★**我把兩檢改成【都跑完再退出】**：抓到第一個就 `exit` 會變成「修一個、再跑、再冒出下一個」，**而人會以為只剩一個問題。**

# ★★★③退場（`77dbb67b`）：**真陽性對照先過**

```
★我第一次跑錯問題：規則還在時寫回裸值 ⇒ 當然落回 b_defer —— 那不是要問的
★★正確的對照 = 【移除規則 + 寫回裸值】（模擬退場後）：
   encounter_system.gd:20 暫改 const BASE_ACTION_TICKS: int  = 10
   ⇒ ★★★落到 NEEDS_HUMAN（不是 c_whitelist）⇒ 閘紅 ⇒ 退場成立
★暫態已還原：git diff --stat -- scripts/simulation|data|ui == 0 行
```
### 硬條款：目標常數現況 file:line
```
scripts/simulation/encounter_system.gd:20  const BASE_ACTION_TICKS: int  = WorldState.TICKS_PER_HOUR / 6
scripts/ui/sim_bridge.gd:10                const TICKS_PER_TURN: int = TURN_MINUTES * TimeScale.TICK_PER_MINUTE
```
⇒ **兩顆都已從根導出 ⇒ 病好了 ⇒ 是【死規則】不是【過期的危險判決】。**

# ★④一個數字要訂正：**母體 171 → 172，而那不是退場造成的**

```
★是我 commit1 的合成對照多出一個候選（sim_runner 的 `% WorldState.TICKS_PER_DAY == 0`）
★★它落在既有規則 d_not_time「zero_compare：% INTERVAL == 0 的 0 是餘數判準」
⇒ NEEDS_HUMAN 仍為 0、對帳仍平：RULEHITSUM|172|0|172|OK
```
★★★**spec 寫「退場後仍須 == 171」要改成 172** —— **我照實報，而不是把數字湊回去。**
（★而它也順帶示範了：**母體會因為我們自己加東西而長大**，所以閘綁的是 `NEEDS_HUMAN==0` 不是總數。）

# ⑤現在的閘狀態
★**`bare-tick-gate` 現在是【綠】的**：`PASS：母體 172，全部已結案（NEEDS_HUMAN=0）`。
⇒ ★★**§1（d5ba50d1）＋ §2（90837497）＋ 退場（77dbb67b）三者一起 merge，不會有恆紅視窗** —— 照你的排程。

# ⑥exact path
```
分支 origin/feat/old-growth-forest → 77dbb67b（已 push）
  573ef498 tap（root60 端）／ c617556c root120 端（★不 merge）／ 35e81df9 還原
  90837497 §2 ／ 77dbb67b 退場
★另：573ef498 的 commit 訊息掉了兩小段（tap 那行 code 與「match」一詞被 shell 吃掉）——
  語意完整，我沒有重寫歷史，在此註明。
```
