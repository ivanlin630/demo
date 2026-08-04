---
from: systems
to: implementer
status: consumed
topic: "[dispatch build distribute免費直注relief(R²CLEAN,spec=2026-08-04-infonet-distribute-free-relief-HOW.md,blueprint GO,機制最後一bug)·root(diagnostic#6重現bed persist 0b599dc8):distribute賑濟convoy 6/6 arrive非黑洞卡settle站5/6 bail(sell_owner_no_coin×4/sell_ownerless×1),interaction:765-767 distribute注override_ask=local_value×price_factor,price_factor=(0.5+greed)/(0.5+honor)分子最小0.5永不0→oask永不0→免費仁君路free_dist=(override_ask==0)UNREACHABLE=dead code實作bug·fix:①interaction:767 distribute的oask=maxf(local_value*pf,0.0)改oask=0.0(免費直注gift,啟用既有free_dist路:跳:857 sell_owner_no_coin/affordability/sell_no_price→qty=minf(order_rem,sellable)→TileBank.deposit免費存resident據點→bid=0 coin no-op守恆→distribute.deliver bump)②ownerless 1/6小edge順手:distribute(free_dist意圖)若owner==null但tile是resident據點→允許TileBank.deposit到tile非:854 sell_ownerless bail(複雜則標tracking,override_ask=0已解4/6主體)·守:免費gift非crank(mini-util _try_distribute_side/util公式一字不改,發不發=人格秤送了=免費,本病=決策fire但settle定價卡非util低)/coin守恆(bid=0雙向no-op)/人格語意保留/economy sellable扣reserve不變/determinism零RNG·branch續feat/info-network-whole·完HANDBACK to:systems我路measurer re-measure症1端到端on persist bed(config/infonet_whole.json,distribute.deliver 5/6→6/6+food_delivered顯著>1+糧真到resident runway回升)→QA"
branch: feat/info-network-whole
---

# dispatch build — distribute 免費直注 relief（R² CLEAN、機制最後一 bug）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-distribute-free-relief-HOW.md`（R² CLEAN）。**branch**：續 `feat/info-network-whole`。
**root**：distribute 賑濟 convoy 6/6 arrive（非黑洞）、卡 settle 站、5/6 bail；`interaction:765-767` distribute `override_ask=local_value×price_factor`、`price_factor` 分子最小 0.5 永不 0→oask 永不 0→**免費仁君路 UNREACHABLE=dead code**。

## 建什麼
1. **`interaction_system.gd:767`**：distribute 的 `oask = maxf(local_value*pf, 0.0)` → **`oask = 0.0`**（免費直注 gift）。
   - 啟用既有 `free_dist` 路：跳 `:857 sell_owner_no_coin`/affordability/`sell_no_price` → `qty=minf(order_rem, sellable)` → `TileBank.deposit` 免費存 resident 據點 → `bid=0` coin no-op（守恆）→ `distribute.deliver` bump。
2. **ownerless 1/6 小 edge 順手**：distribute（free_dist 意圖）若 `owner==null` 但 tile 是 resident 據點 → 允許 `TileBank.deposit` 到 tile、非 `:854 sell_ownerless` bail（**複雜則標 tracking**、`override_ask=0` 已解 4/6 主體）。

## 守（build 硬守）
- **免費 gift 非 crank**（[[feedback_genuine_value_not_crank]]）：**mini-util `_try_distribute_side`/`_distribute_candidates` util 公式一字不改**——發不發=人格秤、送了=免費；本病=**決策 fire 了但 settle 站被定價卡住**、非 util 不夠。
- **coin 守恆**（`bid=0` 雙向 no-op）+ **人格語意保留** + **economy**（`sellable` 扣 reserve 不變）+ **determinism 零 RNG**。

## 驗收（re-measure 症1 端到端 on persist bed、我路 measurer）
- **`distribute.deliver` 5/6→6/6 真 settle** + **`food_delivered` 顯著 >1**（多筆真到）+ **★糧真到 resident 據點 storage、runway 回升**（症1 首次真閉環）。
- 糧到仍不足救人 = **economy-balance follow-up 記檔**（非本 fix）。
- 人格分化（仁君派/greed 低不派）+ coin 守恆 + determinism + Part1+3+scout+letter 不退。

**完 → HANDBACK `to:systems` → 我路 measurer re-measure 症1 端到端 on `config/infonet_whole.json` persist bed（糧真到 resident、`GODOT_TIMEOUT=1200`）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 判 arc-done vs economy-balance follow-up → 推用戶驗收。** 卡 → 報 `to:systems`。
