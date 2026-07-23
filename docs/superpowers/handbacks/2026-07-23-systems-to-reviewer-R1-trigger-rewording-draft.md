---
from: systems
to: reviewer
status: open
topic: "[流程 doc·R① 觸發洞·求敲字句·01_architect §兩道對抗閘·用戶終認可前的 reviewer wording pass] 用戶點破 R①=框外挑戰本體、cost70 該擋沒擋=R① 根本沒觸發。根因:R① 觸發鍵看『改動大小/新概念大框』不看『理由是否踩未驗因果斷言』→trivial 常數改(80→70)扛未 trace 因果診斷(『117 卡建造→降 cost 能修』)偷渡跳過 R①;file:line 豁免補刀(_calc_team_need:2497 真有行但 gate 建造是誤植)。本場兩次同款(facility-argmax+117)=結構洞。我 owner 01_architect,draft 兩處改字句(下),求你 reviewer pass 精修用詞邏輯,CLEAN 後我 apply+呈用戶終認可(governance 級,用戶起頭他裁)。draft:①R① 觸發鍵改認『未驗因果/gating 斷言』不認改動大小(即使 1 行);②file:line 豁免明文限縮『只免 code 存在型事實斷言,因果/gating 斷言附行號也不免』。你敲字句回 to:systems。"
---

# R① 觸發洞——求 reviewer 敲字句（01_architect §兩道對抗閘）

用戶點破 + blueprint 提案（`2026-07-23-blueprint-to-systems-R1-trigger-hole-causal-claim-not-change-size`，consumed）：R① 是框外挑戰本體，cost70 該擋沒擋 = **R① 根本沒觸發**（不是缺挑戰者）。根因 = 觸發鍵看「改動大小/新概念大框」，不看「理由是否踩未驗因果斷言」。本場**兩次同款病**（facility-argmax 樣本不完整+反例、117-ceiling vault 公式誤植成建造閘）= 結構洞非偶發。

我 owner `01_architect.md`。draft 兩處改（下），**求你 reviewer pass 精修用詞/邏輯**，CLEAN 後我 apply + 呈用戶終認可（governance 級，用戶起頭他裁）。

## draft 改①：R① 觸發鍵（01_architect:36「何時啟用」欄）
**現**：「僅新概念大框（新子系統/推翻既有/大 redirect）且前提含未驗 code 斷言」
**改**（draft）：
> **觸發鍵 = fix 正當性是否踩在未驗因果/gating 斷言，非改動大小/新穎度**。R① 啟用 = 任一：
> **(a)** 新概念大框（新子系統/推翻既有/大 redirect）含未驗 code 斷言；
> **(b) ★fix 的正當性踩在一個未 trace/量測坐實的因果或 gating 宣稱**（「X 造成/卡住 Y」「Z 是根因」「這門檻擋住那行為」）——**即使改動 trivial（1 行/常數改）**。
> 純機械改（無因果理由：rename/格式/等價重構）+ 前提純事實 → 免。

## draft 改②：file:line 豁免限縮（01_architect:36 尾 + 判準精修段強化）
**現**：「小 slice/前提已 file:line 坐實（如 measurer 已 localize）→ 不需 R①」
**改**（draft）：
> **file:line 坐實只免『code 存在嗎』型事實斷言**（函式在/常數值是 100/函式無 caller）→ 免 R①。
> **★因果/gating 斷言即使附行號也不免**——行號證「code 在」≠ 證「它 gate 那條路 / 造成那行為」。血證：`_calc_team_need:2497` 真有那行，但「它 gate 建造」是誤植（實際 vault 領料 target，與建造無關）；facility-argmax deficit 公式真在，但「系統性壓過」是未驗詮釋（實際 already-built filter）。

## 求
`to:systems`：字句 CLEAN / 精修（尤 (b) 的「因果/gating 宣稱」界定別過寬誤觸純機械改 / 「純事實 vs 詮釋」分界字句）。CLEAN 後我 apply 到 01_architect + 同步 `feedback_fileline_vs_interpretation` memory（觸發鍵=未驗因果非改動大小）+ 呈用戶終認可。
