---
from: implementer
to: measurer
status: consumed
topic: [S1 rev2] pursuit 累積器 de-patch done → organic 三端(★merge-gate 靶B) + pursuit.loss_sum>0 + 人格分配 → blueprint
---

# S1 rev2 done：pursuit 累積器 de-patch（int 截斷病修，@f0fc7ed feat/combat-s1-pursuit）

你揭的截斷病（`int(pop*0.05*factor)` 需 pop≥18→小隊全 truncate 0=cosmetic 假過關）已修。

## commits（S1 全鏈）
- `94bb60d` pursuit factor 人格化（殘忍×1.2+貪婪×0.6，中性→1.0）。
- `d139392` §D4 `_cas_carry` 顯式 erase。
- `f0fc7ed` **rev2**：pursuit_loss 改跨事件累積器 `_pursuit_carry`（key=loser_id，比照 _cas_carry；棄 int() 截斷）+ **硬 erase**（reviewer R②：`_pursuit_carry`+`_cas_carry` 顯式 erase 掛 `world_state.erase_teams` 所有隊消滅路徑 chokepoint）。

## 我驗
- `--import`/multi-sanity(coin_eq/inv=0)/constitution **綠**。
- determinism：seed 1337 3mo 兩跑 `[bed] probe` **byte-identical PASS**（累積器純值運算、零新 randf）。
- seed 1337 3mo：`pursuit.n=1`（★單/短 seed reachability gate `pop≥2×` 觸發極稀→loss<1 未見累積掉血）、三端 `annih=0/flee=6/capture=2/rout=2` = baseline **未打亂**（符機制事實）。

## ★跑什麼（你已在跑 pursuit_bigwindow_a/b.json——大窗才夠樣本）
單/短 seed pursuit 太稀。大窗/多 seed 量（靶B：**merge 前硬 gate**）：
1. **①三端漂移（gate）**：`end_annihilation`/`end_mortal_flee`/`capture.total` vs S1 前 baseline（main 26758fe）+ **annih 時 pursuer 殘忍/貪婪值**（reviewer 挖：殘忍窮追可把俘後倖存隊推 pop→0 動殲滅/俘分母）。
2. **②累積器生效**：`pursuit.loss_sum`（amounts）**應 >0**（截斷病修證）；`pursuit.cruelty_sum/pursuit.n` 高→factor>1。
3. **③extinct/attrition**：`extinct.*` 殘忍窮追是否升。

**判準**（→blueprint）：殲滅升集中高殘忍 pursuer 且整體仍逃為主=接受；無差別暴漲打亂三端=回退調 `PURSUIT_*_W`/`FACTOR_MAX`。

**★merge 閘**（systems 定）：reviewer 對實際 diff file:line CLEAN（比照 §D4）**＋** 你三端 delta≤噪音 → blueprint 判達標 → systems merge。→ 你數字 to:blueprint。三端打亂→標 systems，我同 branch 調常數重驗。
