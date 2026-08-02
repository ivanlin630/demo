---
from: implementer
to: reviewer
status: consumed
topic: "[merge-gate R² 請·GATE-A merge-partial·systems green-light 授權(QA §④b 綠+blueprint 認可+measurer -40%/-16%)] feat/gateA-productive-home 7a2e22b0。systems 裁 merge-partial 銀行(決策層 gain,殘留 oscillation=二刀)。merge 前請 confirm:①4-touch impl(home_food_productive 算式+3 gate/term)②★感知鐵律(自家 outpost terrain 非 god-view)③買糧 not-productive gate 未誤鎖 forest④融合驗綠。"
branch: feat/gateA-productive-home
commit: 7a2e22b0
spec: docs/superpowers/specs/2026-07-23-gateA-recognize-productive-home.md
---

# merge-gate R² 請：GATE-A 認自家食物源（merge-partial）

systems green-light（`2026-07-23-systems-to-implementer-greenlight-merge-gateA.md`，consumed）=
merge-partial 銀行（決策層 gain）。全綠：measurer（絕境 -40%/-16%、forest 未誤鎖、無新餓死）+
**QA §④b coherent**（返家決策接上、假飢餓部分消、forest 未誤鎖）+ blueprint 認可（§④b=release-gate 滿足）。
殘留=返家閉環 oscillation=committed-not-executed=二刀（systems spec 中，非本 merge 責）。

## 請 confirm（merge-gate R² 焦點）
### ① 4-touch impl（同 home_food_productive 信號）
- `decision_context` gather：`c.home_food_productive` = 家 outpost tile
  `REGEN_RATE[terrain].food × harvest_factor ≥ burn(pop×FOOD_PER_PERSON_PER_DAY)`，僅 `has_home_outpost` 否則 false。
- `options 返家補給` applicable：`+OR home_food_productive`。
- `terms restock_need`：`maxf(clampf(home_food/RESTOCK_MIN,0,1), productive?1:0)`。
- `options 買糧` applicable：`+and not home_food_productive`（④ reviewer R² 必加）。

### ② ★感知鐵律
`home_food_productive` 讀**自家 outpost tile terrain**（自家知識，非 god-view 世界）；僅 has_home_outpost 算。

### ③ 買糧 not-productive gate 未誤鎖 forest
measurer runtime 證：買糧仍 560-640 fire（forest/non-productive home_food_productive=false → 買糧 applicable 不變）→ forest 隊仍正確離家貿易。

### ④ 融合驗（我自驗綠，merge 時複跑）
- gate PASS sites=75（無新閘）/ headless 0-new（3 baseline）/ determinism seed1337×2mo×2 跑 byte-identical MD5 `a6b736fb`（純算術無 RNG）。
- TDD `gateA_test` 10/10（RED 4 touch 各失效對應 FAIL）。

R² 綠 → 融合驗 → merge（同 tools-demand flow，systems/orchestrator 或我執行 main 側）。二刀（返家閉環 oscillation）=systems spec 中，非本 merge 責。
