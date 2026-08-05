---
from: systems
to: reviewer
status: consumed
topic: "[R² merge-gate 審 faction-cohesion 實作(feat/faction-cohesion 90631616、HOW spec R² 你上輪 CLEAN、現審 build diff 對 spec+§1 防crank 命門真落地才過)·實作:P4 主刀 _faction_stay_benefit(relief_memory 自身 benefactor + heard_reputation belief、人格 mod、零 god-view)+benefactor write@distribute settle+defect 死 cliff→連續 defect_util=distress×deficit−stay_benefit(保 unrest>=20)+整併三決策點 a_score=honor+stay_benefit+uprising 後果秤(守城後 stay vs secede)·gate:cohesion_test 6/6(分化命門 被救→留/沒被救→走+零god-view+該散的散+uprising 後果)+headless 0-new+constitution 74+determinism 7CB7D680 byte-identical≠baseline·★審點(§1 防crank 命門):①禁刪真走親驗=defect/uprising 的 clear_team_faction exit 保留否(只加 stay-side、走側沒被焊死)②禁 boost 逼留=stay_benefit 讀真機制(relief 史/聲譽)非常數加成/無配額指標③零 god-view=stay_benefit 讀自身 benefactor memory+known_reputations belief 非全知 relief 統計④defect_util 連續非新 cliff+unrest>=20 gate 保留⑤三決策點整併真統一(a_score 用同 helper)⑥該散的散=cohesion_test⑥暴君 member 真餓仍 defect(stay_benefit 低沒焊死)·★立國查根結果=『立國』goal 從未 emit(orphan consume:1820/erase:4501)=正統 arc 記檔非本批·R² CLEAN→measurer 量分化(好vs爛領主壽命+該散照散、無配額)→QA→用戶·地基 KEEP"
---

# R² merge-gate 審 faction-cohesion 實作

HOW spec R² 你上輪 CLEAN → implementer build 完（`feat/faction-cohesion` `90631616`）→ R² merge-gate 審 diff（對 spec + **§1 防crank 命門真落地**才過）。

## 實作（對 HOW spec）
- P4 主刀 `_faction_stay_benefit`（relief_memory 自身 benefactor + heard_reputation belief、人格 mod、零 god-view）+ benefactor write@distribute settle。
- defect 死 cliff → 連續 `defect_util = distress×deficit − stay_benefit`（保 `unrest>=20` gate）。
- 整併三決策點 `a_score = honor + stay_benefit`。
- uprising 後果秤（守城後 stay vs secede）。

## gate 全綠
cohesion_test **6/6**（分化命門 被救→留/沒被救→走 + 零god-view + 該散的散 + uprising 後果）+ headless **0-new** + constitution **74** + determinism **7CB7D680 byte-identical**（≠baseline=行為真改）。

## ★審點（§1 防crank 命門）
1. **禁刪真走**（親驗）：defect/uprising 的 `clear_team_faction` exit **保留否**（只加 stay-side、走側沒被焊死）。
2. **禁 boost 逼留**：stay_benefit 讀**真機制**（relief 史/聲譽）非常數加成；**無穩定配額指標**。
3. **零 god-view**：stay_benefit 讀自身 benefactor memory + known_reputations belief、**非全知 relief 統計**。
4. **defect_util 連續**非新 cliff + `unrest>=20` gate 保留。
5. **三決策點整併真統一**（a_score 用同 `_faction_stay_benefit` helper）。
6. **該散的散**（cohesion_test⑥）：暴君 member 真餓**仍 defect**（stay_benefit 低、沒焊死 genuine exit）。

## ★立國查根結果（附）
「立國」goal **從未 emit**（orphan：consume `:1820` / erase `:4501`、無 emit 點）= founding never-establish 真根 = **正統 arc 記檔非本批**（大改）。

## 序
R² CLEAN → measurer 量分化（好 vs 爛領主壽命 + 該散照散、**無配額**）→ QA 故事稽核（留/走合人格）→ 用戶。地基 KEEP。
