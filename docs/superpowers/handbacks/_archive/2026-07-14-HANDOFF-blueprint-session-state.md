---
from: blueprint
to: blueprint
status: consumed
topic: [★交接·重開讀我] Slice A(survival-layer-unify)全完+雙量測驗收正向,未merge,待用戶裁(a)直接merge+tuning follow-up 或(b)先tuning再merge;當機診斷已結案(mrcbt CBT bug)
---

# ★ 交接：blueprint session 狀態（重開後先讀）

## 專案卡點（唯一待辦=等用戶裁）
**Slice A（求生層統一/人格化資源預算）全完、雙量測驗收正向、未 merge main。等用戶二選一：**
- **(a)** 直接 merge main + tuning 排 follow-up（接受 attrition 1.3-1.7x 當階段成果）
- **(b)** 先做一輪 tuning（層0 加強／層5 餓時食物壓過軍備／weapon-buy drive 調弱）再 merge

重開後先問這個。用戶當機前正要裁，被打斷。

## Slice A 現況
- branch `feat/survival-layer-unify` @ `67d4a470`（**未 merge**；main HEAD=`3154d52e`）。
- 全 Slice A：層0 boost + 候選2 統一門檻 + 層5 + 候選1 + Fix3c。
- pipeline 全 idle：implementer hold-warm、reviewer/measurer/qa idle。信箱零 open（除本交接）。

## 雙量測結果（都在手上，當機前完成）
- **第一次**（measurer 03:40, branch 67d4a470）：attrition **1.9-3.7x→1.3-1.7x**、established +1、性格分化 3 樣本 PASS、Fix3c PASS、憲法閘/determinism PASS。但爆疑點「第三種死法」= Team14 decision_count=0 疑架構絕症。
- **第二次**（systems 同世界 reeval 05:12, commit `3154d52e`）：**推翻**——「第三種死法」=假象（SpecimenTracer tap 沒接 order 系統）。Team14 其實活躍決策（buy weapon×6/buy food×34-64/飢餓徵幣），真殘根=**軍備買贏買糧→餓死=可 tuning**，非架構絕症。
- ★注意：measurer `.status.md` 還寫舊結論「架構性殘根」——已被第二次推翻，權威以 `3154d52e` 為準。

## 殘根性質（供裁決）
attrition 1.3-1.7x 的殘死法 = **可調 tuning**（層0 力道/層5 食物vs軍備優先/weapon-buy drive），非需再開架構 arc。→ 支持 (a) 也支持 (b)，看用戶要不要先收乾淨。

## 其他延續選項（HANDOFF 07-13 遺留，仍開）
- established 跨 seed 穩定（現 1/3 點亮 seed7）
- 重評頻率再 tune（381次/90天，比理想略高）
- 補回歸驗證（faction協同/飢荒/戰鬥細部這輪沒細查）

## 當機診斷（已結案，非專案，存 A:\GDS\temp\crash-diagnosis-2026-07-14.md）
- 根因=**Macrium Reflect CBT driver `mrcbt.sys` NULL-deref**（關檔 handle 時），老碟 WD10EALX SATA 逾時觸發。
- 用戶**已移除 Macrium**，但 mrcbt driver 這次開機還 RUNNING 在記憶體 → **用戶正重開機清它**。
- 重開後驗 `sc query mrcbt` 應回「服務未安裝」。WD10EALX(10.8年老碟)排退役。
- 6 顆碟 SMART 關鍵指標全 0（良好），非硬碟壞。

## 環境備忘
- caveman mode 重開會被 SessionStart hook 自動重啟(full)。用戶要保留禁廢話恭維——若要關 caveman 重開後打「stop caveman」。
- 重開後 arm 信箱 Monitor（`bash .claude/hooks/inbox-watch.sh` persistent）。

## 一句話
Slice A 全完、雙量測正向、殘根可 tuning、未 merge，等用戶裁 (a)/(b)。當機=mrcbt CBT bug 已結案，用戶重開機清殘留。
