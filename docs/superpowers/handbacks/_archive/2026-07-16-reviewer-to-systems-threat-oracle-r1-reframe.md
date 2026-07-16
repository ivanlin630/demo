---
from: reviewer
to: systems
status: consumed
topic: "[R①判決·reframe] threat oracle前提——第三種結局:混合(同need的2軸模式),非純各算非純同源。核心威脅感知(threat_react)確認只有ThreatAssessment.score一個函式、4個呼叫點皆讀同源、門檻面只1個base常數+人格衍生+用途margin(非3個獨立不一致門檻)。但發現一個真獨立公式:_should_attack有自己的strength-ratio評分,跟threat_react完全不同方向(攻擊發起判斷非被威脅感知)——不該被naive合併"
---

# R① factcheck 判決：threat oracle 前提（重排 Arc2）

verdict: **reframe（第三種結局：混合，同 need 的 2 軸模式）**
premise_contradiction: **部分成立**——「8處各算」與「3門檻不一致」兩條斷言皆被 refute，但「該收 oracle」不是全錯，是 scope 需訂正

## 逐條 refute-向 factcheck（★特別 skeptical，自己 grep+read，不採信稽核轉述）

### 1. 「threat 真 8 處各算 vs 同源 filtered」— **REFUTED 主體 + 發現一個真獨立分支（混合結局）**

`ThreatAssessment.score(state, self_team, other)`（`threat_assessment.gd:10-19`）是**唯一**核心威脅感知公式（`approach×1.0 + hostility×1.0 + (power_ratio−1.0)×0.5`）。全 codebase grep 確認**只有 4 個呼叫點**，全部直接呼叫這同一函式，非各自重寫：
- `faction_ai_system.gd:432`（`_has_active_threat` 迴圈內）
- `faction_ai_system.gd:457`（同函式第二處，同迴圈不同分支）
- `decision_context.gd:177`（ctx gather 計算 `threat_react`）
- `decision_context.gd:406`（ctx gather 另一處，需查是否重複計算同一件事——若是，這本身是**可收斂的真冗餘**，但仍是「同源」非「各算」）

其餘我在 `options.gd:116/163/166/169`、`decision_engine.gd:143`、`terms.gd:180`、`faction_ai_system.gd:397/401` 找到的十幾個「threat」相關 file:line，**全部是讀取已算好的 `ctx.threat_react`/`ctx.threat_threshold`**（decision_context gather 時算一次、存進 ctx，後面到處讀取複用），不是重新計算——這跟 roadmap「8處各算」的框架完全不符，是同源单次計算+多處消費，**同 Arc2 dispatch 那次「看似多路實則同池 filtered」的假象一樣**。

**但發現一個真正獨立的分支**：`_should_attack`（`interaction_system.gd:346-364`）計算自己的 `str_ratio = own_armed/def_est` + 自己的評分公式 `score = ambition×0.3+martial×0.3+greed×0.2+(str_ratio−1.0)×0.2−caution×0.5`——**完全不呼叫 `ThreatAssessment.score`，是獨立算式**。這不是巧合式重複，是**方向性不同**：`ThreatAssessment.score` 回答「對方對我而言有多危險（防禦/受威脅視角）」，`_should_attack` 回答「我該不該主動打對方（攻擊發起視角，我方相對強弱評估）」——**這正是 Arc1 need 案例裡「自用（保留向）vs 貿易（流出向）」同型的方向不對稱**，不該被 naive 合併成一個標量。

**精確結論**：不是「8處各算」，是「**4處同源（可能其中一處冗餘可收斂）+ 1處方向性獨立（不該合併）**」。

### 2. 「3 門檻不一致」— **REFUTED**

門檻面只找到 **1 個 base 常數**：`THREAT_BASE_THRESHOLD=0.3`（`threat_assessment.gd:6`）。其餘：
- `ctx.threat_threshold = THREAT_BASE_THRESHOLD + caution×0.3`（`decision_context.gd:170`）——**衍生自同一常數**，加人格修正，非另立門檻。
- `PREEMPT_MARGIN=2.0`（`faction_ai_system.gd:113`）——**不是另一個門檻，是疊加在 `threat_threshold` 之上的額外 margin**（`:401 ctx.threat_react < ctx.threat_threshold + PREEMPT_MARGIN`），服務「忙碌隊要更高門檻才值得打斷」這個明確不同的用途（註解 `:110-112` 說明白：「忙碌隊只有『壓境能傷你』威脅才打斷……天然實現『能傷你』語意」）。

**這不是「3個不一致門檻互相矛盾」，是「1個 base 常數 + 1個人格衍生版本 + 1個用途特化的疊加 margin」**——三者有明確的衍生/疊加關係，不是三套互不相關各自訂的數字。跟 Arc1 「食物 need 6 個閾各自訂」的情況不同——這裡沒有找到互相矛盾、無關聯的獨立門檻常數。

### 3. 「升 ThreatAssessment 全域 oracle 與現用衝突？」— **CONFIRMED 不衝突（但 oracle 化本身的必要性存疑）**

現有 4 個呼叫點全部是「直接呼叫 `ThreatAssessment.score`」或「讀 ctx 裡已算好的值」，沒有任何 caller 對這個函式的**輸出語意**做過會被破壞的特殊假設。升級/包裝成正式 oracle（如果指的是加一層查詢介面）不會破壞現有 caller。**但**——根據上面 1/2 的發現，**現況已經是單一函式+單一衍生門檻**，không有「發散的多套實作」需要收斂。若 threat oracle arc 的定位是「消滅各算亂象」，前提不成立（那個亂象不存在）；若定位是「把 `_should_attack` 的獨立攻擊發起判斷也接進來也用同一個 oracle 查詢」，那是**新增功能整合**而非「de-patch 收斂」，性質不同，需要 systems 明確 scope。

## 結論：reframe，非純 CLEAN 非純 premise_contradiction

依你列的三種可能結局，這次落在**第三種：混合**（同 Arc1 need 的 2 軸模式）：
- 「8處各算」「3門檻不一致」兩條核心斷言**被 refute**——核心威脅感知（threat_react）本來就是單一函式+單一衍生門檻，非發散亂象。
- 但**確實有一個真獨立分支**（`_should_attack`）方向性不同，若要收，性質是「新整合方向性不同的攻擊發起判斷」而非「消滅重複的威脅感知計算」。
- **建議**：threat oracle arc **大幅降級或重新定義 scope**——若 systems/blueprint 仍想做，spec 應誠實框成「① 確認 threat_react 側已統一（無需大改，可能只需收斂 `decision_context.gd:177`/`:406` 疑似冗餘的雙重計算，小工）② 評估要不要把 `_should_attack` 的攻擊發起判斷也接進統一 oracle（這是新整合工作，需藍圖裁定值不值得做，非 de-patch 補丁）」，不能照 roadmap 原始「8處各算+3門檻不一致」的框架寫 spec——那個框架已被本輪查證推翻。

## 下一站
回你（同 Arc1/Arc2 模式）——**這是第三次同款稽核前提被 R① 修正**（need 7→2軸、dispatch 三重→4同源filtered、threat 8→4同源+1獨立）。建議 blueprint 重新檢視這份「連三次」出狀況的靜態稽核本身的方法論，而非逐條個別修正——可能稽核產出時系統性高估了「分散度」。前提不支持照原框架寫 spec，需你/blueprint 重新定 scope 後才進 R②。
