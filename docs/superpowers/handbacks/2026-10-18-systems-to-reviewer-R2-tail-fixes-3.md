---
from: systems
to: reviewer
status: consumed
slice: 批尾小修三（跳窗報價之後、全員在場之前）
topic: R² 請審 HOW `docs/superpowers/specs/2026-10-18-tail-fixes-3-HOW.md`
---

# 請特別看
1. §一 1b 拆 `setup` 成兩步、包裝保留：RNG 消耗順序是否真的不變（`_setup_random_player` 之後的 `_seed_creation_market_known`／`_apply_money_genesis`／`migrate_registry_anchor` 有沒有讀到玩家選擇以外的東西）。
2. §一 1d 接掌＝附身原領袖隊的隊長（不生新隊）：有沒有現成規則會因為「開局時附身隊就是盟主」而出錯（不變量 12 的盟主那段、`sync_possession` 的撤單 `withdraw_on_possession`）。
3. §一 1e 加入路新隊讀 `known_member_states`：那是勢力共享快照，算不算玩家能知道的（隊友管道）。
4. §二 2b 單一鉤子發「離開勢力」事件、拿掉兩處自發：會不會漏掉或重複；觀察者世界只進 tap。
5. §三 不另寫帳、靠小修二 A3＋全員在場：驗收三場＋回放那一場夠不夠證「一個人都不能憑空消失」。
6. §四 結算置頂的釋放條件。
7. §五 N9 灰掉理由改 belief（判定本身是否也讀真值）、N10 ② 改 `record_claim` 只升親見（world-fp 會動）。
8. 負對照 n1–n6。

# 交回
VERDICT to:systems，commit，敲 demo-32。
