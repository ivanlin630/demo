---
from: systems
to: measurer
status: consumed
topic: 敗北逃 rev2 殲滅端定向 exercise 床——造 n_high>0 情境量殲滅稀/under → to:blueprint 定案
---

# 量測工單：殲滅端定向 exercise 床（systems 定情境 / measurer 造+跑）

## 為什麼（blueprint 裁，`blueprint-to-systems-defeat-flee-annih-unmeasured`）
organic full_probe（3seed/3mo）殲滅=0 = **sample 空洞非「稀」**：`mortal_flee.n_high=0`（零高勇氣小隊進戰）→ 勇者血戰端**從沒 exercise**。organic seed 打不到「高勇氣×小隊×被圍」交集。∴ 造定向確定性床把殲滅端逼出來，量真數字。**rev2 公式不動、不調參**。

## 機制窗（systems 已核，床設計靠它）
`_mortal_flee_check`（worktree `feat/defeat-flee`）：`mortal_pressure = criticality + outnumber*MORTAL_OUTNUMBER_W(0.5)`，`flee_thr = 0.5 + courage*0.6`。
- courage=f(leader `好戰`/`慎重`)：`clampf(0.5+(好戰-慎重)*0.5,0,1)`。勇者 = 好戰=1/慎重=0 → courage≈1.0 → **flee_thr=1.1**。
- criticality=(4-eff)/3：eff=1→1.0、2→0.667、3→0.333（eff=pop-wounded）。
- outnumber=clamp(enemy_eff/max(eff,1)-1,0,1)。
- **勇者 last-stand 窗**：eff=1 vs **enemy_eff=1** → outnumber=0 → pressure=1.0 **<1.1 → 留 → 下 round 殲滅**（`:205-212`）。
- eff=1 vs enemy_eff≥2 → outnumber=1.0 → pressure=1.5 **≥1.1 → 逃**。
∴ 勇者殲滅只在**近均等 1v1 殘兵**窄縫成立 = 天生稀。床要覆蓋這縫 + 兩側（逃側）證 split。

## 床要什麼（確定性 synthetic，非 organic warring）
1. **建 synthetic WorldState**（固定 seed，deterministic 建隊/建 leader）。可複用 `warring_states_seed.gd`/`WarringHarness` 建隊 helper。**★禁原地 checkout；`godot --path .worktrees\defeat-flee`；`--import` 先跑（新探針 key）；GODOT_TIMEOUT=600。**
2. **掃 encounter matrix**（每格多 repeat 湊樣本，建議每格 ≥20 場）：
   - courage 桶：**high（好戰=1/慎重=0）** 為主，附 mid（0.5/0.5）/low（好戰=0/慎重=1）對照。
   - self eff（pop-wounded）：{1, 2, 3}（小隊）。
   - enemy eff：{1, 2, 3, 4}（span outnumber 0→saturate）。
   - 每 encounter：`start_combat` → 跑 round 至終止（`Probe.enabled=true`）。
3. **量（分 courage 桶）**：`combat.end_annihilation` / `end_mortal_flee` / `capture.total`(或 `conq.retreat_captured`) / `mortal_flee.n_high/mid/low` / `annih.n_high/mid/low` / `str_ratio_annih_mean` + `pop_ratio_annih_mean`。

## 定案條件（blueprint 判，你只出數字）
`n_high>0` 達成後 → **高勇氣桶內殲滅是否稀但>0**：
- 稀但>0（勇者血戰質感在、集中 eff=1 均等 1v1）→ blueprint 判可接受 → rev2 定案。
- 仍=0 or over → 真證據談調參，屆時 systems 開工單（候選 `MORTAL_OUTNUMBER_W↓` / `COURAGE_SPREAD↑`）。

## 完後
handback **to:blueprint**：殲滅端數字（分 courage 桶 + annih rate among high-courage）+ 確認 n_high>0。床 code 進 `scripts/debug/`（守衛床，留檔複跑）。
