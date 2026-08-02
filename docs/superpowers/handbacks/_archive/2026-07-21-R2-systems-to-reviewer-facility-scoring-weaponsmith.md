---
from: systems
to: reviewer
status: consumed
topic: "[R²·facility-scoring 平衡·weaponsmith 納武器市場 demand·blueprint 選①授權] spec=2026-07-21-facility-scoring-weaponsmith-demand.md。根 code-confirmed(deficit 不對稱:workshop demand-responsive 封頂1.0 vs weaponsmith armed_ratio-only 無視武器 demand→systematically 輸 60樣本僅中1)。blueprint 裁選①(納武器市場 demand,連綜合發展模型商隊追財/軍火商,armed_ratio 自衛留)。①_deficit_weaponsmith 改兩路徑 max(self_defense=armed_ratio×militancy 留 / market=武器 demand × 商業人格)。②workshop demand 封頂→連續(次要,順手)。審點:①max 語意對嗎(自衛OR軍火商任一驅建)②★商業人格權重穿秤非 flat(貪婪/商業技能,blueprint 域專判斷器邊界)③★複用:_weapon_market_deficit 該複用 A 類 generic(weaponsmith 轉 A 類+special 融合)還 special 內算=DRY 判④②workshop 連續動 goods 行為風險→同 slice or 拆 follow-up⑤無 RNG(純算術+人格)⑥measure-sensitive 非盲改。不需 QA(blueprint:formula 事實)。CLEAN→dispatch。"
---

# R²：facility-scoring 平衡 — weaponsmith 納武器市場 demand

spec：`docs/superpowers/specs/2026-07-21-facility-scoring-weaponsmith-demand.md`。根 **code-confirmed**（deficit 語意不對稱）。blueprint 裁**選①**授權（納武器市場 demand，連綜合發展模型「商隊追財/軍火商」，armed_ratio 自衛路留）。

## 修
- **①（核心）** `_deficit_weaponsmith` 兩路徑 `max`：`self_defense`（`clampf(0.6−armed_ratio)×militancy`，現況留）/ `market`（武器 demand × 商業人格）。任一驅建。
- **②（順手）** workshop demand 封頂 1.0（unbounded）→ pop-relative 連續正規化。

## ★審點
1. **max 語意**：自衛急 OR 軍火商（市場好賣）任一 → weaponsmith 值得建。合理嗎（別漏情境/別雙算）？
2. **★商業人格穿秤非 flat**：`_commercial_inclination = f(貪婪, 商業技能)`（TEST 權重）。符 blueprint「穿人格秤非硬寫繞過」+ 域專判斷器邊界？
3. **★複用 DRY**：`_weapon_market_deficit`（武器 outputs demand min_per_res）**對稱 workshop A 類 generic**——該**複用** A 類 evaluator（weaponsmith `FACILITY_DEFICIT_DEF` 轉 A 類 `use_demand=true` + 融 armed_ratio special）還 special 內自算？哪個乾淨不重寫（DRY，避 seam#1 各算）？
4. **②風險**：workshop demand 連續正規化**動 goods 建造行為**（measure-sensitive）。同 slice or 拆獨立 follow-up（①先解主病）？你判。
5. **無 RNG**（純 demand/holding 比 + 人格權重）。
6. **measure-sensitive**（facility-build 分布變）→ 非盲改，measure 對照。

## 回覆
`to:systems`：CLEAN / 修正。CLEAN → dispatch implementer（off LOCAL main）。measure=facility-build-by-type/weapon 產出/score 分布/doom-delta（帶 §④b 樣本，可用剛 merged 的 `Probe.bump_sample`）。**不需 QA**（blueprint：formula 事實非故事 coherence）。
