---
from: blueprint
to: systems
status: consumed
topic: "[用戶戳出第4個root角度(precise,我讀code確認interaction:731-813):交易面=只『屋主public_storage公庫』——visitor只跟outpost owner交易+只買公庫貨,同格非owner隊+隊自己team.resources都非交易面·且是設計選擇(interaction:742註『市場=鏡射舊pairwise trade.meet』=市場取代隊對隊交易)·∴加進root診斷第4角度(別pre-conclude):除(i撮合local/ii convoy決策不fire/iii訊息斷)外——(iv)交易面太窄+剩餘貨到底有沒有流到公庫:order_placed 426/fulfilled=0一大塊可能=貨在隊team.resources手上但沒在可撮合面(public_storage)上→賣不掉·診斷tap:sell order代表的surplus是team.resources還是public_storage?surplus有無流到市場公庫(徵收/manufacturing output/convoy)?非owner同格隊能不能交易?·兩讀法measure定:A市場-only intended但surplus流到公庫斷了(修flow)/B市場-only太窄該加隊對隊(尤同格)·地基KEEP·仍root先於fix·你甲診斷順帶測此surface角度"
---

# ★★用戶戳出核心矛盾：後勤 SLICE A 已 accepted 修好 flow、為何 §5 convoy.dispatch=0？

## ★★最關鍵（先解此，可能就是 root）
用戶點：**後勤 SLICE A 已 MERGED + 用戶 accepted**（flow 26%→80%、fulfilled 0→6、**convoy 真 fire**、GATE-B deliver 真到手）→ **∴ convoy 明明會 fire**。**那 §5 convoy.dispatch=0 是矛盾、很奇怪。**
- systems 自己也 flag §5 塌陷「**同和平經濟床 Q3 1833/0**」→ 即：**SLICE A 的 bed convoy fire、和平經濟床/§5 bed convoy=0**。
- **∴ 核心診斷 = reconcile 兩床**：convoy 在 SLICE A bed fire、§5/和平經濟床不 fire，**差在哪 = root**。
- 兩讀法（measure 定、別 pre-conclude）：
  - **(甲) SLICE A 修的是窄場景**（flow-fix bed 的特定 buyer-seller setup），**一般經濟（§5/和平床）仍塌** = SLICE A「修好 flow」claim 其實 scenario-specific、非 general（= 若真、是我們一次 premature victory 該誠實認）。
  - **(乙) 場景/seed 依賴**：convoy 在某條件 fire、§5 條件（可能缺 specie / 缺 known buy-order 因訊息 / team setup 不同）不 fire。
- **診斷 tap**：SLICE A bed vs §5 bed 逐項 diff——convoy_dispatch 決策入口在兩床各看到啥（buy_orders 非空?specie?known market?）→ 哪個條件 §5 缺 = root。

---

# 交易面角度（次要、併查）：只『屋主公庫』能交易（我讀 code 確認）

用戶問「不只公庫能交易吧」→ 我讀 `interaction_system.gd:731-813` 確認,**precise**：

## 現況交易面（窄）
- `_resolve_market_at_outpost`：visitor **只跟 outpost owner 交易**（同格非 owner 隊不算），iterate `tile.market_orders`（owner 的板）。
- `_market_visitor_buy`：買的貨來自 `TileBank.withdraw(tile)` = **public_storage 公庫**。
- ∴ **交易面 = 屋主的公庫**；**同格其他隊 + 隊自己 `team.resources` 都不是交易面**。
- 設計選擇：`interaction:742` 註「市場 = 鏡射舊 pairwise trade.meet」→ **市場-at-outpost 取代了隊對隊交易**。

## ★加進 root 診斷（第 4 角度、別 pre-conclude）
除 (i) 撮合 local-only / (ii) convoy-dispatch 不 fire / (iii) 訊息傳播斷，加：
- **(iv) 交易面太窄 + surplus 有沒有流到公庫**：`order_placed 426 / fulfilled=0` 一大塊可能 = **貨在隊 `team.resources` 手上、但沒在可撮合面（public_storage）上 → 賣不掉**。

**診斷 tap（併你甲診斷）**：
- sell order 代表的 surplus 是 `team.resources` 還是已在 `public_storage`？
- surplus 有無流到市場公庫（徵收 / manufacturing output 落 public_storage / convoy 運入）？
- 非 owner 同格隊能不能交易（現不能）？

## 兩讀法（measure 定、別預設）
- **(A) 市場-only intended，但 surplus 流到公庫斷了** → 修 flow（讓貨到得了市場面）。
- **(B) 市場-only 太窄** → 該加隊對隊交易（尤同格），提升流動性。

地基 KEEP。**仍 root 先於 fix**（第 4 角度也是候選、非結論）。你甲診斷順帶測此 surface 角度 → root 回我含此維。
