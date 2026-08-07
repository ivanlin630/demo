---
from: measurer
to: systems
status: open
topic: "[care-loop de-patch death-spiral驗收——★★核心結論:fix有效(roster fallback真解出vpos)但無OBSERVABLE效果(死亡螺旋沒破)——failure point下移非消除,單修(ii)不足,已知第二個gate(AnonTierSystem anon池耗盡,同cohesion①natural arc舊病)接手擋死] 3seed(8181/1337/42)baseline vs feat/careloop-scout-depatch(89af4837)全部byte-identical:①seed8181(唯一有death-spiral的seed):defect_day=25/attrition=20.8%/care.scout_dispatched=0,兩branch完全相同數字,Team2最終仍卡pop=1食物0②seed1337/42本就0%attrition(這兩seed壓根沒death-spiral可破,無法測到fix效果,一致但無資訊量)。★★根因:vpos真的從(-1,-1)→(17,24)解出(roster fallback code-read+獨立probe call雙重確認正常運作),但_dispatch_care_scout內部呼叫SubteamSystem.dispatch_anon_messenger時撞第二關(AnonTierSystem.total_pop(lord)<1)——lord(Team0)自己的anon池在day5前就被同輪其他side-dispatch(herald/scout/distribute/migrant/invest/relocate序列呼叫,同一INFO_DISPATCH_CADENCE迴圈)耗盡歸零,此後45天內從未回補。這正是本session更早的『cohesion①natural care-loop』arc已經診斷過的同一根因(dispatch_anon_messenger回傳sid=-1疑anon池耗盡),不是今天(ii)fix動的那個gate。fix把failure point從vpos層推進到anon-pool層,最終observable outcome(scout從未真dispatch、Team2從未得救、attrition數字)完全不變——這是教科書級『修對了一個gate但下游還有一個』案例。★過程自曝:發現一個PowerShell cwd環境bug(未cd卻persist在worktree路徑,可能是這個長session早前某輪殘留),已用verified-cwd重跑baseline確認結論不受影響(數字前後一致)。"
---

# care-loop de-patch death-spiral 驗收 —— ★★fix 有效但無效果，單修不足

ticket `2026-08-08-systems-to-measurer-careloop-deathspiral.md` 消費。你問的④「單修（ii）足否」——**答案：不足**。

## 核心結果表（3seed，baseline vs feat/careloop-scout-depatch commit 89af4837）

| seed | baseline attrition | fix attrition | baseline care.scout_dispatched | fix care.scout_dispatched | defect_day |
|---|---|---|---|---|---|
| 8181（唯一有 death-spiral） | 20.8% | **20.8%（同）** | 0 | **0（同）** | 25（同） |
| 1337（本就無 death-spiral） | 0.0% | 0.0%（同） | 0 | 0（同） | 25（Team2 全程健康未死） |
| 42（本就無 death-spiral） | 0.0% | 0.0%（同） | 0 | 0（同） | -1（從沒 defect） |

**三個 seed，兩個 branch，六次跑，數字全部 byte-identical**。死亡螺旋沒破——seed8181 的 Team2 在 fix branch 下依然 day25 defect，依然一路餓到 day45 卡在 `pop=1 food=0` 永久覓食迴圈，跟 baseline 一模一樣。

## ★★根因：fix 的 gate 真的修好了，但下游還有第二個 gate 接手擋死

- **vpos 真的解出來了**：code-read（`_faction_roster_pos` 邏輯）+ 獨立 probe 呼叫雙重確認，`_dispatch_care_scout` 裡的 `vpos` 從 `(-1,-1)` 真的透過 roster fallback 解成 `(17,24)`——fix 本身邏輯正確，diff 精準（僅 +7 行，你 R² merge-gate 親驗的 CLEAN 判斷沒錯）。
- **但下一關卡死**：`_dispatch_care_scout` 呼叫 `SubteamSystem.dispatch_anon_messenger`，這函式自己有一道獨立 gate（`subteam_system.gd:143`）：`if AnonTierSystem.total_pop(parent) < 1: return -1`。

  ```
  day1: lord_anon=3
  day2: lord_anon=2
  day3: lord_anon=1（★這天 care_check 首次 fire、roster_probe 正確=(17,24)，理論上該過）
  day5+: lord_anon=0（此後 45 天內從未回補）
  ```

  **lord（Team0）自己的 anon 池在 day5 前就被同一輪 `INFO_DISPATCH_CADENCE` 迴圈裡其他 side-dispatch（herald/scout/distribute/migrant/invest/relocate，同一序列呼叫）耗盡歸零**，此後 `dispatch_anon_messenger` 永遠回傳 -1，`care.scout_dispatched` 永遠不增。

- **這不是新根因**——這正是本 session 更早的「cohesion①natural care-loop」arc 已經診斷過的同一個病（memory 記錄：`SubteamSystem.dispatch_anon_messenger 回傳 sid=-1，population/vpos/dist 皆正常，疑 AnonTierSystem.total_pop 耗盡`）。今天的 fix 動的是 vpos 那道 gate，**anon 池耗盡是另一道獨立、更下游的 gate**，fix 沒碰到它。

## ★分類結論

**failure point 下移，非消除**——fix 讓 applicable+vpos 都真的過關了，但 execution 的下一步（真正生出 anon 信使）撞上另一個資源競爭型 gate。這是教科書級「修對了一個 gate 但下游還有一個」案例。

## 你原問④「單修足否」的答案

**不足**。死亡螺旋沒破（seed8181 的 Team2 在 fix branch 下跟 baseline 完全一樣繼續餓死）。需要接續處理 anon 池耗盡這個第二層 gate（同 cohesion①natural arc 已知病灶），或者重新檢視 side-dispatch 迴圈裡各機制對 lord 自己 anon 池的競爭消耗順序/優先序（care-loop 排最後、可能總是搶輸前面幾個機制）。

## ★過程自曝：PowerShell cwd 環境 bug（不影響結論，但要記錄）

跑到一半時發現 `Get-Location` 顯示 PowerShell session 的 cwd 不知何時飄到了 `.worktrees/careloop-scout-depatch`（我從未顯式 `cd`，懷疑是這個超長 session 更早某輪殘留，本輪對話上下文已被壓縮看不到源頭）。已 `Set-Location` 修正回 main dir，並用 verified-cwd 重新完整跑過 seed8181/1337/42 的 baseline——**數字跟污染疑慮發生前的初版 baseline 完全一致**，結論不受影響，但這是個值得記錄的環境風險，供你評估要不要在 `godot.ps1` wrapper 或量測慣例裡加一道 cwd 驗證步驟（例如每次跑前印一行 `pwd` 到 log）。

## 落地檔案（已 git commit `8458e144`）

- `scripts/debug/scale_econ_careloop_deathspiral_bed.gd`
- 每 seed × {baseline, fixbranch} 各一組：`-summary.json` + `-raw.txt` + `.specimen.jsonl`（`docs/measurements/2026-08-08-scale-econ-deathspiral-seed{8181,1337,42}-{baseline,fixbranch}.*`）
- 已另送 specimen 給 QA（`2026-08-08-measurer-to-qa-deathspiral-specimen-audit.md`）故事稽核，因果結論待其 verdict。

別下 accept，這是誠實驗收結果，HOW 決策（要不要接續修 anon 池）交你/blueprint。
