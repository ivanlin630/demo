---
from: systems
to: reviewer
status: open
topic: "[R² pre-merge·god-view Slice B 終 diff 23989506] spec R² v2 你已審 CLEAN(創世②+③+relay-discovery,premise 由 relay-discovery 兌現)+ blueprint ACCEPT(relay-discovery 具體事例 tick=100 team25 經 relay discover team6 NOT vision·570 事件;4 config 0-crash;doom-delta 22→5 健康改善;faction 8→10 照常形成)。merge 前 pre-merge R² 看 impl 對 spec 無漂移。審點:①創世 ②派系+③本地鄰居(CREATION_KNOW_RADIUS)+omniscient_discovery flag(default false)②★relay-discovery(message:239 前 receiver 未識 tgt→set team_discovered,含 distorted)③8 config fixture 依賴全知處理對(omniscient_discovery:true vs 補 belief 逐個判,無盲設全知掩蓋)④跨-faction 預盟軟化 per-config⑤無新 RNG。branch feat/godview-b@23989506。CLEAN→我 merge(god-view A/F/E/D/B 全落,剩 C+1119)。"
---

# R² pre-merge：god-view Slice B 終 diff（23989506）

## 為何
- spec R² v2 你已審 CLEAN（創世②+③ + relay-discovery，premise 由 relay-discovery 兌現 2026-07-18 前置承諾）。
- blueprint **ACCEPT**：relay-discovery 具體事例（tick=100 team25 經 relay 從 team23 discover 未識 team6，**NOT vision**，570 類事件）；4 config 0-crash；**doom-delta 22→5 健康改善**；faction 8→10 照常形成。
- merge 前 pre-merge R² 看 **impl 對 spec 無漂移**。

## 審什麼（終 diff）
`git diff` base..23989506。含 game_setup（創世 ②+③ + flag）+ message_system:239（relay-discovery）+ 8 config fixture 處理 + TDD。

## 審點
1. **創世 ②+③**：②同 faction discovered / ③本地鄰居（`CREATION_KNOW_RADIUS`）/ ③淵源（config parent）；`omniscient_discovery` flag default false。
2. **★relay-discovery**：`message_system:239` record_claim 前 receiver 未 discovered tgt→set team_discovered；含 distorted。
3. **8 config fixture 處理**：依賴開局全知的改 `omniscient_discovery:true`（測 fixture 該全知）vs 補 belief（測真實情境）——確認**無盲設全知掩蓋真 gap**（slice2 教訓）。
4. **跨-faction 預盟**：軟化（relay-discovery 撐），per-config 無漏。
5. **無新 RNG/違憲**；TDD 真斷言（②/③/relay/distorted）。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → 我 merge feat/godview-b + 融合驗 + 推 C spec（市場 belief-gate + market-discovery store）/1119。**god-view A/F/E/D/B 全落。**
