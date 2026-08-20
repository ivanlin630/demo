---
from: systems
to: implementer
slice: specimen-lineage-scope
tier: probe
status: open
topic: "[派工·★插隊到 failure-feedback 前面(小、且卡住 convoy 那條 slice 的 QA 站)·specimen 選樣血緣封閉修·根因已定位:SpecimenDumpHelper.setup_from_env 把 state.specimen_team_ids 在 setup 當下【凍結成固定清單】,而 porter 子隊是 SubteamSystem.dispatch 執行期才生成的新 team_id → 永遠進不了範圍;實證 convoy specimen 1701 行裡 convoy 出現 0 次、只有母隊 3/5/7,整條 slice 的主角自始至終沒被錄到·改法(我傾向 a,你可反對):在 trace 判定處改成【母隊在範圍內 → 其子隊自動在範圍內】(往上走 parent_team_id 鏈),不必在 spawn 點註冊;★硬要求:純觀測、零行為改動、禁耗 global RNG、det×3 byte-identical 必須不變·驗收=拿 convoy 那床重跑一次,grep -c convoy specimen > 0 且能看到 porter 的 motive→action→outcome·做完直接回我,我再放 measurer 重產 specimen 給 QA"
---

# 派工：specimen 選樣血緣封閉（★插隊）

## ★排序變更
**這張插到 `failure-feedback` 前面。** 理由：**小**，而且**卡住 convoy 那條 slice 的 QA 站**（QA 已回「判不了」）。
做完這張再回去做 failure-feedback。

## 根因（已定位，不用再查）
`SpecimenDumpHelper.setup_from_env`（`scripts/debug/specimen_dump_helper.gd`）把
`state.specimen_team_ids` **在 setup 當下凍結成固定清單**；
porter 子隊是 **`SubteamSystem.dispatch` 執行期才生成的新 `team_id`** ⇒ **永遠不可能進範圍**。

**實證**：convoy specimen **1701 行**、`grep -c convoy` ＝ **0**、只有母隊 `3/5/7`。
**整條 slice 的主角自始至終沒被錄到** —— 聚合數字全有，故事層完全空白。

## 改法（我傾向 (a)，你有更好的可以反對，說理由）
- **(a)** 在 **trace 判定處**改成：**母隊在範圍內 → 其子隊自動在範圍內**（往上走 `parent_team_id` 鏈）。
  不必在 spawn 點註冊，也不怕漏掉任何生成路徑。
- (b) 在 `SubteamSystem.dispatch` 生成時註冊——**我不偏好**：那是「**在每個 spawn 點記得註冊**」的紀律型解，
  跟本 session 已經栽三次的同一族（枚舉會過期）同形。

## ★硬要求
- **純觀測、零行為改動**；**禁耗 global RNG**（觀測不得改變被觀測物——這條已栽過三次）。
- **det×3 byte-identical 必須不變**（若變了就是你動到世界，不是動到觀測）。

## 驗收
拿 convoy 那床重跑一次：**`grep -c convoy <specimen>` > 0**，且**看得到 porter 的 motive → action → outcome**。
★ **交 specimen 前自己先跑這條 grep**——**檔案存在 ≠ 內容涵蓋**（新入 `invariants`）。

做完直接回我，我再放 measurer 重產 specimen 給 QA。
