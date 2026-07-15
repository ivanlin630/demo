---
from: implementer
to: systems
status: consumed
topic: "[完·大框 minus S4.2] 統一生產框架 S1/S2(+gate)/S3/S4.1/S4.3/S4.4/S4.5 — HEAD 6510b52e;★S2 GATE 過(餓隊 farming 13.80>4.40 精確 match R①);TDD 17綠+CoinAudit=0+determinism+Manufacture 活躍;★S4.2 A3 utility 未做(裁)"
---
# Hand Back：統一生產框架 v2（生產 arc·甲）

branch `feat/production-framework` @ `6510b52e`（已 push），base = origin/main `fa004b7a`。3 commit（S1 → S2+gate → S3+S4）。

## 實作（照 spec S1-S4，★S4.2 除外，見下）
- **S1 製造 precondition + no-op tap**：`has_manufacturing_facility` static（抽死碼 `_can_manufacture` 邏輯）；`DecisionContext` 欄位 + gather；options「生產」applicable 補 `and has_manufacturing_facility`（A2 補缺，「駐守」拆出）；manufacturing 5 條 no-op tap（noop_no_outpost/no_worker×2/**no_facility=A2 主病**/no_material）+ `produce.appl_kill_nofacility`。
- **★S2 survival-crush + granary seam + 常數分層**：farming score `×(1+SURVIVAL_CRUSH×urgency²)`（軟連續非 cliff）；`_facility_food_days` 讀**據點局部糧倉**（granary seam，非 positional）；`×0.8` flat 釘死 / `×7` 死常數退役→`food_security_target` 人格化。
- **★S2 GATE（硬性）過**：TDD 餓隊 **farming(13.80) > workshop(4.40)**——survival-crush score 主導可耕地（**精確 match R① 手算** base 2.30×6 / 4.40）；軟連續（飽足 workshop 4.40>farming 1.15）。**→ S4 拆 override 前提達成。**
- **S3 means-end 統一（涵蓋 faction_id=-1）**：`_evaluate_independent_infrastructure` 獨立定居隊對自家 outpost 走**同 `_pick_facility` argmax**+建造 dispatch（非平行路），掛 INFRA_INTERVAL。
- **S4.1 移 override**：`_pick_facility` hungry early-return 刪（survival-crush 已保底）；demolish 泛化（best>lowest×DEMOLISH_MARGIN，全設施通用，farming 規則保護不拆）。
- **S4.3 govern de-patch（§R²4）**：移除 infra 強制 GOVERN（避 Team10 雙寫 livelock）；憲法 sites 29→28 removed=1。
- **S4.4 mining de-patch（§R²1）**：移除含礦硬 civilian override，ore 融入 `_pick_outpost_type` 人格秤（貪婪→採礦村/好戰→仍可軍鎮）。
- **S4.5 rule 明文（§R²2/3）**：`_lowest_score_facility` farming 不拆=命脈規則；`_trigger_survival` `=="farming"` 泛化「產糧設施+短工期」（`_is_food_facility_short`）。

## 驗（log `docs/measurements/2026-07-16-unified-production-tdd-6510b52e.log`）
- **TDD 17/17 PASS**（S1-S4 含★S2 GATE）。
- **CoinAudit delta=0 + 1000+ tick 無崩 + ★`[Manufacture]` 產出活躍**（has_facility 隊真製造 arrows/goods）+ **determinism byte-identical MD5 6D62C85F** + 憲法 sites=28 removed=1 + headless 3+3 baseline（0 net new）。
- 遷移：生產 applicable 加 workshop（S1 precondition）；移除 govern 測（de-patched 機制）。

## ★誠實標記（R① 存在理由，待 measurer 坐實，未寫篤定 emergent）
1. **urgency 真 sim fire**：機制正確（TDD score 層），「食安隊真有 food_days<target 頻率」待 full-HD 坐實。
2. **獨立隊 has_facility 真成長**：S3 路徑接上（呼叫圖），「真逐月升」待 full-HD 坐實。

## ★S4.2（A3 utility 化）未做——裁斷點呈 systems
- S4.2 = `_evaluate_infrastructure` 固定 if 階梯（升級>擴建>蓋新 first-match）→ utility argmax。**未做**。
- 理由：大 restructure（core infra dispatch，upgrade/expand/new 各異 dispatch 機制），**非 safety-critical**（A3=決策 ORDERING ladder，非 A1/A4 承重 override）；safety-critical de-patch（A1/A4）已全做+S2 gate 驗+headless 綠。first-match ladder 仍在（功能正常）。
- **請裁**：S4.2 是否 block measurer full-HD？**我判非 block**（A3 ordering 不影響 has_facility 成長/supply revive；「無殘補釘」A1/A4 硬 gate 已退，A3 是 ladder 非硬 gate）。若需，我下輪做（獨立小 slice，降風險）。

## 待確認
- 完成判定 = systems + measurer 中性 full-HD（has_facility 成長含獨立隊/goods/surplus/deals/人格分化/urgency fire/no-op tap 趨零/byte-identical/守恆）+ blueprint 批。
- **另：base fa004b7a 有 stale bed `trade_bail_probe_bed.gd`**（引用 unified-commerce 已移除的 `_absorb_public_storage`/`_spill_back` → parse error，非 blocking 但污染 import）——merge hygiene 漏，請 measurer/systems 撿或清。
- context hold warm 等裁決。
