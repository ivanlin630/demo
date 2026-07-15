---
from: systems
to: reviewer
status: open
topic: "[R²·merge-gate·全實作] 統一商業+coin@160301d9——用戶拍merge(閘①你R²必過);spec已R²CLEAN(異質+round2),但實作跨多commit(spec impl+wiring fix+probe fix+coin combo)→複核全branch實作cohere+match spec+無回歸;閘②probe measurer已核遷移非regression"
---

# R² merge-gate：統一商業 + coin 全實作（用戶拍 merge，你 R² 必過）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

用戶拍 merge（機制證明+coin 雙向+守恆,blocker 移生產子系統故 revise「revive 才 merge」）。**閘①=你 R² 必過**（大框:market-as-place+accessor 統一+de-patch+coin 多層）。

## 審什麼（★merge-gate:全實作 cohere + match CLEAN spec + 無回歸）
spec 已 R² CLEAN（你異質框外審 3 缺口 + round2 補齊）。**但實作跨多 commit 疊起**——請複核**全 branch 實作**（`git diff main...origin/feat/unified-commerce`，head `160301d9`）：
1. **spec 主體實作**（M1-M5）match CLEAN spec？——`_resolve_market_at_outpost`（owner-mediated 雙側+order_id 直沖）、`effective_holding` 6 縫、去 absorb/spill、掛單人格化、de-patch kill-list、invariants 公開地標豁免。
2. **wiring fix**（`sim_runner:353` 新 resolver wire + 舊路由巧遇非市場格）——3 缺口的履約權威側直記真接？
3. **probe fix**（funnel + 29 bail 分因 probe headline）。
4. **coin combo**（`_collect_member_tax` tune 強 K0.6/MIN0.15/FLOOR2.0）——守恆 person→team？
5. **★無回歸**：de-patch（拆 absorb/雙 resolver/死常數 kill-list）沒傷既有交易/飢荒/戰鬥鏈？巧遇路仍 wire（interaction:238-244 非市場格）？

## 已備料（供你複核，非要你重跑）
- systems 驗全 diff PASS（各 commit）；measurer full-HD 驗:機制證明(deal_market 0→2)、coin 大勝(no_coin -99.9%)、守恆 CoinAudit=0、byte-identical、盲點閘綠。
- **閘②probe measurer 已核**：order_fulfilled 雙路共用同 counter（舊 settle_orders + 新 `_settle_owner_order:834`）→ **7→0 是真低樣本非 probe 遷移非 regression**；巧遇路 code 確認仍 wire 無回歸。
- **誠實標（閘③,merge log）**：機制+coin 通，**供給 sell_no_surplus 51.7% 待生產 arc**（非本 merge blocker,用戶裁 blocker 移生產子系統）。

## 流向
CLEAN → systems merge（誠實 log 標供給待續）→ patch-gate-first 供給牆 → 決定 2 甲/乙。
仍有結構洞/回歸 → to:systems halt（merge 前擋）。**這是 merge-gate,大框最後一審。**
