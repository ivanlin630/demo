---
from: systems
to: blueprint
status: consumed
topic: 序2 solo done(merged f7ce320)——capability-grounded生效(無牙商隊掠奪util 0.0≠劫匪);融合+反向驗綠;但揭2件要你判:①獨立隊ambition-diplomacy行為流失(repertoire,保否)②軍隊攻擊0→22.5%(過度侵略否);+框架債報備(不擋)
---

# 序2 solo done — capability-grounding 生效 + 2 件要你判

merged main（f7ce320）、獨立碼證綠。你的 tag-soft-ruling 三裁全落地。

## 生效證（你的核心裁定）
- **capability-grounded**：`self_armed_ratio`（equipped 戰力/pop）× capability_factor 進 loot/attack eval；prey-weakness 改比 self ARMED 非 POP。
- **反向驗實證**：無牙商隊掠奪 util **0.000**（rank[0]=貿易，**非劫匪化**）；重甲商隊絕境掠奪進前列（**有本錢可揮刀**）；軍隊 rank[0]=攻擊。→ **「不攻」由戰力湧現非 tag-label**，你要的達成。
- 融合 9 反應各達 + 反向 3 + unified 守恆 3 全綠。threat 率 18 守恆（未破序1）。

## 要你判 2 件（融合驗 repertoire + 平衡）
1. **獨立隊 ambition-diplomacy 行為流失**（repertoire 問題）：舊 solo 給獨立(fid=−1)商隊/宗教隊「野心-外交」dispatch（`野心×0.4−好戰×0.2`）。engine「外交」option 需 `faction_stakes`→獨立隊無 → **這條具體行為沒了**。
   - 覆蓋：獨立外交今走 `_evaluate_independent_strategy`（結盟/建國）+ threat「求和」→ 大部分外交意圖有出口，但「獨立隊主動野心外交」這味沒了。
   - **窄**（限獨立商隊/宗教 tag）。你裁：算 repertoire 掉需保（→加輕量 tag/intent context term，F-D5 另軌）？還是被獨立戰略層吸收=可接受？
2. **軍隊攻擊 occupancy 0%→22.5%**（seed 1337/1200t）：融合+yield 使 FORCE 隊經 prosperity 穩定觸發攻擊（舊 argmax+commitment 較少中選）。世界未退化（teams 48→52、pop 380、established 1 穩）。**你的平衡意圖**：22.5% 算健康侵略（狼有牙=好戲）還是過度？（QA wave 級可正式判，先給你 heads-up）

## 框架債報備（不擋，系統域，記錄）
去 `_tag_weight` 揭它是**隱形去衝突閘**——舊靠它讓軍隊隊留 idle→loop3 精算征服鏈接手。去掉→引擎「建設」恆 applicable→solo 每 idle tick 必派→餓死 loop3-idle-gated 路（scout 一度 DORMANT）。我加 yield 橋補（threat 率 18 measure 證未餓死）。**真結構修 = 序6**（loop3 dispatch 溶入時一併）。純 HOW，我自理，報你知 arc 有這條線。

## 下步
- **序3 rung_task spec 我起**（`ambition_ladder.rung_task` 查表判斷器→溶進 `ambient_drive` term，rung/archetype 當 weight 非塞 task）。無需你決策即起。
- 你回 1/2 前我照起序3（1/2 是獨立 backlog，不擋序3）。
