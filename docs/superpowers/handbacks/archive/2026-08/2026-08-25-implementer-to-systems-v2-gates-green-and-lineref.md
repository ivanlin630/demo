---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
branch: feat/convoy-return-task-authority @ 8d27e3f0 (pushed)
topic: ★補第 4 個 entry 後閘全綠(headless 8=baseline/憲法 PASS/det×3 穩定);★你那條「母體元素定義不同」我要補正一半:另一半是【行號漂移】——跨輪引用行號本身不可靠,建議站點一律用語意錨;★兩張票的 merge 順序仍等你定
---

# v2 閘全綠 ＋ 一條補正

## §1 閘（補上第 4 個 entry 之後重跑）
| 閘 | 結果 |
|---|---|
| headless | **8 ＝ baseline，0-new** ✅ |
| 憲法 | **PASS**（`sites=74, removed=1`）✅ |
| det×3 | `c1e3f7c5db444fc06c6a826efa77b146` × 3，**穩定** |
| `commitment-field-scan` | **16/16 PASS** |
| `decision-entry-scan` | **4/4 PASS** |

★`det fp` 與 base 相同 —— 照你 `03b §④k`（a4 床對決策/仲裁層無覆蓋＝已知限制），
**我不為它寫解釋，生效與否一律用 §N 兩欄與覆蓋率判。**

## §2 ★補正你那條「母體元素定義不同」——**還有一半是行號漂移**

你說 `:5002`（你數的 `rank_*` 呼叫點）與我實作的 `:5019` 對不上，歸因於「母體元素定義不同」。
★**部分是，但另一半是【行號漂移】**：我在那之前往 `faction_ai_system.gd` 插了
`_detect_commitment_stall` 的函式定義（約 40 行）＋三個呼叫 ⇒ **後面的行號整體下移**。
⇒ **那兩個數字很可能指的是同一個地方。**

★**這反而讓你的通則更強**：**跨輪引用【裸行號】本身就不可靠。**
本 session 已被它咬過三次：
1. R² 驗窮盡宣告時說「**行號小漂移非實質錯**」
2. A1 的站點表（spec 寫的行號與實作時已不同）
3. 這次的 `:5002` vs `:5019`

⇒ ★**建議（我自己先照做）：報站點用【語意錨】而不是裸行號** ——
`函式名 + 呼叫的是哪支 API`（例：`_evaluate_survival → rank_survival`），
**行號只當輔助、不當識別**。
★**這與「掃描要靠語意關係不是文字位置」是同一條原則的另一個面向** ——
**位置會漂，關係不會。**

## §3 現況與相依（仍等你裁）
1. ★**merge 順序**：`construction_abandoned` 事件在**本 branch**、消費它的
   `FailureMemory.record(執行型)` 在**磚 branch** ⇒ **事件先進 main，磚的記錄側才接得到**。
   兩張都動 arbiter 附近。
2. **記錄側其餘站點的型別**：仲裁拒單你已裁「第四類、不入記憶」；
   **組隊失敗／路不通** 兩類**還沒裁**，我不自己歸。
3. **磚那邊的 A 面**（`outpost.l0_to_l1`）仍需**同一張床對 main 的 baseline** 才能讀
   —— 我沒自己跑（measurer busy beacon）。

## §4 我的鏈紀律修正（自承後的落實）
★**每個 commit 完成即發 handback，不在終端累積**。
上一次 1h+ 靜默是因為我只在自己終端回報 —— **對你而言等於沒發生**。這封是照新紀律發的。
