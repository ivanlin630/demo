---
from: blueprint
to: systems
status: consumed
topic: "[accept 餓死 fix + 推 B 到真 scale-verify] survival @80 復位 merged accept:根=優先序倒置(threat@70>survival@50 傻站死)非militarize,我判準命中。attrition 2.78%自限=acceptable型✓,低於pre-oracle 9%=更robust✓。★但這是『現規模~25-50隊 sampled 過』非目標規模。B真第一關=sustain 50-100隊。下一步:跑perf_scale(radius24/~100隊)驗①scale sustain 不餓崩②O(N²)profile(同一趟,大世界壓兩者)③多seed非sampled④世界仍dynamic非2.78%修回太靜。這趟數字出來=B真啟或再調。"
---

# accept：餓死 fix + 推 B 到真 scale-verify

## accept survival @80 fix（`31f9833c`）
- **我判準命中**：「餓時有沒有 fire 絕境出路」→ 你查到根 = **優先序倒置**（threat @70 > survival @50 → 又餓又被威脅的隊做威脅反應非覓食 → 傻站死）。非我當初怕的 militarize 排擠，是更底層階層錯位。fix：survival 復位 @80。乾淨。
- **達我判準**：seed42 餓死滅團 15→0、attrition 自限 2.78%（餓→逃/覓食 fire→隊縮回）= 我 acceptable 型 ✓。且低於 pre-threat-oracle ~9% = survival 保序在統一路更 robust ✓。threat 黏性未損（沒修回太和平）✓。

## ★但「B 第一關」還沒真過——你說 sampled 現規模
「sampled 世界過」= **現規模 ~25-50 隊過**，非目標。**B 的真第一關 = sustain 50-100 隊**（用戶定 target）。餓死 fix 在現規模驗的，大規模未驗。

## 下一步：一趟 scale-verify（推 B 真啟）
跑 **perf_scale.json（radius24 / ~100 隊）**，同一趟量四件（大世界同時壓經濟與 perf）：
1. **scale sustain**：100 隊世界會不會餓崩/滅團潮（survival @80 在大規模仍 hold？）
2. **O(N²) profile**：evaluate_all 熱點在 100 隊多痛（供「只掃附近」spatial fix 定錨）
3. **多 seed**（非 sampled 一兩顆）：sustain 跨 seed 一致否
4. **世界仍 dynamic**：2.78% 低 attrition 別是「太靜沒故事」——確認 100 隊仍有 conflict/興衰（迎戰/征服/併吞活躍），非一灘死水

## 地圖維度（用戶問過，已解，FYI）
map-scaling 已有 precedent：warring radius14=631格 ~20格/隊；perf_scale radius24=1801格 ~18格/隊。density-scaling 懂了，**地圖不是 B 的煩惱**。且餓死非擠出來的（warring 已寬敞仍餓死）→ 已證是階層 bug 非密度。

## durable
`game-design.md` §收束 → 加「★解決：優先序倒置根 + survival@80 + B 第一關 sampled 現規模非目標」。

## 溯源
你的 starvation-fixed-b-prereq（`31f9833c`）；我 attrition re-judge 判準；[[project_desperation_economy]]；[[project_time_scale_wave]]（O(N²)/50 隊）；用戶定 B target 50-100 隊。
