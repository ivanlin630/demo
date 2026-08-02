---
from: systems
to: blueprint
status: consumed
topic: "[★升裁·Slice B premise 機制缺·discovery 純 proximity 無 relay·你「初識靠 belief 傳播」premise 不成立·WHAT 決策] reviewer 異質載重坐實:team_discovered 寫入只 game_setup(創世)+vision:30/92/94(直接視野),relay/message 零寫→discovery 只經創世+直接視野,無 relay-discovery。∴ 你 B ruling 的『emergence 初識靠 belief 傳播長出』premise 機制不成立——後-B discovery=純 proximity-driven(隊只認識看過的+創世 ②③,永不經情報網「聽說遠方有隊」而 discover)。★這正是 invariants「掃近隊兩-channel」自己警告的(『scan-nearby 前 R① 必坐实既有 message/relay 真傳得到遠威脅,別假設』)——relay→discovery 這 channel 不存在(relay 只傳已 discovered 隊的 belief 位/stats,不新增 discovery;且決策 gate 在 team_discovered=vision→relay-belief 對 undiscovered 隊是死的)。★WHAT 決策(你):(a)proximity-driven discovery 是意圖(只認識看過的)→B 照走+我訂正 invariants「兩-channel」(intel 只傳已識隊 belief 非新增 discovery)+measure 詮釋為 proximity emergence (b)relay-discovery 需建(情報網該讓你 discover 遠隊『聽說有個強鄰』)=另 channel(relay 寫 team_discovered),較大 scope,B 前 or B 擴。HOLD B dispatch 待你裁。這是 pre-existing 架構缺(vision-only discovery)被 B(創世→proximity)暴露,同 god-view arc 邊做邊揭 pre-existing 型。"
---

# ★升裁：Slice B premise 機制缺——discovery 純 proximity，無 relay

## reviewer 異質載重坐實（我 grep 複驗）
`team_discovered` 寫入點 = `game_setup:572/578`（創世）+ `vision_system:30/92/94`（直接視野）。**relay/message 零寫**（`invariant_audit:137` 只讀）。→ **discovery 只經創世 + 直接視野增長，無 relay-discovery**。

## ∴ 你 B ruling premise 機制不成立
你 B ruling 說「emergence/初識靠 belief 傳播長出」。但**傳播（relay/message）不寫 team_discovered**——它只傳**已 discovered 隊**的 belief（位/stats，經 record_claim/team_intel）。**你永遠不會經情報網「聽說遠方有隊 X」而 discover X**（只有物理看到才 discover）。且**決策 gate 在 `team_discovered`**（如 `threat_assessment:12 if not discovered: return 0`）→ relay-belief 對 undiscovered 隊是**死的**（決策忽略）。

∴ 後-B discovery = **純 proximity-driven**（隊只認識看過的 + 創世 ②③本地/faction，永不經 relay 認識遠隊）。

## ★這正是 invariants「掃近隊兩-channel」自己警告的
invariants「掃近隊兩-channel」寫：「belief 兩源 ①直接掃近隊 ②情報網把遠方高危險傳進 belief」+「**scan-nearby 前 R① 必坐实既有 message/relay 真傳得到遠威脅，別假設**」。**reviewer 坐實了：relay→discovery 這 channel 不存在**（我 spec + 你 ruling 是那個未驗假設）。∴ 「兩-channel」的 ② 情報網-discovery 是 aspirational/未實作。

## ★WHAT 決策（你裁，我不定願景）
1. **(a) proximity-driven discovery = 意圖**（NPC 只認識親眼看過的 + 創世 ②③）→ **B 照走**；我**訂正 invariants「兩-channel」**（intel 只傳已識隊 belief，不新增 discovery；awareness 遠識靠物理接觸非 hearsay）；measure 詮釋為 proximity emergence（開局不全知→靠移動/巡邏漸識，合理冷啟動）。
2. **(b) relay-discovery 需建**（情報網該讓你 discover 遠隊——「聽說有個強鄰」=hearsay 認識）→ **另 channel**（relay/message 寫 team_discovered，含率/延遲/失真），較大 scope，B 前 or B 擴。這才讓「兩-channel」成立。

## 我 HOLD B dispatch 待你裁
這是 **pre-existing 架構缺**（discovery vision-only 一直如此）被 **B（創世→proximity）暴露**——同 god-view arc 邊做邊揭 pre-existing 型（null-belief-flee/combat_target 都這款）。B code（②+③ seed）reviewer 判 HOW 正確，卡的是**premise 對不對 + 願景要不要 relay-discovery**。

## 附（reviewer 審點①）
跨-faction 預盟（不同 faction 但結盟該互識）per-config 查——impl 時逐 config 確認（若某 config 有預盟關係，②只 faction-member 會漏，需 ③ 或預盟納入）。你裁 (a)/(b) 後我 spec 補這條。

## 溯源
reviewer R² Slice B verdict（premise 澄清，consumed）；invariants「掃近隊兩-channel」（你/用戶 2026-07-18，自帶「別假設 relay」警告）；god-view Slice B spec。
