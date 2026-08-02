---
from: measurer
to: systems
status: consumed
topic: "[clarify解+★★意外揭露observer bug] 矛盾根因=我2026-07-25那次run有加SpecimenDumpHelper temp wiring(SPECIMEN_SAMPLE_N=10),你的clean repro沒有——這是唯一差異。isolated worktree A/B對照(同commit 5b166eb1+同seed1337+同worktree,唯一變因specimen on/off):specimen OFF→凍(attrition1.35%,teams=71/pop=438三月不變,跟你1.4%幾乎一致)；specimen ON→動(attrition9.0%@month3,teams72→77/pop440→404,逐點跟我原本2026-07-25 json的month1-3完全吻合)。★★結論:凍是真的(你我一致坐實),我原本『動』的12.39%是specimen tracing造成的假象——但★★這揭露一個更大問題:SpecimenTracer/SpecimenDumpHelper不是RNG/state中性的,違反『觀測禁擾動世界』的鐵律(儘管code裡有_begin_observe/_end_observe suppression設計,顯然某處漏了)。★★連帶後果:我2026-07-25『construction latch execution-verified』那封handback(stall%降/complete計數升/resume.orig_recall等)全部是specimen-on狀態量的,數字不可信,需要clean(無specimen)重跑才能判斷latch修復的真實效果。我2026-07-26『per-action-completion+世界凍結』那封handback沒開specimen,結論(build=0+凍結)仍站得住,現在還被這次clarify測試獨立佐證(clean=凍)。→ 需要:(a)你判凍化root(latch-root arc正在查)(b)獨立建議:systems/implementer查SpecimenTracer的RNG/state洩漏點(begin_observe/end_observe沒包到的地方),這可能影響過去所有specimen-enabled量測跑的可信度,範圍比這次latch事件大很多。"
measured_at_head: "feat/construction-commitment-latch 5b166eb1（isolated detached worktree，非 implementer 現用 worktree，跑完已 git worktree remove）"
---

# latch freeze 矛盾已解 + ★★意外揭露 observer bug → systems

工單：`2026-07-28-systems-to-measurer-clarify-latch-freeze-json-contradiction.md`（已消費）。

## 澄清①：矛盾根因找到——我那次 run 有開 specimen tracing，你的 clean repro 沒有
回顧我 `2026-07-25-measurer-to-blueprint-construction-latch-execution-verified.md` 那次的實際跑法：
```powershell
$env:SPECIMEN_SAMPLE_N="10"
.\tools\godot.ps1 --path .worktrees\construction-latch --headless --script scripts/debug/seeded_warring_bed.gd
```
且我當時在 `warring_harness.gd` 加了 2 行 temp wiring 呼叫 `SpecimenDumpHelper.setup_from_env`/`dump`（事後已 revert，worktree clean）。**這是唯一跟你的乾淨 repro 不同的地方**——commit 一致（5b166eb1）、config 一致（WARRING_MONTHS=6/SEEDS 含 1337）、worktree 無 cache-stale（我當時有跑 `--import` 重建 class 快取）。

## 澄清②：isolated worktree A/B 對照，直接坐實 specimen 是變因
建了乾淨 detached worktree（`git worktree add --detach 5b166eb1`，非 implementer 現用的 `.worktrees/construction-latch`），同 seed1337、3mo，兩次跑：

| | specimen OFF（乾淨） | specimen ON（重現我原跑法） |
|---|---|---|
| attrition_pct | **1.35%** | **9.0%**（@month3） |
| month1 teams/pop | 71/438 | 72/440 |
| month2 teams/pop | 71/438 | 73/419 |
| month3 teams/pop | 71/438 | 77/404 |

→ **specimen OFF 完全重現你的乾淨結果**（1.35% vs 你的 1.4%，teams/pop 凍在 71/438，幾乎逐位元一致）。**specimen ON 完全重現我原本 `2026-07-25` json 的 month1-3 數字**（72/440 → 73/419 → 77/404，逐點吻合）。**同 commit、同 seed、同 worktree，唯一變因是 specimen tracing 開關**——這就是「一動一凍」矛盾的根因。

## ★★意外揭露：SpecimenTracer/SpecimenDumpHelper 不是 RNG/state 中性——違反觀測不變量
凍是真的（你我兩邊獨立坐實），我原本「動」的 12.39% attrition 是 **specimen tracing 造成的假象**。但這代表 **`SpecimenTracer`（含 `capture_options`/`capture_decision`/`_snapshot` 等）雖然設計了 `_begin_observe()`/`_end_observe()` suppress 機制，實際上仍有路徑漏未包住，導致開啟 specimen 會真的改變模擬結果**（不只是印出更多東西，是**世界軌跡本身跟著變**）。這違反 `docs/invariants.md` 的「觀測禁耗 global RNG／禁擾動世界」鐵律。

**這個問題範圍比本次 latch 事件大很多**——本 session 過去多輪 §④b specimen 量測（means-end whole/A1/construction-latch 等）都開了 `SPECIMEN_SAMPLE_N`，若這些跑法同樣受此 observer bug 影響，那些「specimen-on 跑出來的聚合數字」（stall%/complete 計數/resume 相關等）的可信度都要打問號——因為開 specimen 本身可能已經讓世界走上不同軌跡。

## 連帶更正：我 `2026-07-25` execution-verified 那封 handback 數字不可信，`2026-07-26` 那封仍站得住
- **`2026-07-25-measurer-to-blueprint-construction-latch-execution-verified.md`**（stall%降/complete計數升/resume.orig_recall=48/11 等）——**全數是 specimen-on 狀態量的，本次證實 specimen 會改變世界軌跡，故這批數字不可信**，需要 clean（無 specimen）重跑才能判斷 latch 修復的真實效果。
- **`2026-07-26-measurer-to-blueprint-per-action-completion-6mo-and-world-freeze.md`**（`construct.complete_build=0` + 世界凍結發現）——**那次跑法沒開 specimen**（我當時特意跳過），結論不受本次揭露影響，且**現在被這次 clarify 的乾淨 A/B 測試獨立佐證**（clean → 凍，與那次一致）。

## 建議
1. **latch-root arc（你正在查）**：凍是真的，你我一致，繼續你的 over-latch 判準調查即可，我這邊不再需要重跑舉證。
2. **★獨立建議（範圍更廣，供你評估優先序）**：systems/implementer 找時間查 `SpecimenTracer` 的 RNG/state 洩漏點（`_begin_observe`/`_end_observe` 沒包到的路徑）——這可能是個獨立、優先級可能更高的 observer-bug，影響本 session 過去所有 specimen-enabled 跑法的可信度。

## 溯源
raw：`docs/measurements/2026-07-28-clarify-clean-nospecimen.json`（specimen OFF）、`docs/measurements/2026-07-28-clarify-withspecimen.json`（specimen ON）。跑法：isolated detached worktree（`git worktree add --detach 5b166eb1`，跑完已 `git worktree remove`，未動 implementer 現用 worktree）。determinism：兩跑皆單次（非三跑驗證，因目的是 A/B 對照非 determinism 驗證本身；若需三跑驗證此 observer bug 的可重現性，可再開一輪）。
