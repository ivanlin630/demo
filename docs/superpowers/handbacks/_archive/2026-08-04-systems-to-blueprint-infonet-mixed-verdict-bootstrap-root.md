---
from: systems
to: blueprint
status: consumed
topic: "[資訊網whole measurer verdict=MIXED(非全綠非全紅)·2/4真活2/4死·QA:PENDING(attrition行為結論待QA故事稽核+specimen非中性)·①✅Part1看板relay+Part3 peer交易真活=商業unstall genuine(trade.deal+72%/order_fulfilled 5→25 warring多床非窄場景)②✅⚠attrition=genuine emergent合作非戰鬥抑制regression(winner_loot↑6→12/10→23·combat持平偏升·starve_anon↓4→1·商業↑=真解釋;但月1雙seed scope限縮+specimen非中性→QA:PENDING未鎖)③★★BLOCKER:Part2 herald求援+scout偵察=完全0 fire(用戶核心有意決策死)+甲distribute仍0·root獨立驗code-proven(非行為需QA):help_target identity解析對(decision_context:350自家faction領主leader_team_id via faction結構)但POSITION卡best_estimate live-belief(:348無belief位→-1→永不applicable),faction成員從不meet→無live-belief位→永不知去哪求=bootstrap死結·fix方向:help/scout_target_pos fallback faction-結構已知位(faction家/首府outpost·成員assigned據點=membership已知非god-view,信使仍物理走delay,≠直掃backdoor)·感知鐵律read待你ratify(faction自家seat位membership已知=reliable端非god-view)④★observer-RNG regression:specimen跑91 vs clean 86 teams=SpecimenDumpHelper非中性(第3次同族feedback_observer_no_rng不變量違),undermines QA specimen trace,must-fix·序建議:1 observer-RNG fix(specimen可信)→2 bootstrap fix(Part2活)→3 re-measure→4 QA故事稽核→5 accept·地基KEEP待你ratify感知鐵律read+序"
---

# 資訊網 whole verdict = MIXED（2/4 真活、2/4 死、待 fix + QA）

measurer 獨立 whole 量（`2026-08-04-measurer-...-verdict.md`、多床 warring+explicit fixture）。**非全綠非全紅**：

## ✅ 真活（Part1+Part3）
- **S-prop 看板 relay + S-trade peer 交易**：商業 unstall **genuine**——`trade.deal +72%`（36→62/40→66 兩 seed）、`order_fulfilled 5→25`（5倍）、`board.relay_deposit 356-504`、`peer_deal 27/34`。**warring 多床、非窄場景 premature**。
- **economy 不爆**（keep-line 守、領主餘糧穩定）、determinism byte-identical、fog 小規模保住。

## ✅ ⚠attrition = genuine emergent 合作、非戰鬥抑制 regression（但 QA:PENDING）
- attrition 0.68%→0%/0.69%→-0.46%；**戰鬥沒被壓**：`conq.winner_loot↑`(6→12/10→23)、`conq.declared/combat_entered` 持平偏升。真解釋=`death.starve_anon↓`(4→1) + 商業↑。
- **★QA: PENDING**（我機械閘）——此=**行為因果結論**（「attrition↓=合作非壓戰鬥」正是前科誤讀家族）、**待 QA 故事稽核**；且 specimen 跑非中性（下 ④）→ 故事 trace 需 fix 後重跑。**未鎖此結論**。scope 限縮：月1雙seed（measurer 誠實揭、未 cross-month）。

## ★★BLOCKER：Part2 herald+scout = 完全 0（用戶核心「有意決策」死）+ 甲 distribute 仍 0
- **root = bootstrap 死結（code-proven、我獨立驗、非行為需 QA）**：`decision_context.gd:342-350` help_target **identity 解析對**（自家 faction 領主 `leader_team_id`、via faction 結構）**但 :348 POSITION 卡 `BeliefSystem.best_estimate(team,lord).tile_pos`**——無 live-belief 位→-1→`help_target_id` 留 -1→option 永不 applicable。scout 同款（:365 子民 belief 位無→跳）。**faction 成員從不 meet→無 live-belief 位→永不知去哪求/查=死結**（跨 explicit fixture + warring 84-92 隊皆 0、非邊角）。
- **fix 方向（HOW、感知鐵律-clean）**：`help/scout_target_pos` **fallback 到 faction-結構已知位**（faction 家/首府 outpost、成員 assigned 據點）——**membership 已知（你知自家 faction 的 seat/成員據點）≠ god-view**，信使仍**物理走 belief-或-home 位（delay）**。**≠直掃 backdoor**（真物理載體、延遲、deposit）。
- **★待你 ratify 感知鐵律 read**：faction 自家 seat/成員據點位 = **membership 已知（reliable 端）非 god-view**——同資訊網「intra-faction 快 reliable」的底線（你知自己屬於哪、home 在哪）。此非開直讀後門（載體照走）。

## ★observer-RNG regression（must-fix、undermines QA specimen）
- specimen 跑 `teams=91` vs 同 seed clean 跑 `teams=86`＝**SpecimenDumpHelper 非中性**（第 3 次同族、[[feedback_observer_no_rng]] 觀測儀器禁耗 global RNG 不變量違）。measurer 誠實取 clean 跑數字。**must-fix**：否則 QA 讀的 specimen trace 是分岔世界、故事稽核不可信。

## 序建議（measure-first、QA gate 尊重）
1. **observer-RNG neutrality fix**（specimen 可信）→ 2. **bootstrap fix**（Part2 herald/scout 活、甲 distribute 通）→ 3. **re-measure whole**（含中性 specimen）→ 4. **QA 故事稽核**（attrition 合作 + Part2 湧現 + 死因故事、出 verdict ref）→ 5. blueprint accept。

**待你**：①ratify 感知鐵律 read（faction seat/成員位 membership 已知=legal）②序 OK？→ 我設計 bootstrap fix + observer-RNG fix HOW spec → R² → build → re-measure。地基 KEEP。**（現 infonet 未 accept、Part2 核心未活、誠實不宣稱勝。）**
