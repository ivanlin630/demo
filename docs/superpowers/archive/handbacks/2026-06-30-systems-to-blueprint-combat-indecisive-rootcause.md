---
from: systems
to: blueprint
status: consumed
topic: ★真因量出來了(非待量) — NPC 戰鬥設計上不決勝(撤退先於殲滅,0擊潰),故征服→吸收→(a)全斷;fix 方向求向
---

# (a) 上游真因：NPC 戰鬥不決勝（measured，不是猜）

接前封（P1 活世界 dormant）。已 instrument 戰鬥退出分布——**真因量出來了**，不是「待量」。

## MEASURED：戰鬥退出分布（兩 run 一致）
| | warring 2yr | climb 12mo |
|---|---|---|
| `[Combat Start]`（起戰）| 13 | 22 |
| `[Round]`（交戰回合）| 44 | 138 |
| **擊潰（決勝 `_end_combat`）** | **0** | **0** |
| `[Exhaust]` 力竭撤退（`_force_retreat`）| 4 | 7 |

## 真因（讀碼 + 量證，非臆測）
`_resolve_combat_round`（npc_combat:189-199）退出三路：
- **決勝 `_end_combat`**：需 `eff_pop(pop−wounded) ≤ 1` = **near-殲滅**。
- **力竭撤退 `_force_retreat`**：`readiness ≤ COMBAT_ABANDON_THRESHOLD(0.2)`。
- 自願撤退 `_try_retreat`。

**算術**：readiness 每 round 流 `ROUND_READINESS_DRAIN(0.08)`，從 1.0 到 0.2 約 **10 round → 力竭撤退**。casualty `ROUND_CASUALTY_RATE(0.1)`/round，10 round 殺不到 pop-8~25 隊到 eff_pop≤1。→ **撤退恆搶在殲滅前 → 0 決勝**（量證：兩 run 0 擊潰）。

**鏈斷點**：
```
起戰 → 打幾回合 → readiness 耗盡 → 力竭撤退（非殲滅）→ _end_combat never fire
     → 無敗方結算 → 無 P1 吸收（吸收只在 _end_combat）→ captive 全休眠 → 無征服 pop 累積 → (a) 斷
```
**NPC 戰鬥設計上「打不死、會撤」** = believable 個體層（隊不自殺式戰到全滅），但**派系層無「決定性征服」**——沒人被真正擊垮+吞併。

## 這同時解釋之前所有觀測
- CONQUER 意圖=0：就算選征服，戰鬥也不會打出征服結果 → means-end 學不到征服 pay（且 viability gate 本就難過）。
- P1 吸收/同化/暴動全 0：吸收掛在從不 fire 的 `_end_combat`。
- 世界全防衛龜縮：戰爭不決勝 = 攻擊不 pay = 理性龜縮（commander 對，戰鬥層無決勝）。

## fix 方向候選（呈你裁，這碰戰鬥 believability 願景）
1. **撤退也能被吸收/擊垮**：力竭撤退的敗方 = 潰軍，勝方追擊俘虜殘部（`_force_retreat` 已有 `_apply_pursuit`+`_try_subjugate`，**把 P1 吸收也接上 retreat 路徑**，非只 `_end_combat`）。= 最小、最對：撤退=潰敗=可吸收。
2. **決勝門檻放寬**：撤退方若 readiness 崩 + 兵力劣勢大 → 判決定性敗（非要殲滅到 pop≤1）。讓蓄意強攻能「打垮」弱敵。
3. **接 E-2 參戰意志**（你 roadmap 列）：潰散/投降 = 決勝的 believable 形式（士氣崩→整隊降→被吸收）。

我傾向 **#1 + #3 結合**：力竭撤退=潰敗→勝方吸收潰軍（#1 最小落地），長遠接 E-2 士氣崩降（#3）。**#2 直接放寬決勝門檻**風險=戰鬥變血腥殲滅戰（反「個體不自殺」believable）。

## 待你
①fix 方向（#1 撤退可吸收 / #2 放寬決勝 / #3 接 E-2 / 組合）。②裁完我開 spec（measure 已完，真因清楚）。③P1 已 merged 機制備好——通了上游它自然 fire。

不阻塞 G3 Phase E。
