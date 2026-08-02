---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·god-view Slice B·issues(premise 澄清,非 code 錯)] ②+③ config seed HOW 正確。但★審點④載重:team_discovered 只在 game_setup+vision:94 寫(廣掃坐實),relay/message 零寫→discovery 只經直接視野增長,非 relay。∴ blueprint「初識靠 belief 傳播長出」premise 機制不成立,emergence 後-B=純 proximity-driven。需 blueprint 確認 proximity-driven 是意圖(vs 需 relay→discovery 另 channel)+measure 據此詮釋。+審點①跨-faction 預盟 per-config 查。"
---

# R² verdict：god-view Slice B（創世全知→②+③）

**VERDICT: issues（premise 澄清 + per-config 查，非 code 錯）** — ②+③ 創世知識 seed 的 HOW 正確；但**審點④揭一機制 premise gap**（blueprint 的 emergence 模型與實際 discovery 增長機制不符），影響 measure 詮釋 + 可能揭缺 channel。`premise_contradiction: partial`（root 成立；emergence「belief 傳播長初識」premise 被 code 打臉）。

factcheck 對 HEAD `62cbf7c5`。

## Root 坐實
`game_setup._setup_explicit_teams:574-578`：`for ta: for tb: if ta!=tb: team_discovered[ta].append(tb)` = all-pairs 創世全知。8/11 config explicit → 多數 sandbox 開局全知。坐實。

## ★審點④（載重發現）：discovery 只經視野增長，非 relay → emergence premise gap
**全 repo `team_discovered` 寫入站廣掃（exhaustive）= 只 2 處**：
- `game_setup:572/578`（創世 seed，Slice B 改的）。
- `vision_system:92/94`（runtime **直接視野**偵測）。
- **message_system / belief_system / faction_ai 零寫 team_discovered**（grep 空）。

∴ **team_discovered（threat/finder/interaction 的 gate）只經直接視野（proximity）增長**；relay/message 傳 belief（team_intel 位置/stat）但**不創造 discovery**。
- **blueprint WHAT premise「初識/外交/威脅該靠 belief 傳播長出」機制上不成立**：belief 傳播（relay）加 team_intel、**不加 team_discovered** → 初識只經 vision（proximity），非 relay。
- **invariants「遠方危險經情報網進 belief」對 threat 無效**：`threat_assessment.score:12 if not team_discovered.has(other): return 0.0` → relay-only（未 vision-discovered）的遠敵 → 威脅 0。兩-channel 對**已 discovered** 隊的 belief 有效，對**未 discovered** 遠隊無效。全知時（pre-B）全 discovered→relay 有效；post-B 未 discovered 遠隊 threat 0。
- ∴ **post-B emergence = 純 proximity-driven**：兩遠隊永不互動直到物理接近 vision（vision:24 tick_discovery 每 tick 跑→隊移動即漸長 discovery，**不 deadlock** 但限鄰近）。

**要求（dispatch/measure 前）**：
- **(a) blueprint 確認 emergence 模型**：proximity-driven 冷啟動（meet neighbors→expand→meet more，realistic）是意圖嗎？還是 blueprint 期待 **relay-driven 遠識**（聽聞遠方隊即納入考量）？後者需 **relay→team_discovered channel**（新機制，非本 spec，另 slice）。**別讓 spec premise「belief 傳播長初識」與實際 vision-only 增長不符**→measure 誤判。
- **(b) measure 詮釋校準**：「遠隊開局不互動、待 proximity 才貿易/外交」是 **expected proximity-driven**（非 emergence broken）；measure 該驗「discovery 曲線隨隊移動漸長 + 鄰近互動起得來」，非「全域互動即刻」。

## 其餘審點

1. **②+③ 判準完整性 → 大致 CLEAN，1 flag**。②同 faction + ③本地鄰居 + ③淵源涵蓋創世該知。**flag：跨-faction 預盟**——若某 config **顯式預設不同 faction 的結盟隊**（開局即盟），②+③ 不涵蓋（不同 faction + 非本地 → 不 discovered）→ 該盟約起不來直到 proximity。**per-config 查 8 config 有無跨-faction 預盟/預設外交**；有則納入判準（或確認該盟靠 proximity 建立 OK）。runtime 結盟不受影響（那時已 discovered）。

2. **CREATION_KNOW_RADIUS ≥ VISION_RADIUS(3) → 方向 CLEAN**。創世認識比即時視野稍廣（出生認識附近）合理，TEST VALUE measure tune。

3. **8 config fixture 依賴全知 → CLEAN（spec 正確標 slice2 教訓）**。逐 config 判「純機制測該顯式 `omniscient_discovery:true`」vs「真實情境測補 belief」——spec 已警「別盲設全知掩蓋真 gap」。impl per-config 落地。同意此紀律。

5. **determinism → CLEAN**。②+③ = config 讀 + proximity `_hex_dist`，零 RNG。config flag 純讀。

## config flag / TDD → CLEAN
`omniscient_discovery`（default false，純機制 test set true）+ TDD（②同 faction/③本地/flag 保全知/default 非全知）設計合理。

## 回覆
issues（premise 澄清）→ ②+③ code/config flag/fixture 紀律 HOW **我認可**。卡兩點：
1. **★blueprint 確認 emergence 模型 proximity-driven（vs 需 relay→discovery 另 channel）** + measure 據此詮釋（別把「遠隊待 proximity 互動」誤判 broken）。spec 措辭改「初識靠 **vision** 增長」非「belief 傳播」（機制準確）。
2. **審點① per-config 查跨-faction 預盟**（8 config 有無顯式跨勢力預盟需納判準）。
處理完（尤 blueprint emergence 模型確認）回 R² → dispatch + measure。

——此 flag 同 dist_factor 型：「聽起來對」的 premise（belief 傳播長初識）底下機制不符（relay 不寫 discovery）。measure-first 前先坐實機制，免 measure 誤判 [[feedback_structural_audit_complement]]。
