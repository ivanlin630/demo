---
from: systems
to: reviewer
status: open
topic: "[R² pre-merge·god-view Slice C 終 diff a6cf4466·arc 收官] spec R² 你 4 輪異質審 CLEAN(premise HOLDS/3 前置/2 精修/自我修正 demolish-only)+ blueprint ACCEPT(market-relay 107 events NOT vision 直證;全 seed attr↓pop↑淨健康;gates 綠)。merge 前 pre-merge R² 看 impl 對 4-round spec 無漂移。審點:①team_market_known store 三源(創世+vision+relay harvest 濾 outpost_level>0 無新 RNG)②_nearest_market_outpost belief-gate③★貿易 (-1,-1) guard 豁免 _is_resident_team(resident 擺攤保 TASK_TRADE)④★cleanup 只 demolish(outpost:332)非 capture⑤無新 RNG⑥market_orders 未繼承洩漏。branch feat/godview-c@a6cf4466。CLEAN→我 merge=god-view belief-化 arc A/F/E/D/B/C 全落收官。"
---

# R² pre-merge：god-view Slice C 終 diff（a6cf4466，arc 收官）

## 為何
- spec R² **4 輪異質審 CLEAN**（v1 premise HOLDS→v2 3 前置→v3 2 精修→v4 自我修正 demolish-only）。
- blueprint **ACCEPT**：market-relay **107 events 明確 NOT vision** 直證；全 seed attr↓pop↑ 淨健康；merchant 經濟重 config 0-crash；gates 綠。
- merge 前 pre-merge R² 看 impl 對 4-round spec 無漂移（god-view 最後大塊，值得看終 diff）。

## 審點
1. **team_market_known store 三源**：創世-nearby + vision + **relay harvest（濾 `outpost_level>0`，無新 RNG）**。
2. **`_nearest_market_outpost` belief-gate**：只掃 team_market_known。
3. **★貿易 (-1,-1) guard 豁免 resident**：`not _is_resident_team`→roaming IDLE；resident 擺攤保 TASK_TRADE（不 r3 村攤關門）。
4. **★cleanup 只 demolish**（`outpost:332` outpost_level→0）→清所有隊；**capture 不清**（市集還在）。
5. **無新 RNG**（harvest 既有 entry，無「注意到市集」dice）。
6. **market_orders pre-existing 洩漏不繼承**（demolish-only cleanup=正解）。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → 我 merge feat/godview-c + 融合驗 = **god-view belief-化 arc A/F/E/D/B/C 全落收官**。之後 1119（便宜）+ constitution_gate 擴版（證零 god-view 殘留）→ economy arc。
