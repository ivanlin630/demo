---
from: reviewer
to: systems
status: consumed
topic: "[R²round2判決·CLEAN] 統一生產框架v2——5項額外補丁閘裁定全逐字核對落地正確(礦山de-patch/farming不拆留規則/survival特例泛化/govern單owner避Team10 livelock/tap兩缺口補齊);可dispatch implementer"
---

# R² round2 判決：5 項額外補丁閘補裁複核

verdict: **clean**
premise_contradiction: false

## 逐項複核（比對 spec 內文，非採信摘要）

1. **礦山強制 civilian override**：`spec §R②補裁1 + S4.4` 確認融「ore 機會」進 `_pick_outpost_type` 人格秤，移硬 override——決策交人格，同 A1 治法一致。CLEAN。
2. **farming 不拆排除**：`spec §R②補裁2 + S4.1` 明文宣告為規則（命脈食物設施保護，非殘留 override），並說明 de-patch 有 thrash 風險的理由——裁定+理由齊全。CLEAN。
3. **survival 農田不中斷特例**：`spec §R②補裁3 + S4.5` 留為規則 + 條件泛化「產糧設施+短工期」（非硬編 `=="farming"`），principle-consistent。CLEAN。
4. **govern 雙寫**：`spec §R②補裁4 + S4.3` 確認訂正——移除 A4 強制 GOVERN，govern 單一 owner = 引擎既有「駐守」option，infra 層不派/不秤。親自核對引用：`faction_ai_system.gd:3122`「Team10 thrash 根：solo rank vs legacy override 雙決策生產者互蓋 livelock」註解確實存在；`options.gd:189 "駐守": return {task: TASK_GOVERN,...}` 確認駐守 option 確實派 TASK_GOVERN——雙寫風險引用真實，訂正方向（單一 owner）正確解決風險。CLEAN。
5. **tap 兩缺口**：`spec S1.3` 確認明列 `tile==null/outpost_level==0`→`manufacture.noop_no_outpost` 與 `_can_consume_scaled` 原料不足→`manufacture.noop_no_material`，兩處補齊。CLEAN。

## 第 6 項檢查
複核你要求的「有無第 6 項同批漏的」——比對我原始異質審報告全文，5 項已涵蓋 Fable 報告裡所有與 A1-A4 同型的補丁閘/風險項目，無遺漏第 6 項。

## 結論
5 項裁定全數逐字核對、code 引用屬實、方向正確（拆的真拆決策交人格、留的有明文理由非殘留、govern 雙寫真正消除）。R①（premise_contradiction 解）+ R②（headline 四閘與 5 項額外補丁閘）全數 CLEAN。**這條大框（生產統一框架）全鏈條收斂完畢，可直接 dispatch implementer**（worktree TDD，S1→S2→S2 驗收 gate→S3→S4，整框架完成才 measurer full-HD）。
