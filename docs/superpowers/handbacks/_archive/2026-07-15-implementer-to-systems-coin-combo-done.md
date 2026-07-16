---
from: implementer
to: systems
status: consumed
topic: "[完·coin combo] fold 成員稅+tune 強進 branch — HEAD 160301d9;TDD no_coin binding 破(coin 0→468→deal)+守恆+determinism;live owner_no_coin 30→5;★headline revive 須 measurer full-HD(72.75% config),trade_funnel_bed seed1337 binding=buy_no_want 非 coin"
---
# Hand Back：coin combo（fold 成員稅 + tune 強進 unified-commerce）

branch `feat/unified-commerce` @ `160301d9`（已 push）。probe-fix bail 因 probe 保留（你指示有價值）。

## 做（照 dispatch）
- **fold `_collect_member_tax`**（coin-B，coin-circulation 574d4a56）進 branch：person.coin→team.coin 月週期稅、領袖人格 rate、留 PERSONAL_COIN_FLOOR、守恆池間搬。掛既有月 extraction 呼點。
- **★tune 強**（coin now load-bearing，單刀 3.6% 太弱）：`MEMBER_TAX_K 0.3→0.6`、`MIN 0→0.15`（保底稅全隊回補）、`MAX 0.5→0.7`、`PERSONAL_COIN_FLOOR 5.0→2.0`。全 TEST VALUE（measurer 校）。

## 驗（log `docs/measurements/2026-07-15-unified-commerce-coin-combo-160301d9.log`）
- **TDD 23/23 PASS**：成員稅守恆（Δperson=Δteam=156、留 floor）+ **★combo：稅前 team.coin=0→買不成；稅後 coin=468→到市場成交（food=19）＝no_coin binding 破（機制證）**。
- **CoinAudit delta=0×4** + **determinism byte-identical MD5 C7862C80** + 憲法 sites=29 + headless 3+3 baseline（0 net new）。

## ★live combo（trade_funnel_bed seed=1337 3mo）——binding 差異，誠實報
- **owner-side coin 修證**：`sell_owner_no_coin` **30→5**（member tax 給 team coin，owner 能收購訪客貨）。
- **但 `deal_market` 仍=2（此 bed 未 revive）**：★**trade_funnel_bed(seed1337) 的 binding ≠ no_coin**——
  - 此 bed 主 bail = **`buy_no_want=12`（商隊無個人 reserve 缺口不買＝merchant 完成 trade 下刀②scope）** + `sell_no_surplus=26` + 站5 arrive 4.4%（域外 LOD）。
  - **此 bed 無 `buy_no_coin` bail**（買方在此 config 不缺 coin）→ coin combo 在此 bed 無 headline 空間。
- ∴ **combo-revive headline 屬 measurer 的 full-HD config（visitor_no_coin 72.75% 坐實 binding 處）**；trade_funnel_bed seed1337 複現不了 72.75% 場景（coin 非其 binding）。

## ★裁斷點呈 systems（別 overclaim）
- coin combo **機制正確**（TDD no_coin binding 破 + live owner_no_coin 30→5 + 守恆）——**已做完你要的 fold+tune**。
- **但我無法在手上的 bed 觀到 headline revive**（trade_funnel_bed binding 是 buy_no_want+LOD 非 coin）。**請 measurer 在 no_coin=72.75% 的 full-HD config 重測 combo**（該 config 才是 coin binding 處，才驗得出 revive）。
- 若 measurer full-HD combo revive → to:blueprint 批 merge。**若仍不 revive → 更深根（buy_no_want 商隊② / 域外 LOD arrive 4.4%）**，我判下序 = merchant 完成 trade ②（buy_no_want 直擊）> LOD arrive。scope 待你裁。

## 待確認
- 完成判定 = measurer full-HD（no_coin config）重測 combo revive + systems + blueprint 批。context hold warm 等裁決。
