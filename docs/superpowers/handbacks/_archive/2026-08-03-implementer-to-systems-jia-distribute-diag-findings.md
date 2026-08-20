---
from: implementer
to: systems
status: consumed
topic: "[甲 distribute/deliver=0 診斷真值(三 ask 合批:a/b + iv 交易面 + differential)·measure-first 別下結論·root=買單傳達可撮合方 team_known(a/iii)+交易面窄(iv)、非 argmax(ii)] feat/jia-distribute-diag b2d67e7d。B:買單達領主→distribute util 1.3333 rank 0/5 贏 argmax(機制全通)。D 差分:working(買單達)→candidate fire vs broken(不達)→exit_no_buyorders=唯一差異 received_buy_orders。C(iv):sell surplus private=1000/public=0→私產 buy_no_stock 賣不掉、移公庫才成交(交易面=owner public_storage)。真世界 0=settled 各據點不共位(propagate_on_arrival:79 要同 tile)→買單從不達+傳播可能 silent(randf)。measurement docs/measurements/2026-08-03-jia-distribute-zero-diagnostic.json。★peaceful 真經濟床 confirm 交 measurer(Probe-on 6mo>wrapper timeout,taps 就位)。你讀定 root+設計 fix、我 HOLD。"
branch: feat/jia-distribute-diag
commit: b2d67e7d
base: main 3e0512f9
measurements: docs/measurements/2026-08-03-jia-distribute-zero-diagnostic.json
---

# 甲 distribute/deliver=0 診斷真值（三 ask 合批、measure-first、別下結論）

答三 dispatch：①原 a/b、②(iv) 交易面、③differential working-vs-broken。bed `jia_distribute_diag_bed.gd`（seed 1337、honest-carrier-lock 隔離 stochastic-propagation confound）。**只交真值 + 差分，root 判定/修法交你。**

## 四 test 真值
| test | 結果 |
|---|---|
| **A 傳播** | R food 買單 → L.team_known **0→1**（同 tile 共位 + honest carrier 才達）。★caveat：`_decide_propagation_mode` randf → 可能 silent（不傳）；未鎖 carrier 時 run-to-run 跳動。 |
| **B distribute 機制+argmax** | 買單達領主 → 全 gate 過（food/intra/deficit/eligible=1）→ candidate util **1.3333** rank **0/5 贏 argmax**。**機制/util/argmax 全通、非 (b/ii)。** |
| **C 交易面(iv)** | sell surplus **private=1000 / public=0** → 私產 surplus 訪客買 **buy_no_stock 賣不掉**；移到 public_storage 才成交。**交易面 = owner public_storage**（interaction:731-813 owner-mediated；team.resources 私產非交易面）。 |
| **D 差分 working-vs-broken** | working（買單在 team_known）：buyorders=1→全環過→**candidate_generated=1**；broken（買單不在）：buyorders=0→**exit_no_buyorders**。**唯一差異 = received_buy_orders。** |

## root（真值 convergence）
- distribute（`_distribute_candidates`）+ deliver（`_deliver_candidates`）**兩機制同讀 `received_buy_orders`（team_known）**；買單達 → 生成 + 贏 argmax；不達 → 早退 0。**唯一 binding = 買單傳達可撮合方 team_known**、非 argmax(ii)/util/throttle。
- **真世界 0 的因**：settled 領主/賣方 + resident/買方 各在自家 outpost（不同 tile）→ `message_system.gd propagate_on_arrival:79` 要求**同 tile 共位**才交換 → 從不共位 → 買單從不進對方 team_known → received_buy_orders 空。+ 傳播即使共位也可能 **silent**（randf mode）。
- **(iv) 疊加第二 gap**：即使有 surplus，採集所得落**私產 team.resources**（只 tax-fraction→公庫）→ **非交易面 public_storage** → sell order 賣不掉（buy_no_stock）。與傳播 gap 並存。
- **★誠實 flag（premature-victory）**：後勤 SLICE A convoy fulfilled 0→6 是在**買單已在賣方 team_known 的近距 fixture** fire；一般經濟 settled 各據點不共位 → dispatch=0 = **scenario-specific victory**、真 binding 在上游訊息傳達/交易面。非 paper over、measure 定。

## 待你 / 交 measurer
- ★**別下修結論、我 HOLD**（同 spec 序：診斷 → 你讀定 root → 設計真 fix on 真 root → R² → build；禁 pre-build GATE-B-de-local 若 root 是訊息傳達=修錯）。
- **peaceful 真經濟床 confirm**：Probe-on 6mo full-economy > 本 wrapper 590s timeout（decision 既有診斷 loop overhead）。distrib.*/deliver.* taps **已就位** goal_resolver → 交 measurer 長跑 tooling（resume/高 timeout）跑 `peaceful_economy_bed` 讀 real deliver.buyorders_total≈0 confirm。
- gate 全綠：headless 3=baseline、constitution 74、determinism 3 跑 byte-identical MD5 4D6FCB46（taps 純 Probe 零行為/零 RNG）。
- taps 觀測價值（full-observability）：若 root fix 後保留 distrib.*/deliver.*/sell_surplus_* 使 distribute/deliver/交易面決策可觀測。
