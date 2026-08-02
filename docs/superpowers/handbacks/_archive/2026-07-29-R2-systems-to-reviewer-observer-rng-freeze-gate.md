---
from: systems
to: reviewer
status: consumed
topic: "[R²·observer-no-global-RNG靜態閘·spec=2026-07-29-observer-rng-freeze-gate-HOW.md·動機=observer_no_global_rng 4次血證證人工記性擋不住(現無靜態閘:constitution_gate只掃sim+漏pick_random/shuffle,observability_gate只管tap coverage,runtime byte-identical只覆蓋exercise到路徑)·機制=observability_gate加第③檢查:observe-pure marker檔內禁5類global-RNG向量(擴3→5含pick_random/shuffle)+local-seeded逃生口(rng.前綴放行但pick_random/shuffle照抓因無本地版)+順手補constitution RNG_RE·純靜態零風險] observe-RNG靜態閘。審逃生口regex邊界+marker慣例+向量集完整性。"
---

# R²：observer-no-global-RNG 靜態閘

## spec
`docs/superpowers/specs/2026-07-29-observer-rng-freeze-gate-HOW.md`（讀它）。

## 一句話
`feedback_observer_no_global_rng` 憲法級但 **4 次血證證人工記性擋不住**，現況**無靜態閘覆蓋此軸**（constitution_gate 只掃 sim+漏 pick_random/shuffle；observability_gate 只管 tap coverage；runtime byte-identical 只覆蓋 exercise 到的路徑，血證根教訓＝leak 躲在 harness 沒跑到的路徑）。→ 加**靜態閘補未 exercise 路徑**：observe-pure marker 檔內禁 5 類 global-RNG 向量。

## ★reviewer focus（異質 refute）
1. **2b local-seeded 逃生口 regex 邊界**：`rng.randf(`（識別字`.`前綴＝本地放行）vs bare ` randf(`/`=randf(`（global 抓）——這判別**會不會漏**（如 `self.randf(`？多行？）**或誤報**（合法 case 被抓）？
2. **★pick_random/shuffle 不吃逃生口對否**：Array/Dict `.pick_random()`/`.shuffle()` 我斷言**一律 global RNG（GDScript 無本地版）**故前綴`.`也照抓——**這斷言真否**（有沒有 `rng` 能驅動的本地版被我誤殺）？
3. **向量集完整性**：5 類（randf/randi/randf_range/randi_range/randomize + pick_random/shuffle）**有沒有漏**其他耗 global RNG 向量（`randi_range` 我加了；`RandomNumberGenerator` 全域單例？其他 Array 隨機方法？）？
4. **marker 慣例 vs 中央清單**：`# @observe-pure` 檔頭 marker（自我文件化、新 helper 加 marker 自動納管）vs 中央 allowlist——marker 靠作者加**會不會漏**（新 observe helper 忘加 marker＝逃管）？中央清單腐化 vs marker 遺漏，哪個風險大？

## 判
CLEAN → implementer。有洞（尤其 2/3 向量斷言錯＝誤殺合法 code）→ 回 `to:systems`。**非 blocker on 別的 arc**（正交 framework 債，roadmap fork PAUSE 期正好做）。
