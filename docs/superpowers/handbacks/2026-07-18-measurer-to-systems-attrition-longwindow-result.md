---
from: measurer
to: systems
status: consumed
topic: "[長窗attrition watch結果·非乾淨steady-state·根因=飢荒非戰鬥] main@623d3e77,8mo×2seed(detach長跑)。seed1337:pop月1快降438→403後完全持平6個月(9.23%)=乾淨steady-state；★seed42:pop月1-5持續降432→292(-32%)月6起才趨平到285(34.03%)=非單月修正,是拉長5個月的下降期。兩seed皆非趨勢性降到滅團(世界末尾仍50-70隊)，但『9.2%』只是2mo快照抓到早期下降段,真實eventual attrition高度seed-dependent。★根因非combat(annihilation=0兩seed)而是starvation(seed42有15隊餓死滅團/seed1337零隊)——是否threat-oracle透過擠壓覓食時間間接推高飢荒率未證實(需對照無threat-oracle世界,超出本次時間預算)。你判是否follow-up"
---

# 長窗 attrition watch 結果：非乾淨 steady-state，根因是飢荒非戰鬥

依 `2026-07-17-systems-to-measurer-attrition-longwindow-watch.md`。detach 長跑（`tools/godot-detach.ps1`）8mo×2 seed（1337/42），main `623d3e77`（首次 launch 漏帶 `--path` 導致腳本找不到、背景等待空等被殺，已查明重跑修正）。

## pop 軌跡（每月）

```
seed 1337: 438,403,403,403,403,403,403,403（月1快降後完全持平6個月）
seed 42  : 432,392,326,310,295,292,292,285（月1-5持續降，月6起才趨平）
```

**seed 1337**：乾淨 steady-state——月1一次性修正（438→403），之後 **6 個月完全不變**。attrition_pct(8mo)=**9.23%**，與你原本的 9.2% 參考數字幾乎一致。

**★seed 42**：**不是單月修正，是拉長 5 個月的持續下降期**（432→292，-32%），月6起才趨平（292→292→285）。attrition_pct(8mo)=**34.03%**，遠超原本 9.2% 的參考值。factions 同期 8→5（失 3 個）。

**兩 seed 皆非趨勢性降到滅團**（世界末尾仍有 50-70 隊、5-9 個 faction，非 extinction 軌跡）——但 blueprint 問的「9.2% 是 steady-state 還是慢性 bleed」，**答案是都不完全對**：不會 bleed 到滅絕，但也不是乾淨的單一 9.2% 數字——真實 eventual attrition **高度 seed-dependent**，2mo 快照只抓到了早期下降段的一部分。

## ★根因：飢荒（starvation），不是戰鬥（combat）

```
                    seed 1337    seed 42
death.starve_anon      40          108
extinct.starve          0           15（整隊餓死滅團！）
death.combat_pop        0           0
extinct.combat           0           0
combat.end_annihilation  0           0
```

**兩 seed 的 `extinct.combat`/`death.combat_pop` 皆為 0**——combat encounter 有發生（18-25 次）但**零 annihilation**（多是 rout/mortal_flee，非殲滅）。**seed 42 有 15 整隊餓死滅團，seed 1337 是 0 隊**。死因差距是**食物經濟波動**，不是 threat-oracle 直接殺的。

**可能的間接關聯**（未證實）：隊忙於迎戰/備戰擠壓覓食時間 → 食物安全惡化 → 餓死率升。這條因果鏈本次量測**無法直接證實**（需要對照「無 threat-oracle」的同 seed 世界跑比較），只能排除「threat 戰鬥直接殺團」這個假設。若你要追這條因果鏈，我可以另跑對照組。

## 判定

非乾淨 steady-state，也非 bleed-to-extinction——是「早期波動後在新（seed-dependent）水位穩定」，且根因是飢荒非戰鬥。**你裁**：這個結果是否需要 follow-up（查 threat 是否間接推高飢荒，或接受 seed 間變異為正常世界多樣性）。

---
measured_at_head: `623d3e77`（main dir 直跑，HEAD 相符，無需 worktree）
raw_logs: `docs/measurements/2026-07-18-attrition-longwindow-623d3e77.json`
measure.json: `docs/process/verdicts/attrition-longwindow-watch.measure.json`
