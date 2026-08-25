**子 session**（`.worktrees/<feature>/`，`feat/<feature>` branch）：實作 plan。

## ★現況檔 ⏸已停更（開工/完工自更，01 監控用）
> **⏸ 停更中（O1，2026-08-21）**：本現況檔的**更新義務已停**——它宣稱是「即時狀態快照」，實際 `03_implementer` 停在 8/5（16 天）、`04_qa` 停在 8/14（7 天），而且已從快照長成 append log（02 已 153KB）。**★病根：它是「不會過期的手寫狀態」，所以爛了**——對照 `.busy.*` beacon 帶死線會自動過期，兩個方向的錯都不致命。
> **改用**：`bash .claude/hooks/peers.sh`（誰在線＝讀 lock 租約，**推導不手寫**）＋ watchdog v4 的 `open 信/長工作/commit` 分類。
> **處置**：先停更 → 觀察一週（**至 2026-08-28**）沒人 miss → 刪檔。**這段期間不要再寫入。**

> ★詳 → `detail/03_implementer-cases.md`

## 實作摘要
- 改了哪些檔案（每檔一行說明）
- 與 spec 的差異（若有）

## 連動風險
列出其他系統可能受影響的部分，收件方決定是否補修：
- `系統A`：說明為何可能受影響
- （無則寫「無已知連動風險」）

## 待確認
- 設計決策（實作中遇到 spec 未覆蓋的情況）
- 建議後續 task（發現的潛在問題或改進點）
```

> ★詳 → `detail/03_implementer-cases.md`

## ★每-task lifecycle（待命↔worktree，2026-07-09 用戶定）

implementer 是**主目錄 standby session**，per-task 進 worktree 做、做完回主目錄，**主目錄永遠停在 main**（防共用 dir 卡 feature branch 的事故）。


> ★詳 → `detail/03_implementer-cases.md`

## ★長工作 beacon（watchdog v4 用，2026-08-21 用戶定案）

長工作（長跑量測／大窗 bed／長編譯）**開跑前寫、跑完刪**：


> ★詳 → `detail/03_implementer-cases.md`

## ★裁定：`plans/` 停用，HOW spec 就是唯一產物（systems 裁 2026-08-21）

**背景**：blueprint 在 P9 工單裡把「`plans/` 空目錄＝plan 還欠不欠」交給 systems 前置定。


> ★詳 → `detail/03_implementer-cases.md`

## ★★「改測」的合法性判準（systems 立 2026-08-21，血證 ＝ 四端同秤刀）

**預設仍是：不准改測**（改測是把紅藏起來最便宜的方式）。**例外只有一種形狀**，三條**全部**成立才合法：


> ★詳 → `detail/03_implementer-cases.md`

## ★★★重構的「fp 不變」是等價證明，**不是執行證明**（2026-08-25）

**「改接線不改數值」的正確驗證形態 ＝ determinism fingerprint 不變。**★**這很強 —— 但它只證明一半。**


> ★詳 → `detail/03_implementer-cases.md`

## ★★★失敗處置有【兩個正交軸】：**會不會叫** vs **會不會停**（2026-08-25，我下錯指令的血證）

**我要求把 31 處 `[FAIL] print` 改成 `assert`，理由是「`assert` 至少會吐 `SCRIPT ERROR`」。**
★**那句話沒錯，但我從【會叫】推到【該用 assert】，漏了它還【會停】。**

> ★詳 → `detail/03_implementer-cases.md`
