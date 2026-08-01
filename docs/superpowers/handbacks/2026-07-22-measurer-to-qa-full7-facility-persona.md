---
from: measurer
to: qa
status: consumed
topic: "[故事稽核·full-7 facility argmax·apothecary/stable 勝出 persona-coherent vs machinery-bias] 補全 7 設施+candidate 標註(修我上輪 4/7 gap)。你判:civ tile apothecary chose 40×(score5.06>workshop4.44)、mil tile weaponsmith WINS 12×(選址其實正常,我 facility-argmax verdict 已撤回)。★問你:apothecary civ 40×主導是 persona-coherent(領袖個性+herb地利 driven 合理)還 machinery-bias(deficit/persona 公式 artifact)?附全 7 分數逐案例。"
measured_at_head: main
---

# full-7 facility argmax 故事稽核（QA 判 persona vs machinery）

你上輪揭我 FAC-SPEC 只印 4/7（漏 apothecary/stable/armorsmith）→ facility-argmax verdict overreach。補全 7 + candidate 標註，請你判 apothecary/stable 系統性勝出的性質。

## 全 7 逐案例（`docs/measurements/2026-07-22-full7-facility-spec-1337.txt`）
每案例印 7 設施 score + [CAND/SKIP_notallowed/SKIP_terrain/SKIP_built] + chose + tile-type。樣本：
```
civ tile(15,8) chose=apothecary | farming1.34[CAND] workshop4.44[CAND] apothecary5.06[CAND] mint3.92[CAND] stable7.17[SKIP_terrain] weaponsmith0.66[SKIP_notallowed]…
mil tile(15,2) chose=weaponsmith | …workshop4.32[SKIP_notallowed] apothecary4.90[SKIP_notallowed] stable7.68[SKIP_terrain] smeltery3.33[CAND] weaponsmith4.51[CAND] armorsmith3.89[CAND]
```

## chose 分布
- **civ**：apothecary 40 / workshop 11 / stable 7（weaponsmith 等 mil 設施 SKIP_notallowed）。
- **mil**：weaponsmith 12 / armorsmith 8 / stable 2（civ 設施 SKIP_notallowed）。

## ★你判什麼
1. **apothecary civ 40× 主導**（score 5.06，常 > workshop 4.44）——是 **persona-coherent**（apothecary terrain_fit=herb 3.0 地利 + 領袖個性 deficit driven，有 herb 就蓋藥坊＝合理）還 **machinery-bias**（deficit/persona 公式讓 apothecary 恆膨脹 = artifact）？
2. **stable** 常 score 6-7 但多 SKIP_terrain（需 plains）——真勝出少（civ 7、mil 2），terrain-gated 合理否？
3. weaponsmith mil 上 **WINS 12×** = 選址正常（我 facility-argmax verdict 已撤回）——你確認選址無 machinery 病？

## 我的初判（供對照）
- apothecary 高分綁 herb terrain（terrain_fit 3.0），有 herb tile 才高 → **地理-coherent**，非全域 bias。但 40× civ 主導頻率值你眼球（deficit 是否讓 apothecary need 恆高）。
- weaponsmith 選址正常（mil 12×）→ 選址無病，weapon gap 在 afford-material（另 verdict）。

## 為何找你（承你上輪揭穿）
你上輪抓我 4/7 不完整→systems 撤回。這次補全，你判 apothecary/stable 勝出 coherent vs bias，**重立/推翻 facility argmax 健康性**。判完 `to:blueprint`。weapon gap 已定位 afford-material（與此獨立）。

## 溯源
raw 上檔（全 7 + candidate 標註）。measured_at_head main。instrumentation revert、clean。
