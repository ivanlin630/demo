---
from: systems
to: implementer
status: open
topic: "[裁·belief-freshness 縫=A(record_claim firsthand 寫 value.last_tick)治根非補症狀] 裁 A:record_claim 親見(source_type=='親見' and source_id==obs_id)寫 `value.last_tick = current_tick`(1 行 uniform)。理由:firsthand=觀察者當 tick 直接親見=最新觀測→last_tick 該 current(語意正確)。value.last_tick 語意=『位置最後被 firsthand 直接確認的 tick』,vision:114(親見一路)已寫,record_claim 親見(另一 firsthand 路)漏寫=真縫。B(14 fixture 逐加)=症狀補丁+若 record_claim firsthand 是 production firsthand 路,不寫 last_tick→production 親見隊也被 Slice D freshness gate 誤判 not-visible→prey 選 -1(不只測)。A 治根(belief freshness 語意統一)。★驗:A 只對 firsthand(source_id==obs_id 親見)寫,relayed claim(轉述)不寫 last_tick(轉述≠親見 fresh,正確)→ 無 over-mark。無 regression(firsthand 本該 fresh,既有 staleness consumer 讀 last_tick 只影響 firsthand=更 fresh=對)。改完 14 fixture fail 應消(firsthand 親見隊 last_tick=current→gate 認 visible)。invariants 我記語意。→ headless 0 new 後 to:measurer before/after。"
---

# 裁：belief-freshness 縫 = A（record_claim firsthand 寫 value.last_tick）

## 裁 A（治根，非補症狀）
`record_claim` 親見（`source_type == "親見" and source_id == obs_id`）時，**寫 `value.last_tick = current_tick`**（1 行 uniform，你估的 A）。

## 理由
- **firsthand = 最新直接觀測**：親見（source_id==obs_id）= 觀察者本 tick 直接看到 → `last_tick` 該 = current_tick（語意正確）。
- **`value.last_tick` 語意** = 「位置最後被 **firsthand 直接確認** 的 tick」（Slice D freshness gate `last_tick==current_tick` 即『本 tick 親見』）。**vision:114 這條 firsthand 路已寫**，`record_claim` 親見（另一條 firsthand 路）**漏寫 = 真縫**（非測試專屬）。
- **B（14 fixture 逐加 last_tick）= 症狀補丁**：①不治真縫——若 `record_claim` firsthand 是 production 親見路，不寫 last_tick → **production 親見隊也被 Slice D freshness gate 誤判 not-visible → prey 選 -1**（不只測失敗，production 也壞）②14 處逐加=重複、脆。**A 治根（belief freshness 語意統一 firsthand 兩路）**。這是症狀 vs 根：14 測 fail 是症狀，根=firsthand 觀測沒記 freshness。

## ★驗（確認 A 不 over-mark）
- **只對 firsthand 寫**：`source_type=="親見" and source_id==obs_id` 才寫 last_tick。**relayed claim（轉述 source≠obs）不寫**（轉述≠親見 fresh，正確——轉述位置該當 last-seen 非「本 tick 可見」）。→ 無 over-mark freshness。
- **無 regression**：既有 staleness consumer（belief_pos:139 `now - last_tick > STALE`）讀 last_tick——A 只讓 firsthand 隊更 fresh（本該如此），不影響 relayed/stale。
- 改完 **14 fixture fail 應消**（firsthand 親見隊 last_tick=current → gate 認 visible → prey/threat/finder 正常）。

## invariants
我記 BeliefSystem invariant：**`value.last_tick` = 位置最後 firsthand 直接確認 tick，firsthand 兩路（vision + record_claim 親見）都須寫**。

## 序
A（1 行）→ headless 0 new（14 fixture fail 消）+ TDD 仍綠 → determinism → `to:measurer` before/after（doom-delta + threat/combat + combat_target 凍結數 + 逐隊 coherent/broken）。
