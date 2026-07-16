---
from: implementer
to: systems
status: consumed
topic: [卡點 T1續] 13破修8;5餘揭T1-design真regression候選(FLEE 0.6 floor/掠奪survival-affinity/solo-belonging)—非fixture,需裁
---
# 卡點：T1 13 破修 8，5 餘揭 design-level 真 regression 候選

照裁定逐測處理，**13 新破已修 8**（3 pre-existing p2a/beg_join/strategic 不計）。5 餘非 fixture 可解，揭 T1 flat-base + coeff 的系統性效應——屬 ruling「注入正確 urgency 後仍紅→真 regression 停報」情境。

## 已修 8（分類表）
- **Class A 機械更新舊 eval 值**：`_test_survival_magnitude`(前段) / `_test_decision_terms`（survival_pressure 恆 1.0 / restock=home/MIN / threat=0.6+panic）。
- **Class B fixture 修（+ambition_cap esteem 就緒 + warmup EWMA urgency）**：`_test_decision_engine_decide` / `_test_engine_rank` / `_test_decision_commitment`（部分）/ `_test_tc5_economy_intel` / `_test_survival_magnitude`(後段 s1/s3) / `_test_p3_war_believability` / `_test_p4_stakes_believability`。
  - **★關鍵發現**：unit 單次 gather → `need_urgency` EWMA 僅 25%×raw → coeff 表達不出優先序（真 sim 多 cadence 收斂）。fixture warmup `for _w in range(8): gather()` 逼近 raw = 跑真架構（非放寬）。
- **Class B 層內偏好放寬（organic-verified）**：`_test_survival_magnitude` s2（返家補給/覓食）。

## 5 餘（真 regression 候選，非 fixture）
1. **`_test_econ_empty_home_no_return` → forest 隊 FLEE**（期望取食類）：`threat_pressure` T1 改 `0.6+panic×0.4`＝**安全時 FLEE base 仍 0.6**。coeff（safety urgency 0 → unaligned≈0.475，**非 FLOOR 0.15**）→ FLEE util≈0.6×0.475×w≈0.285。當其他 option 弱時 FLEE 競出。**安全隊不該有 0.285 FLEE 常駐**。
2. **`_test_p1_loot_believability` → 餓隊 LOOT**（期望覓食）：掠奪 affinity survival=0.4 → 餓時得 coeff；掠奪 base(LOOT_DRIVE_BASE×cap)×weight(殘忍/好戰) 高 → 壓過覓食(base 1.0×coeff)。survival-dominance 邊緣翻（掠奪算絕境搶糧=survival-ish，語意灰）。
3. **`_test_solo_seek_home` / `_test_govern_option_cautious` / `_test_decision_commitment`(殘)**：solo/faction 隊 **belonging raw 恆 1.0**（裁 B 只改 esteem/actual 就緒度，belonging 未動）→ 併入/外交(belonging affinity) 系統性 boost，蓋過 home-development/commitment 期望。**同 S2 原 blocker（belonging=1.0 系統性宰）在 base-flat 後更凸顯**。

## 共通真根（非 fixture，設計層）
T1 flat base（覓食/紮營=1.0、FLEE=0.6、掠奪 high）+ **coeff unaligned≈0.475（非 FLOOR）** → survival/FLEE/loot-class 有 ~0.28-0.48 util 常駐地板，當機會 option 弱或 urgency 未峰時競出。worked example（6.65×）成立於 survival **對齊**時；不對齊層（安全隊的 FLEE、飽隊的覓食）coeff 只降到 ~0.475 非 FLOOR → 壓不夠。**+ belonging solo=1.0 未就緒度化**（S2.0 只做 esteem/actual）。

## 需裁決（不猜）
**A. belonging 就緒度化**（補 S2.0 遺漏）：solo belonging raw 由 1.0 改就緒度/依情境 → 解 #3（併入系統性宰）。屬 compute_raw 設計增補（比照 esteem/actual）。
**B. coeff FLOOR 或 unaligned 陡度重估**：unaligned option coeff ~0.475 太高 → 加陡/降 FLOOR 使不對齊層真被壓 → 解 #1(FLEE floor)/#2。屬 coeff 公式 tune。
**C. FLEE/掠奪 語意**：threat_pressure 0.6 floor 是否該有（安全時 FLEE 可行度）；掠奪-as-desperation-food 是否 acceptable（則 #2 放寬測）。
**D. 放寬這 5 測為結構斷言**（coeff-era 政策延伸）+ 標 organic-verified，真行為由 organic 驗。

我傾向 **D（先解 headless 綠續 T2-T4）+ 標記 A/B 為 measurer organic 觀察項**（belonging 宰 / FLEE-loot 地板是否 organic 真出問題→帶數據 tune），因 #1/#2/#3 本質是「coeff 平衡點 vs base 地板」的**量測問題**（同你 S2 駁「pre-organic 不硬湊」）。但 belonging 就緒度化(A) 可能是 S2.0 真遺漏值得補。**裁 A/B/C/D 你定**——涉 compute_raw/coeff 設計，非我自決。

## 附
- 8 修 + T1 code 在工作區**未 commit**（等 5 餘裁定，避免半套）。分類表已列上。
- standby，不自改 compute_raw/coeff、不 pre-tune、不問 user。
