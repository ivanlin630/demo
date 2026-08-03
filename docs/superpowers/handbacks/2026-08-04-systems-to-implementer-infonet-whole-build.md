---
from: systems
to: implementer
status: consumed
topic: "[dispatch build資訊網whole(R²CLEAN,spec=2026-08-04-information-network-whole-HOW.md,WHAT LOCKED=2026-08-03-information-network-core-design.md)·一root三症同propagation dead-end(:79)·接既有seam非建新引擎:Part1看板relay(read_market_board:194擴雙向deposit+read,markets累積異地news再輻射,decay沿用,守物理抵市集)·Part2求援option→TASK_HERALD(既有信使)+偵察option→TASK_SCOUT(既有),reuse _dispatch_envoy/_tick_envoy/_recall_envoy belief-pos travel範式,option進REGISTRY({terms,applicable,to_task}同求和),applicable=need/knowledge-based非死常數,util base=真期望價值人格MODULATE(傲↓務實↑求生欲/關切/多疑/野心)·Part3交易面broaden(_resolve_market_at_outpost:731擴同格willing任何store公私團庫+keep-line=TradeValuation.reserve既有)·Part4饑荒-flee同root免另修·★build可分片commit(S-prop/S-herald/S-scout/S-trade)但量=whole一次(禁分片量)·守:人格非死常數門檻/genuine非crank(★per-option util dump驗傲vs務實分化)/感知鐵律(載體物理belief-pos延遲無god-view,constitution_gate綠)/determinism零新randf/economy不爆keep-line/need-gated/★全量暫態可觀測性(新info-decision·carrier·state必接tap餵measurer)·2 R²追蹤:①calibration常數必錨真值(herald_cost/scout_cost/decay/info_value DERIVED真量非invent,同idle-labor PER_HAND紀律,禁crank能讓求援fire的常數)②hub效應tap(熱門市集高頻造訪會否功能near-global-awareness,交measurer量)·base fresh main(地基勞力池/de-patch/B/甲/後勤已merged)·branch feat/info-network-whole·完HANDBACK to:systems我路measurer whole一次量→blueprint JUDGE"
branch: feat/info-network-whole
---

# dispatch build — 資訊網 whole（R² CLEAN）

**spec**：`docs/superpowers/specs/2026-08-04-information-network-whole-HOW.md`（R² CLEAN）
**WHAT (LOCKED)**：`docs/superpowers/specs/2026-08-03-information-network-core-design.md`
**base**：fresh main（地基 勞力池/de-patch/B/甲/後勤 已 merged）。branch `feat/info-network-whole`。

## 建什麼（★接既有 seam、非建新引擎——spec 有 file:line）
- **Part1 看板 relay**：`read_market_board`（order_system:194）擴**雙向**——訪客抵市集 outpost 除讀外**也 deposit 自己 team_known 的 order/news copy 到看板**（帶 decay：board entry age 過閾值/strength<0.05 清）。markets 累積異地 news 再輻射。守物理抵市集（outpost_level>0）。
- **Part2 有意 info 決策**（進 `DecisionOptions.REGISTRY`、{terms,applicable,to_task} 同「求和」範式）：
  - **求援** → `TASK_HERALD`（既有信使）：applicable=有未滿足 need + 知潛在施助者（belief/faction）；util base=紓困真期望值、人格 MODULATE（傲↓務實↑依附↑孤高↓）；to_task reuse `_dispatch_envoy` belief-pos travel→抵達 deposit 求援 msg 進目標 team_known。
  - **偵察** → `TASK_SCOUT`（既有、scout查證迴路 faction_ai:360）：applicable=有 info-gap+在乎；util base=info_value(belief uncertainty×決策影響)、人格（關切↑多疑↑野心↓好奇↑）；to_task 走查/讀看板/返 fresh belief。
- **Part3 交易面 broaden**：`_resolve_market_at_outpost`（interaction:731）擴同格 willing、任何 store（公/私/團庫）、只賣真剩餘（keep-line=`TradeValuation.reserve` 既有）。tile→teams bounded。
- **Part4 饑荒-flee**：Part1+2 通 → `food_seek_target` 源② received_sell_orders 有值 → relocate applicable。**無獨立修**、量時驗。

## 守（build 時硬守）
- **人格非死常數門檻**：applicable=need/knowledge-based（有 need+知對象 / 有 gap+在乎）、**禁偷藏 runway<X / 沉默>N 常數**；propensity=人格 util。
- **genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：util base=真期望價值、人格 MODULATE 非 arbitrary boost。**★per-option util dump 必接**（傲 vs 務實 求援傾向真分化=驗收項）。
- **感知鐵律**：載體物理走 belief last-seen 位、延遲、無 teleport/god-view live-track；decay/distort 沿用；`constitution_gate` god-view detector **必綠**（無新 indexed 他隊 live 態讀 / whole-map 掃）。
- **determinism 零新 randf**（deterministic 路）+ **economy 不爆**（keep-line 不空掏）+ **need-gated full-stop**。
- **★全量暫態可觀測性**（[[feedback_full_transient_observability]] 不變量）：**新 info-decision / carrier / board-relay / state 全接 Probe tap**（herald/scout dispatch、看板 deposit/read、求援/偵察 candidate 生成+util、food_seek_target 獲值、trade.deal/distribute.dispatch）——餵 measurer whole 量、免盲點捏假故事。

## ★2 R² 追蹤（build 硬守）
1. **calibration 常數必錨真值**（同 idle-labor PER_HAND / mfg-hub 紀律）：herald_cost/scout_cost/decay 參數/info_value scale/紓困 payoff norm **DERIVED from 真量**（載體 cost 錨 travel tick×pop burn、info_value 錨 belief uncertainty×決策影響），**禁 invent「能讓求援 fire」的常數**（=crank paper over）。TEST VALUE 標 + 錨定 rationale 註。
2. **hub 效應 tap**（交 measurer）：看板 relay 結構乾淨但**tap 熱門市集造訪頻率 + 隊 belief freshness 分佈**——量「功能上會否逼近 near-global-awareness」（非只看 detector）。

## 量 = whole 一次（★禁分片量）
build **可分片 commit**（S-prop/S-herald/S-scout/S-trade、單測各片），**但整合後一次量 whole**（同床跑）：
- §5 商業 unstall：`trade.deal / convoy.dispatch / order_fulfilled` 真 >0（多床）。
- 饑荒解：`distribute.dispatch / food_delivered` 真 >0（領主經**傳到的 belief** 賑濟）+ **relocate 找糧活**（food_seek_target 獲值）。
- 人格分化（per-option util dump 傲少求/關切多查）+ fog 保住（遠/敵 stale）+ determinism byte-identical 不凍雙 seed。

**★誠實 measured 才宣稱**（[[feedback_verify_execution_end]]：驗執行端真效果、非只 candidate 生成）。完 → HANDBACK `to:systems` → 我路 measurer whole 一次量 → blueprint JUDGE → Telegram 用戶驗收。卡 → 報 `to:systems`。
