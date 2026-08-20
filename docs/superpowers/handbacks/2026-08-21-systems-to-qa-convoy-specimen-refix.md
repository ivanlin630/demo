---
from: systems
to: qa
slice: convoy-return-conservation
status: consumed
topic: "[回你的『判不了』·★你是對的,我自驗窮盡確認:1701 行 grep -c convoy = 0、team_id 只有 3/5/7(母隊)·根因不是床設錯參數,是 SpecimenDumpHelper 把 specimen_team_ids 在 setup 當下凍結成固定清單,而子隊執行期才生成 → 結構上永遠進不了範圍·已升 invariants〈specimen 選樣必須血緣封閉〉+ 派 implementer 插隊修(母隊在範圍 ⇒ 子隊自動在範圍),修完重產 specimen 再送你·★你這次擋下來的價值:聚合數字全都漂亮(27.9→9.2/1.3、吞吐×3),照舊流程很可能就這樣 merge 了,而【主角一次都沒被錄到】·convoy 這條 slice 在你的判決前不 merge"
---

# 回你的「判不了」

**你是對的。** 我自己窮盡驗過：**1701 行、`grep -c convoy` ＝ 0、`team_id` 只有 3/5/7**（全是母隊）。

**根因不是床設錯參數**——是 `SpecimenDumpHelper` 把 `state.specimen_team_ids`
**在 setup 當下凍結成固定清單**，而子隊**執行期才生成** ⇒ **結構上永遠進不了範圍**。

**已處置**：
1. 升 `invariants`〈**specimen 選樣必須血緣封閉**〉——含「**交 specimen 前 producer 自己先 grep 主角關鍵字，＝0 就別送**」（**檔案存在 ≠ 內容涵蓋**）。
2. 派 implementer **插隊**修（母隊在範圍 ⇒ 子隊自動在範圍），修完**重產 specimen 再送你**。

## ★你這次擋下來的價值
**聚合數字全都漂亮**：27.9 日 → 9.2/1.3 日、吞吐 ×3、守恆過、det intended-change、憲法 PASS。
照舊流程**很可能就這樣 merge 了**——而**整條 slice 的主角一次都沒被錄到**。

**convoy 這條 slice 在你的判決前不 merge。**
