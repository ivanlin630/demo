---
from: implementer
to: measurer
status: open
topic: S1 追擊放血人格化 done+驗 → 跑 organic 大窗量 ①人格分配 ②三端不打亂 ③extinct/attrition
---

# S1 追擊放血人格化 done（commit 94bb60d @feat/combat-s1-pursuit，base main 26758fe）

## 做了什麼（照 spec §S1 / 工單，無 deviation）
- `_apply_pursuit`：固定 `PURSUIT_RATE(0.05)` → `rate = PURSUIT_RATE * factor`，`factor = clampf(1 + (殘忍-0.5)*1.2 + (貪婪-0.5)*0.6, 0, 2.5)`（勝方領袖）。中性(0.5/0.5)→factor 1.0=保 5% mean。reachability gate `pop>=2×` **不動**。
- +4 常數 `PURSUIT_CRUELTY_W/GREED_W/FACTOR_MIN/MAX`。
- 探針：`pursuit.n`（counts）+ `pursuit.loss_sum`/`cruelty_sum`/`greed_sum`（amounts）。harness PROBE_KEYS/AMOUNT_KEYS 已加。
- **機制事實**（別誤判）：pursuit 在 combat 結束後放血、不重入殲滅檢查 → **不動 end_annihilation 三端**；動放血量 + 潰逃隊後續 extinct/attrition。

## 我驗（單 seed，非定案）
- `--import`/multi-sanity(coin_eq 平/inv=0)/constitution **綠**。
- determinism：seed 1337 兩跑 `[bed] probe` **byte-identical PASS**（factor 純值運算、零新 randf）。
- seed 1337 organic：`pursuit.n=1`（★單 seed reachability gate `pop>=2×` 觸發極稀→樣本不足人格分佈）、三端 `annih=0/flee=6/capture=2` = defeat-flee baseline **未打亂**（符機制事實）。

## 待你跑（organic full_probe 大窗，樣本夠）
單 seed pursuit.n=1 太少。**大窗/多 seed** 量：
1. **①人格分配**：`pursuit.cruelty_sum/pursuit.n` 高段 pursuer factor>1、慈悲<1；`pursuit.loss_sum/pursuit.n` vs baseline 0.05×pop 對照（中性應 ≈baseline mean，非全面膨脹）。
2. **②三端不打亂（地板1）**：`end_annihilation`/`end_mortal_flee`/`capture.total` ≈ S1 前 baseline（預期 annih 幾乎不動）。
3. **③extinct/attrition**：`extinct.*`/attrition 是否因殘忍窮追升（軍閥暴虐湧現訊號）。

→ 你 to:blueprint 判（殘忍軍閥暴虐湧現 vs 打亂三端）。**若三端被打亂** → 標 systems（調 `PURSUIT_*_W` 或 `FACTOR_MAX`）。

worktree `feat/combat-s1-pursuit` @94bb60d，`godot --path .worktrees/combat-s1-pursuit` 跑你的 beds。
