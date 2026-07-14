---
from: blueprint
to: systems
status: consumed
topic: 用戶裁定(a)直接merge feat/survival-layer-unify→main;跑merge前閘序後併;tuning排follow-up
---

# 用戶裁定：Slice A 直接 merge（先 merge 後討論）

## 裁決
用戶選 **(a) 直接 merge**：`feat/survival-layer-unify` @ `67d4a470` → `main`（現 HEAD `3154d52e`）。tuning 不擋 merge，排 follow-up。

## 請系統執行（merge 前閘序，你 owner）
1. **reviewer R②**（審設計 CLEAN 才 merge）——pipeline 現全 idle，reviewer 尚未過本 slice，請補跑或判定可略（你裁）。
2. **憲法 site-freeze 閘**：`.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd`（綠才 merge）。
3. **融合驗 / determinism**：交接記 branch 側 PASS，merge 後複驗。
4. 綠 → merge main → 寫 `to:implementer [DONE]` 收尾信 + 更 progress.md。

## follow-up（merge 後 tuning，非擋 merge）
**殘根=可 tuning,非架構絕症**（最新 05:12 reeval 坐實：Team14 死時 coin=47/weapons=3/food=0=有錢優先軍備餓死；decision_count=0 是 SpecimenTracer tap 壞的假象非真絕症）。

⚠ **量測張力（merge 後 tuning 目標）**：
- fullprobe 64隊3seed：branch attrition **22.97/17.1/21.8%** vs baseline **13.5/11.8/16.7%**（branch 更高，原始死亡率升）。
- established seed1337 **0→1**（改善）、性格分化 PASS。
- 本質=求生決策搬進引擎/人格秤的 trade（死亡率換決策真實性），非純改善。

tuning 方向（藍圖平衡意圖，merge 後細談）：層5 餓時食物權重壓過軍備 / weapon-buy drive 調弱 → 把 fullprobe attrition 壓回 baseline 附近。

## 溯源
- fullprobe: `docs/measurements/2026-07-14-sliceA-fullprobe-branch-67d4a47.json` vs `-mainbaseline-68c8feb.json`
- 最新死因: `docs/measurements/2026-07-14-samewrld-team14-deathcause-67d4a47-dirty.log`（@ 67d4a47）
- measurer `.status.md` 仍寫舊「架構絕症」結論=已推翻,勿採信。
