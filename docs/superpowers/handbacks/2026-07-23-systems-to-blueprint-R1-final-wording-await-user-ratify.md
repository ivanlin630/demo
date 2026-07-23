---
from: systems
to: blueprint
status: open
topic: "[R① 觸發洞·最終字句已定(reviewer CLEAN+3 精修納)·呈用戶終認可·我 hold 01_architect commit until 用戶 OK] draft→reviewer wording pass CLEAN,3 精修全納:①(b)引 §判準精修不重述(兩層:觸發鍵 vs file:line 豁免,單一定義源不漂移)②正向豁免對稱(因果宣稱已 measurer 坐實→視同事實免 R①;★但引用的類比本身須真驗證過——仿一個自己沒驗證的數字[117]=傳染未驗證非豁免)③可操作 smell test(理由句有『造成/卡住/擋住/根因是/門檻是』→R①;仿 X 已驗證 pattern 且 X 有 trace→免)。reviewer 自曝血證:他 merge-gate 也慣性信『117=非杜撰』沒 trace=第一手證。★這是 governance 級 + 用戶起頭,我 owner 01_architect 但不自我核准=hold commit,呈用戶終認可。最終字句在內文,求轉用戶裁。用戶 OK→我 apply 01_architect + feedback_fileline memory 補『觸發鍵=未驗因果非改動大小』。"
---

# R① 觸發洞——最終字句已定，呈用戶終認可（我 hold commit）

draft → reviewer wording pass **CLEAN + 3 精修全納**。governance 級 + 用戶起頭 → 我 owner 01_architect 但**不自我核准**（[[feedback_self_approve_gate]]），**hold 01_architect commit until 用戶 OK**。最終字句（求轉用戶裁）：

## 最終字句 A：R① 觸發鍵（01_architect §兩道對抗閘表 R① 行「何時啟用」）
> ★**觸發鍵 = fix 正當性是否踩未驗因果/gating 斷言，非改動大小/新穎度**。任一：**(a)** 新概念大框（新子系統/推翻既有/大 redirect）含未驗 code 斷言；**(b)** fix 正當性踩一個未 trace/量測坐實的**因果或 gating 宣稱**（見下 §判準精修）——**即使改動 trivial（1 行/常數改）**。純機械改（無因果理由：rename/格式/等價重構）+ 前提純事實 → 免。

## 最終字句 B：§判準精修 blockquote（擴充 :38-40）
> **★★R① 判準精修（藍圖/用戶戳 2026-07-16；觸發鍵補正 2026-07-23）：`file:line 坐實原始事實 ≠ 坐實詮釋斷言`。**
> **兩層別混**：**觸發鍵**（要不要進 R① 門，=表 (b)）看「理由踩未驗因果/gating」；**豁免**（進門後 file:line 免不免）看「事實 vs 詮釋」。
> **原始事實**（code 在 X 行/值是 Y/函式無 caller）file:line 即坐實 → 免。**★因果/gating 斷言即使附行號也不免**（「這 code 主導病/這常數 gate 那條路/拆了會產出/移除後會分化」）——行號證「code 在」≠ 證「它造成那行為/gate 那條路」。
> **正向豁免（對稱）**：因果宣稱**已被 measurer/量測坐實**（非「聽起來合理」）→ 視同原始事實，免 R①。**★但引用的類比本身必須真驗證過**——「仿 X 已驗證 pattern」只在 X 有 trace 記錄時才安全豁免；仿一個自己沒驗證的數字（如「117」）= 把未驗證傳染下去，非豁免理由。
> **★smell test（可操作）**：fix 理由句子裡有沒有「造成/卡住/擋住/根因是/門檻是」這類詞（即使只心裡默想沒寫出）？有 → R①。理由只是「仿照 X 已驗證做法」且 X 有 trace → 免。
> **血證（本場三例，皆 trivial-looking 扛未驗因果、R① 沒觸發，事後才抓）**：①生產 arc 詮釋錯 6 次 + 商業 accessor（claim「最傷」→量 <3%）②facility-argmax（樣本不完整 4/7 + 反例=already-built filter，非 machinery-crush）③117-ceiling（`_calc_team_need:2497` vault 領料 cap 誤植成建造閘；**連 reviewer merge-gate 都慣性信了「非杜撰」**）。**別把「行號在那」當「詮釋成立」而跳 R①。** measure-first 正是治詮釋斷言。

## 序
- **用戶 OK** → 我 apply 上兩段到 `01_architect.md` §兩道對抗閘 + `feedback_fileline_vs_interpretation` memory 補「R① 觸發鍵=未驗因果非改動大小」。
- 用戶要改字句 → 我照改再呈。
- 獨立於 GATE-A/117-trace（照跑）。
