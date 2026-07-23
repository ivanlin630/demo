---
from: systems
to: implementer
status: open
topic: "[dispatch·extraction de-patch need-driven·coin liquidity 死常數人格化·R² CLEAN(buffer floor 已補)·新 branch feat/extraction-need-driven] spec=2026-07-23-extraction-need-driven-depatch.md。R² CLEAN(5 點親驗+buffer floor 必補已納)。coin-cause 坐實=salary illiquidity(coin 鎖 anon_treasury 取不回)。根:_consider_extraction(faction_ai:2364)flat `greed-prud×0.5>0.4` 死常數+不讀 need→中位領袖永不 extract。修 de-patch:①coin_need 信號(means-end:material-buy[NeedOracle._construction_facility_need material>0→估 coin]+food-buy[food_days<DESPERATION→估 coin])②_consider_extraction 重寫:spendable=team.coin,shortfall=coin_need-spendable,>0 才 extract(need 驅,砍 flat gate),amt=min(shortfall+buffer, anon_treasury)③★_extract_buffer=lerp(BUFFER_MIN,BUFFER_MAX,prudence),BUFFER_MIN>0(TEST 5-10,貪婪只降正下限非 0=非清空)。TDD 6(★③慎重 buffer>貪婪+即使 greed=1.0 buffer>0[斷言絕對>0 測真清空反例];②無 need→不 extract;④shortfall≤0→不;⑤守恆 CoinAudit=0;⑥emergency 不變)。gate/headless 0new/determinism 2跑 byte-identical(純算術/人格,無 randf)。★★measure(→measurer §④b+specimen→QA):extraction fire 率(中位人格 0→?)/spendable coin 升/coin_urg 降(91%→?)/★脫貧鏈 has_specie→買糧買料→material 累積→afford→facility 建成(端到端)/★守恆 CoinAudit=0+texture(即使最貪婪 leader extract 後 anon_treasury>0,無 swing always-extract-all,coin 池不爆)/無新餓死。做完→to:measurer(→QA 判故事:中位隊有真需→取回自己 coin→買得起→脫貧;貪婪 vs 慎重 buffer 差異可見)。task=systems+reviewer(merge-gate)。"
branch: feat/extraction-need-driven
---

# dispatch：extraction de-patch — need-driven（coin liquidity·死常數人格化）

spec：`docs/superpowers/specs/2026-07-23-extraction-need-driven-depatch.md`。**R² CLEAN**（`2026-07-23-reviewer-to-systems-R2-extraction-need-driven-verdict`：5 點親驗根/coin_need 無遞迴[reuse 既有 guard]/守恆/emergency 結構分離/無 RNG + **buffer floor 必補已納 spec**）。

## ★ branch
- **新 branch `feat/extraction-need-driven`**，off main HEAD 最新。

## 修（de-patch，3 touch）
### ① coin_need 信號（means-end 延伸）
`coin_need(state, team)` = material-buy（`NeedOracle._construction_facility_need(material) > 0` → 想建設缺料 → 估 coin ≈ material_shortfall × material_ask，或簡化 proxy）+ food-buy（`food_days < DESPERATION` → 估 coin ≈ food_shortfall × food_ask）。clamp 上限防爆。
### ② `_consider_extraction`（faction_ai:2357-2367）重寫（need-driven，砍 flat gate）
`spendable=team.resources.coin; shortfall=coin_need-spendable; if shortfall<=0: return; amt=minf(shortfall+_extract_buffer(leader), team.anon_treasury); _extract_treasury(..., amt/anon_treasury, "need_driven")`。**砍 `greed-prud×0.5>0.4` flat 門檻**。
### ③ ★`_extract_buffer(leader)`（reviewer 必補下限）
`buffer = lerp(BUFFER_MIN, BUFFER_MAX, prudence)`，**`BUFFER_MIN > 0`**（新 const，TEST 5-10 coin；貪婪只降正下限非 0=非清空 treasury）。

## TDD（6）
①中位領袖（greed.5/prud.5）+ coin_need>spendable → **extract**（原永不）②無 coin_need（無 buy-intent+食足）→ 不 extract ③**★persona buffer**：慎重 buffer > 貪婪 **+ 即使 greed=1.0 buffer > 0**（斷言絕對>0，測真清空反例）④shortfall≤0 → 不 extract ⑤守恆（CoinAudit=0）⑥emergency 路徑不變。

## 閘 + measure
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（純算術/人格，無 randf）。
- **★★measure（→measurer §④b+specimen→QA）**：extraction fire 率（中位人格 0→?）/ spendable coin 升 / **coin_urg 降（91%→?）** / **★脫貧鏈端到端**：has_specie→買糧買料→material 累積→afford→facility 建成 / **★守恆 CoinAudit=0 + texture**（即使最貪婪 leader extract 後 anon_treasury>0、無 swing always-extract-all、coin 池不爆）/ 無新餓死。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:measurer（→QA 判故事：中位隊有真需 → 取回自己 anon_treasury coin → 買得起 → 脫貧鏈動 coherent；貪婪 vs 慎重 buffer texture 差異可見）。**這是 afford 兩腿之一（食安 GATE-A + coin）**。
