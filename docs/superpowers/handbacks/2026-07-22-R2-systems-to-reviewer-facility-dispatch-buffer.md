---
from: systems
to: reviewer
status: open
topic: "[R²·facility dispatch afford buffer ×1.5→1.1·Gate B cheap 獨立·blueprint授權] spec=2026-07-22-facility-dispatch-afford-buffer.md。根:_dispatch_facility_builder:2780 owner avail<cost×1.5 return false(weaponsmith material 80→需120),但in-place _can_afford用exact(80)=不一致anomaly;mil隊54-80常roaming走dispatch路→卡120建不了。修:×1.5→named const FACILITY_DISPATCH_AFFORD_MULT=1.1(TEST VALUE,降undocumented 0.5×大buffer,留小buffer防rounding)。審點:①一致化理由對嗎(dispatch 0.5× buffer vs in-place exact=真anomaly非故意設計?查有無blame/血證那0.5×是承重的[如防owner depletion thrash])②1.1 vs 1.0(match in-place)哪個(1.1留subteam攜料保守buffer)③★仍是trade-primary次要(只降門檻,mil仍需有material,買才夠=material貿易流另軌measure主線)——別誤當主fix④無RNG⑤measure與material貿易流分開別conflate。CLEAN→dispatch。★注意:別重蹈今日『在未驗前提上調常數』——此項前提=code-fact(×1.5 vs exact不一致)+material真短缺QA-passed,較穩,但1.1值本身是tuning由measurer/QA長跑驗。"
---

# R²：facility dispatch afford buffer ×1.5→1.1（Gate B cheap 獨立）

spec：`docs/superpowers/specs/2026-07-22-facility-dispatch-afford-buffer.md`。blueprint 授權（cheap 不等）。

## 根 + 修
- `_dispatch_facility_builder:2780` `avail < cost×1.5`（weaponsmith material 80→需 120），**in-place `_can_afford` 用 exact（80）= 不一致 anomaly**。mil 隊 54-80 常 roaming 走 dispatch 路 → 卡 120。
- 修：`×1.5` → `FACILITY_DISPATCH_AFFORD_MULT=1.1`（TEST VALUE）。

## ★審點
1. **一致化理由**：dispatch 0.5× buffer vs in-place exact = **真 anomaly 非故意設計**？**★查有無 blame/血證那 0.5× 是承重的**（如防 owner 撥完料 depletion → thrash）——別拆承重 buffer（今日 subteam-idle 血證：blanket 排除是承重的）。
2. **1.1 vs 1.0**（match in-place）：1.1 留 subteam 攜料保守 buffer。哪個乾淨？
3. **★仍是 trade-primary 次要**（blueprint ②）：只降門檻，mil 仍需**有** material（54-80 靠買才夠 80）→ material 貿易流（另軌 measure）才是主。**別誤當主 fix**。
4. **無 RNG**。
5. **measure 與 material 貿易流分開**（別 conflate：此驗「有料隊建得成」/那驗「無料隊買得到」）。

## ★紀律提醒
別重蹈今日「在未驗前提上調常數」——**此項前提 = code-fact（×1.5 vs exact 不一致）+ material 真短缺 QA-passed**，較穩；但 **1.1 值本身是 tuning，由 measurer/QA 長跑驗**（新規則）。

## 回覆
`to:systems`：CLEAN / 修正（尤其 ×1.5 是否承重）。CLEAN → dispatch。
