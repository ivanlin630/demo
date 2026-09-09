---
from: systems
to: implementer
status: consumed
slice: 三死鍵（計謀/統領/順從）
topic: ★序=①移速票之後（blueprint 裁）,不是現在做｜★★三條修法不同:(b) 統領可做、(a) 計謀 HOLD（我報給 blueprint 的前提是錯的,已撤回,等他重裁）、(c) 順從 BLOCKED（WHAT 缺口,正典 8 鍵沒有承載「服從性」的鍵）｜★★★接對鍵時 default 要跟著改 0.5→0.0（skills 的預設是 0.0,沿用 0.5 會把「沒技能的人」當成中等）
---

# 票：`docs/superpowers/specs/2026-09-09-three-dead-value-keys-HOW.md`

**序**：①移速票之後（`…-DISPATCH-plan-speed-from-real-move-cost.md`），原②材料去重之前。
**現在不要開始**——先把 greed-URGENT（`貧婪`）和 ① 做完。這封是讓你知道下一站是什麼。

## 一句話的病

`values.get("X")` 讀一個**全庫從來沒有人寫過**的 X ⇒ `Dictionary.get` 回 default
⇒ **那個量恆等於 0.5**，而程式照跑、註解照樣描述它的效果。
★比 `貧婪` 更難發現：**它從一開始就是錯的，沒有「之前是對的」可以 diff。**

## 三條的狀態不同，別一把抓

| | 位置 | 狀態 | 修法 |
|---|---|---|---|
| **(b) 統領** | `decision/terms.gd:192` | ★**可做** | 讀 `skills` 的 `統領`，★**default 改 `0.0`**；`ctx` 若沒有 skills，照 `decision_context.gd:581` 注入 `_loyalty` 的同一套做法注入 |
| **(a) 計謀** | `advisor_system.gd:25` | ★**HOLD** | 等 blueprint 重裁（見下） |
| **(c) 順從** | `resource_system.gd:526` | ★**BLOCKED** | 正典 8 鍵沒有承載「服從性」語意的鍵 ⇒ WHAT 缺口，已回 blueprint。★禁自造新鍵、禁硬塞語意不合的鍵 |

### (a) 為什麼 HOLD：★我報給 blueprint 的前提是錯的

我跟他說那是「違憲補丁閘、顧問系統那條路從來沒 fire 過、後面可能藏一整塊行為」。
**讀完整個檔之後不成立**：`_advisor_tone`（:24）只被 `_pick_variant` 的 `_:` default 分支呼叫（:53），
回的是**給 `TextBank.fmt` 的文案 variant 字串** ⇒ presentation，不是決策。
同函式另外三條（好戰/信義）讀真鍵、會 fire ⇒ 不可達的只有 `"sarcastic"` 一個語氣。

⇒ 他基於錯前提裁了「禁止把鍵接對讓 `>0.7` 開始 fire」。我已撤回並請他重裁：
`docs/superpowers/handbacks/2026-09-09-systems-to-blueprint-RETRACT-advisor-is-a-tone-picker-not-an-engine-gate.md`
**在他回覆之前不要動 (a)。**

## ★★★接對鍵時最容易漏的一格

`values` 的預設是 **0.5**，`skills` 的預設是 **0.0**。
把 `values.get("統領", 0.5)` 改成 `skills.get("統領", 0.5)` 是**另一個 bug**：
它會讓「完全沒有統領技能的人」被當成中等統領。⇒ **default 一起改成 `0.0`。**

## 驗收（blueprint 裁的，spec §3 有全文）

★接線前該量**恆 0.5** ⇒ 接線後**跨 agent 有變異**：dump 分布（min/median/max ＋ 幾個不同值），
**不是單點**——只印一個 agent 的值分不出「接上了」與「剛好那個人是 0.5」。

完後改本信 `status: consumed`。
