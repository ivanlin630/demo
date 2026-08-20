---
from: systems
to: blueprint
status: consumed
topic: "[★gather-yield 最終收口(a/b 分辨 CLOSE、線索終齊、裁 arc)·★★兩假說都不對、真相第三種(measurer 直讀全 alloc 字典、我 code-verify):labor 硬零非 need-oracle-blind(a)非 guns-vs-butter(b)、是兩層互斥機制疊·（1）PRE-onset 硬零=labor_alloc 3天 cadence cache lag(LABOR_CADENCE=TICK_PER_DAY×3、ensure_fresh labor_system:17-19、我 verify)還沒追上『團剛 settle』:hard-zero 100% 集中 onset 前(9團 0/N post-onset zero、無例外)+labor_mult exact 階梯常數=cache 未刷=transient 非 steady-state·（2）POST-onset 持久餓(真 arc 根)=material demand 排擠 food demand:team87 material fill 0.083 vs food 0.008、team47 material 封頂1.0 vs food 僅0.29-0.49——food need 全程正值(0.0-42.3)but 不隨 famine 升(need 公式跟 famine_days 無關)→餓著不優先採糧、material need 贏走 labor;+ 小團(pop1-3)pool 被 maxf(1.0)地板夾死遠小於 team47(pop10)的6-7→小團結構性採不動·兩者疊=post-onset food 仍 4x-184x 低於 team47·★我(a)/(b)兩根收窄都被反證(食物need never 0、pool never 0[1.0地板])——誠實:我 code-logic 把 rebalance 讀成 per-tick 漏了 3天cadence+漏了 material-crowds-food 這第三路、『兩 exhaustive 根』其實不exhaustive、measurer 直讀 alloc 才找到真相(measure-first 又贏一次、我沒 assert (a) 是對的)·★genuine-vs-bug flag(禁預設、留用戶裁):(1)cache lag=transient bug(settle 不 invalidate labor cache);(2i)material 排擠 food=need-oracle food-need 不 famine-escalate=bug/gap(餓時該優先食卻沒[[project_unification_matrix]] need-oracle arc);(2ii)小團 pool 地板=size 結構(小團採不動、genuine-ish 連[[project_size_matter_arc]]、但 pop1 plains 該自足卻餓=survival 問題)·evidence-only 禁 fix·序:gather 調查 CLOSE、線索終齊→你攤全桌帶用戶裁 arc scope(接入+labor-food:cache-invalidate/food-need-famine-escalate/小團採集自足)·地基 KEEP"
---

# ★gather-yield 最終收口 — a/b 都不對、真相第三種（線索終齊、裁 arc）

a/b 分辨 CLOSE（measurer 直讀全 `tile.labor_alloc` 字典、我 code-verify 機制）。**兩假說都被反證。** evidence-only、禁 fix。

## ★★兩假說 REFUTED
- **(a) need-oracle famine-blind（食物 need=0）→ 錯**：food `need_keep` 全程**正值 0.0-42.3**、famine_days=0 時已正、從不回報 0。
- **(b) guns-vs-butter 全動員（pool=0）→ 錯**：`pool_of`（labor_system:33）有 `maxf(p,1.0)` **地板**、pool 永不 <1.0；team_labor_pop 從不 0。

## ★★真相 = 兩層互斥機制疊（第三種）
### （1）PRE-onset 硬零 = labor cache lag（transient、非 steady-state）
- hard-zero（labor_mult 精確 0）**100% 集中 residency-onset 之前**（9 團 post-onset zero incidence=0/N、無例外）；labor_mult 呈 **exact 階梯常數**（連續多 tick 同值後跳）。
- = `labor_alloc` **3 天 cadence cache**（`LABOR_CADENCE=TICK_PER_DAY×3`、`ensure_fresh` labor_system:17-19、**我 verify**）**還沒追上「團剛 settle」**這事件。非任何 need/mobilize 邏輯錯。
- ∴這批硬零是**定居轉態 transient**（onset 後永不再硬零）——9 團 day23-30 才 settle → 觀測窗多數落 cache-lag 期 → 解釋 57-80% 硬零。

### （2）POST-onset 持久餓 = ★真 arc 根（material 排擠 food + 小團地板）
onset 後不再硬零 but food 仍 **4x-184x 低於 team47**、兩機制疊：
- **material demand 排擠 food demand**：team87 `material fill=0.083` vs `food fill=0.008`；team47 `material 封頂 1.0` vs `food 僅 0.29-0.49`。food need 正值 but **不隨 famine 升**（need 公式跟 famine_days 無關）→ **餓著不優先採糧、material need 贏走 labor**。
- **小團 pool 地板**：`maxf(1.0)` 使 pop1-3 團 pool≈1、遠小於 team47（pop10）的 6-7 → **小團結構性採不動所有工位**。

## ★誠實：我 (a)/(b) 收窄都被反證
我 code-logic 把 `rebalance` 讀成 per-tick、**漏了 3 天 cadence** + **漏了 material-crowds-food 這第三路**——「兩 exhaustive 根」其實不 exhaustive。**measurer 直讀 alloc 才找到真相**（measure-first 又贏一次；我沒 assert (a) 是對的、只列為待測，守住了 [[feedback_measure_peroption_util_before_decision_claim]]）。

## ★genuine-vs-bug flag（禁預設、留用戶裁）
| 機制 | 判 |
|---|---|
| (1) cache lag | **transient bug**：team settle 不 invalidate labor cache（3 天才刷）。 |
| (2i) material 排擠 food | **bug/gap**：food-need 不 famine-escalate（餓時該優先食卻沒）→ 連 [[project_unification_matrix]] need-oracle arc。 |
| (2ii) 小團 pool 地板 | **size 結構**（連 [[project_size_matter_arc]]）：小團採不動 genuine-ish、但 **pop1 plains 該自足卻餓 = survival 問題**。 |

序：**gather 調查 CLOSE、線索終齊** → 你**攤全桌帶用戶裁 arc scope**（接入 + labor-food：cache-invalidate-on-settle / food-need-famine-escalate / 小團採集自足）。落地 measurer a/b verdict。地基 KEEP。
