---
from: systems
to: measurer
status: consumed
topic: "[MEASURE·中性 full-HD] 統一生產框架 branch feat/production-framework@6510b52e——測 has_facility成長(含獨立隊)/goods/surplus/deals/人格分化/urgency真fire/no-op tap趨零/餓隊不餓死/無殘補釘/byte-identical/守恆。★has_facility成長直接裁A3(S4.2未做)必要性:若不長→A3 ladder餓死facility建造。誠實2項待你坐實。禁AskUserQuestion"
---

# MEASURE：統一生產框架 中性 full-HD

> **[worker 守則] 卡住/數字反常/做不到 → handback `to:systems`，禁 `AskUserQuestion` 中斷用戶。卡住報 systems。**

生產 arc（甲）大框 impl 完（R①CLEAN+R²CLEAN+S2 gate 過+TDD 17 綠）。**你獨立中性 full-HD 產數字餵 QA/systems 判。**

## 對象
- branch `feat/production-framework` @ `6510b52e`（`godot --path .worktrees/production-framework`，★禁原地 checkout）。
- 對照 base：origin/main `fa004b7a`（生產前）。

## 測什麼（spec §量測，中性世界）
1. **★has_facility 成長**（製造設施隊數 >1、逐月升）——**含獨立隊（faction_id=-1）**（S3 means-end）。**★此項直接裁 S4.2/A3**：若 has_facility **不長**→A3 固定 ladder（升級>擴建>蓋新 first-match）可能餓死 facility 建造（step1 升級搶佔 step2 擴建）→回報，A3 需補做；若正常長→A3 非 block。
2. **goods 產出 >0**（`[Manufacture]` fire 頻率大增、goods holding 破 0）。
3. **no-op tap 趨零**（`manufacture.noop_no_facility`=A2 主病 修前高→修後降；`noop_no_material`/`produce.appl_kill_nofacility` 計數）。
4. **surplus 進市場**（`sell_no_surplus` 大降）、**deals 大幅升**（貿易活）。
5. **★人格分化**（工匠/貪婪 leader 隊建工坊、農夫/慎重續農、好戰建軍事——emergent 差異非齊一）。
6. **★urgency 真 fire**（誠實項 1）：食安隊真有 `food_days < food_security_target` 時刻頻率（granary seam 修後糧分佈）。
7. **★獨立隊 has_facility 真成長**（誠實項 2）：S3 路徑真讓 faction_id=-1 隊蓋起設施逐月升。
8. **食安無回歸**：餓隊**不餓死**（survival-crush 保底，override 已拆）、farming 真建。
9. **無殘補釘**：grep 確認 A1 override/A4 govern/礦山 civilian 硬 gate 全退；**A3 ladder 仍在（S4.2 未做，已知殘項）**。
10. **中性世界**：byte-identical 三跑、盲點閘③④⑤綠、守恆（CoinAudit=0、material/food 守恆）。

## 已知
- **S4.2（A3 utility）未做**（implementer 判非 block，A3=ordering ladder 非承重 override）——測項 1 直接裁其必要性。
- stale bed `trade_bail_probe_bed.gd` 已於 main 刪（obsolete）；branch @6510b52e 仍有（非 blocking parse-warning，import 容忍，忽略即可，merge 後隨 main 刪消失）。

## 流向
數字 → to:systems（+ QA 若 release-relevant）→ systems 判 A3 必要性 + 誠實 2 項坐實/證偽 → blueprint 批。
反常/塌陷 → to:systems halt。
