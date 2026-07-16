---
from: blueprint
to: systems
status: consumed
topic: [新大方向 characterize] 名聲驅動自願歸附——查三閉環現況+scope;consolidation走pull繞征服死結
---

# systems 工單：名聲驅動自願歸附 — 三閉環 characterize + scope

用戶定案（2026-07-11）。design doc 已寫 + committed（`consolidation-unified-decision-design.md` §★★★名聲驅動自願歸附）。這是 consolidation arc 的解答，**繞過征服死結**。

## 核心（WHAT）
decision trace 揭：和平併 ~0 = 征服/覓食/逃跑被調主宰 + 強方吸納(push)恆輸征服。**改走 pull**：弱隊自願投奔**記憶中名聲好**的保護傘。
- 逃 vs 投靠 weight 讀**主觀** `known_reputations[protector]`（team_data:187 已 per-observer）。
- 高名聲仁君→滾自願聯邦(pull)；低名聲暴君→鐵蹄征服(push，現狀不動)。**不動征服平衡**（避 risky rebalance）。
- 名聲=主觀 + 傳播（用戶選 b=吃親身+二手傳聞）+ 事件記憶(relation_edges)。

## 要你 characterize（先查現況，別建）
**三閉環 — 各回 file:line + 現況（已在/部分/沒建）：**
1. **`known_reputations` 更新源**：`team_data:198 update_reputation` 被**什麼觸發**？只親身接觸(打/交易)，還是也吃**傳聞**(message_system/belief_system 帶二手名聲)？用戶要 b=也吃傳聞——現在接了沒？
2. **事件→名聲**：`relation_edges`(protect/gratitude/betray/killed) 有沒有接進 `update_reputation`？護人→名聲漲、背叛→跌，這條在不在？
3. **名聲賺得起/掉得下**：現有觸發夠不夠讓名聲脫離中性 0.5 有意義波動？否則磁鐵發不動。
+ **決策改點**：`投靠`/`survival(FLEE)` 的 term/weight 現在讀不讀 `known_reputations[protector]`？（trace 場景 E：逃 1.0 vs 投靠 0.82，掛名聲後高名聲 host 該讓投靠翻盤。）

## scope 評估
這是**新大方向**（比補 utility 大）：名聲傳播(接 message/belief) + 主觀名聲驅動歸附 + 逃vs投靠改 + 名聲賺取閉環。回報：
- 三閉環各**已在多少 / 要建多少**。
- 總 scope 量級（tweak / 中 slice / 大 arc）。
- 咬哪些既有系統(message/belief/relation_edges/known_reputations)——**複用非重造**(01 judge 盤點)。

→ blueprint 給 user 裁投資額。**a/b/c 續按住**（這條若成，consolidation 靠名聲歸附活，不需征服 rebalance）。

## 守則
- 複用既有(known_reputations/message/belief/relation_edges)，禁重造。
- 名聲驅動決策仍走 rank_scored 真 term，過框架內冗餘 lens。
- 主觀非全知（讀 per-observer known_reputations，非全域真值）——這是用戶核心要求，別偷懶直讀全域。

先 characterize + scope，別急建。回 blueprint。
