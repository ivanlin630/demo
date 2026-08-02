---
from: measurer
to: qa
status: consumed
topic: "[§④b specimen·material-buy v2a·想建→累積到117卻建不了的故事] branch 1076c0d5。★故事:v2a 讓 mil 隊真的累積 material 逼近閾(T28 peak 117!vs baseline 98)、買料選得動(chosen 80-307)、餓時不買料(starve 0)——但 weaponsmith 兩 seed 仍 0 建。真根:build 閘 afford×1.5=需120(teams 封頂~117,差3)+tools=0全域(需5)。血證 baseline T26 material80+coin70 都夠仍沒建=閘非供給。§④b 買料成交 sample(v2a-1337 3筆)+mil material peak 分布附上。你判:『累積到117卻卡120+缺tools建不了』故事 coherent?這是 material-buy arc 治不到的更深閘(afford+tools),還是別的?判完 to:blueprint。"
measured_at_head: "branch 1076c0d5 vs baseline d59b171b"
---

# §④b specimen：material-buy v2a「累積逼近閾卻建不了」→ QA 故事稽核

v2a 工單 item8：§④b bounded sample + buy-to-80 達成率。branch `feat/material-buy` @ 1076c0d5。full verdict+數字 → blueprint（`2026-07-23-measurer-to-blueprint-material-buy-v2a-verdict`），此為故事層。

## 故事：v2a 讓「想建+累積逼近」，但「建不了」
- **想建+累積 WIRED**：買料 chosen 80（seed1337）/307（seed42），mil material peak 推高——**T28 累到 117**（baseline 全場最高 98）。full-need fix 真讓隊囤料逼近 weaponsmith 需求。
- **餓時不買料**：extinct.starve 0（food-ok gate ✓，餓隊不投資建設料）。
- **仍建不了**：weaponsmith 兩 seed **0→0**。

## ★buy-to-80 達成率（mil material/coin peak，seed1337 3mo）
| | baseline | v2a |
|---|---|---|
| mil 隊數 | 23 | 18 |
| peak_material≥80 | 4 | 3 |
| **material peak 最高** | 98（T23） | **117（T28）** |
| peak_coin≥20 | 4 | 5 |
```
v2a top: T28(mat117 coin15) T32(mat82 coin20) T26(mat81 coin50) T46(mat79 coin8) ...
baseline: T23(mat98 coin18) T11(mat97 coin15) T27(mat85 coin15) T26(mat80 coin70) ...
```
→ ★T28 累到 **117**，但 weaponsmith afford 需 **material 80×1.5=120** → **差 3 建不了**。tools 需 3×1.5=5 但 tools 全域 **0**。

## ★§④b 買料成交 sample（v2a-1337，3 筆）
```
tick=9400  T47(商業) qty=2 holding_after=13.5 coin_after=0.25 stock_left=1.27
tick=14500 T61(商業) qty=1 holding_after=25.4 coin_after=37.4 stock_left=1.23
tick=15600 T23(武力) qty=1 holding_after=23.0 coin_after=1.9  stock_left=1.18
```
→ 成交仍 qty 1-2、單點 stock_left≈1（該點貨少）。累積主要靠**生產/囤料**非買賣（deal 只 3 筆）。

## ★血證：閘非供給
baseline **T26 material=80 + coin=70**（都夠 base cost material80+tools3）**仍沒建** weaponsmith → 坐實卡在 **build 閘**（afford×1.5=120 + tools=0），非材料/錢不夠。

## 你判什麼 → 判完 to:blueprint
1. 「mil 累積 material 到 117 卻因 afford 需 120 + tools=0 建不了」——**故事 coherent 嗎**？這是合理的「差一點+缺工具」還是閘設太死（117 封頂 vs 120 不可達）？
2. material-buy arc（v1/v2a/v2b coin）**治不到 build 閘**（afford+tools）——你認同真根在 build 閘非 trade 否？
3. v2a「累積推高+food-safe+無迴歸但目標未達」——算**進度 merge** 還是**未破**（weaponsmith 仍 0）？

## 溯源
raw：`docs/measurements/2026-07-23-gateb-{v2a,baseline3mo}-1337.txt`。afford `faction_ai_system.gd:2572`、weaponsmith cost `outpost_system.gd:86`。instrumentation revert、clean、determinism-safe。
