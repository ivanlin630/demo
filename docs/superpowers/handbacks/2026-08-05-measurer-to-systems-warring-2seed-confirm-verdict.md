---
from: measurer
to: systems
status: consumed
topic: "warring 2seed確認verdict:★★seed1337易變單seed假象確認,非真regression——4跑矩陣:main/1337=0.68%(舊值同)main/42=0.69%(舊值同)branch/1337=1.80%(重跑重現,同RE7)branch/42=0.23%(★較main改善,非惡化)。seed1337惡化+seed42改善=方向不一致=典型seed-cascade類別(RE#3-#6反覆出現同型),非branch造成的系統性regression。determinism:branch/1337單獨重跑二次(4跑batch超時後隔離重試)兩次數字一致(1.80%)。★附帶發現:重跑期間worktree game_setup.gd出現另一session(疑implementer)未commit WIP改動——create_faction actual sequential id vs config faction_id map修正,ˋ直接命中我RE6/RE7回報的『T2疑跨faction送relief給T1』觀察,已避開不動不commit,如實回報供留意"
---

# warring seed1337 attrition 2 seed 確認：seed1337 易變單 seed 假象（非真 regression）

## 做法

- 4 個獨立 process（各自 1200s budget，避免同 process 序跑 2 seed 撞 timeout）：`main×{1337,42}` + `branch(9b502d52)×{1337,42}`，各 1mo，純觀測（`WarringHarness.run` 直讀 `attrition_pct`/`final`，無額外 tap）。
- 首次 4-run batch（2 process，各序跑 2 seed）撞 `GODOT_TIMEOUT=1200` 被殺（單 process 序跑 2 seed 耗時 > 1200s，非死鎖，純算力預算不夠），拆成 4 個單 seed 獨立 process 後全數成功完跑。

## ★★核心結果

```
                 seed1337    seed42
main (baseline)   0.68%       0.69%
branch(9b502d52)  1.80%       0.23%
```

- **seed1337**：0.68%→1.80%（惡化，跟 RE-measure#7 原始數字一致，本輪隔離重跑一次再次確認=1.80%，兩次一致）。
- **seed42**：0.69%→**0.23%**（★改善，非惡化）。
- **方向不一致**（一 seed 惡化、一 seed 改善）——**符合你們判準「seed42 持平/改善→seed1337 易變單 seed 假象」**，也符合過去 RE-measure#3~#6 反覆出現的「seed1337 易變、seed42 穩或反向」同型 seed-cascade 類別（非本輪新現象）。
- **讀作**：目前證據不支持「9b502d52 造成系統性 attrition regression」，較像 seed1337 這個特定種子對此 mechanism 改動敏感（RNG-cascade 分岔），seed42 反而受益。記已知類別，非 blocker。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-infonet-2seed-confirm-main-seed1337-1mo.txt`（7198行）
- `docs/measurements/2026-08-05-infonet-2seed-confirm-main-seed42-1mo.txt`（7488行）
- `docs/measurements/2026-08-05-infonet-2seed-confirm-branch-seed1337-1mo.txt`（8831行，隔離重跑版本）
- `docs/measurements/2026-08-05-infonet-2seed-confirm-branch-seed42-1mo.txt`（8148行）

## 清理狀態

- temp `infonet_2seed_attrition_bed.gd`（main+worktree 兩邊）已刪除。

## ★附帶發現（如實回報，未介入）

跑本工單期間，發現 worktree `scripts/simulation/game_setup.gd` 有**另一 session 的未 commit WIP 改動**（疑 implementer 正在做，本工單信裡提過「9b502d52 或含 T3 fix 後版」）：`_setup_explicit_teams` 修正 `create_faction` 回傳的實際 sequential faction id 跟 config `faction_id` 的映射（原本非 leader 成員直接拿 config `faction_id` 當 in-sim id 查 `state.factions`，跟 `create_faction` 內部用的 sequential 實際 id 不一致，可能配錯 faction）。
**★這精確命中我 RE-measure#6/#7 回報的觀察**：「T2(疏忽領主)的 convoy 卻把 relief 送給 T1(非自己 faction 的 resident)」——如果 config faction_id 和 in-sim 實際 faction id 錯位，就會導致 belief/roster 用錯 faction 分組，送錯目標。**沒有動這個檔案（別的 session 的未 commit WIP，不動不 commit，避免干擾）**，如實回報供你們追這條線。若這正是 T3 fix，下輪重跑應該會看到 T3 也開始收到 relief。

★別下 accept，seed1337/seed42 分歧方向已如實回報，regression 真假交你們定。
