---
from: systems
to: reviewer
status: consumed
topic: "[R²·設計審] 供給seam修統一effective_holding accessor——非糧賣單+settle對齊public_storage(同food WS-2c);★守恆核心=spend_holding扣對storage;premise file:line坐實免R①"
---

# R²：供給 seam 修（統一 effective_holding accessor）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-supply-seam-effective-holding.md`。
blueprint 確認願景：`2026-07-15-blueprint-to-systems-supply-seam-fix-direction.md`（seam 對齊 + 統一 accessor 家族別再漏）。

## premise 已 file:line 坐實（免 R①）
manufacture→public_storage(`_add_output:117`)、非糧賣單讀 team.resources=0(`order_system:110`)、settle 扣 team.resources(`_execute_transfer:665`)。full-HD 血證 order_fulfilled≈0 + arb_kill_nostock 數千/月。

## 審什麼（seam 修，標準審）
1. **統一 accessor**：`effective_holding(state,team,res)` = team.resources + 自家 public_storage（泛化 effective_food，保 alias 不破 caller）。`spend_holding(state,team,res,qty)` = 先扣 public_storage 餘扣 team.resources。**驗**：泛化不破既有 effective_food caller？spend 順序（public_storage 先）對否？
2. **★守恆核心**：Fix4 settle `_execute_transfer:665` seller 扣改 `spend_holding`（貨從 public_storage 出）。**驗**：賣讀 effective（含 public_storage）+ settle 扣 spend_holding（扣 public_storage）→ 一致無幽靈貨？spend 不透支（public_storage+resources 都不夠時）？CoinAudit/InvariantAudit=0 守得住？
3. **food+非糧統一不留兩套**：`_tick_food_granary_sell` 也 refactor 走 effective_holding（別留 food 一套非糧一套=第三資源又漏的根）。**驗**：food 賣單語意（cap×reserve）refactor 後不變（227 筆量級）？
4. **邊界**：只接 storage，不改產能/價格/regen（產能夠不夠 seam 修後 measure-first）。施工隊不賣建材 gate 保。determinism 零 randf。

## 特別看（守恆坑）
- **buyer 收貨側**：`_execute_transfer:666` buyer 收進 team.resources（不改）——賣方 public_storage 出、買方 resources 進＝不對稱但守恆（總量守），確認可接受（買方之後自己 re-store/用）。
- **spend_holding 扣不足**：若 sell qty > 實際 effective_holding（時間差：掛單後貨被消耗）→ spend 應扣到 0 為止不透支，settle qty 應 min(order_qty, 實際可扣)。驗這條不破守恆。
- **effective_holding 對「非定居隊」**：無自家 outpost→public_storage 部分=0→退化成 team.resources（現行）。驗移動隊/商隊不受影響。

## 流向
CLEAN → dispatch implementer（feat/supply-seam-effective-holding）→ measurer 中性 full-HD（order_fulfilled 回升 + arb_kill_nostock 降 + coin 流 + 守恆）→ QA → blueprint 批。
premise_contradiction 或守恆漏 → to:systems halt。
