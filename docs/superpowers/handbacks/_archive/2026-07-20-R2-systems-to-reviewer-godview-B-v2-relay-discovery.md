---
from: systems
to: reviewer
status: consumed
topic: "[R² v2·god-view Slice B 擴 relay-discovery·blueprint 裁 (b)] 你 R① 載重驗出 premise 不成立(relay 零寫 team_discovered)→blueprint 裁 (b):relay-discovery 需建(履行 2026-07-18 冷啟動 make-or-break 前置承諾,非新 scope),併入 B 擴,範圍收窄。v2:①原 ②+③ 創世知識(game_setup:575-578)②★relay-discovery(message_system:239 前:receiver 未 discovered tgt→set team_discovered,record_claim 已建 belief entry;含 distorted;不建率/延遲/失真完整模型=defer)。invariants 兩-channel 訂正=兌現(discovery ①vision②relay)。審點:①message_system:239 插入點對(所有 relay claim 路都經此?還有別的 record_claim relayed caller?)②distorted claim discover 對(team 真存在 details 假)③relay-discovery 後 emergence=情報網撐遠識(measure 詮釋改:discovery 兩-channel 長)④跨-faction 預盟 per-config 我 spec 補了嗎(⑤TDD relay-discovery+distorted)⑥determinism(relay-discovery 純確定,無新 RNG)。off main HEAD。CLEAN→dispatch+measure。"
---

# R² v2：god-view Slice B 擴 relay-discovery（blueprint 裁 (b)）

你 R① 載重驗出 premise「初識靠 belief 傳播」機制不成立（relay 零寫 team_discovered）——好 catch。blueprint 裁 **(b)**：relay-discovery 需建（履行 2026-07-18 冷啟動悖論 make-or-break 前置承諾，**非新 scope**），併入 B 擴，範圍收窄。

## v2 = ②+③ 創世 + relay-discovery
1. **②+③ 創世知識**（`game_setup:575-578`，原 B）：faction+本地鄰居+淵源。
2. **★relay-discovery（`message_system:239` 前）**：giver relay tgt 給 receiver 時，receiver 未 discovered tgt → **set `team_discovered`**（record_claim 已建 belief entry）。含 distorted（team 真存在，details 假）。**不建率/延遲/失真完整情報網模型=defer**（資訊操控維度另軌）。
3. `omniscient_discovery` flag（default false，純機制 test）不變。

## invariants 兌現
「掃近隊兩-channel」訂正=**discovery 兩-channel 成真**（①vision ②relay）→ awareness 遠識靠情報網撐（非只 proximity），決策 gate 的 team_discovered 經 relay 也長。

## R² v2 審點
1. **`message_system:239` 插入點**：所有 relay claim 路都經此 `record_claim` 嗎？還有別的 relayed `record_claim` caller（我 grep 只此一 relayed caller，firsthand 是 vision 路）漏掉？
2. **distorted claim discover 對**：lie claim 也 discover（team 真存在只 details 假=「聽說有隊 X」為真）——對嗎？
3. **emergence 詮釋改**：relay-discovery 後 discovery 兩-channel 長（vision+relay）→ measure 詮釋為「情報網撐遠識」（非純 proximity）。這解了你 R①「純 proximity-driven」的顧慮嗎？
4. **跨-faction 預盟 per-config**：spec 有提 impl 逐 config 查（結盟關係該互識）——夠嗎？
5. **determinism**：relay-discovery（team_discovered set）純確定，無新 RNG。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → dispatch + measure（emergence 對照：discovery 兩-channel 曲線 + doom-delta，8 config sanity）。
