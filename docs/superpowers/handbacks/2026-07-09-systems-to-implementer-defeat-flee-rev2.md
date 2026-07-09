---
from: systems
to: implementer
status: open
topic: 敗北逃決策 rev2 重做（pop-based 公式 + capture 修）——reviewer CLEAN,接 feat/defeat-flee
---

# 實作工單：敗北逃決策 rev2（pop-based + capture 修）

spec（rev2 鎖，reviewer CLEAN）：`docs/superpowers/specs/2026-07-09-defeat-model-flee-before-annihilation.md` §D1 rev2。接 worktree `feat/defeat-flee`（@19ffb82，已有 v1）。

## 改什麼（2 處）
1. **`_mortal_flee_check` 公式改 pop-based**（棄 str_ratio 反噬）：
   - `criticality = clampf((MORTAL_EFF_POP+1-eff)/MORTAL_EFF_POP, 0,1)`（eff=1→1.0）
   - `outnumber = clampf(eff_enemy/max(eff,1) - 1.0, 0,1)`；`mortal_pressure = clampf(criticality + outnumber*MORTAL_OUTNUMBER_W(0.5), 0,1.5)`
   - `flee_thr` 不變（0.5+courage*0.6）。其餘結構（插入點/雙方序/return）不動。
2. **capture 修**（reviewer 挖根因）：`AnonTierSystem.capture_routed_as_captive` 俘虜嚴重度 `severity = maxf(1.0-retreater.readiness, _pop_criticality(retreater))`（`_pop_criticality=(MORTAL_EFF_POP+1-eff)/MORTAL_EFF_POP` clamp，讀 retreater eff pop 內算，不改 caller 簽名）。`max` 加性安全（readiness 路不變、pop-flee 路俘升）。
3. 探針：+`combat.pop_ratio_annih`（殲滅時敵/我 eff pop 比）。

## 驗（重跑 acceptance full_probe 3 seed）
- ①三端復活：`end_annihilation` 顯著降、`end_mortal_flee` 升常態、`capture.total` **升**（俘虜中頻，capture 修生效）、殲滅稀但>0。
- ②照妖鏡#1 桶有數據 ③大隊(eff>3)≈baseline ④`str_ratio_annih`/`pop_ratio_annih` 證殲滅集中眾寡均等。
- `--headless --import`/sanity/constitution 綠。

## 完後
handback to:systems + acceptance 數字 to:blueprint 判三端配比。**若仍 under/over-fire** → 標明報 systems（調 MORTAL_* 常數或回 blueprint）。
