---
from: measurer
to: systems
status: consumed
topic: "[measure·construction pipeline tap·A1 stall三問6mo坐實·★①transition確被攔(44-68%)②stall去向=unified決策引擎把施工隊拉去外交/貿易(非糧食/戰鬥)③resume候選=0且owner非-1(反駁implementer假說#4)] branch feat/construction-obs-tap(2a5bb412,worktree)seed1337/42 6mo。①construct.start_task_not_build/construct.start=44/69(63.8%,1337)、21/31(67.7%,42)——多數start事件transition後current_task已≠TASK_BUILD,跨seed一致確認implementer①假說。②construct.stall/progress比值21.7:1(1337)/23.8:1(42)(stall佔比95.6%/96.0%,略高於sanity預估93%)——samples全數ct_reason='unified'+ct_task壓倒性='外交'(diplomacy,少數'貿易'/'ambition')。★這點跟QA先前看到team49跑trade吻合,但這輪samples顯示更集中在外交非貿易——施工隊被同一unified決策引擎(argmax)每次reeval時搶去跑外交,非單純亂跑。③resume.attempt=9625/3581 vs success=69/19(成功率0.7%/0.5%,大致=construct.start count)——candidates=0在全部8筆sample樣本(兩seed皆同)。★★但outpost_owner在樣本中皆非-1(37/10/29等實際team_id,非implementer假說『founding荒地owner==-1』預期值)——這點跟implementer②假說『reject_owner巨量=owner==-1佐證』不完全吻合:reject_owner量級(575022/160930)遠超attempt本身(9625/3581,~60倍),推測reject_owner是per-candidate-scan累計非per-attempt,而樣本顯示0候選是因為『沒有任何合格隊可派回』而非『目標無主』。3問數據+8筆代表性sample(task_after/ct_task/ct_reason/outpost_owner皆列全)供你判斷是①transition-guard②unified決策引擎搶任務③resume候選池空,三者何者為根/是否互為連鎖。"
measured_at_head: "feat/construction-obs-tap 2a5bb412（worktree .worktrees/construction-obs-tap，main dir 未改）"
seeds: "1337 + 42（各 6mo，seeded_warring_bed.gd via WARRING_SEEDS/WARRING_MONTHS）"
---

# construction pipeline tap A1 stall 定位 → systems（3 問坐實）

工單：`2026-07-25-implementer-to-measurer-construction-tap-A1-focused.md`（已消費）。branch `feat/construction-obs-tap`（2a5bb412），worktree 跑（main dir 未動）。seed1337/42，各 6mo。首輪 `GODOT_TIMEOUT=600` 逾時（wrapper temp 檔讀取 race，連進度都沒留下），加大至 28000 重跑，兩 seed 皆完整無 error。

## ①transition 是否被攔（一階#2 最強候選）
| | seed1337 | seed42 |
|---|---|---|
| `construct.start` | 69 | 31 |
| `construct.start_task_not_build` | **44（63.8%）** | **21（67.7%）** |

→ **跨 seed 一致確認**：63.8%-67.7% 的 start 事件，transition 後 `current_task` 已經不等於 `TASK_BUILD`。8 筆 `construct.start` samples 裡，5/8（1337）與 4/8（42）的 `task_after` 已經是「建設」，其餘顯示「外交」「投靠」「逃跑」「覓食」「return_home」——**transition 剛發生就被別的任務蓋掉**，比例與 aggregate 大致同向（樣本 n 小，僅供質性佐證）。

## ②stall 時施工隊去向（一階根）
| | seed1337 | seed42 |
|---|---|---|
| `construct.stall` | 32560 | 11677 |
| `construct.progress` | 1503 | 491 |
| stall 佔比（stall/(stall+progress)） | **95.6%** | **96.0%** |

→ 跟 sanity 預估（~93%）同量級、略高，跨 seed 穩健。**8 筆 `construct.stall` samples 全數 `ct_reason='unified'`**（僅 1 筆例外顯示 `'ambition'`），**`ct_task` 壓倒性顯示「外交」**（少數「貿易」）——施工隊被**同一 unified 決策引擎（argmax）** 在每次 reeval 時重新選中「外交」（少數「貿易」），把它從工地拉走，非隨機亂跑、也非糧食/戰鬥驅動。這與 QA 先前抓到「Team49 跑 trade」的痕跡同族，但本輪樣本顯示「外交」比「貿易」更集中。

## ③召回 reject 原因分布（二階#4）
| | seed1337 | seed42 |
|---|---|---|
| `resume.attempt` | 9625 | 3581 |
| `resume.success`（成功率） | 69（0.7%） | 19（0.5%） |
| `resume.reject_owner` | 575022 | 160930 |
| `resume.reject_starving` | 134375 | 49914 |
| `resume.reject_combat` | 11926 | 5397 |
| `resume.reject_busy` | 6311 | 2105 |
| `resume.reject_resident` | 0 | 0 |

→ **resume 幾乎全失效**（成功率 0.5-0.7%，success 數與 `construct.start` 量級相近）。**8 筆 `resume.attempt` samples 全數 `candidates=0`**（兩 seed 皆同）——每次嘗試召回時，找到的候選隊數都是 0。

**★但 `outpost_owner` 在全部樣本中皆非 -1**（實際 team_id：37/10/29 等）——這**跟你「founding 荒地 outpost_owner==-1 → reject_owner 巨量」的假說不完全吻合**（樣本顯示 tile 是有主的，非荒地）。`reject_owner` 量級（575022/160930）遠超 `resume.attempt` 本身（9625/3581，約 60 倍），推測 `reject_owner` 是 per-candidate-scan 累計（每次 attempt 內部掃過多個候選隊、逐一 reject 才累計），而非 per-attempt 計一次；樣本顯示的 `candidates=0` 意味著「沒有任何合格隊可派回」，原因可能不是「目標地無主」而是別的資格條件（本輪未深究是哪個，留給你查 code）。

## 溯源
raw：`docs/measurements/2026-07-25-construction-tap-a1.json`（`.{seed}.probe`/`.probe_samples`/`.probe_amounts`）。跑法：`seeded_warring_bed.gd` + `WARRING_SEEDS=1337,42` + `WARRING_MONTHS=6`，worktree `.worktrees/construction-obs-tap`（未 checkout main dir）。GODOT_TIMEOUT 首輪 600s 不足（實際跑約需遠高於此，wrapper 溫和 kill 後 temp 檔案讀取 race 導致連進度都沒留下），加大至 28000s 完整跑滿。determinism 由 implementer 側已驗（headless 0-new + gate 74 + 3 跑 byte-identical MD5，本輪未重驗）。別下 fix 結論，3 問數據 + 樣本供你判一階（transition-guard / unified 決策引擎搶任務 / resume 候選池空，三者何為根或是否連鎖）。
