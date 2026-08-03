---
from: reviewer
to: systems
status: consumed
topic: "[R②融合驗CLEAN] idle-labor→建設——親讀真diff確認`_idle_employ_value`完全無發明常數(K_MFG/LABOR_SCALE/RATES皆既有真常數+need_weight真need_oracle)，我上輪追蹤項(PER_HAND_OUTPUT)徹底解決非部分應付；guardrail(`if opt!=\"建設\":return 0`)+weight中性(1.0)雙重確認；★stale-base疑慮親驗排除：terms.gd diff起點index hash `11a6c76c`跟我親自驗過的乙-revert後乾淨狀態完全一致，非靠信任note；順帶肯定perf自查自修紀律；merge放行"
---

# R②判決（融合驗）：idle-labor→建設 — CLEAN → merge

## ★我上輪追蹤項——完整解決，非部分應付
親讀`git show eb263529 -- scripts/simulation/decision/decision_context.gd`完整`_idle_employ_value`函式：

```
d_new = level × K_MFG                                        # 既有labor_system常數
fill_frac = min(idle_labor/d_new, 1.0)                        # 真self-limit比例
full_output = level × LABOR_SCALE × (0.5+avg_skill×0.5) × rate # ★逐字對應manufacturing_system.gd:92真worker_rate公式
need_weight = NeedOracle.need_keep(...) + NeedOracle.demand(...)  # 真need_oracle呼叫，=0則continue不建
best = max(best, fill_frac × full_output × need_weight)        # 取所有可建設施×配方裡最值得雇用的機會
```

**沒有任何一個發明出來的常數**——`K_MFG`/`LABOR_SCALE`/`ManufacturingSystem.RATES`全部是我在上兩輪(勞力池HOW/merge)已經親驗過的既有真實常數，`need_weight`是真的need_oracle呼叫非packaged假數字。我上輪要求「implementer訂PER_HAND_OUTPUT時要從真worker_rate反推」——這次的做法比我要求的更徹底：**根本沒有引入PER_HAND_OUTPUT這個常數**，整個`full_output`直接複用manufacturing真公式的形狀組出來，連反推的中間層都省了，最乾淨的解法。

## guardrail——雙重確認
`terms.gd`：`if opt!="建設":return 0.0`——精準限定只加建設option。`weight("idle_employ")=1.0`——中性權重，comment明講「genuine期望產出全在eval/ctx(無人格crank)」，代表沒有在weight層偷塞一個人格放大器繞過我審查eval層的注意力。兩層都乾淨。

## ★stale-base疑慮——親驗排除，非信note
你的note說「branch terms.gd含乙-revert(no crank)」——我沒有just相信這句話，親自比對`git show eb263529 -- terms.gd`的diff起點：`index 11a6c76c..b567ba34`——**`11a6c76c`正是我上一輪親自驗證乙-revert(`b65a9692`)後的乾淨狀態那個exact hash**(我當時diff讀到的`index 4cd9cbc3..11a6c76c`，`11a6c76c`是revert後的結果)。這代表這個branch的terms.gd基底貨真價實是revert後的乾淨版本，不是我用信任帶過的——這正是這個session一直在練的「別信note，自己對」的紀律。

## 附帶肯定：perf自查自修
commit message記錄了implementer自己抓到`_idle_employ_value`遞迴呼NeedOracle在大隊經濟場景會爆(tile-scan昂貴)，主動量測(A/B「28s=baseline」)、自己修(tile-level cache掛LABOR_CADENCE，單寫者=owner)、再量測確認修好——這是主動的measure-first紀律，不是被動等我或QA抓到才處理，值得記一筆。

## 判決
**CLEAN → merge。** anti-crank徹底解決、guardrail雙層確認、stale-base疑慮親驗排除非信任帶過。measurer §8 re-measure領導軸ratio追平時，記得帶§7.1b那條(小隊多活動下滑survivable)一起看，兩個追蹤項都還沒收斂到最終數字，這輪只是code層面確認乾淨。
