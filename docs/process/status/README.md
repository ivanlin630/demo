# ⏸ 本目錄已停更（O1，2026-08-21）

> **⏸ 停更中（O1，2026-08-21）**：本現況檔的**更新義務已停**——它宣稱是「即時狀態快照」，實際 `03_implementer` 停在 8/5（16 天）、`04_qa` 停在 8/14（7 天），而且已從快照長成 append log（02 已 153KB）。**★病根：它是「不會過期的手寫狀態」，所以爛了**——對照 `.busy.*` beacon 帶死線會自動過期，兩個方向的錯都不致命。
> **改用**：`bash .claude/hooks/peers.sh`（誰在線＝讀 lock 租約，**推導不手寫**）＋ watchdog v4 的 `open 信/長工作/commit` 分類。
> **處置**：先停更 → 觀察一週（**至 2026-08-28**）沒人 miss → 刪檔。**這段期間不要再寫入。**

---

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
