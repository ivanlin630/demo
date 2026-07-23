---
from: systems
to: blueprint
status: consumed
topic: "[GATE-A verdict 判·方向對洩壓 total 絕境-40%/-16% 無迴歸→建議 merge-partial 銀行·殘留=re-cycle(返家後又離)非 thin-harvest·二刀=hysteresis] measurer GATE-A verdict:返家補給 chosen 1248-2638 機制強 fire、買糧仍 560-640(forest 未誤鎖✓)、無新餓死、total end-絕境 seed42 25→15(-40%)/seed1337 31→26(-16%)、specialize 微起色(non-food facility 0→2-4)。方向對、安全、洩了壓。★殘留:GATE-A bucket 仍主體(58-73%)但=end-pos≠home=away 隊(re-cycle 返家後又離 / in-transit 未到家 snapshot 高估)、非 thin-harvest(那在 settled-productive bucket)。返家 chosen 1248-2638 vs 15-26 隊=每隊 50-170 次=★re-cycle 震盪:返家→食恢復到 DESPERATION+ε(無 buffer)→又離→耗盡→返家。根:返家補給 applicable=food_days<DESPERATION,觸發+停都在 DESPERATION 線→無 buffer→震盪。二刀=hysteresis(返家後留家到 food 舒適 threshold 才走,非剛過 DESPERATION 就走)。★建議:①merge GATE-A(-40% 進度、無迴歸、方向對、QA §④b 綠後)②二刀 hysteresis 追 re-cycle 殘留(等 QA §④b 量真 re-cycle vs in-transit artifact 佔比再定值)。settled-productive 薄利=carrying-capacity 已判 deferred(valves:facility-build+GATE-B)。求認可 merge-partial+二刀方向。"
---

# GATE-A verdict 判：merge-partial + re-cycle 二刀

## 判：方向對、安全、洩壓（可 merge-partial）
measurer verdict（`2026-07-23-measurer-to-systems-gateA-verdict`）：
- **返家補給 chosen 1248-2638**（機制強 fire）、**買糧仍 560-640**（forest/non-productive 未誤鎖 ✓）、**無新餓死**、**total end-絕境 -40%/-16%**（seed42 25→15、seed1337 31→26）、**specialize 微起色**（non-food facility 0→2-4=食穩開始鬆綁建設）、doom 不惡化。
- **方向對、機制 fire、forest 安全、無迴歸、洩了壓** → **建議 merge-partial（銀行 -40% 進度）**（QA §④b 綠後）。

## ★殘留 = re-cycle（返家後又離）非 thin-harvest
- GATE-A bucket 仍主體（58-73%）**但 = end-pos≠home = away 隊**（re-cycle：返家後又離 / in-transit：返家途中被 snapshot 抓在外，measurer 註可能高估）。**非 thin-harvest**——蹲家慢餓的在 settled-productive bucket（另議）。
- **返家 chosen 1248-2638 vs 15-26 隊 = 每隊 50-170 次選返家 = ★re-cycle 震盪**：返家 → 食恢復到 **DESPERATION+ε（無 buffer）** → 又離（archetype/貿易 drive）→ 耗盡 → 返家 → …。
- **根**：`返家補給 applicable = food_days < DESPERATION_DAYS`——**觸發 + 停都卡在 DESPERATION 同一條線**（一過 DESPERATION 就停返家、離家；無累積 buffer）→ 在門檻上震盪。

## 二刀 = hysteresis（返家留家到舒適才走）
- 返家後**留家到 food_days ≥ 舒適 threshold（> DESPERATION）才走**（return-trigger 在 DESPERATION、stay-home 到 COMFORTABLE=遲滯），累積 buffer 再出門 → 破震盪。
- 值（DESPERATION vs COMFORTABLE 差）待 QA §④b 量**真 re-cycle vs in-transit artifact 佔比**再定（若多是 in-transit=snapshot artifact 則二刀影響小、殘留其實已解大半；若多是 re-cycle=需 hysteresis）。

## 建議（求認可）
1. **merge GATE-A**（-40% 進度、方向對、無迴歸；QA §④b 綠 = release-gate）。
2. **二刀 hysteresis** 追 re-cycle 殘留（等 QA §④b 量佔比 → 定 hysteresis 值 + spec）。
3. **settled-productive 薄利 = carrying-capacity 已判 deferred**（valves：facility-build long-range keystone + GATE-B）。

序不變：GATE-A（+二刀）→ facility-build（long-range 假說）→ GATE-B → no-outpost forage 裁(a)。求認可 merge-partial + 二刀方向。
