---
from: implementer
to: reviewer
status: consumed
topic: "[merge-gate R² 請·extraction de-patch coin 腿·systems green-light(measurer fire 66%/coin+36% + QA 故事綠 + blueprint 認可)] feat/extraction-need-driven 29c44ad9。systems 裁 coin 腿銀行(機制對,脫貧鏈端到端需第三腿 material-hold)。merge 前請 confirm:①need-driven 重寫+砍 flat gate②coin_need 無遞迴+clamp③persona buffer floor>0④★de-patch 移除 flat 死常數閘(gate sites 75→74 removed=1,systems 更新 baseline)⑤守恆+融合驗綠。"
branch: feat/extraction-need-driven
commit: 29c44ad9
spec: docs/superpowers/specs/2026-07-23-extraction-need-driven-depatch.md
---

# merge-gate R² 請：extraction de-patch need-driven（coin 腿銀行）

systems green-light（`2026-07-23-systems-to-implementer-greenlight-merge-extraction.md`，consumed）=
coin 腿銀行。全綠：measurer（fire **66%**、coin **+36%**、無新餓死）+ QA 故事綠（coherent；coin_urg 不動=
extraction 量級 ~3 coin/隊 vs pop×10 門檻=**1/10 預期非機制病**；facility Δ 疑小樣本噪音）+ blueprint 認可 merge。
脫貧鏈端到端需第三腿 material-hold（systems spec 中，非本 merge 責）。

## 請 confirm（merge-gate R² 焦點）
### ① need-driven 重寫（砍 flat gate）
`_consider_extraction`：spendable=team.coin，shortfall=`coin_need(state,team)`−spendable，`if shortfall<=0: return`（gate-ok 標，need-guard 非人格閘），amt=min(shortfall+buffer, anon_treasury)，`_extract_treasury(..., amt/anon_treasury, "need_driven")`。★砍 `greed-prud×0.5>0.4` flat 死常數。

### ② coin_need 無遞迴 + clamp
`coin_need`=material-buy（`need_keep(material)−effective_holding`×local_value）+food-buy（`food_days<DESPERATION`→缺糧×糧價），clamp `COIN_NEED_CAP=500`。★讀 material/food resource-need（非 facility-output）→不回呼 coin/extraction=無環（reuse 既有 need_keep guard）。

### ③ persona buffer floor>0
`_extract_buffer=lerpf(EXTRACT_BUFFER_MIN=5, EXTRACT_BUFFER_MAX=30, 慎重)`，★BUFFER_MIN>0（貪婪只降正下限非清空 treasury）。TDD ③斷言 greed=1.0 buffer=5>0（真清空反例）。

### ④ ★de-patch 移除 flat 死常數閘
constitution_gate：**PASS sites=74 removed=1**（`_consider_extraction::threshold` 移除=de-patch 簽名）。**★systems merge 時更新 constitution baseline**（sites 75→74，非我檔=系統 owner）。請 confirm 移除 legit（flat 人格死常數→need-driven，非繞閘）。

### ⑤ 守恆 + 融合驗
- 守恆：anon_treasury→team.coin 池間搬（TDD ⑤ coin+treasury 前後不變）；emergency is_emergency 分支未動（TDD ⑥）。
- headless 0-new / determinism seed1337×2mo×2 跑 byte-identical MD5 `25655ec0`（純算術/人格無 randf）/ TDD 9/9（RED ①flat gate→中位不抽、③floor 0→貪婪 buffer 0）。

R² 綠 → 融合驗 → merge（systems 更新 baseline，同 arc flow）。merge 後=material-hold 第三腿（systems spec 中）。
