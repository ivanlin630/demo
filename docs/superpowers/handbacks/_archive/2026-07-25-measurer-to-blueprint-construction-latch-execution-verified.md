---
from: measurer
to: blueprint
status: consumed
topic: "[measure·construction latch+resume治本execution-verified 6mo·★stall%確降但兩seed幅度不一+complete計數兩seed反向+16/16抽樣completion仍全是upgrade_facility(0筆build)] branch feat/construction-commitment-latch(5b166eb1,worktree)seed1337/42 6mo。stall佔比:seed1337 95.6%→87.3%(降8.3pt),seed42 96.0%→89.7%(降6.3pt)——兩seed皆確定改善,但改善幅度不算大,仍近9成tick離格。construct.complete:seed1337 33→56(+70%顯著升),★seed42 12→10(-17%不升反降,跟implementer給的1mo seed1337 sanity[1→6]方向一致但你我沒seed42 sanity可對照,cross-seed不一致)。resume.orig_recall兩seed皆>0(48/11,達implementer硬標準),但該key未列入CONSTRUCT_SAMPLE_KEYS(worktree code定義,非量測缺口)故拿不到樣本細節。★★關鍵:construct.complete的16筆抽樣(兩seed各8,含construct.start+construct.complete兩key)全數action='upgrade_facility',零筆'build'——即『新outpost真建成』這條ticket寫的硬標準,從抽樣證據看仍未坐實(可能真的還是0,也可能只是抽樣沒抽到,無法從現有8-cap樣本100%排除)。若要100%排除,需再加per-action-type計數tap(本輪為求時效未加,留你/systems判是否需要)。farming_final顯示farm_pos_teams(有farming設施的隊數)兩seed 25/7,farm_zero(無)103/64,indep_farm_pos 11/3——這些是existing outpost設施分布,非新建outpost計數。§④b specimen已產(13973/5248 entries)→QA。你判release-pass或再開一輪『per-action-type outpost_built計數』工單。"
measured_at_head: "feat/construction-commitment-latch 5b166eb1（worktree .worktrees/construction-latch，main dir 未改）"
seeds: "1337 + 42（各 6mo，seeded_warring_bed.gd via WARRING_SEEDS/WARRING_MONTHS）"
---

# construction latch+resume 治本 execution-verified 6mo → blueprint

工單：`2026-07-25-implementer-to-measurer-latch-resume-execution-verified-remeasure.md`（已消費）。branch `feat/construction-commitment-latch`（5b166eb1），worktree 跑（main dir 未動）。seed1337/42，各 6mo。

## stall 消退（確定改善，兩 seed 一致但幅度不算大）
| | seed1337 | seed42 |
|---|---|---|
| stall 佔比 pre-fix（`construction-obs-tap` 上輪） | 95.6% | 96.0% |
| stall 佔比 post-fix（本輪） | **87.3%**（stall=14034/progress=2046） | **89.7%**（stall=3515/progress=404） |
| 降幅 | -8.3pt | -6.3pt |

→ **兩 seed 皆確定改善**，方向一致，但**幅度不算大**——仍有近 9 成的 construction ticks 是「施工隊離格」。

## construct.complete（兩 seed 反向，值得留意）
| | seed1337 | seed42 |
|---|---|---|
| pre-fix（`construction-obs-tap` 上輪） | 33 | 12 |
| post-fix（本輪） | **56（+70%）** | **10（-17%）** |

→ seed1337 明顯上升，**seed42 反而略降**——與 implementer 給的 1mo seed1337 sanity（1→6，+500%）方向一致，但沒有對應的 seed42 sanity 可比對，這輪 6mo 實測顯示 **cross-seed 不一致**，如實回報不下因果。

## resume.orig_recall（兩 seed 皆 >0，達 implementer 硬標準）
| | seed1337 | seed42 |
|---|---|---|
| resume.orig_recall | 48 | 11 |
| reeval.build_latch（latch 觸發次數） | 46224 | 9788 |

→ 兩 seed 皆 >0，達 ticket 訂的「load-bearing」硬標準。**但 `resume.orig_recall` 未列入 worktree code 的 `CONSTRUCT_SAMPLE_KEYS`**（這是他們 tap 定義的選擇，非本輪量測缺口），故拿不到樣本層級細節（哪隊被救回、救回後去向）——只有聚合計數。

## ★★關鍵：抽樣證據顯示新 outpost 建成仍未坐實（0/16 為 'build' action）
`construct.start` + `construct.complete` 兩 key 各抽 8 筆（兩 seed 共 16 筆抽樣）：
- **全數 16 筆 `action` 欄位皆為 `'upgrade_facility'`，零筆 `'build'`**。

→ ticket 訂的硬標準「outpost_built>0」——從**抽樣證據**看，仍未能坐實有新 outpost 真的建成（可能真的還是 0，也可能只是 8-cap 抽樣沒抽到，**無法 100% 排除後者**）。`construct.complete` 計數本身確實上升（至少 seed1337），但抽樣顯示這些完工事件目前看到的全是既有 outpost 的設施升級，非新建。若要 100% 排除抽樣盲區，需要一個**per-action-type 的聚合計數 tap**（例如 `construct.complete.build` vs `construct.complete.upgrade_facility` 分開計數）——本輪為求時效未加，留你/systems 判斷是否需要開一輪追加。

## farming_final（既有 outpost 設施分布，非新建計數，供參考）
| | seed1337 | seed42 |
|---|---|---|
| farm_pos_teams（有 farming 設施） | 25 | 7 |
| farm_zero_teams（無） | 103 | 64 |
| indep_farm_pos | 11 | 3 |

## 溯源
raw：`docs/measurements/2026-07-25-latch-resume-a1-6mo.json`（`.{seed}.probe`/`.probe_samples`）、`docs/measurements/2026-07-25-latch-resume-specimen-{1337,42}.jsonl`（§④b specimen，另封 to:QA）。跑法：`seeded_warring_bed.gd` + `WARRING_SEEDS=1337,42` + `WARRING_MONTHS=6`，worktree `.worktrees/construction-latch`（未 checkout main dir）。★本輪臨時補 specimen 支援（複製 `specimen_dump_helper.gd` 進 worktree + `warring_harness.gd` 加 2 行 `SpecimenDumpHelper.setup_from_env`/`dump`，純 worktree 內 temp，**已 revert，worktree clean**，main 未動）。GODOT_TIMEOUT 首輪 300s（sanity）/後續 28000s（正式跑），兩者皆基於前幾輪學到的量級選擇。別下 fix 結論，數字供你判 release-pass 或加開 per-action-type 計數工單。
