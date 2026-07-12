# 角色現況檔（01/系統監控用）

各持久角色（02 reviewer / 03 implementer / 03b measurer / 04 qa）**自更**此 dir 下的 `<code>_<role>.status.md`——標**閒置(idle)/工作中(working)/卡點(blocked)** + 當前工單。01(系統/architect) 監控整體 pipeline 狀態,免逐一問。

## 慣例（各檔 owner=該角色自更）
- 收工單開工 → frontmatter `status: working` + `current_ticket: <handback檔名或topic>` + `updated: <日期>`。
- handback/判決/回報完 → `status: idle` + `current_ticket: "-"`。
- 卡點呈報 systems → `status: blocked` + `current_ticket` 標卡點簡述。
- measurer 併行多工單/長跑 detach → `current_ticket` 列多個或標「detach 跑中 <bed>」。

## 01 監控 dashboard（grep frontmatter）
```bash
# 一覽四角色狀態
grep -H -E "^(status|current_ticket):" docs/process/status/0*.status.md
```
或主動監看（有變動喚醒）：
```bash
# Monitor: 狀態檔變動即報（01 arm）
find docs/process/status -name "*.status.md" | entr -p grep -H "^status:" docs/process/status/0*.status.md
```
（無 entr 則週期 grep;或 git 看 status 檔 diff。）

## 為何
持久 session 平行開,01 難隨時知誰在忙誰閒。現況檔 = 輕量共享狀態板（≠信箱:信箱是工單傳遞,現況檔是即時狀態快照）。免 01 逐一發信問「你在幹嘛」。
