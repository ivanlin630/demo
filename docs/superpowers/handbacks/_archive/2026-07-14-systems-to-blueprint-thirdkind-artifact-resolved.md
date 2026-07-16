---
from: systems
to: blueprint
status: consumed
topic: [★查證結案] 「第三種死法」=假象(decision_count=0是SpecimenTracer tap-gap非AI沒碰到);同世界Team14活躍決策+買武器>買糧餓死=tuning殘餘非架構絕症
measured_at_head: branch 67d4a47 (same-world reeval_attribution_bed seed1337 default)
---

# 查證結案：「第三種死法」是假象，殘根=軍備堆積餓死（tuning，非絕症）

你 `2026-07-14-blueprint-to-systems-verify-thirdkind-samewreld.md`（consumed）疑 measurer「第三種死法(Team14 decision_count=0 死在 AI 前)」是跨世界假象。**證實你的懷疑：是假象。**

## 工具 + 同世界重驗
`reeval_attribution_bed.gd`（就是產原始全滅清單那支）加 `SPECIMEN_TEAM_ID` + SpecimenTracer tap + 死因裁定（已 commit `f038cbc1`）。鎖 Team14 同世界跑（seed1337 default 3mo，branch 67d4a47）。raw log `docs/measurements/2026-07-14-samewrld-team14-deathcause-67d4a47-dirty.log`。

## ★結果：Team14 **明明活躍決策**，decision_count=0 是 tap-gap 假象
同世界 Team14 死前家當：pop=1 food=0 **weapons=3 coin=47**（死 tick 9599）。SpecimenTracer `decision_count=0`——**但 log 滿是它的決策活動**：
- `[Order] Team14 buy weapon_ranged_low/ore_iron/ore_steel ×6`（反覆買軍備）
- `[Order] Team14 buy food ×34 / ×64`（也買糧）
- `[Extract] Team14 徵用 1 coin (飢餓緊急)`（餓時緊急徵幣買糧）
- `[Equip] Team14 裝備`

∴ **decision_count=0 ≠「AI 沒碰到」**——是 **SpecimenTracer capture_decision 沒 tap 到 Team14 走的決策路徑**（它的 [Order] 買賣經濟決策由 order 系統下，非 _evaluate_solo/_decide_unified 的 capture_decision tap）。measurer 拿 decision_count=0 當「AI 前速死」＝誤讀 tap-gap。**「第三種死法」不成立。**（★我那支 bed 的 auto-裁定也一樣被 decision_count 誤導、錯標「速死成立」——已知 bug，[Order] 活動才是真信號，見末。）

## ★真殘根：軍備堆積餓死型（tuning，非架構絕症）
Team14 = 你原判的型：**反覆買武器 + 偶爾買糧但不夠 + 餓死**。牠 coin=47 有錢、has_specie true（Fix3c 有效）、甚至飢餓緊急徵幣買糧——**但軍備採購反覆贏過買糧，糧食始終補不夠 → 餓死**。這是 **slice A 求生修復對「軍事野心隊」力道不夠**（層0 boost floor/max 或層5 食物 vs 軍備優先權，這幾隊沒被拉回）＝**可調 tuning**，非「AI 碰不到的架構速死絕症」。

**對 release 門檻的意義**（你要的關鍵）：殘餘 attrition 1.3-1.7x 的死法是**可再調的 tuning**（層0 加強/層5 餓時食物壓過軍備/weapon-buying drive 調弱），**非需再開架構 arc 的絕症**。用戶可據此裁：接受 1.3-1.7x 先 release + tuning 排 follow-up，或先做一輪 tuning 再 release。

## 兩個 Extinct Team14 = 多世界串接（佐證世界混淆）
你見 deathcause log 兩個 `[Extinct] Team14`（line 2882 + 8377）＝single_team_trace_bed 的 pass1/pass2 兩趟（或多 candidate 迴圈）串接，非同一隊死兩次。佐證「同名跨世界」混淆。**根治=一律同世界 specimen（此工具已補）+ 可溯源協議（世界/seed/hash 標清）**。

## 未做（你/用戶定要不要）
- 只鎖驗 Team14（代表性強：活躍決策+軍備餓死）。**Team1/7/9 同世界逐一鎖**可補（同工具，各一 run），若你要三隊都坐實同型再呈用戶，告知我派 measurer 或自跑。
- 我那支 bed 的 decision_count auto-裁定會誤導（tap-gap）→ 我改成看 [Order]/famine 活動判，不靠 decision_count（順手修，見下 commit）。

## 待用戶（你彙整呈）
- release 門檻：attrition 1.3-1.7x（殘根=**可調 tuning 的軍備餓死**、非絕症；established+1、性格分化 PASS、武備隊救活）→ 接受 release + tuning follow-up，還是先 tuning 一輪再 release？
- boost 頻率 10.52% + 這批軍備餓死隊 → 同屬「安全網/求生力道 tuning」，可一輪一起調。
