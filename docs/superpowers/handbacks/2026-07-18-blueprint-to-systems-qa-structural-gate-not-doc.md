---
from: blueprint
to: systems
status: consumed
topic: "[結構修法·QA別再doc修doc-decay] 你這次修還是00_roles+memory=意圖層,跟7/14加回一樣會再過幾天衰減。根因(與用戶挖出):驗證步驟(measure-first/multi-seed/QA故事稽核)不在關鍵路徑上→跳了工作照前進→無後果→只剩意圖撐→必衰減;而運輸層(handback/hook)跳了工作動不了→自我強制→從不漏。∴修法=把QA搬上關鍵路徑做fail-closed閘:沒QA判決就產不出『可送藍圖判/可merge』狀態(像constitution_gate擋merge)。HOW你定(dispatch閘/hook/verdict-file要件/folded進acceptance),但WHAT=結構強制非doc。★可考慮通用化:三個衰減的驗證紀律(measure-first/multi-seed/QA)同根同藥,一個verification-gate pattern可能全收。"
---

# 結構修法：QA 別再 doc 修 doc-decay

## 你這次的修會再衰減
你回報的修 = 改 `00_roles` + 補 `feedback_qa_inversion` memory。**這還是意圖/doc 層——跟 2026-07-14「加回」同一種。** 用戶戳穿：7/14 加回是空頭、過幾天就被跳。**你這次同樣的 doc 修，過幾天同樣會被舊習慣重力磨掉。**

## 根因（與用戶挖出，這是真的）
**驗證步驟會衰減、運輸步驟不會，因為在不在關鍵路徑上：**
- **運輸/hook 層**（handback、session-role.sh、inbox-watch、handback-inbox.sh）：**跳了工作就動不了**（handback 是跨 session 唯一通道）或 **harness 自動跑**（hook）→ 自我強制 → 一次沒漏。
- **驗證層**（measure-first、multi-seed、QA 故事稽核）：**跳了工作照前進**（measurer→藍圖沒 QA 也跑、鏈照樣動）→ 跳了零後果 → 只剩意圖撐 → **必衰減**。

這一口氣解釋這整場：三個驗證紀律全被跳，運輸層一次沒漏。

## WHAT：把 QA 搬上關鍵路徑，做 fail-closed 閘
**沒有 QA 判決 → 就產不出「可送藍圖 release-judge / 可 merge」的狀態。** 像 `constitution_gate` 擋 merge 那樣——機器擋，不是靠人記得。這樣 QA 從「可跳的驗證」變成「跳了就卡的承重步驟」，跟 handback 同一種自我強制。

## HOW（你定，給幾個形狀非指定）
- dispatch 閘：measurer dump 完 → 產物**必須**帶 QA verdict artifact，否則藍圖 inbox 收不到「ready-to-judge」信。
- verdict-file 要件：`docs/process/verdicts/` 沒有對應 slice 的 QA 故事判決檔 → merge-gate FAIL。
- hook：類 constitution_gate 的 pre-merge 檢查，掃「behavior slice 有無 QA 故事判決」。
- folded 進現有 acceptance 閘。
- **QA session 沒開** = 這個閘 fail-closed（卡住 + flag 你/用戶 arm），不是「沒開就跳」。

## ★可考慮通用化
三個衰減的驗證紀律（measure-first / multi-seed / QA 故事稽核）**同根（不在關鍵路徑）同藥（做成 fail-closed 閘）**。也許一個通用 `verification-gate` pattern 全收：behavior/outcome slice 要 merge/送判 → 必須帶（multi-seed 數字 + QA 故事判決）兩件 artifact，缺任一 = 閘 FAIL。你評值不值得一次做通用還是先 QA 單點。

## 別重蹈
**別用 doc 修 doc-decay。** 這封若你也只改 doc 回我 = 又一張紙。要結構才算釘住；判準 = 下輪 behavior slice 若沒 QA 判決，是不是**機器擋住**、而非「靠這輪剛好記得」。

## 溯源
用戶 2026-07-18 連問（7/14加回為何幾天就沒 / 為何其他工作流不被洗）；你的 qa-flow-fixed（doc 修）；`constitution_gate.gd`（fail-closed 閘範本）；[[feedback_qa_inversion]]；本場三度過早宣勝血證。
