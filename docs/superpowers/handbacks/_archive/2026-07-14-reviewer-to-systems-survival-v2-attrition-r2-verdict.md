---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·異質框外審已做] 求生層v2 attrition 根治：CLEAN 附條件（免額外 bisect 輪，headline 驗收即隱含 bisect）"
---

# R② 判決（升異質框外審，refute-first）：CLEAN 附條件

verdict: clean（附條件，見下）
premise_contradiction: false

## factcheck（worktree `.worktrees/survival-layer-unify` 現碼驗，非 main）
- `need_hierarchy.gd:14` `ESTEEM_FOOD_REF_DAYS=3.0`、`:57` `food_ready=clampf(food_days/ESTEEM_FOOD_REF_DAYS,0,1)`——你 Fix3 v1 diff 描述坐實。
- `ambition_ladder.gd:24` `RUNG_CRASH_FOOD_DEEP=-2.0`、`faction_ai_system.gd:1770` 讀之——Fix2 crisis 判準坐實。
- 手算你的 0.57 vs 0.45（food_days=2.5, solo 隊 raw_belonging=1.0 情況下）：`AFFINITY["生產"]=[0.3,0,0,0.5,0.2]` vs `["買糧"]=[0.9,0,0.1,0,0]`（`need_hierarchy.gd:75,95`），raw[SURVIVAL]=0.5、raw[ESTEEM]≈0.83（safe/ambition_gap≈1 時）→ alignment_生產≈0.57、alignment_買糧≈0.45-0.55（視 belonging）——**數量級對得上，機制成立**：跌破絕境仍給生產夠高 alignment 去壓買糧。Fix3 為主兇的機制敘事可信。

## 逐點 refute 回應

1. **根因歸屬（Fix1/Fix4 有無份）**：機制面驗證 Fix3 確有能力單獨造成此病（見上手算），但**不能排除 Fix1/Fix4 疊加放大**——沒 bisect 無法排除。**不要求你現在另跑一輪隔離 bisect**：驗收法⑥（attrition 回落 headline）本身就是隱含 bisect——v2 若把 attrition 打回 baseline，即經驗證實你的歸因足夠（無論是否 Fix1/4 也有貢獻，此輪已解）；**若 v2 跑完 attrition 仍顯著高於 baseline（非 ±可接受餘裕）→ 那才是硬信號「歸因不完整」，屆時才值得真 bisect**，非現在預防性做。省一輪工。
2. **GRADUAL_DECLINE_FLOW≈-0.5 over-trigger**：你已在驗收法保留「reeval.crisis 仍遠低 13997」為閘（spec §驗收⑥尾句），量測會抓到——不阻塞 spec，但**明確要求**：measurer 這次連 reeval 頻率數字也要跟 attrition headline 一起報，不能只報 attrition 過關就算數（怕 over-trigger 用別的代價換來 attrition 達標，例如 spam 到某種程度也會意外壓低 attrition，但代價是效能/thrash 復發）。
3. **人格化 trap（謹慎隊變相 lock）**：spec 自己驗收⑥已框「謹慎存活/野心賭徒可能死＝角色缺陷非 bug」——這是設計意圖非盲點，判**可接受**，但**要求驗收⑥的量測不能只看「Team14 型死亡消失」，還要抽驗謹慎領袖隊（caution 高）是否仍能在合理時間內升階**（非永久 esteem 卡 0，即使 ref=7 也該隨時間脫困可達）——若谨慎隊长期(如全 3mo)升不了階＝ trap 換皮沒解，需回頭調 CAUTION 係數非 declare 完工。此為驗收法補項，非阻塞 dispatch。
4. **layer 獨立性（compute_raw 讀 leader trait）**：§2 原意「禁讀他層 urgency」防的是 esteem 讀 survival/safety 的**urgency 值**造成循環耦合；leader trait（慎重/野心）是**靜態人格輸入**，非其他 raw layer 的輸出，性質同 `consistency_coeff`（`need_hierarchy.gd:136-139`）早已讀 leader_values 的先例——不算破壞 §2。**唯一要求**：把這條界線寫進 `need_hierarchy.gd` 頂部 §2 注解（「raw 可讀世界訊號+靜態人格 trait，不可讀其他 raw[layer] 的值」），避免下次改動誤判邊界。文件性補丁，不阻塞。
5. **survival 該不該是硬中斷**：正確留議 blueprint，非本輪範圍，同意擱置。

## 條件（非阻塞 dispatch，併入本輪驗收要求）
- 驗收⑥ headline 若沒回落到 baseline ±可接受 → 視為 premise 訊號不足，屆時要求真 bisect（非現在先做）。
- measurer 報告需**同時**附 attrition + reeval 頻率兩數字（防 #2 的 over-trigger 換皮風險被漏看）。
- 驗收法補「謹慎隊（caution 高）長期升階可達性」抽驗（防 #3 trap 換皮）。
- `need_hierarchy.gd` §2 注解補人格 trait 例外說明（文件性，implementer 順手做）。

## 回報
CLEAN → dispatch implementer 改 branch（v2 併 v1 branch 上）+ 上述條件寫進 measurer 驗收清單。
（寄件永遠 open，你讀後改 consumed。）
