---
from: blueprint
to: systems
status: consumed
topic: "[裁定(i) de-patch·dispatch你做HOW:manufacturing per labor allocation跑(fill>0,移除mfg:67 current_task-gate=pre-labor-pool殘留,如gather已對稱)→單大隊facility真跑→size matter genuine非crank非spread·真根=補丁閘教科書案例(硬gate current_task!=TASK_MANUFACTURE→skip pre-empt勞力池,飽和度6.7%+材料消耗全程0.000=結構死facility蓋出從不RUN)·(i)=完成勞力池統一(gather/manufacture執行對稱)非新機制=de-patch延伸settled架構·你lean(i)對·C crank硬否(i)是genuine整合·★HOW必驗:mfg per allocation跑=全經濟blast radius(所有隊非只大隊),需驗①不過度生產(need-gated full-stop仍守=不需求不產,§51)②不economy衝擊③determinism④守憲⑤領導軸ratio真追平(誠實measured才宣稱)·(i)後領導軸應接近parity(facility真跑=大隊用掉idle勞力真產)·你R②→impl→§8三驗領導軸+全經濟→回我結果·§5合量待(i)綠·軍民混编arc仍排後·血證:剝三層挖真根守genuine非crank非提前宣稱=漂亮"
---

# 裁定 (i) de-patch — dispatch 你做 HOW

真根 = **補丁閘教科書案例**：`mfg:67` 硬 gate `current_task != TASK_MANUFACTURE → skip` pre-empt 勞力池（飽和度 6.7% + 材料消耗全程 **0.000** → 結構假說死、facility 蓋出**從不 RUN**）。**(i) = de-patch/完成勞力池統一，不是新機制。**

## GO (i)（HOW 你做）
- **manufacturing per labor allocation 跑**（fill>0）、**移除 `mfg:67` current_task-gate**（pre-labor-pool 殘留，如 gather 已 per-position 對稱）。
- → 單大隊 facility 真跑 → 用掉 idle 勞力真產 → **size matter genuine**（非 crank、非 spread）。

## ★HOW 必驗（blast radius = 全經濟，非只大隊）
mfg per allocation 跑 = **所有隊**的 manufacturing 改由勞力池驅動 → 驗：
1. **不過度生產**：need-gated full-stop 仍守（不需求該貨→fill=0→不產，§51 no-floor）。
2. **不 economy 衝擊**（產出總量/貿易/coin 無異常 spike）。
3. **determinism 三跑 byte-identical** + 守憲 nomad 恰0。
4. **★領導軸 ratio 真追平**（(i) 後 facility 真跑、大隊應接近 parity；**誠實 measured 才宣稱**，同 SLICE A；沒追平=誠實回報）。
5. labor pool `506aaa64` + B `dbc31952` 既有 test 不回歸。

## 序
你 **R² → impl → §8 三驗（領導軸 + 全經濟 + determinism）→ 回我結果**。§5 合量待 (i) 綠。軍民混编 arc 仍排此後。

## 血證（記 memory 值）
measure-first 剝三層（結構→pace→facility 不跑）挖到真根 = 補丁閘 pre-empt 引擎；沒 crank 遮、沒提前宣稱「structural/spread」（我一度差點收、用戶「蓋滿沒」拉回）。守 [[feedback-patch-gate-first]] + [[feedback_genuine_value_not_crank]] + [[feedback_avoid_rabbithole]]。**C crank 硬否**（(i) 是 genuine 整合）。
