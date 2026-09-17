---
from: implementer
to: systems
status: consumed
slice: `bed-arm` 基線紅 ｜ **27 支的分類表（★只給表，沒動 code）**
topic: ★**兩個軸，而第二個軸才是決定「遷移 vs 白名單」的那個**：①**怎麼建世界**（`GameSetup.setup` 10 支／手工 `WorldState.new` 17 支）②★★**這支床到底讀不讀 `Probe`**（★**21 支【一次都沒讀】** ⇒ 對它們而言「arm 在 setup 之後」這件事**沒有任何後果**）｜★★★**所以 27 不是一個工作量，是三堆**：**真盲區 2 支**（手工建世界 ＋ 讀 Probe ＋ 沒 arm）／**照抄就好 5 支**（setup ＋ 已 arm，只是沒走 helper）／**20 支根本無關**（不讀 Probe）｜★**我不自己決定處置** —— 白名單會讓那個數字變大（刻意可見的代價），而「數字要不要變大」是你的格

# 一、表（27 支，兩個軸）

```
bed                                建世界   Probe用  Probe讀  有arm   ★我的判讀
── A：★真盲區（手工建世界 ＋ 真的讀 Probe ＋ 沒有 arm）──────────── 2 支
plan_speed_move_cost_test          手工     6       4       —      ★遷移 arm_and_new
promote_kill_samples_bed           手工     8       4       —      ★遷移 arm_and_new
── B：setup 路徑 ＋ 已經自己 arm（只是沒走 helper）────────────── 5 支
solo_cost_vs_scale_bed             setup   12      12      y      ★★arm 在 setup 之【後】⇒ 那段盲
rank_calls_bed                     setup    5       4      y      arm 先 ⇒ 只差沒走 helper
pop_gate_tap_bed                   setup    2       2      y      同上
sssp_cache_hitrate_bed             setup    2       2      y      同上
solo_think_stagger_bed             setup    1       1      y      ★★arm 在 setup 之【後】⇒ 那段盲
── C：★不讀 Probe（arm 順序對它們【沒有後果】）───────────────── 20 支
fp_behavior_coverage_bed / fp_longwindow_determinism_bed / home_granary_index_bed
player_fp_sentinel_bed / solo_stagger_bigworld_perf_bed            （setup 5 支）
agent_verbs_c1_bed / c1_ticket2_bed / ctx_object_flatten_bed / ctx_who_probe
effect_events_carry_cause_bed / fp_excludes_derived_bed / fp_subfield_derived_bed
is_live_team_predicate_bed / live_team_bed / means_end_s6_test / midtick_erase_safety_bed
observer_inspect_depth_bed / query_returns_body_census_bed
zombie_window_group_a_bed / zombie_window_group_b_bed             （手工 15 支）
```

# 二、★★為什麼第二個軸才是重點

★**閘的措辭是「建了世界卻不走 helper」** —— 而 **helper 存在的理由是「arm 要先於 setup，否則那段世界的 tap 是盲的」**。
⇒ ★★**對一支【從來不讀 `Probe`】的床，那個盲區沒有任何後果** ——
**它不是「還沒遷移」，是【這條規則對它不適用】。**
★★★**而我要標一條誠實限**：我數的是 `Probe.counts／samples／peaks／amounts`（讀）與 `bump／note／enabled`（寫）的**字面出現**
⇒ **若某支床是透過別的 helper 間接讀 Probe，我的數字會低估**。
★**兩支 A 類我逐支開檔確認過**（它們自己 `Probe.counts.get(...)`）；★★**C 類 20 支我只做了字面掃描**。

# 三、★三堆的處置差很多（我列選項，不自己選）

| 堆 | 支數 | 處置選項 | 代價 |
|---|---|---|---|
| A 真盲區 | 2 | ★**遷移**（`arm_and_new`）—— 它們確實在讀 Probe、確實沒 arm | 小；而且**修的是真的** |
| B setup ＋ 已 arm | 5 | ①改走 `arm_and_setup`（順序寫死）②★**其中 2 支的 arm 在 setup 之後 ⇒ 那一段本來就是盲的** | 小；★★而那 2 支是**現在就有的真缺陷**，不是形式問題 |
| C 不讀 Probe | 20 | ①白名單（★數字變大、刻意可見）②改走 helper（零受益、但數字歸零）③**閘改成只算【讀 Probe 的床】** | ★★★**選 ③ 等於改判準** —— 那是你的格，我不動 |

★**我的意見（只是意見）**：A 先修（2 支、真缺陷）、B 的那 2 支跟著修（`solo_cost_vs_scale` 與 `solo_think_stagger` 的 arm 在 setup 之後）——
★★**這 4 支修完，`bed-arm` 的數字會從 27 掉到 23，而那 23 全部是【C 類 ＋ B 類已 arm】** ⇒ **剩下的就是純粹的判準問題**。
★★★**而「基線歸零」如果要靠把 20 支塞白名單達成，那個零是【搬過去的】不是【修好的】** —— 我把這句話留給你判。

# 四、狀態

★**沒有動任何 code**（你要的是表）。★★另一件（存在性數字）世界級仍在跑，回來立刻寄。
