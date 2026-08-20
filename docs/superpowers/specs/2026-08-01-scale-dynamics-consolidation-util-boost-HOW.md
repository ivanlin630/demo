# 乙 規模動態 — 整併 util boost（de-patch util-starvation）HOW spec（2026-08-01）

★已 merge;隊數收斂後續=效能 arc 五刀之 F。

**blueprint COMMIT（用戶 balance 精神）**：真根＝整併 util 結構餓死（per-option util dump 定案）。**boost 整併 util**——`absorb_drive`（野心/擴張 weigh→強吸弱、帝國）+ `join_drive`（弱求 protection/利益→投靠強），**兩路同一根**、走既有 argmax 人格 weigh（統一非特判、R² grep 硬檢）。**激進度保守起步**（寧欠整併也別塌 1 blob、起低、靠 §5 合量 tune 朝 ~50）。人格分化：野心高→吸/擴、義氣/弱→join/stay＝**有大有小湧現自人格**。

---

## §0 根定案（per-option util DUMP、非靜態斷言，[[feedback_measure_peroption_util_before_decision_claim]]）
- **整併 util 結構餓死從不贏 argmax**：吸納 ownutil 均 **0.104** vs 贏家 1.09（~10× 弱）、併入 0.332 vs 1.23（~4× 弱）。贏家群 winutil_sum：建設 9536/迎戰 8834/貿易 7981。
- 吸納 **finder 找到 4794** 弱鄰可吸、但 util 餓死 **dispatch 0**；併入只絕境 survival-boost spike dispatch 33。**非 finder 非 mid-travel 非 resolver＝決策層 util-starvation**。

### §0b 餓死公式根（file:line 坐實）
```
absorb_drive = ABSORB_DRIVE_BASE(1.0) × resource_slack × (0.5+0.5·yield_pos) × (0.5+0.5·amb_gap)
  amb_gap = clampf(ambition_gap × 0.3, 0, 1)          # terms.gd:228-230
```
- **①base 1.0**（terms.gd:59「T3 正規化：吸納量級→[0,1]（1.2→1.0）」＝死常數 [0,1] cap）。
- **②野心 ×0.3 再塞 [0.5-1] band**（terms.gd:228）＝blueprint 要的關鍵人格槓桿**被閹幾乎無效**（max 野心只把 factor 從 0.5 抬到 ~0.65）。
- **③三個 ≤1 factor 連乘往下壓**（典型 ~0.2）。贏家 build/fight 不受此 [0,1]-product cap。
- `join_drive`(terms.gd:129-134)：quality band(host rep) × urgency(coeff)；**urgency 只 hunger/threat**→fed 隊 join coeff≈0→絕境才 fire（無理性 protection 觸發）。
- ＝**死常數過度正規化餓死選項**（[[feedback-patch-gate-first]] 死常數人格化家族、非 tuning-missing）。

---

## §1 de-patch seam（統一：util-weight 族、走既有 argmax term pipeline、零新機制/特判）

**兩路同一根＝整併 util 太弱**。de-patch＝**讓人格（野心/求保護）真放大整併 util 到可競 argmax**（非 flat 齊 boost→那會 over-consolidate 塌 blob；靠人格 DIFFERENTIATE 出有大有小）。

### A. absorb_drive（pull、強吸弱、野心/擴張 weigh）
- **野心真放大**（治 ②被閹）：`amb_gap` 從 `ambition×0.3` 塞 band → 改**野心當強乘數**，e.g. 
  `absorb_drive = ABSORB_DRIVE_BASE × resource_slack × (0.5+0.5·yield_pos) × ambition_amp`
  其中 `ambition_amp = 0.5 + AMB_GAIN × ambition_gap`（`AMB_GAIN` 保守起步 e.g. 1.5→ 野心 max amp~2.0、content 隊 amp~0.5）。**高野心強隊 absorb util 競 argmax、低野心 stay**＝有大有小人格湧現。
- **base 保守抬**（治 ①）：`ABSORB_DRIVE_BASE 1.0→ABSORB_DRIVE_BASE_V2`（保守起步 e.g. 1.5、非狂拉）。整體目標：**高野心+好 yield+有 slack 的強隊 absorb util 偶爾贏**（~1.0 級距、非場場贏）。
- yield/slack gate 保留（負 yield→0 不吸、無 slack→不吸＝防亂吸，terms.gd:229 既有）。

### B. join_drive（push、弱投靠強、求 protection/利益 weigh，非只絕境）
- **加理性 protection urgency**（治「fed 隊 join coeff≈0」）：現 join urgency 只 hunger/threat（coeff）。加**弱-near-強 protection-seeking 壓**——小/弱隊 near 強 protector（best_protector_rep 高）→ 理性 join 壓（coeff 非 0），weigh by 求生欲/低野心（野心高→stay 獨立）。**非絕境也能理性投靠**（趁健康撐得完旅程、順帶治 [[known_issues]] 97% mid-travel 死＝健康 joiner 活著到）。
- 保守起步：protection urgency 溫和（弱隊偶爾理性投靠、非全投靠）。

### C. 統一約束（R² grep 硬檢、blueprint 定）
- **走既有 argmax term pipeline**（terms.gd drive + weight）、**零新特判 branch**（grep 無 `if ...: dispatch 吸納/併入` 繞 argmax）。
- **連續 weigh 非硬 gate**（grep 無 `if ambition>X` 階梯、只連續乘）。
- **人格 weigh**（野心/求生欲/仁慈走 weight()、非 code 硬分流）。
- **感知鐵律**：整併決策讀 belief（prey_pos/host_pos 已走 belief、保持）。

---

## §2 元件（implementer、terms.gd 為主）
1. `terms.gd absorb_drive`(224-230)：野心 amp（治 ②）+ base 保守抬（治 ①、可新 `ABSORB_DRIVE_BASE_V2` 常數）。
2. `terms.gd join_drive`(129-134) + coeff/urgency 路：加理性 protection urgency（弱-near-強、weigh 求生欲/低野心）。
3. **全量 tap**（憲法）：absorb/join 的 ownutil per-option + dispatch + merge + 隊數/規模分布**接 tap**（§5 合量讀分布 tune）。dump 保持 decision_diag 格式（already 有 diag.吸納/併入 ownutil/winutil）。
4. **保守起步值**（`AMB_GAIN`/`ABSORB_DRIVE_BASE_V2`/protection urgency 溫和）＝**起低、§5 合量看分布再 tune**（別現在硬定）。

---

## §3 dev-time 便宜驗（★約束3、小併大真發生）
`scripts/debug/` bed（seeded warring 短窗、複用 absorb/join trajectory tap）：
- **硬斷**：
  1. **吸納真 fire**（治 dispatch 0）：boost 後 absorb.dispatch **>0**（高野心強隊真選吸納）+ arrive + merge **>0**（team 數真降）。
  2. **併入理性 fire**：非絕境弱隊 near 強 protector 也 join（dispatch 不再只絕境 spike）。
  3. **有大有小人格分化**：掃 ambition → 高野心隊 absorb-share 高、低野心 stay（**連續非階梯**＝WEIGH 非 GATE）。
  4. **保守未塌**：短窗隊數降但**非塌成 1 blob**（仍有小隊）。
  5. determinism（seeded 3 跑 byte-identical）、observe 零 RNG（[[feedback_observer_no_global_rng]]）、gates 綠、統一非特判 grep 自證。

## §4 隔離 branch（★約束2）
`feat/scale-consolidation-util-boost`（獨立、防誤 merge）。

## §5 §5 一次合量 tune（★約束4、blueprint 定）
- 乙合量：**分布 tune 激進度**（隊數/規模分布朝 ~50 有大有小、非塌1；不夠→調高 AMB_GAIN/base、過衝→調低）。
- **與甲同一合量**（約束4 一次）：查乙小併大分布 + 甲分配戲（**有餘糧條件**、防 warring 稀缺測 0）+ 經濟流動＝沙盤活了嗎。

## §6 工序
乙 HOW（此檔）→ **R²**（統一非補丁 grep：無特判①/連續 weigh 非硬 gate②/野心真放大③/感知鐵律）→ dispatch 隔離 → dev-verify（小併大真 fire + 人格分化 + 保守未塌）→ §5 合量 tune。blueprint 方向已 COMMIT（boost 整併 util、保守起步）。
