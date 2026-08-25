---
from: implementer
to: systems
status: consumed
topic: "[§4b done·branch feat/settlement-s4b @8cb9a51b·base main 0481315a·T1 擴點 option(applicable 只物理可行性、util=你給的精確公式三項同量綱零係數、idle_labor 只當篩選未進公式、delegate 既有路、priority=PRIO_DISPATCH+why-comment)+T2 overflow margin 1.15(唯一新常數、保底不刪、加 overflow_split.mechanical_fire probe)+T3 不做·TDD settlement_s4b_test ALL PASS(15)·constitution PASS 75 未回升·s2b/s1/s2a/agri a/b 全綠·determinism 三跑 byte-identical ★新 fp=dd01150d0e6510b78599588343f341e9(intended-change 真現形、與 base main 不同)·headless 0-new·★一個要你知道的湧現性質:pop_mult 飽和區(pop≥20)家內邊際恆 0→大村擴點 net 只剩 分點−成本=幾乎必正、擴張門檻在大村消失(既有 _inflow_est sqrt clamp 0.5~2.0 的性質、非我加的)、建議列 measurer 具名科目]"
branch: feat/settlement-s4b
commit: 8cb9a51b
---

# §4b done（三動機 + 擴點純邊際帳 + overflow margin）

## T1 擴點 option
- **applicable=只物理可行性**：`has_own_outpost` + `_evaluate_new_outpost_location` 回有效 pos + 母隊 `pop ≥ settler×2`（**沿用 `_dispatch_builder` 既有規則**：`settler = maxi(6, level*4)`、母隊須 2 倍；未新增門檻）+ 非玩家。
- **util＝你給的精確公式**（三項同量綱 食物/日、**零換算係數**）：
  - 家內邊際 `= _inflow_est(家est, pop) − _inflow_est(家est, pop−settler)`（鏡射 `migrant_marginal` 差分、方向相反）
  - 分點期望邊際 `= _inflow_est(候選地 est)`，est 用 `camp_target_est` pattern（`VillageEstimate.make(候選 terrain, 1, 0, settler)`）
  - 建置成本 `= 分點邊際 × clamp(工期天數 / PLANNING_HORIZON_DAYS)`（既有 `BUILD_TICKS["civilian"][0]` + 既有視野常數攤提）
  - `util ∝ max(0, 分點 − 成本 − 家內) / 日需求`，人格只 modulate 既有權重（野心 0.6 / (1−慎重) 0.4）
- **`ctx.idle_labor` 照裁定只做 applicable 篩選/早退**（`idle_labor > 0` 才算），**沒進 util 公式本體**。
- **to_task=delegate 既有路**（`{delegate:true, build_type, target, settler}` → `_dispatch_builder`）；照 reviewer 親查結論**沒加 commit-hook**。
- **`priority`=`PRIO_DISPATCH` + why-comment**（§4a invariants 契約）。
- **效能**：`_evaluate_new_outpost_location` 是 O(tiles)、不能每次 gather 跑 → 用**既有 `INFRA_INTERVAL` cadence 快取**（TeamData 加 `expand_eval_next_tick`/`expand_site_cached`＝純效能快取、不入 fingerprint、過期即重算）。

## T2 overflow margin
`check_overflow_for_team` 觸發改 `population > cap × POP_OVERFLOW_MARGIN`（**1.15、本 slice 唯一新常數**）；保底不刪；加 `overflow_split.mechanical_fire` probe 供 measurer 驗「機械觸發→趨近 0」。

## TDD / gate

| 項目 | 結果 |
|---|---|
| `settlement_s4b_test` | **ALL PASS（15）** |
| ①動機分化 | 無家團 `can_expand=false`；有家+候選+pop 足才 true |
| ②邊際帳零係數 | 三項逐項與 `_inflow_est` 差分**數值對得上**（實測家內 0.000／分點 8.764／成本 0.041）、`net≤0→util=0` |
| ③commit priority | `priority_for(擴點)=50`、非 survival set |
| ④margin | `pop=cap+1`（101 vs cap 100、界 115）→ 機械**不** fire；`pop=117 > cap×1.15` → **仍** fire（117→100、無死角） |
| ⑤既有不破 | 紮根 @50 且仍在 survival set、紮營/擴點並存 |
| constitution | **PASS sites=75**（未回升） |
| s2b / s1 / s2a / agriculture_a / agriculture_b | 全 **ALL PASS** |
| determinism | **三跑 byte-identical** ★**新 fp `dd01150d0e6510b78599588343f341e9`**＝**intended-change 真現形**（與 base main 不同；不像 §4a 那輪 dormant） |
| headless | **0-new**（6 known assert + 3 known FAIL） |

## ★一個湧現性質，你可能要列 measurer 具名科目
測到的實數：**家內邊際 = 0.000**。原因是既有 `_inflow_est` 的 `pop_mult = clampf(sqrt(pop/5), 0.5, 2.0)` 在 **pop ≥ 20 就飽和**（30 人和 24 人都是 2.0）→ 抽走 6 個 settler **對家內產能估計沒有任何損失**。
後果：**大村（pop≥20）的擴點 net 只剩「分點邊際 − 建置成本」＝幾乎必為正**→ 擴張在大村幾乎沒有機會成本、門檻消失；小村（pop<20，未飽和）才會有真正的取捨。
這是**既有 `_inflow_est` 的性質、不是我加的東西**（公式照你給的寫、沒動 `_inflow_est`），但它會直接決定「三動機分化 bounded」那條 gate 的表現（可能出現大村狂開分點）。建議列進 measurer 那輪具名科目；要不要動 `pop_mult` 飽和點是設計面、我沒碰。

其餘：§4c（`site_failed`/`site_thrived` memory + 30 天線性衰減）未做＝下一 slice。地基 KEEP。
