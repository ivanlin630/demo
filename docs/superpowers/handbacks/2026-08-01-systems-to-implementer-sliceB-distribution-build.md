---
from: systems
to: implementer
status: open
topic: "[甲SLICE B領主分配政策=統一光譜·開工·spec終稿docs/superpowers/specs/2026-08-01-logistics-slice-B-lord-distribution-policy-HOW.md(R²CLEAN+bid<=0洞已訂正)·統一光譜:給免費(義氣)←賣公道→賣高價(貪剝一筆)→賣外拋棄子民,一argmax一convoy+貿易脊椎人格weigh位置零新市場·四元件:A deficit偵測(領主掃自有resident food runway<DISTRIB_DEFICIT_DAYS)B _distribute_candidates(goal_resolver仿_deliver_candidates,target鎖自有deficit居民buy-order,price_factor=clamp((0.5+greed)/(0.5+honor))連續,util=relief(honor放大)+coin(greed放大)競argmax)C DELIVER復用_market_visitor_sell+加override_ask:float=-1注入口(distribute傳local_value×price_factor,override_ask==0跳owner coin<=0/bid<=0 bail+qty=min(order_rem,sellable)免div,>0保留affordability cap)D unrest耦合(持續deficit→UnrestBank.add,fed→reduce,餵現成defection≥20)·★四約束鎖統一非補丁R²grep硬檢:候選非特判/連續weigh非硬gate/價格modulation非新機制/復用市場非新class·★感知鐵律:讀本勢力自有居民deficit=合法非god-view·★全量tap:distribute util per-option/DELIVER量/deficit runway/unrest源·dev-verify三人格湧現+連續掃greed非階梯+coin守恆·隔離branch feat/logistics-sliceB-distribution"
branch: feat/logistics-sliceB-distribution
---

# 甲 SLICE B 領主分配政策（統一光譜）— 開工

**spec 終稿**：`docs/superpowers/specs/2026-08-01-logistics-slice-B-lord-distribution-policy-HOW.md`（R² CLEAN + bid<=0 洞已訂正 §2C）。premise §0b 四項全 PROVEN（grep 坐實）。

## 統一光譜（blueprint 裁、用戶定）
```
給免費(義氣max) ← 賣公道(neutral) → 賣高價(貪,剝一筆) → 賣外拋棄子民(貪max,餓死)
```
一 argmax 一 convoy+貿易脊椎、人格 weigh 位置、**零新市場**。三湧現（仁君/苛捐雜稅/拋棄子民）同機制 seed。

## 四元件（詳 spec §2）
- **A deficit 偵測**：領主掃自有 resident food runway < `DISTRIB_DEFICIT_DAYS`。
- **B `_distribute_candidates`**（goal_resolver、仿 `_deliver_candidates`:125）：target 鎖自有 deficit 居民 buy-order（居民 deficit 自動掛單 order_system:128-136）；`price_factor=clamp((0.5+greed)/(0.5+honor),0,CAP)` 連續；util=`relief(deficit×(0.3+honor)) + coin(price_factor×local_value×affordable×(0.3+greed))` 競 argmax 對 sell-external。
- **C DELIVER**：復用 `_market_visitor_sell` + 加 `override_ask: float=-1` 注入口（−1＝現行、normal trade 零變）；distribute 傳 `override_ask=local_value×price_factor`；**`override_ask==0` 跳 owner-coin<=0(819)+bid<=0(828) bail、qty=min(order_rem,sellable) 免 829 div**；**`>0` 保留 affordability cap（既有 829=苛捐雜稅）**。
- **D unrest 耦合**：持續 deficit→`UnrestBank.add`、fed→`reduce`，餵現成 `unrest_turns≥20→event_faction_defect`。

## ★硬約束（違＝reject）
- **四約束鎖統一非補丁**（R² grep 硬檢）：①候選非特判 branch（無 `if kind=="distribute"` 繞 argmax）②連續 weigh 非 `if greed>X` 硬 gate ③價格 modulation 現成 local_value 非新定價機制 ④復用市場非新 market/order class。
- **感知鐵律**：讀本勢力自有居民 deficit＝intra-faction 合法、非 god-view 敵情。
- **全量暫態可觀測性**：distribute util per-option / DELIVER 量 / deficit runway / unrest 增減源**全接 tap**（否則 QA 判官盲）。
- **零全域 RNG on observe 路徑**（[[feedback_observer_no_global_rng]]）。

## dev-verify（§3、交付前自跑）
三人格湧現（仁君免費 fed→unrest reduce / 苛捐 price 高居民買不夠→unrest↑+領主 coin↑ / 拋棄全賣外→defection）+ **掃 greed 0→1 連續變非階梯** + coin 守恆（居民付=領主收）+ determinism 3 跑 byte-identical + gates 綠。

## 交付
- code 寫 worktree `feat/logistics-sliceB-distribution`（隔離、約束2）、handback 寫 main mailbox。
- dev-verify 綠 → handback `to:systems`（帶 bed 數字：三人格 fire/unrest/coin）→ 我收 → R² 融合驗 → 乙合量。
- 卡住/scope 變 → 報 `to:systems`（禁 inline 越界、禁問用戶）。
