---
from: systems
to: implementer
status: consumed
topic: "[measure-first·ground GATE-B撮合賣方delivery gap(別靜態斷言,同買方dump款)·和平床加一次性dump:選一個賣方隊(Team3 material=400 surplus)在某decide tick,印per-option util全排序+winner·尤其『賣material/去市場賣』相關option util vs它贏的·+印Team3實際行為(有無TASK_TRADE去市場deliver? tile_pos移動? 掛sell order後material有無離開inventory到市場granary?)·目的:定GATE-B撮合真gap=賣方不decide sell-trip(decision)vs decide了但空間到不了買方市場(spatial/delivery)·純觀測零sim改·落地docs/measurements標path] dump Team3賣方per-option util+實際delivery行為,定GATE-B撮合真gap(賣方不decide去賣vs decide了空間到不了)。純觀測。落地。"
branch: feat/peaceful-economy-bed
---

# measure-first：ground GATE-B 撮合賣方 delivery gap（別靜態斷言）

**背景**：measure 定案——買方決策 fire 正常（T0 build_workshop 贏 argmax→走 TASK_TRADE 買 material），但 material order 0 fulfilled=**GATE-B 撮合**（賣方 material 空間到不了買方搆到的市場 granary）。blueprint reframe：logistics arc=**execution/delivery 層**，SLICE A=「讓貨物理到達交易點」。**賣方 delivery gap 未 ground**（禁靜態斷言，同買方 dump 款）。

## 做（一次性 dump，純觀測零行為變，同買方 per-option util dump 款）
和平床選一個**賣方隊**（**Team3**：`material=400` surplus、有掛 `sell material×335`）在某 decide tick：
1. 印該隊 **per-option util 全排序 + winner**（同 T0 買方 dump 格式）——尤其**「賣 material / 去市場賣 / 貿易」相關 option 的 util** vs 它實際贏的 option。
2. 印 **Team3 實際 delivery 行為**：有無 `TASK_TRADE` 去市場 deliver？`tile_pos` 有無移動去市場？掛 sell order 後 material 有無**離開 inventory 到市場 granary**（TileBank）？還是留家？
3. （若有）印 `_merchant_trade_target`/`_market_visitor_sell` 相關 tap（賣方 seek/arrive/deposit）。

## 目的（定 GATE-B 撮合真 gap，二選一）
- **(a) 賣方不 decide sell-trip**（decision gap）：賣 option 輸 argmax（Team3 選建設施/govern 而非去賣）→ gap 在賣方決策。
- **(b) 賣方 decide 了但空間到不了**（spatial/delivery gap）：Team3 有 TASK_TRADE 去賣但到的市場非買方搆到的、或 material 沒真 deposit→留家。
- ★這定 SLICE A 修法方向（decision vs delivery/spatial）。

## 驗 + 交付
- bed exit0、gates 綠、落地 `docs/measurements/`（標 exact path 驗存在）。
- handback `to:systems` 帶 **Team3 per-option util + 實際 delivery 行為（sell option 贏否/material 有無離家到市場）**。
→ 我讀 → 定 GATE-B 撮合真 gap（decision vs delivery）→ scope SLICE A HOW（讓貨物理到達交易點）。★別下 fix 結論（只交真數）。卡住報 `to:systems`。
