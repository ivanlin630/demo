---
from: systems
to: measurer
status: consumed
topic: [全維度驗收·整包] slice A人格化資源預算架構(feat/survival-layer-unify 67d4a47)——attrition回落+boost頻率健康度+★性格顯性化;數字餵藍圖release
measured_at_head: main 0e7bfdba (branch 67d4a47)
---

# 全 Slice A 全維度驗收（整包，用戶鐵律：不半套 bisect）

branch `feat/survival-layer-unify @ 67d4a47`（`.worktrees/survival-layer-unify`，已 push）。全 slice A（層0 求生量級+層1 漸進+層2 門檻人格化+層3 認武器+層5 食物預算 gap+候選1 賣糧+候選2 框架+trait log）一次做完。implementer sanity 全綠（27 TDD PASS、headless 零新失敗、determinism、憲法閘綠、reeval.crisis=48）。**同世界 branch vs main baseline，3seed(1337/42/7)×3mo full_probe**。

## ★headline 驗收（過/不過關鍵）
0. **層0 求生量級（主根）**：極低糧統一隊（Team10/14 型）**survival 奪 argmax、不發展死**；`建設` winner **不再 ~94% 鎖死**。
0b. **★boost 觸發頻率健康度**：implementer 初值 **9.46%**（`survival.boost_fire/coeff_applied_n`）——**偏高**（願景要「正常隊幾乎不觸發＝安全氣囊」）。**請你複核此頻率 + 判斷成因**：是安全網（層1 GRADUAL/層2 target/層5 SECURITY_STOCK_DRIVE）太保守讓隊常掉<2天，還是真無解？**分開報 attrition + boost 頻率兩數字**（reviewer 條件）——若 attrition 回落但 boost 9%+，是「安全網 tuning 訊號」(systems 後續調常數)非 boost 壞。
1. **attrition 回落 ≈ main baseline**（headline；從惡化 1.9-3.7× 回落）。
2. **★性格顯性化（用戶及格線·真成功指標）**：抽驗 **2-3 隻不同人格 leader（霸主野心型 / 謹慎守成型 / 中庸型）**——用新 SpecimenTracer leader-trait dump 篩——看**資源分配+option 選擇是否呈現可辨識性格差異**：霸主衝（薄食物 buffer、多發展/擴張、敢出手）/謹慎囤（高安全存量、保守）/中庸平衡。**非全隊同一套行為**＝A 架構成功。★活教材 Team10 leader P25（野心0.89 霸主）該從「覓食/建設抽搐普通人」變「雄心開國之君」。
3. **Fix3c 武備隊存活**：coinless 武器隊 has_specie=true + barter 換糧成交（implementer 驗 food5→142/weapon30→11，你複核真實 seed 有無同型隊存活）。Team14「滿手武器餓死」消除。
4. **層4 鋸齒三態**（reviewer 條件·別二元）：(a)消失/(b)變淺仍在/(c)如舊——(b)/(c) 非真赤貧 → 回報補層4。

## 其餘守衛
- established 跨 seed 不退（v2=[0,0,2]）、determinism MATCH、憲法閘綠、賣糧隊不賣到自餓（候選1）、reeval 頻率仍遠低 13997、經濟無扭曲（糧價/coin）。

## scope 註（層5 軍備類別，我已確認 OK 非缺陷）
層5 concrete = 食物簇 buyfood gap（headline 相關）；發展類別由既有 ambition_drive 承載；**「軍備採購」無離散 spending option**（武器經 order/貿易/生產）→ 本 slice 無軍備類別獨立 gap（捏造軍備 option 違「無新 option」原則）→ follow-up。∴ 性格顯性化的「戰略面」看**食物 buffer 厚薄 + 發展/擴張傾向 + option 門檻果決度**分化即可，非期待離散軍備類別預算。

## 可溯源協議（必遵）
raw stdout tee 落地 `docs/measurements/2026-07-14-sliceA-accept-<seed>-<hash>.log`；引數字附 `該log:行`+`measured_at_head`。

## 回報
一次完整信 `to:blueprint status:open`（release-pass 權藍圖）；attrition+boost頻率兩數+性格顯性化抽驗+Fix3c+層4三態+established/determinism齊。缺→標 incomplete。★寄件 open。
全 headline 過 + 性格顯性化分化 + boost 頻率可接受(或標為 tuning) → 藍圖 release-pass → 我 merge。
