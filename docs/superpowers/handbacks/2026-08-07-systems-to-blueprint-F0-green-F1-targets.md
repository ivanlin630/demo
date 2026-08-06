---
from: systems
to: blueprint
status: consumed
topic: "[★F0 安全網綠 MERGED(8df7d33d)=框架收尾 prerequisite 就位→F1 啟動·F0:StateFingerprint 全 world-state canonical hash(純讀零寫零 global RNG)+27-fingerprint baseline(3床×3seed含1337×3tick)·★自驗 fp_acceptance 5/5(★零 RNG 直接斷言 compute 前後 randi 相同=零 draw[第三度 RNG 警戒守住]+deterministic+純讀不寫零 mutation+軌跡不變+敏感=改1隊 current_task 即 fp diff 安全網有效)+假覆蓋逐域 distinct 27/25/15/27/25/20 無死值(subteam/letter/combat/relocate 真 exercise)·gate:constitution 75(純讀 observer 零新 site)+headless 0-new+merge-gate 亲验零 randf/randi·★§2.2 硬規此後生效:純結構 slice(②)必 fingerprint 三跑一致+regression 不變(byte-identical 只搬位置);行為變 slice(①人格化)fingerprint 預期變(intended 分化、與②分 slice 不混)·★F1 審靶 enumerate(①硬綠首 slice=threshold 死常數審):constitution baseline 9 個 threshold-type sites=decision_engine::rank_scored_ctx / diplomatic::_calc_diplomacy_score / faction_ai::{_evaluate_all_body/_evaluate_independent_strategy/_evaluate_new_outpost_location/_evaluate_subteam/_evaluate_survival/_evaluate_threat/_evaluate_uprising}·systems F1 audit=逐一看具體 threshold 分 physical-viability(世界物理留)vs death-constant(§5 照妖鏡人格化靶)→產分類清單餵你 spec 人格化·序:F1 audit(systems 產分類)→你 spec 人格化 slices→R①→R²→build(fingerprint 預期分化驗 intended)·地基 KEEP"
---

# ★F0 安全網綠 MERGED（8df7d33d）= 框架收尾 prerequisite 就位 → F1 啟動

## F0 交付
`StateFingerprint` 全 world-state canonical hash（純讀零寫零 global RNG）+ 27-fingerprint baseline（3床×3seed含1337×3tick）。
- ★**自驗 fp_acceptance 5/5**：★零 RNG 直接斷言（compute 前後 randi 相同=零 draw、**第三度 RNG 警戒守住**）+ deterministic + 純讀不寫零 mutation + 軌跡不變 + **敏感**（改 1 隊 current_task 即 fp diff=安全網有效）。
- 假覆蓋逐域 distinct（27/25/15/27/25/20 無死值、subteam/letter/combat/relocate 真 exercise）。
- gate：constitution 75（純讀 observer 零新 site）+ headless 0-new + merge-gate 亲验零 randf/randi。

## ★§2.2 硬規此後生效
純結構 slice（②）必 **fingerprint 三跑一致 + regression 不變**（byte-identical 只搬位置）；行為變 slice（①人格化）fingerprint **預期變**（intended 分化、與②分 slice 不混）。

## ★F1 審靶 enumerate（①硬綠首 slice = threshold 死常數審）
constitution baseline **9 個 threshold-type sites**：
- `decision_engine::rank_scored_ctx` / `diplomatic::_calc_diplomacy_score`
- `faction_ai::{_evaluate_all_body / _evaluate_independent_strategy / _evaluate_new_outpost_location / _evaluate_subteam / _evaluate_survival / _evaluate_threat / _evaluate_uprising}`

## 序
systems F1 audit = 逐一看具體 threshold 分 **physical-viability**（世界物理、留）vs **death-constant**（§5 照妖鏡人格化靶）→ 產分類清單餵你 spec 人格化 → R①→R²→build（fingerprint 預期分化驗 intended）。systems 續 F1 audit。地基 KEEP。
