---
from: systems
to: implementer
status: open
topic: "[measure-first診斷·甲distribute=0教科書條件真根(§5揭:領主food 3280餘糧+同faction resident瀕死unrest623+resident掛food買單14-18次卻distribute整輪0 fire)·measurer線索(不代因果):_distribute_candidates(goal_resolver:126-201)掃received_buy_orders(order_system:164-174讀team_known order_buy訊息非同faction全知),post_order emit_message傳播(order_system:30-34)但是否達領主team_known未tap·★分兩因(禁靜態斷言禁猜):(a)candidate從未生成(訊息未達領主team_known→buy_orders空→_distribute_candidates早退)vs(b)candidate生成但輸argmax(領主全程task=覓食從未distribute convoy)·做:一次性診斷tap(cheap dev-verify複用§5條件或小fixture領主surplus+同faction resident deficit掛food買單):①_distribute_candidates入口tap:領主received_buy_orders(food)非空?(訊息真達?)②若非空:distribute candidate真生成?util值vs argmax贏家(per-option util dump,分candidate-lost)③若空:訊息傳播鏈斷點(post_order emit→message propagate→領主team_known,哪環沒到)·純觀測tap零行為變零RNG·落地docs/measurements→我讀定(a)/(b)真根·★別下修結論只交真值(a訊息傳播修/b argmax util,天差)·隔離branch feat/jia-distribute-diag"
branch: feat/jia-distribute-diag
---

# measure-first 診斷：甲 distribute=0 教科書條件真根（§5 揭）

**背景**：§5 一次合量揭 **甲 distribute 教科書條件卻整輪 0 fire**（領主 food 3280 餘糧 + 同 faction resident 瀕死 pop10→2/unrest 623 從未賑濟 + resident 掛 food 買單 14-18 次）。**這是本 session 核心病「決策 fire 卻不執行」在整世界重現、必 measure-first 分真根、禁靜態斷言禁猜。**

## ★分兩因（measurer 線索、不代因果）
- `_distribute_candidates`（goal_resolver:126-201）掃 `received_buy_orders`（order_system:164-174 讀 `team_known` order_buy 訊息、**非同 faction 全知**）；`post_order` emit_message 傳播（order_system:30-34）**但是否達領主 team_known 未 tap**。
- **(a) candidate 從未生成**：訊息未達領主 team_known → `received_buy_orders(food)` 空 → `_distribute_candidates` 早退。
- **(b) candidate 生成但輸 argmax**：領主全程 task=覓食、從未 distribute convoy。

## 做（一次性診斷 tap、cheap dev-verify、複用 §5 條件或小 fixture 領主 surplus+同 faction resident deficit 掛 food 買單）
1. **`_distribute_candidates` 入口 tap**：領主 `received_buy_orders(food)` **非空?**（訊息真達領主?）。
2. **若非空**：distribute candidate 真生成? util 值 vs argmax 贏家（**per-option util dump**、分 candidate-lost、[[feedback_measure_peroption_util_before_decision_claim]]）。
3. **若空**：訊息傳播鏈斷點（post_order emit → message propagate → 領主 team_known、哪環沒到）。
- 純觀測 tap（零行為變、零 RNG、determinism 保）。

## 交付
- 落地 `docs/measurements/`（標 path）帶 (a)/(b) 分因真值。
- handback `to:systems`（★別下修結論、只交真值：a 訊息傳播斷點 vs b argmax util 值、天差）→ 我讀定真根 → 定修法。
- 隔離 branch `feat/jia-distribute-diag`。卡 → 報 `to:systems`。
