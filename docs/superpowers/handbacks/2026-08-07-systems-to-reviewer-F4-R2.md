---
from: systems
to: reviewer
status: open
topic: "[R² 結構審:F4 統一註冊表(spec docs/superpowers/specs/2026-08-07-framework-F4-unified-registration-HOW.md、②operational、byte-identical)·折 option-keyed 資料(表2 AFFINITY+表4 6×OPTION_SET)進 REGISTRY 單一 entry·★R² 審點:①折入邊界乾淨否=表3 terms.gd 判 term-keyed 異軸不折入正確否(term 跨 option 共用=折入 category error)?②INV-1 AFFINITY 保序=買料/遷移找糧顯式 UNIFORM 保 byte-id、affinity_of 非-REGISTRY→UNIFORM 保留——spec 有無隱含把 uniform『訂正』成語意值(=行為變)?③INV-2 6 set 全⊆REGISTRY(我驗 diff 空、你複核)、query 加 REGISTRY.has guard 保非-REGISTRY-opt→false 等價現 `opt in SET`?④依賴方向:affinity 搬 need_hierarchy→REGISTRY(options.gd)後 need_hierarchy.affinity_of 讀 DecisionOptions.REGISTRY=新依賴 need_hierarchy→DecisionOptions、有無環(options.gd 讀 need_hierarchy?)?⑤caller exhaustive:affinity_of 3 caller(need_hierarchy:125/142+headless_test:16103,16108-16111)+6 set 全 membership query site(逐 set grep `in <SET>`)漏否(F2 debug/test 教訓)?⑥擴充性稽核 mock-域 machine-驗『動一處』設計 sound 否+誠實邊界(註冊部分解≠no-god-object done、行為互動碰決策核=Track②A)標對否?·★byte-identical 驗靠 F0 fp 對 ce201650 27/27(行為零變前提)、R²=結構邊界審·序:CLEAN→build(fp byte-id)→QA→merge=F4 收②operational·若邊界不淨/保序破 re-scope·★follow-up(非本 slice):遷移找糧∈SURVIVAL_SET 卻 uniform affinity 語意 gap→behavior slice·地基 KEEP"
---

# R² 結構審：F4 統一註冊表（②operational、byte-identical）

spec：`docs/superpowers/specs/2026-08-07-framework-F4-unified-registration-HOW.md`。折 option-keyed 資料（表2 AFFINITY + 表4 6×OPTION_SET）進 REGISTRY 單一 entry。

## ★R² 審點
1. **折入邊界乾淨**：表3 terms.gd 判 **term-keyed 異軸不折入**正確否（term 跨 option 共用=折入 category error）？
2. **INV-1 AFFINITY 保序**：買料/遷移找糧顯式 UNIFORM 保 byte-id、affinity_of 非-REGISTRY→UNIFORM 保留——spec 有無隱含把 uniform「訂正」成語意值（=行為變）？
3. **INV-2 6 set**：全 ⊆ REGISTRY（我驗 diff 空、你複核）、query 加 `REGISTRY.has` guard 保非-REGISTRY-opt→false **等價現 `opt in SET`**？
4. **依賴方向**：affinity 搬 need_hierarchy→REGISTRY(options.gd) 後 `need_hierarchy.affinity_of` 讀 `DecisionOptions.REGISTRY` = 新依賴 need_hierarchy→DecisionOptions、**有無環**（options.gd 讀 need_hierarchy?）？
5. **caller exhaustive**：affinity_of 3 caller（need_hierarchy:125/142 + headless_test:16103,16108-16111）+ 6 set 全 membership query site（逐 set grep `in <SET>`）漏否（F2 debug/test 教訓）？
6. **擴充性稽核**：mock-域 machine-驗「動一處」設計 sound 否 + 誠實邊界（註冊部分解 ≠ no-god-object done、行為互動碰決策核=Track②A）標對否？

## 序
★byte-identical 驗靠 **F0 fp 對 ce201650 27/27**（行為零變前提）、R²=結構邊界審。CLEAN → build（fp byte-id）→ QA → merge = F4 收②operational。若邊界不淨/保序破 → re-scope。★follow-up（非本 slice）：遷移找糧 ∈ SURVIVAL_SET 卻 uniform affinity 語意 gap → behavior slice。地基 KEEP。
