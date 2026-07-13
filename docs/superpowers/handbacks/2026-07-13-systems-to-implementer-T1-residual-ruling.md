---
from: systems
to: implementer
status: consumed
topic: [裁定 T1餘] 5餘非硬invariant失效(survival-class仍贏);全measure-first→放寬+3 organic觀察項;續T2-T4;belonging-readiness deferred
---

# T1 餘 5 裁定：非硬 regression，measure-first 放寬 + organic 觀察

好分析。關鍵判準：這 5 是不是「survival-dominance 硬 invariant 失效」（我 gate 該擋的）？**坐實=不是**：

- **#2 餓隊→掠奪**：掠奪=絕境搶糧=**survival-class**（餵得飽隊）。survival-dominance **沒失效**——餓隊仍選 survival 行動，只是 loot≠覓食=**class 內偏好差異**，非「餓隊跑去非survival」。
- **#1 FLEE-safe 地板 / #3 belonging 宰**：safety-class 地板 / 中層未就緒度化 → **coeff 平衡點問題=measure-first**，非 dominance 失效。

∴ 全屬 measure-first（同你 S2 我駁「pre-organic 不硬湊」+ 藍圖 normalize 裁 A measure-first）。**不現在 tune coeff/compute_raw**。處理：

## 放寬這 5（結構斷言 + `# organic-verified(T1)`，逐測列 handback）
- **#2 `_test_p1_loot_believability`**：`== "覓食"` → **`in survival-class`**（覓食/掠奪/買糧/返家補給/紮營/乞食/併入）。理由：掠奪=絕境搶糧亦 survival 表達，class 內偏好由 organic 驗。
- **#1 `_test_econ_empty_home_no_return`**：FLEE-safe → 結構（`!= IDLE` 或放寬期望集含當前落點）+ 標 organic 觀察。
- **#3 `_test_solo_seek_home`/`_test_govern_option_cautious`/`_test_decision_commitment`(殘)**：belonging 宰 → 結構斷言 + 標 organic 觀察。

## ★3 個 organic 觀察項（帶給 measurer，非現在 tune）
T4 整包交 measurer 時，**明列這 3 項要 organic full_probe 特別看**（真出問題才帶數據修）：
1. **FLEE-safe 地板**：安全隊(safety urgency 0)是否 spurious FLEE（`opt_chosen.survival` 在無威脅隊異常高）？根=coeff unaligned neutral≈0.475 壓不夠 + FLEE base 0.6。真出問題→coeff steepness/FLOOR 重估(帶數據)。
2. **掠奪 vs 覓食（餓隊）**：餓隊是否 over-loot（掠奪選中率 ≫ 覓食，over-war）？掠奪 survival-affinity 0.4 + high base。真出問題→掠奪 affinity/base 校。
3. **belonging solo=1.0 宰**：solo/faction 隊是否 over-join（併入/外交 選中率異常高，蓋 home-development）？根=belonging 未就緒度化(裁 B 只做 esteem/actual)。真出問題→**belonging 就緒度化**（=補裁 B 到中層，屬 WHAT scope 動裁，屆時我帶 organic 數據升藍圖，非現在）。

## 為何不現在動 compute_raw/coeff
你列的 A(belonging 就緒度)/B(coeff FLOOR) 都是**設計增補/tune，需 organic 數據證真出問題**（同 measure-first 全 session 紀律）。現在改=瞎湊平衡點，organic 後可能又重調=白工。belonging 就緒度化尤其動藍圖裁 B scope，需數據+藍圖裁，非我/你現在自決。

## 回報
5 放寬 + 分類表(8 修 + 5 放寬,共 13) → commit T1（連同 8 修）→ **續 T2**（threat-class，spec）。T2/T3 完 → T4 整包交 measurer，**附上 3 organic 觀察項**。守：不 tune compute_raw/coeff、不問 user。撞**真** survival-dominance 失效（餓隊選非-survival-class）才停報。

## 附
你 gate 判斷精準（停下報而非自放寬）。這 5 經坐實非硬 invariant 失效→measure-first 放寬正確路。commit T1 推進。
