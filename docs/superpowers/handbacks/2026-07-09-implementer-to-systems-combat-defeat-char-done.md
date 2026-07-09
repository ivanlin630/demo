---
from: implementer
to: systems
status: consumed
topic: combat 殲滅-heavy characterization 完成——釘死=①+③ 耦合（小隊 eff 1~2→第1輪殲滅,readiness 從沒 drain 到）
---

# combat 殲滅-heavy characterization — 完成（純探針，無 fix）

worktree `feat/combat-defeat-char` @ `b4a6a18`（base origin/main 3e4f7b5）。
數據：`docs/process/verdicts/combat-defeat.fullprobe.json`（3 seed 1337/42/7）。

## 做了什麼（純探針，Probe.enabled 才動 → off byte-identical）
`npc_combat_system.gd`：`_combat_track` static 追每場 round+起始 eff pop；`_probe_combat_end` 釘死結束原因/race/wnd/小隊。`warring_harness` `combat.*` PROBE_KEYS + AMOUNT_KEYS。

## ★★釘死（18 combat / 3 seed）

| seed | ended | annih | rout | retreat | 敗方rdns>門檻 | pop≤3 | 均round | 均pop_start | 均敗方rdns | 均敗方wnd比 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1337 | 9 | 9 | 0 | 0 | 9 | 9 | 1.0 | 1.0 | 0.92 | 0.0 |
| 42 | 8 | 7 | 1 | 0 | 8 | 7 | 2.1 | 1.9 | 0.83 | 0.0 |
| 7 | 1 | 1 | 0 | 0 | 1 | 1 | 1.0 | 1.0 | 0.92 | 0.0 |
| **總** | **18** | **17** | **1** | **0** | **18** | **17** | — | — | — | — |

**釘死判 = ① + ③ 緊耦合**（非單一）：
1. **① annihilation 恆贏 race，且不接近**：18/18 結束時敗方 readiness **仍 >門檻**（均 0.83~0.92，門檻~0.2）→ readiness **從沒 drain 到潰退線**。均 round **1~2**（readiness 0.08/round 需 ~10 round 才到 0.2 → 根本沒機會）。潰退/FLEE 路徑存在但**結構性搶不到**。
2. **③ 小隊太少是根動力**：17/18 敗方 `pop_start ≤3`（均 eff pop **1~2**）。均敗方 wnd_ratio **0.0** → 敗因是 **pop 直接歸零（`pop-wounded≤1`），非 wounded 累積 cascade**。eff pop 1~2 的隊，**1 次 casualty（ROUND_CASUALTY_RATE=0.1 但小隊 round 整數化/flank ×1.3）即殲滅**。
3. ∴ 因果鏈：**warring 的 combat 幾乎都是 eff pop 1~2 的小隊遭遇 → `maxi(pop-wounded,1)≤1` 第 1~2 輪必觸 → 遠早於 readiness(~10輪)/FLEE → 100% annihilation**。②（路徑罕觸）是**結果非根因**（路徑在，但小隊+速殺讓它永遠搶不到）。

## 對照敗北三端
- `capture.total` 低、`rout.total` 近 0（本 char 僅 1 rout/18）、retreat 0 → **敗北模型三端（損耗/俘虜/潰散）塌成殲滅一端**（game-design:1130 違背），根=小隊速殺。

## 藥方方向（我不開，供 blueprint 判願景）
釘死既是 ①+③ 耦合，藥不只調 casualty/drain 比。候選（blueprint 定願景後另 slice）：
- 若要「弱隊倖存變絕境」湧現 → 需讓**小隊 combat 不必然殲滅**：如 eff pop 低時 readiness drain 加速 / 或小隊觸 rout 門檻放寬 / 或 pop-annihilation 線改 %（非絕對 ≤1）給小隊逃生窗。
- 但**根動力是「combat 都發生在 eff 1~2 小隊間」**——若這本身是世界該有的（小隊本就脆），則藥在「敗北=潰散/被俘」該在殲滅前觸發（給小隊 rout/surrender 出路），非改殺傷率。
- **請 blueprint 判**：殲滅-heavy 是 bug/塌陷 vs 世界本該如此；潰散/俘虜該多常發生（敗北模型意圖 owner）。

## 閘
- `--headless --import` 無 error；`game_sim_multi` 0 SCRIPT ERROR/invariants=0；`constitution_gate` PASS(29,0)。純探針無行為變。

**無 fix**——釘死交你綜合回 blueprint 判願景方向，再開修藥 slice。measurer 可背景複跑。
