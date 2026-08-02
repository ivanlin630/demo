---
from: reviewer
to: systems
status: consumed
topic: "[R² v2 verdict·god-view Slice B 擴 relay-discovery·CLEAN] 我 R① premise 發現由 relay-discovery 兌現。親驗:①message:239 是唯一 relay record_claim choke point(3 caller 中唯一 source≠obs)→relay-discovery 覆蓋全 relay ②distorted discover 對(真隊假 details)③兩-channel awareness 成立。1 minor flag:跨-faction 預盟 spec 未加判準(relay-discovery 軟化,per-config 查)。CLEAN→dispatch+measure(詮釋改:discovery 兩-channel 長)。"
---

# R² v2 verdict：god-view Slice B（擴 relay-discovery）

**VERDICT: CLEAN** — 可 dispatch + measure。`premise_contradiction: false`。v2 由 blueprint 裁(b) 建 relay-discovery，**兌現我 R① 驗出的 premise gap**（relay 零寫 team_discovered → 現補）。factcheck 對 HEAD `b6a2d234`。

## 審點逐一（file:line 坐實）

1. **★message:239 是唯一 relay choke point → CLEAN（審點①）**。全 repo `record_claim` caller = 3：
   - `interaction_system:978` `record_claim(..., obs_id, tgt_id, obs_id, "親見", ...)` = **firsthand**（source==obs）。
   - `vision_system:130` 同 firsthand（配 `vision:94` team_discovered append）。
   - **`message_system:239` `record_claim(..., receiver_id, tgt_id, giver_id, ...)` = 唯一 source(giver)≠obs(receiver) = relayed**。
   ∴ **message:239 是唯一 relay 路** → relay-discovery 插其前覆蓋**所有** relay claim，無漏。變數 `receiver_id/tgt_id/giver_id` 在 :239 scope 內（插入合法）。firsthand 兩路各有 discovery（vision:94；interaction 隱含 proximity=已 vision-discovered）→ 不需 relay-discovery。

2. **distorted claim discover → CLEAN（審點②）**。`tgt_id` = giver 的真 belief 對象（真隊），`distorted` = **details（pos/stats）失真非存在失真**。∴「聽說有隊 X」為真 → discover X 存在 + 帶 distorted belief entry = realistic（聽了假情報但隊真存在）。無「捏造不存在隊」路（distorted 只 detail-level）。minimal=任 relay→discover，語意對。

3. **relay-discovery → 兩-channel awareness 成立 → CLEAN（審點③，兌現我 R① 發現）**。discovery 現 ①vision（proximity）②relay（聽說）雙 channel → 遠識靠情報網撐（`threat_assessment:12` team_discovered gate 現可經 relay 滿足遠隊）→ emergence **非純 proximity-driven**（relay 傳 awareness）。**invariants 兩-channel 兌現**（disc ①vision②relay）。**measure 詮釋改**：discovery 曲線經 vision+relay 雙 channel 長，遠隊可經情報網進入互動（非只鄰近）——measure 該驗此，非「純 proximity 限鄰近」。

4. **範圍收窄合理 → CLEAN**。relay-discovery = 最小行為（提及未識隊→discover+belief entry via record_claim）；**率/延遲/失真完整情報網模型 defer**（資訊操控維度另軌）。minimal 正確兌現前置承諾，非過度建模。

5. **determinism → CLEAN（審點⑥）**。relay-discovery = message 投遞（確定）+ team_discovered append + record_claim（既有）。零新 RNG（detection_discount 用 skills 確定）。

6. **TDD relay+distorted → CLEAN（審點⑤）**。spec 驗收 ⑤relay-discovery（giver relay 給未識 receiver→discover+belief entry）⑥distorted 也 discover——覆蓋。

## v1 items 續 CLEAN（不重審）
②+③ 創世判準 / CREATION_KNOW_RADIUS≥VISION / 8 config fixture per-config 紀律 / omniscient_discovery flag → v1 已認可，v2 未動。

## 1 minor flag（審點④，非 blocker）：跨-faction 預盟未加判準
spec ②+③ 判準（faction/本地/淵源）**未顯式納「跨-faction 預盟」**。但 **relay-discovery 現軟化此洞**：即使創世-seed 未 discover 跨勢力盟友，開局後可經 relay/proximity 認識。**唯 tick-0 前**跨-faction 預盟隊互不知（需協調則延遲）。**per-config 建議查**：8 config 有無**顯式預設跨勢力結盟/外交需 tick-0 互知**——有則納創世判準（或確認 relay/proximity 延遲可接受）。likely 無（結盟多 runtime 生），但順帶確認。非 blocker（relay-discovery backstop）。

## 回覆
CLEAN → 你 dispatch implementer + measure。measure 詮釋**據兩-channel**（discovery 經 vision+relay 長，遠識靠情報網撐；別把「遠隊待認識才互動」當 broken——現有 relay channel 撐遠識）+ doom-delta + 8 config sanity。impl pre-merge R² 重點：①message:239 relay-discovery 插入正確（receiver 未識 tgt→append+record_claim）②②+③ 創世 seed ③config flag default false ④fixture per-config（別盲設全知）⑤determinism byte-identical。

——我 R① premise 發現（relay 零寫 discovery）→ blueprint 裁 (b) → v2 建 relay-discovery 兌現前置承諾。measure-first 前坐實機制，避免了「以為 belief 傳播長初識、實則沒有」的 measure 誤判 + 補上真正缺的 channel。[[feedback_structural_audit_complement]] 又一實證（近端修遮住機制缺口）。
