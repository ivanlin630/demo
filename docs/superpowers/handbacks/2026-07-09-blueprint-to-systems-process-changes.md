---
from: blueprint
to: systems
status: open
topic: 現狀交接給01——process docs全改+memory單寫者=你,接手工作流本體+待決
---

# 給 01（systems）：本 session 改的 process + 你要接手的

> 兩軌切回多終端後 **auto-memory 單寫者 = 系統（你）**。本 session 是無 role 遺留 session（de-facto 藍圖），已直寫了不少 memory + process doc；這封讓你接手 owner。先 `arm 信箱待命`。

## process docs 全改（都 committed main，你是 owner，過目）
- `00_roles.md`：五角色→**含量測員**；auto-memory 單寫者=系統；裁決 marker `[DONE]/[REDO]`；/clear·/compact 重觸 SessionStart 事實；流程文件地圖 + 多終端偏好。
- `03_implementer.md`：per-task lifecycle（standby↔worktree、hold warm、handback X-to-Y 寫 main mailbox 絕對路徑）。
- `03b_measurer.md`（**新**）：量測員職責正典（maker 產數字≠QA；產齊 spec §驗收法守衛別推 QA；GODOT_TIMEOUT=600；--path 留 main dir）。
- `04_qa.md`：QA 不 checkout（讀 diff/show）。
- `07_mailbox_trigger.md`：統一 mailbox（實體資料夾/branch 無關）+ 6 角色。
- `08_machine_workflow_v2.md`：`--from-impl` 下游軌 + 量測員正名。
- `CLAUDE.md`：切回多終端主軌。

## hooks（本地 .claude/，gitignored，單機）
- `session-role.sh`（+measurer/implementer role、arm 名單、指 main mailbox）
- `inbox-watch.sh`（Monitor，指 main mailbox，emit-once）
- `handback-inbox.sh`（UserPromptSubmit 掃）
- `implementer-cleanup.sh`（**新** Stop-hook：implementer 收 `[DONE]` 逼收尾）
- 全域 `~/.claude/statusline-command.ps1`（角色徽章補 measurer）

## LG 機器（tools/orchestrator）改
- `--from-impl` 下游軌（implementer→measure→qa→②→merge）；`make_impl_graph`/`pipeline_impl`。
- measure node 補 `GODOT_TIMEOUT=600`（防 A2a 假 timeout）；`ROLE_DOC[measurer]`→03b。

## memory 現況（你接手單寫）
- [[feedback_mailbox_trigger]]：整套多終端工作流（統一 mailbox/6角色/lifecycle/事故/haiku約束/封存）——最全。
- [[project_reverse_engineering_arc]]：A2b 設計態（#1湧現自秤 done、A2b spec+plan done pending impl→現 core done pending 守衛量測）。
- [[project_orchestrator_machine]]：機器 + A2a 誤判翻案。
- [[reference_hob_perf_protocol]]：HOB perf 協議。

## 待你/藍圖裁
- ctx 汙染三角（零鍵入/warm/零汙染三選二）——現狀 warm+零鍵入，觀察後定。
- `[DONE]/[REDO]` 裁決信誰寫：01/② 判完寫 `to:implementer`（downstream 走 LG 時 ②判後 LG 寫回 terminal）。

重開：`$env:SESSION_ROLE='systems'; claude` → `arm 信箱待命`。
