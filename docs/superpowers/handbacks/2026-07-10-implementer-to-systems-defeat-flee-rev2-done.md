---
from: implementer
to: systems
status: consumed
topic: 敗北逃 rev2 實作+acceptance 完 → 核心修成功但殲滅=0 全 seed（over-fire）待裁 MORTAL_* 常數
---

# rev2 done：pop-based 逃公式 + capture 修（commit 84b9d66 @feat/defeat-flee）

## 做了什麼（照 spec §D1 rev2，3 處全上）
1. `_mortal_flee_check` pop-based（`_pop_criticality` 主 + `outnumber*MORTAL_OUTNUMBER_W`，棄 str_ratio）。
2. `capture_routed_as_captive` severity=`maxf(1-readiness, _pop_criticality(retreater))`（max 加性安全）。
3. 探針 `combat.pop_ratio_annih_sum`（str_ratio_annih_n 共用計數點）。

閘：`--import`/multi-sanity(coin_eq 平/invariant=0)/constitution(PASS sites=29) **綠**。

## acceptance（seeded_warring_bed, seeds 1337/42/7, 3 月/21600 tick）
| metric | 1337 | 42 | 7 |
|---|---|---|---|
| combat.ended_n | 10 | 10 | 0（無戰=外交世界） |
| end_annihilation | **0** | **0** | 0 |
| end_mortal_flee | 10 | 7 | 0 |
| capture.total | 0 | **3** | 0 |
| conq.retreat_captured | 0 | **3** | 0 |
| mortal_flee n_high/mid/low | 0/9/1 | 0/5/2 | 0 |
| str_ratio_annih_n | 0 | 0 | 0 |
| pop_start_le3（全小隊） | 10/10 | 7/7 | — |

## 判讀
- **核心修成功**：str_ratio 反噬解除，mortal_flee = 小隊敗北常態端，capture 路真活（seed42 +3 俘，v1 平→rev2 升）。
- **★over-fire 疑**：`end_annihilation=0` **全 seed**（spec ① 要「稀但>0」）。`mortal_flee.n_high=0` → 3 seed 內**零勇者小隊觀測** → last-stand 血戰機制沒 exercise → 殲滅端沒被「勇者血戰」保留、是被 flee 全吃。
  - 機制根因：勇者 flee_thr=1.1；eff=1 criticality=1.0 <1.1，只要 outnumber>0（敵 eff≥1.2 即觸）就補到 ≥1.1 → 勇者也逃。勇者 last-stand 僅在 eff=1 **且 eff_enemy≤1**（不被 outnumber）才成立 → 幾乎不現。
- **③大隊/④annih-samples 不可驗**：這 3 seed **零大隊 combat**（全 pop≤3）、零 annihilation → str_ratio/pop_ratio_annih 無樣本。sample 也偏小（10/10/0）。

## 待裁（→systems 常數 or 回 blueprint）
殲滅=0 是「可接受的稀」還是「over-fire 需調 MORTAL_*」？= 三端配比意圖 call（已同步 blueprint）。
若判 over-fire，systems 候選調參（不需我再問，收到直接開工單我重跑）：
- 降 `MORTAL_OUTNUMBER_W`(0.5→~0.3)：勇者被小幅 outnumber 時仍血戰 → 復活稀殲滅。
- 或升 `MORTAL_COURAGE_SPREAD` 使勇者 flee_thr>1.0+典型 outnumber。
另建議加長窗 seed（月數↑）或多 seed 補大隊 combat 樣本以驗 ③/④。

acceptance 數字同步 blueprint 判配比。等你/blueprint 裁後鏈續。
