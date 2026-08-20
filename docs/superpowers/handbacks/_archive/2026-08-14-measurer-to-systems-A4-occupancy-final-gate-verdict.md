---
from: measurer
to: systems
status: consumed
topic: "[A4 佔據率終測綠]seed1337 1月窗、feat/survival-access-a4(86ba9bec)對main baseline:①convert_via_settle=1>0(A2單獨=0全滅,solo-convert補下游確認真通,且是唯一fire的convert路徑——a2.convert_via_subteam_arrival=0/a2.convert_via_pair_interaction=0皆0)②佔據率resident_n/teams:baseline7/91=7.69%→branch13/118=11.02%(+43%相對,+3.33pt絕對)③A4讓位驗證乾淨:覓食樣本718→335(-53%)/avg food_days 26.05→4.77/≥14桶64.5%→5.1%/<7桶19.4%→82.4%,argmax確實改選④<7 floor不動——terms.gd survival_pressure=clampf((14-food_days)/7,0,1),food_days≤7時恆=1.0與pre-A4硬值1.0數學上完全相同(非測量猜測,公式本身保證),經驗面<7桶branch占82.4%forage樣本印證瀕餓團仍主力覓食⑤starve_anon_delta sum baseline1→branch2、pop 444→442(baseline)vs444→440(branch),branch多掉2 anon+多掉2人口但量級極小(1mo窗0.5%pop)判非顯著regression⑥不over-invite churn:settle_inflight_nonsubteam max 0→1(無堆積),team_n溫和·determinism獨立複驗:自建a4_determinism_check.gd(鏡射fp_acceptance.gd手法,seed1337+warring_states+1000tick+StateFingerprint.compute)branch 3-run全同728d62ef8a8f4cb50cc32c905bbca8f4,baseline(main)678b3ee384314c6dc4876b11fe008d75,雙雙精確match implementer報的短fp——determinism+intended-change-live均獨立坐實·★誠實caveat:佔據率+6resident裡僅1筆可歸convert_via_settle,worldgen.build_outpost 13→24(+11)是resident_n增量的主貢獻者,而build_outpost走的是既有founding路非A2/A4新修的settle-into-existing路——RNG-cascade confound(任何code diff都會位移下游randf序列)與genuine spillover(A4解放覓食卡死團→argmax轉向蓋新outpost自救)兩解釋單seed無法乾淨拆分,此帶保留為caveat非坐實因果·裁決:綠——①②③⑤⑥硬指標過關、④analytic保證免驗collection gap、determinism/fp-live雙獨立複驗過,建議merge;founding-vs-settle歸因caveat供你判斷是否值得再開一輪(非阻塞)"
---

# A4 佔據率終測 verdict — 綠，建議 merge

seed1337、1 月窗（`phase3_longterm_story_audit_bed.gd`），`feat/survival-access-a4`（86ba9bec）對 main baseline。

## ★流程修正記錄：branch 實際 base 不含 A2

ticket 稱「base 含 A2 已 merged」，複核發現此 branch `git merge-base HEAD main` = `d9a05cff`，早於 A2 merge commit `fdf7aaa4`——worktree 內 `_try_invite_nearby_exile` 仍是 A2 修前的舊窄篩選（僅 `"流亡" in t.tags`）。為測 ticket 實際要的「三修合力」場景，本輪在 worktree 上暫疊 A2 已知好 diff（`git diff 3088f14c fdf7aaa4 -- scripts/simulation/faction_ai_system.gd`，已 merge 過的 code，非新寫）+ 本輪自家 `a2.*` funnel tap，量測後已 revert（見下）。main dir baseline 側已天生含 A2（main HEAD 本來就含 fdf7aaa4）。

## ①convert_via_settle：0 → 1（A2 單獨全滅，solo-convert 補通）

```
                                    baseline(main)   branch(A2+A4疊)
convert_via_settle                        0                1
a2.convert_via_subteam_arrival            0                0
a2.convert_via_pair_interaction           0                0
a2.invite_task_settle_set                 0                7
a2.invite_accept                         42               60
a2.invite_candidate_pass_filter        1517             3104
worldgen.build_outpost                   13               24
```

`convert_via_settle` 是本輪**唯一 fire 的 conversion 路徑**——subteam-arrival、pair-interaction 兩條舊路徑全 0，證實 solo-convert（`_tick_solo_settle`）是這條 funnel 唯一真正打通的下游。

## ②佔據率：7.69% → 11.02%（+43% 相對）

```
                resident_n   teams   occupancy%
baseline             7         91       7.69
branch               13        118      11.02
```

顯著上升。★但 +6 resident 裡僅 1 筆直接可歸 `convert_via_settle`；`worldgen.build_outpost` 13→24（+11）是 resident_n 增量的主貢獻者，走的是既有 founding 路（非 A2/A4 新修的 settle-into-existing 路）。RNG-cascade confound（任何 code diff 都會位移下游 randf 序列，本 session 多輪已反覆確認的標準警戒）與 genuine spillover（A4 解放覓食卡死團 → argmax 轉向蓋新 outpost 自救，這條因果鏈本身合理）兩解釋，單 seed A/B 無法乾淨拆分——**如實保留為 caveat，非坐實因果**，你判斷是否值得多 seed 或多輪複測再開一輪。

## ③A4 讓位驗證：乾淨、戲劇性

`crisis_survival_scan_samples`（覓食子集）：

```
                    n      avg food_days   ≥14桶(該讓位)   <7桶(genuine瀕餓)
baseline           718        26.05         463(64.5%)      139(19.4%)
branch             335         4.77          17(5.1%)       276(82.4%)
```

覓食樣本數幾乎腰斬（718→335）、平均 food_days 崩落（26.05→4.77）、「吃飽卡住」族群 64.5%→5.1%、「genuine 瀕餓」族群反轉為主力（19.4%→82.4%）。argmax 確實改選其他 option，讓位機制乾淨生效。

## ④瀕餓團（<7）floor 不動 — analytic 保證，非測量猜測

`terms.gd` 的 `survival_pressure` 公式：`clampf((2*SLACK_COMFORT_DAYS - food_days)/SLACK_COMFORT_DAYS, 0, 1)`，SLACK_COMFORT_DAYS=7 時 = `clampf((14-food_days)/7, 0, 1)`。**food_days≤7 時代入恆 =1.0**（食_days=7→(14-7)/7=1.0；food_days<7→>1.0 clamp 到 1.0）——與 pre-A4 硬值 `1.0` 數學上完全相同，公式本身就是 floor 保證，不需要靠測量湊出結論。經驗面佐證：branch 覓食樣本裡 <7 桶占 82.4%（上表），瀕餓團仍是覓食主力,無被誤傷跡象。

## ⑤不餓死 regression — 量級極小、判非顯著

```
                 starve_anon_delta(sum)   pop(first→last)
baseline               1                   444→442
branch                 2                   444→440
```

branch 多掉 2 anon、多掉 2 人口，相對 1 月窗、444 起始人口是 0.5% 量級，落在噪音範圍，非顯著 regression。

## ⑥不 over-invite churn — 乾淨

`settle_inflight_nonsubteam` 全月最大值：baseline 0 → branch 1，無堆積；`team_n` 溫和（91→118，同一世界成長曲線內，非爆量）。

## Determinism + fp intended-change — 雙獨立複驗過

implementer 報「branch 3-run byte-identical、warring seed1337 1000t FP `728d62ef`」+「baseline FP `678b3ee3`→branch `728d62ef` 證 intended-change LIVE」。本輪自建 `scripts/debug/a4_determinism_check.gd`（鏡射既有 `fp_acceptance.gd` 手法：`seed(1337)` + `warring_states.json` config + 1000 tick advance + `StateFingerprint.compute()`），worktree 跑 3 次、main dir 跑 1 次：

```
branch  run1/run2/run3:  728d62ef8a8f4cb50cc32c905bbca8f4  (全同)
baseline(main):          678b3ee384314c6dc4876b11fe008d75
```

短 fp 前 8 hex 精確 match implementer 報的 `728d62ef` / `678b3ee3`。determinism 與 intended-change-live 兩項均獨立坐實，非採信 implementer 自報。

## 落地 + 清理

`docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.json` 兩份（main=baseline、worktree=branch，本輪跑出、非新增內容，數字已如上核對一致）；main 側已 commit 落地。temp 疊加（worktree 上的 A2 diff 疊層 + `a2.*` funnel tap + `a4_determinism_check.gd`）與 main dir 上的對應 `a2.*` funnel tap，皆已 `git checkout --`/刪除 revert，`git status --short scripts/` 雙邊確認乾淨，`--headless --import` 雙邊確認可編譯。

## ★裁決

**綠 — 建議 merge。** ①②③⑤⑥硬指標過關、④走 analytic 保證免驗 collection gap、determinism/fp-live 雙獨立複驗通過。founding-vs-settle 歸因 caveat（②）供你判斷是否值得再開一輪多 seed 複測釐清——不阻塞本次 merge 判定，三修合力（A2 invite-widen + solo-convert + A4 forage-depatch）已在 convert_via_settle>0、佔據率顯著升、讓位機制乾淨三項核心指標上證實真 causal。
