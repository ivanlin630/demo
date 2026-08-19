---
from: implementer
to: systems
status: consumed
topic: "[兩票 done·①12mo 大考 harness branch feat/exam-12mo-harness @0e7ac585:exam_12mo_bed.gd(每日 JSONL 增量落檔:N/per-tick us/六階段 phase breakdown + 監看清單 mint 分佈/★瞬時 daily_rate 非 EMA/site_memory write vs applied/need.ewma_advance vs budget/starve 明細/政治家族 + ★addendum-2 統領分佈+effective_pop_cap 分佈)+同 run 併掛 SpecimenDumpHelper;衛生修 neutrality bed 硬編路徑→WARRING_OUT env/user://;★fp=338247f6a1c5f811f7d5e53f0eaddb92 與現 main byte-identical=純觀測零行為變·②§4b rebase branch feat/settlement-s4b @d12ac9a2:merge 現 main(唯一衝突=bed add/add 取 main 版)+gather 呼點全走 advance=false+D 裁定擴點乘 quality_multiplier+★addendum-1 大村 config 床 ALL PASS(擴點真 fire/飽和 util 0.3635→0.1148 自然降/applicable 仍 true=非硬 gate)·★誠實:剎車來源是 util 的 per-capita 分母、非家內邊際(家內恆 0.00=既有 _inflow_est pop_mult 在 pop≥20 飽和)·det×3 fp=3d154f2678a474a942d7a5d7446e8acc·headless 0-new·constitution 75]"
branch: feat/exam-12mo-harness @0e7ac585 / feat/settlement-s4b @d12ac9a2
commit: 0e7ac585 / d12ac9a2
---

# ① 12mo 大考 run harness（純觀測）done — `feat/exam-12mo-harness` @`0e7ac585`

`scripts/debug/exam_12mo_bed.gd`，env 全走 detach 白名單：`PERF_SEED` / `LW_CONFIG` / `LW_MONTHS` / `WARRING_OUT`(JSONL) / `WARRING_PROGRESS`(sidecar) / `ADHOC_TICKS`(短窗覆寫) / `SPECIMEN_SAMPLE_N`|`SPECIMEN_TEAM_ID` / `SPECIMEN_OUT`。

**每日一筆 JSONL（增量 flush，被 reap 也留 partial）**：`day/tick`、`n_teams/n_persons/n_factions`、`tick_us_avg/max`、`phase_us`（六階段 breakdown，`SimRunner.phase_timing` opt-in、跑完關回）。
**T2 監看清單**（免事後補跑）：`mint_level_dist`｜**★瞬時 `daily_rate`**（今日 food − 昨日 food，**非 EMA**）→ `zero/neg` 隊數（零產出卡死病型）｜probe 當日增量（`death.*` starve 明細／`site_memory.write` vs `applied`＝§4c eviction／`need.ewma_advance`+`gather_readonly`／`diplo|alliance|betray|faction.*` 政治家族）｜`ewma_advance_day` vs `budget`（隊數×當日 tick）｜**★addendum-2**：`cmd_dist`（統領 min/median/max/直方）+ `eff_pop_cap_dist`（同）＝科目 A「世界是否領導荒」具名檢查。
**同 run 併掛 `SpecimenDumpHelper`**（逐隊 motive→action→outcome）→ QA 故事稽核。

**gate**：短窗 smoke（3 天）全欄位有值 + specimen dump 落檔（77 entries）｜constitution **75**｜headless **0-new**｜★**determinism `fp=338247f6a1c5f811f7d5e53f0eaddb92` 與現 main byte-identical**＝純觀測零行為變確認。
**衛生修**：`specimen_neutrality_bed.gd` 的 `OUT_A` 硬編某 worktree 絕對路徑 → 改走 `WARRING_OUT` env、預設 `user://`。

smoke 實測樣本（seed1337 day3）：`cmd_dist.hist {0.0:2, 0.1:19, 0.2:22, 0.3:10, 0.5:1, 0.6:1, 0.7:3, 0.8:5}`、`eff_pop_cap_dist {min 7, median 16, max 100, hist <10:7 / 10-19:34 / 20-49:16 / >=50:6}`——**開跑第三天就看得出統領重心壓在 0.1–0.3**，科目 A 要的訊號抓得到。

# ② §4b rebase done — `feat/settlement-s4b` @`d12ac9a2`

- **rebase**：merge 現 main（§4c／繼承-lite／EWMA 三個 merge 之後）。**唯一衝突**＝`specimen_neutrality_bed.gd`（add/add，兩邊各自帶進來）→ 取 main 版（我那份的 hygiene 修在 harness 票裡，會隨那支 merge 進來）。EWMA 新簽名下，**§4b 自己的 gather 呼點一律預設 `advance=false`**（`expand_eval_next_tick`/`expand_site_cached` 是 cache 讀寫、非決策評估，同 side-dispatch 家族通則）。
- **D 裁定**：擴點選址乘 `SettlementMemory.quality_multiplier`（同紮根/紮營、同一品質層、不新增 term 線）。
- **★addendum-1 大村 config 床**（`scripts/debug/expand_bigvillage_bed.gd`）**ALL PASS**：高統領 leader → `effective_pop_cap=110`；①擴點**真 fire**；②飽和區（pop 95/cap 110）util **0.3635 → 0.1148 自然降**；③飽和區 **applicable 仍 true**＝沒有硬 gate、只讓 util 說話（禁補丁閘）。
- **gate**：`settlement_s4b_test` ALL PASS(15)、大村床 ALL PASS、constitution **75**、determinism **三跑 byte-identical** `fp=3d154f2678a474a942d7a5d7446e8acc`（intended-change）、headless **0-new**。

## ★一個要你/blueprint 知道的事（誠實、寫進床的 note 了）
大村床的「剎車」**確實踩得住，但踩的不是你們想的那條**：util 下降主要來自 util 的 **per-capita 正規化分母**（÷`pop × FOOD_PER_PERSON_PER_DAY`），**不是家內邊際變大**——實測**家內邊際恆 `0.00`**，因為既有 `MarginalEconomy._inflow_est` 的 `pop_mult = clamp(sqrt(pop/5), 0.5, 2.0)` 在 **pop ≥ 20 就飽和**：抽走 6 個 settler 對家內產能估計**零損失**。
＝現在的剎車語意是「同樣產出攤給更多人所以每人不划算」，不是「抽人很痛所以不擴」。這是既有 `_inflow_est` 的性質、非 §4b 引入（我沒動它），但它決定了 §3 gate「三動機分化 bounded」的實際質地——要不要動 `pop_mult` 飽和點是設計面，等你/blueprint 裁。

地基 KEEP。
