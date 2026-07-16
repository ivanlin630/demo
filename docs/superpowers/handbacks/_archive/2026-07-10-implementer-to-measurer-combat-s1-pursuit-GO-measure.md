---
from: implementer
to: measurer
status: consumed
topic: [GO] S1 追擊放血人格化 done → organic 三端(★merge-gate 靶B) + pursuit 人格分配數字 → blueprint 判
---

# S1 GO：追擊放血人格化 done（@d139392 feat/combat-s1-pursuit，base main 26758fe）

HOLD 已解除（reviewer② CLEAN——最高風險「pursuit 不動 end_annihilation」驗真；blueprint 框①三靶裁清）。

## commits
- `94bb60d` S1 pursuit 人格化（`_apply_pursuit` factor=殘忍×1.2+貪婪×0.6，中性→1.0 保 5% mean，reachability gate 不動）+4 常數 + pursuit 探針。
- `d139392` §D4 follow-up：`_cas_carry` 顯式 erase（reviewer A，行為不變）。

## 我驗
- `--import`/multi-sanity(coin_eq/inv=0)/constitution **綠**。determinism：pursuit factor 純值運算、零新 randf → seed 1337 兩跑 byte-identical（S1 已驗；D4 erase 純 dict op 不動 probe）。

## ★★跑什麼（靶B：三端=merge 前硬 gate，非事後補量）
blueprint 靶B 裁定：**merge 前**你的 organic 三端數字 → blueprint 判 → **blueprint OK 才 systems merge**。reviewer 挖：capture 快照(`:393`)在 pursuit(`:410`)前=不逆轉已俘，**但殘忍窮追可把「俘後倖存」隊推 pop→0=團滅 → 動殲滅/俘分母**。∴ 三端漂移超界=**回退**。

organic full_probe 大窗/多 seed 量：
1. **①三端漂移（gate）**：`end_annihilation`/`end_mortal_flee`/`capture.total` vs S1 前 baseline（main 26758fe 同床）。**+ annih 時 pursuer 殘忍/貪婪值**（殲滅升是否集中高殘忍 pursuer）。
2. **②pursuit 人格分配**：`pursuit.cruelty_sum/pursuit.n`（高→factor>1）、`pursuit.loss_sum/pursuit.n` vs baseline 0.05×pop（中性應 ≈baseline，非全面膨脹）。
3. **③extinct/attrition**：`extinct.*`/attrition 殘忍窮追是否升。

**判準**（→blueprint）：殲滅升**集中高殘忍 pursuer 且整體仍逃為主**=接受；**無差別暴漲打亂三端**=回退調 `PURSUIT_CRUELTY_W`/`GREED_W`/`FACTOR_MAX`。

→ 你數字 to:blueprint 判。**三端打亂** → 標 systems 調常數（我同 branch 改+重驗）。worktree `feat/combat-s1-pursuit` @d139392。
