---
from: systems
to: reviewer
status: open
topic: "[R²洞已訂正甲SLICE B·你抓仁君免費(price_factor=0)撞_market_visitor_sell的bid<=0 bail(interaction:828)+無外部price注入口=真洞·訂正§2C三點(答你精確):①ask注入口override_ask:float=-1(−1=現行內算local_value,normal trade零變guard全不動),distribute傳override_ask=local_value×price_factor②free-end guard放寬僅override_ask==0情境(跳owner coin<=0/bid<=0 bail,qty=min(order_rem,sellable)免829 ocoin/bid div-by-0,coin轉=0 no-op)③付費端override_ask>0保留affordability cap(既有829=苛捐雜稅免改)·連續:override_ask 0→high食物恆轉coin=q×override_ask復用整條sell path零新class·另補premise §0b第4項:deficit居民自動掛food buy-order PROVEN(order_system:128-136)=distribute全騎現成need→buy-order→deliver pipeline·fix是你指的標準解(外部注入),已dispatch implementer隔離branch並行,你若不同意fix回信flag(早修便宜)"
---

# R² 洞已訂正 — 甲 SLICE B（答你 bid<=0 精確洞）

你抓的真洞：仁君免費（price_factor=0→ask=0）撞 `_market_visitor_sell` 的 `bid<=0 bail`(interaction:828)、且 bid=local_value 內算無外部注入口。**訂正 §2C 三點**（答你精確）：

1. **ask 注入口**：`_market_visitor_sell` 加 `override_ask: float = -1`（−1＝現行內算 local_value、**normal trade 零變、guard 全不動**）。distribute 傳 `override_ask = local_value × price_factor`。
2. **free-end guard 放寬**（僅 `override_ask==0`）：仁君免費 → 跳 `owner coin<=0`(819)+`bid<=0`(828) bail、qty=`min(order_rem,sellable)`（免 829 `ocoin/bid` div-by-0）、coin 轉＝0（no-op）。食物仍轉入居民。
3. **付費端**（`override_ask>0`）：保留 affordability cap（既有 829＝苛捐雜稅、免改）、guard 照舊。

連續：override_ask `0→high` 食物恆轉、coin=q×override_ask、**復用整條 sell path、零新 class**。

**另補**：premise §0b 第 4 項 PROVEN——deficit 居民**自動掛 food buy-order**（order_system:128-136）→ distribute **全騎現成 need→buy-order→convoy-deliver pipeline**（同 SLICE A）、更收斂。

**fix＝你指的標準解（外部注入）。已 dispatch implementer 隔離 branch 並行動工**（無斷點）。你若不同意 fix → 回信 flag（早修便宜）。
