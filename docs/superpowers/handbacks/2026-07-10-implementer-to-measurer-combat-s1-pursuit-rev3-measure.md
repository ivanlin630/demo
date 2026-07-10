---
from: implementer
to: measurer
status: consumed
topic: [S1 rev3] pursuit 絕對 straggler-kill done → organic 三端(★merge-gate 靶B)+loss_sum>0 已見+人格集中 → blueprint
---

# S1 rev3 done：pursuit 絕對 straggler-kill（@f2af65e feat/combat-s1-pursuit）

rev1(截斷)→0、rev2(累積器)→0 兩次零效。blueprint 停機制修補=**棄 pop-%，改絕對小整數**（`5%×小pop` 本質恆~0）。

## 改（取代 rev1/rev2）
- `_apply_pursuit`：`straggler_kill = clampi(round(殘忍×2.0 + 貪婪×0.8), 0, 3)`；`pursuit_loss = mini(straggler_kill, loser.pop)`。慈悲→0 / 中性→1 / 軍閥→3(CAP)。scale 無關（小隊也見血）、bounded、人格 gated。
- 清死碼：撤 `_pursuit_carry` 累積器、刪舊 rev1 四常數 + `PURSUIT_RATE`（grep 確認無他用）。+3 常數 `PURSUIT_CRUELTY_K/GREED_K/KILL_CAP`。保 `_cas_carry` erase（§D4）。

## 我驗（★loss_sum 這次真 >0）
- `--import` **parse 綠**（reviewer② premise_contradiction 常數缺→halt 已解）、multi-sanity(inv=0)、constitution PASS。
- determinism：seed 1337 3mo 兩跑 `[bed] probe` **byte-identical**（round 純值、零 randf）。
- seed 1337 3mo：`[Pursuit] +2傷亡 (straggler_kill=2)` → **pursuit_loss>0 確認**（絕對模型見血，截斷病死透）。`pursuit.n=1`、三端 `annih=0/flee=7/capture=3/rout=2` = baseline 未打亂。

## ★跑什麼（大窗，靶B merge-gate）
單 seed pursuit.n=1 仍稀。大窗/多 seed 量：
1. **①三端漂移（gate）**：`end_annihilation`/`end_mortal_flee`/`capture.total` vs baseline（main 26758fe）+ annih 時 pursuer 殘忍值（殘忍窮追推俘後倖存→pop 0 動分母？）。**絕對小整數(≤3)不該打亂逃為主(~83%)**。
2. **②loss_sum>0 + 人格集中**：`pursuit.loss_sum` >0（已見）；`pursuit.cruelty_sum/pursuit.n` 高段=軍閥見血集中。
3. **③extinct/attrition**：殘忍窮追 straggler-kill 是否升 `extinct.*`。

**判準**（→blueprint）：軍閥見血 + 逃為主 + 人格集中=達標；無差別暴漲=回退調 `PURSUIT_*_K`/`KILL_CAP`。
**merge 閘**：reviewer② 對實際 diff CLEAN + 你三端 delta≤噪音 → blueprint 判 → systems merge。三端打亂→標 systems，我調常數重驗。worktree @f2af65e。
