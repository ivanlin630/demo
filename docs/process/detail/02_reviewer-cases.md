# 02_reviewer 的血證與原文（按需讀，不在開場必讀區）


## 2026-10-07 瘦身搬入：02_reviewer.md 長行全文（必讀檔留一行，原文逐字在此）

### rev-status-stopped

（原 02_reviewer.md:10）

> **⏸ 停更中（O1，2026-08-21）**：本現況檔的**更新義務已停**——它宣稱是「即時狀態快照」，實際 `03_implementer` 停在 8/5（16 天）、`04_qa` 停在 8/14（7 天），而且已從快照長成 append log（02 已 153KB）。**★病根：它是「不會過期的手寫狀態」，所以爛了**——對照 `.busy.*` beacon 帶死線會自動過期，兩個方向的錯都不致命。

### rev-status-dont-write

（原 02_reviewer.md:14）

> ★**現況檔 `docs/process/status/*` 已停更，★★【不要再寫入】**（O1，2026-08-21）——**誰在線一律讀 `bash .claude/hooks/peers.sh`**（讀 lock 租約、**推導不手寫**）。★★★systems 2026-09-22：這一行原本還在命令你去更新那些檔 —— **停更宣告寫在別的文件裡，而這裡的指令沒拿掉** ⇒ 審查員 9/02、9/17 各寫了一次，**他是照著這一行做的**。

### rev-mailbox

（原 02_reviewer.md:17）

開場**不掛 inbox watcher**（★2026-09-23 用戶裁第二版：watcher 整個退役，寄件端會用 `SendMessage` 敲你）。開場只做一件事：`ListAgents` 看自己的 session 名 → `SESSION_ROLE=reviewer bash .claude/hooks/whoami.sh demo-XX` 登記通訊錄（★沒登記＝別人敲不到你）。收 `to:reviewer status:open` 信→讀+判。**出判決 handback（`to:systems status:open`）＋★立刻 SendMessage 敲 systems（ADDR 查 `peers.sh`）——★寄件一律 open,絕不自寫 consumed**（consumed 是收件端讀後回執;寄件自寫=對方只掃 open→靜默漏看）。讀完別人給你的信才把那封改 consumed。詳 `07_mailbox_trigger §status 所有權`。

### rev-redundant-solver

（原 02_reviewer.md:34）

2. **★框架內冗餘求解器**（更隱蔽）：新增 option/term/solver **跟既有某個做重疊的事**嗎？兩路 applicable 域重疊 + 結果殊途同歸（血證：join vs 整併 都走 `merge_teams` 全併、搶同絕境 niche → 整併 marginal 2.5%；用戶抓非 reviewer）→ refute，要求**收斂為一**（一決策 + 參數分流），非並存。

### rev-negative-assertion

（原 02_reviewer.md:58）

- **★負斷言協議**：任何「**X 不存在 / X-only / 從不 fire / 零 caller**」型斷言 **必附窮盡搜索證據**（搜詞 + 範圍、no-head/no-glob-限制、exhaustive）。無證據的負斷言=`premise_contradiction` 級 refute。（血證：systems「capture=encounter-only」grep 過 set_owner 看到 takeover 反證卻沒整合、用戶記憶抓第 6 次；`reference_measurement_protocol` grep-glob/head-截斷家族）。

### rev-retired-citation

（原 02_reviewer.md:59）

- **★引用退休協議**（2026-08-26 立，血證：「已標（史）」的 `k≈2.1` 仍被轉述成「真 N² 嫌」差點決定一整條 arc 刀法）：前提引用 `docs/known_issues.md`（或任何持久狀態文件）的具體數字/結論時，雙軌查：①快速通道 `grep -n '⛔RETRACTED' <檔案>`；②沒被①抓到≠沒被推翻，往下掃幾行看有沒有「已訂正/推翻/削弱/誠實 NULL」+ 日期是否明顯早於引用者聲稱的「現況」。標記括號（如「（史）」）**不算**已退休——讀者眼睛會跳過。

