# 信箱輪詢燒 CPU：每秒 600 次檔案開啟，99.85% 是白費的

status: NOTE（非 owned doc）
from: 影子 blueprint session（不發信、不寫 memory、不消費信箱）
to: **藍圖** → systems
measured_at: 2026-09-06 / HEAD `5bf0b113`
關聯: 與 `5bf0b113`（守衛的母體問題）同一族 —— **機制存在，但沒有東西觸發它**。

---

## §1 症狀

`Antimalware Service Executable`（`MsMpEng.exe`，Windows Defender 即時防護）長時間佔用約 **30% CPU**。

旁證：跑 `du -sh .git docs scripts .worktrees` **兩分鐘 timeout** —— 檔案系統確實被拖慢。

---

## §2 算術

```
handbacks/*.md              1997 個檔
其中 status: open              3 封
inbox-watch 輪詢間隔          20 秒
同時 arm 的角色                6 個
```

`inbox-watch.sh` 每次輪詢用 awk 掃**整個資料夾**，六個角色各自獨立掃：

> **6 × 1997 ÷ 20 ≈ 每秒 600 次檔案開啟**

Defender 即時防護對每一次開啟都要檢查 ⇒ **那 30% 就是這樣來的**。

而且 **99.85% 是白費的**：1997 個檔裡只有 3 封是 `open`，其餘 1994 封都已 consumed、**永遠不會再被吐出來**。

---

## §3 根因：歸檔機制存在，但沒有東西觸發它

`.claude/hooks/handback-archive.sh` **存在**（2026-08-27，3287 bytes），政策也合理：

```
consumed 且不是今天的信 → docs/superpowers/handbacks/archive/YYYY-MM/
保留：open 的 + 今天的
（已知信箱有五種 status：consumed / open / superseded / superseded-by-qa / withdrawn，腳本都認）
```

它確實搬過東西 —— `_archive/` 裡有 **3305 封**。

**但它沒有被接到任何 hook 上。**
`settings.json` 註冊的 8 支是：`session-role` / `doc-line-cap` / `handback-inbox` / `layer-check` / `bash-guard` / `longrun-qa-gate` / `implementer-cleanup` / `zero-output-warn` —— **沒有它**。

⇒ 它是一支**要人手動去跑**的腳本。而 1997 封裡只有 3 封 open，代表**已經很久沒人跑了**。

---

## §4 同一族的第三個實例（前兩個當天就被修掉了）

| 機制 | 誰觸發 | 原本的結果 | 現況 |
|---|---|---|---|
| `bash-guard` 護欄②（兼職互斥） | 依賴 `.busy.*` beacon，**沒人手寫** | 母體恆空 ⇒ 永遠通過 | **✅ 已修 `fe441d56`**：`tools/godot.ps1` wrapper 自己蓋章 |
| `zero-output-warn` | 有接 hook，但 `--author` 篩不掉任何人 | 母體恆滿 ⇒ 恆誤報 | **✅ 已修 `fe441d56`**：新增 `commit-fact.sh`（PostToolUse）記 `.committed.<session_id>` |
| **`handback-archive.sh`** | **沒接 hook，沒人手跑** | **從沒執行 ⇒ 信箱無上限成長** | **⛔ 仍未接**（`fe441d56` 只加了 `commit-fact.sh`） |

★ 前兩個是 `5bf0b113` 講的「守衛的母體沒被驗證」，systems 當天就修掉了。
**剩下這一個更基本：連執行的時機都沒有定義。**

### ★ systems 在修的時候補了一件我漏掉的

beacon 現在**帶 PID**，並且「**PID 已死的 beacon 視為不存在**」。原文（`tools/godot.ps1`）：

> The beacon carries the PID because the OPPOSITE failure is just as bad: if this process is
> killed the cleanup never runs, the beacon leaks, and a permanently-stale beacon turns
> [the guard into a permanent block] … treat a beacon whose PID is dead as ABSENT.

我只想到「母體恆空 ⇒ 永遠通過」，**沒想到反方向：beacon 洩漏 ⇒ 母體恆滿 ⇒ 永遠擋**。
⇒ 一個守衛有**兩種**失效方向，補一邊的時候要同時問另一邊。
（這其實就是 `.busy` 當初設計的那條紀律——**手寫狀態只准存在於「會過期」的形式**——只是當時用死線過期，現在改用 PID 存活，更準。）

> **通則：建一個機制的時候，同時要回答「什麼時候會有東西去執行它」。**
> 答案是「有人記得的時候」＝ 等於沒有答案。

（同族還有 `docs/archive/resolved_issues.md` —— 管道在用（267 行），但 `known_issues.md` 裡仍有 124 行帶已解決標記沒搬。）

---

## §5 三個修法，由快到慢

### ② 先跑歸檔，並接上 hook ← **建議先做這個**

```bash
bash .claude/hooks/handback-archive.sh --dry-run   # 先看會搬多少
bash .claude/hooks/handback-archive.sh
```

1997 → 大概剩幾十封，**輪詢讀取量降 95% 以上**。

然後**接到 `SessionStart`**（或每日排程），不要再靠人記得 —— 否則三個月後同一份 note 要再寫一次。

**零風險、不需要權限、效果立即。**

### ① Defender 排除 `A:\GDS`（需系統管理員）

```powershell
Add-MpPreference -ExclusionPath "A:\GDS"
```

⚠ **安全性取捨**：該資料夾從此不受即時掃描保護。開發用 repo 通常可接受，**但這是用戶的決定**。

建議**先做 ②、量一次 CPU**，還高再考慮這條。

### ③ `inbox-watch` 別掃全資料夾（結構性）

現在每次 awk 全掃。改成先用 mtime 快篩（`find -newermt` 或比對上次輪詢時戳），**只對變動過的檔跑 awk**。

好處：即使信箱又長回幾千封也不會惡化。
⇒ ② 做了之後急迫性降低，可併進凍改令那批。

---

## §6 誠實邊界

- **我沒有實際看到 `MsMpEng` 的 CPU 數字** —— 我的 5 秒取樣沒抓到它（delta < 0.05），30% 是**用戶從工作管理員看到的**。§2 的算術是**因果推論**，不是直接量到「Defender 因為信箱輪詢而忙」。
  ⇒ **驗法**：跑完 ② 之後再量一次 Defender CPU。降了就坐實，沒降就是別的來源。
- `du -sh` timeout 只證明「檔案系統慢」，不單獨證明是 Defender 造成的。
- 我沒有跑 `--dry-run` 確認會搬多少（唯讀原則 + 那是別人的信箱）。
- 我是影子 session，**沒有動任何檔案或 hook**。
