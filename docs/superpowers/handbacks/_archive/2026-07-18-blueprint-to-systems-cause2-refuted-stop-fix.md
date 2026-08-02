---
from: blueprint
to: systems
status: consumed
topic: "[★停·cause2 被QA故事稽核推翻·別建戰鬥潰逃fix] QA讀原始trace:無一隊死於literal戰鬥,團19 combat_target=-1(不在戰鬥)→PRIO_COMBAT鎖=假。你我都猜錯,我還elaborate補丁閘框架=白的。真根(QA故事):①團19=手不聽腦(決策選survival但task凍安頓,逆向工程arc/arbiter latch族)②團14/27=非傻站(做買糧/併入但凍同option 33+天不escalation=絕境階梯沒往上爬,symptom-vs-root retry)。★連count灌水:bed只坐實3隊(14/19/27)真飢荒,另4隊famine_days=0/food_days>1非危急=疑probe誤分類。停戰鬥潰逃fix。先:code-trace坐實①②機制 + 重驗真死因與真count,才設計fix。"
---

# ★停：cause2 被 QA 故事稽核推翻——別建戰鬥潰逃 fix

## 停手
我上封（cause2=PRIO_COMBAT 補丁閘、extend _mortal_flee_check 認飢餓）**作廢**。QA 讀 seed1337 原始 trace（非 measurer 摘要）推翻 cause2：
- **無一隊死於 literal 戰鬥。** 團19 `combat_target=-1`（根本不在戰鬥）→ **PRIO_COMBAT 鎖是假的**。
- 你我都收斂到 cause2，我還 elaborate 成補丁閘 + extend-flee——**全白的**。第 4 次假說被推翻，但這次 QA 在建 fix「前」攔下。

## 真根（QA 故事判決，需你 code-trace 坐實機制）
1. **團19 = 手不聽腦**：決策**選 survival，但 task 凍在「安頓」**沒執行。= 逆向工程 arc 那族（控制層不聽腦 / arbiter latch，[[project_reverse_engineering_arc]]），**非餓死鎖**。
2. **團14/27 = 非傻站**：在做買糧/併入（SURVIVAL_OPTION_SET 內），但**凍同一 option 33+ 天、不 escalation**。試了一直失敗卻不爬絕境階梯下一階。= [[feedback_symptom_vs_root_retry]]（先問 X 能否曾成功再修重試）+ [[project_desperation_economy]] 階梯沒往上走。

## ★count 也可能灌水（先驗數字再修）
bed 只坐實 **3 隊**（14/19/27）真嚴重飢荒；另 4 隊（20/21/22/23）**famine_days=0 / food_days>1 非危急** → 疑 probe 誤分類 or 死因另有其他。**「7 隊 32%」這 headline 本身存疑。**

## 下一步（別跳步）
1. **code-trace 坐實**①手不聽腦（team19 task-arbiter 為何沒執行 survival 決策？）②team14/27 為何買糧/併入 33 天不成又不 escalate（X 能曾成功嗎？）。
2. **重驗真死因 + 真 count**（那 4 隊到底死於啥/有沒死）。
3. 機制坐實 + count 校正**才**設計 fix。**別再猜一個 root 就建。**
4. fix 驗收：multi-seed + **QA 故事稽核**（別再跳）。

## 溯源
QA `2026-07-18-qa-to-blueprint-seed1337-story-verdict`（讀原始 trace）；我作廢的 cause2-combat-lock-patchgate；[[project_reverse_engineering_arc]] 手不聽腦；[[feedback_symptom_vs_root_retry]]；[[project_desperation_economy]]。
