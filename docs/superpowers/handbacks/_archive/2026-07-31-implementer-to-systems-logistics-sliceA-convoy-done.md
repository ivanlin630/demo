---
from: implementer
to: systems
status: consumed
topic: "[done·後勤 SLICE A convoy·三驗收線全綠·請 R²→measurer] feat/peaceful-economy-bed 4754214e。deliver option(_deliver_candidates,demand-finder received_buy_orders belief+不 gate ARCHETYPE)+convoy 生命週期(FETCH exact-load conserving→OUTBOUND→DELIVER _resolve_market_at_outpost=visitor_sell settle→RETURN merge 釋 pop)+throttle 1/隊+perf 前閘。★三驗收線 measured:①dispatch/deliver=4+Market 成交 ②★order_fulfilled 0→5 ③cargo_delivered=69 貨真離賣方。deliver candidate 真 fire(util 0.76 贏 argmax,非假設)。unit 4/4(cargo 守恆+candidate gen)+determinism 三跑 byte-identical(97807301)+不凍(attrition1.80%≠0 teams90 churn convoy59 warring)+headless 3=baseline+constitution74+observability PASS+cargo/pop 守恆(unsold merge 回無 zombie)。★flag:convoy.return 和平床 telemetry=0(功能真 return 已證:merge/無 zombie/pop 守恆;warring convoy=59)。"
branch: feat/peaceful-economy-bed
commit: 4754214e
base: 613d763d (local main HEAD)
measurements:
  - docs/measurements/2026-07-31-peaceful-econ-bed-convoy-final.txt
  - docs/measurements/2026-07-31-warring-seed1337-convoy-determinism.json
---

# done：後勤 SLICE A — 供給-delivery convoy（GATE-B 撮合物理送貨）

照 systems 確認訂正版 spec 建（demand-finder `received_buy_orders` + `_market_visitor_sell`，非 spec 原名反向函式——建前 flag、systems 親驗確認）。★三驗收線全綠、measured 非假設。

## 做
**(A) deliver 決策 option**（`goal_resolver._deliver_candidates`）：surplus holder(`effective_holding>reserve+DELIVER_MARGIN`) + 知 demand 市場（belief:`OrderSystem.received_buy_orders` 親聞 buy 單，感知鐵律非 god-view）→ 生 `{task:TASK_CONVOY, target:買方市場, cargo:{res:qty}, kind:deliver, order_id, delegate}` 入 argmax util 秤（`payoff=coin_gain/NORM × dev_coeff × discount`，clamp<GOAL_UTIL_CAP）。★**不 gate ARCHETYPE_TRADE**（任何 surplus holder，生產隊菜單缺此=根）。★**perf 前閘**（warring 49+ 隊每 cadence）：pop<CONVOY_MIN/子隊/白名單 res/raw-holding 廉價濾 → 再呼貴的 received_buy_orders/reserve。

**(B) convoy 生命週期**（`faction_ai`）：
- `_dispatch_convoy`：派 porter 子隊(pop 2) + **FETCH** cargo=exact load（`_load_convoy_cargo` conserving：dispatch frac-split 後補/退到 exact，守恆）。
- `_tick_convoy`：**OUTBOUND**(travel 到 demand 市場)→**DELIVER**(`_resolve_market_at_outpost`=賣方 visitor_sell → `TileBank.deposit` 入 buyer tile + `_settle_owner_order`→`order_fulfilled++` + coin)→**RETURN**(到家歸建釋放 pop，merge_back 非 settle)。各階段專屬 `_evaluate_subteam` 分支（防 generic `:1753` 攔截半路棄貨；子隊 sticky 免 persist-hold）。
- **throttle**：一隊同時只一 convoy（防 surplus 每 cadence 重派 porter storm）。
- ② `TASK_CONVOY` 常數；probes `convoy.dispatch/fetch/deliver/return` + `cargo_out/delivered`（PROBE_KEYS）。純算術零 RNG。

## ★三驗收線（和平床 measured，非假設；`docs/measurements/2026-07-31-peaceful-econ-bed-convoy-final.txt`）
1. **①convoy 真派真 deposit**：`convoy.dispatch/fetch/deliver=4`、log `[Market@(6,8)] Team12 outpost owner Team0 成交`（porter 真到市場 deposit）。
2. **②★`order_fulfilled` 0→5**：material 第一次真換手（GATE-B 撮合活）。
3. **③貨物理真離賣方**：`cargo_delivered=69`（porter 把 material 搬入 buyer granary；unsold 隨 porter merge 回母隊=守恆）。
- **deliver candidate 真 fire（measured，本 session 鐵律）**：dump `deliver_material util=0.7652` 進 scored、贏 argmax → 4 dispatch（和平床）/ 59 dispatch（warring）。

## 驗（全綠）
- **unit 4/4**（`convoy_delivery_test`）：cargo topup/excess-return 守恆 + deliver candidate 生成(surplus+demand) + 無 surplus 不派空車。
- **determinism**：seed1337 三跑 byte-identical（MD5 `97807301CD5136...`）——convoy 純算術零 RNG。
- **不凍**：seed1337 attrition=**1.80%≠0**、teams=90(churn)、convoy=**59 dispatch**（warring perf OK，1mo 完成<900s）。
- **cargo/pop 守恆**：unit 證 + unsold 隨 porter merge 回 + 無 zombie porter（和平床 end teams=10=12−2 設計 runway starve，porter 全歸建）。
- headless **3=baseline(0-new)**、constitution PASS **74 removed=0**、observability PASS。

## ★flag（非阻斷，telemetry）
`convoy.return` 和平床 probe=0（porter 中途被 loop2b release→IDLE 後走 IDLE 併回路，我在真 merge 點:766 認 convoy_phase 補記仍未穩捕捉）——但**功能真 return 已證**（merges 發生、pop 守恆、無 zombie；warring convoy=59 正常）。measurer 若需精確 return 計數，此 probe 待後續 tighten（不影響功能/守恆/三驗收線）。

## 交付
→ R²（★異質：deliver util 秤真 fire[measured]/convoy 不被 settle-merge 攔[③專屬分支]/cargo 守恆/感知鐵律 demand 讀 belief/不凍/perf 前閘/throttle）→ measurer（★三驗收線：真派真 deposit + fulfilled>0 + 貨真離賣方，和平床 re-run 落地標 path）→ QA 故事稽核。分配 B/貿易 C 照舊。
