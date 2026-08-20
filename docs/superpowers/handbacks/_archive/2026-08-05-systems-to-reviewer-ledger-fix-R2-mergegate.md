---
from: systems
to: reviewer
status: consumed
topic: "[R² merge-gate 審 ledger defensive/rescue 真 consumer fix(feat/missing-contact-ledger baf2a670、修 QA REFUTE 手不聽腦:上輪 defensive/rescue write-only flag 無 consumer)·實作:①defensive→team.contact_vigilant_until(faction_ai:4759 write)→★READ at decision_context:241(if contact_vigilant_until>current_tick→threat_threshold 降)=真消費非新旋鈕(入既有 threat perception 路、既有 threat_threshold 已驅動 備戰/防衛)②rescue→reuse scout dispatch_anon_messenger TASK_SCOUT 到失聯單位 last-known pos(_lost_unit_pos:4748 讀 belief best_estimate/last_known_pos、零 god-view 非 live);ledger entry +last_known_pos·gate:mcl_test 14/14(★⑦defensive threat_threshold thr_after<thr_before 真降=非 write-only 硬驗+⑧rescue scout 真 dispatch)+headless 0-new+constitution 74+determinism 4360AE91 byte-identical(★≠前 inert 9290F462=真 consumer 在 warring fire=手真聽腦)·★審點:①defensive contact_vigilant_until 真被 decision_context:241 READ→threat_threshold(非又一 write-only、非新平行旋鈕=餵既有 threat 路)②rescue scout 真 dispatch+零 god-view(lost-pos belief/dispatch-log)③4 類全真世界效果(redispatch/writeoff 舊有+defensive/rescue 新真=手不聽腦全清)④diversity 仍在(慎重→defensive 真謹慎/義氣→rescue 真派)⑤determinism·R² CLEAN→measurer re-measure(4 類全真+分化+98 breakdown 已查[herald34+scout39+convoy25=98 無 bug、subteam 記帳 WHAT-mandated 下批])→QA 新 verdict→merge(與 cohesion 合併里程碑)·地基 KEEP"
---

# R² merge-gate 審 ledger defensive/rescue 真 consumer fix

修 QA REFUTE 手不聽腦（上輪 defensive/rescue write-only flag 無 consumer）。branch `feat/missing-contact-ledger` `baf2a670`。

## 實作
- **①defensive**：`team.contact_vigilant_until`（`faction_ai:4759` write）→ **★READ at `decision_context:241`**（`if contact_vigilant_until > current_tick` → threat_threshold 降）=**真消費非新旋鈕**（入既有 threat perception 路、既有 threat_threshold 已驅動 備戰/防衛）。
- **②rescue**：reuse scout `dispatch_anon_messenger TASK_SCOUT` 到失聯單位 last-known pos（`_lost_unit_pos:4748` 讀 belief best_estimate/last_known_pos、**零 god-view 非 live**）；ledger entry +last_known_pos。

## gate 全綠
mcl_test **14/14**（★⑦defensive threat_threshold thr_after<thr_before **真降**=非 write-only 硬驗 + ⑧rescue scout 真 dispatch）+ headless **0-new** + constitution **74** + determinism **4360AE91 byte-identical**（★≠前 inert `9290F462`=真 consumer 在 warring fire=**手真聽腦**）。

## ★審點
1. **defensive `contact_vigilant_until` 真被 `decision_context:241` READ** → threat_threshold（**非又一 write-only、非新平行旋鈕**=餵既有 threat 路）。
2. **rescue scout 真 dispatch + 零 god-view**（lost-pos belief/dispatch-log）。
3. **4 類全真世界效果**（redispatch/writeoff 舊有 + defensive/rescue 新真=手不聽腦全清）。
4. **diversity 仍在**（慎重→defensive 真謹慎/義氣→rescue 真派）。
5. determinism byte-identical。

## 序
R² CLEAN → measurer re-measure（4 類全真+分化+98 breakdown 已查[herald34+scout39+convoy25=98 無 bug、subteam 記帳 WHAT-mandated 下批]）→ QA 新 verdict → merge（**與 cohesion 合併里程碑**）。地基 KEEP。
