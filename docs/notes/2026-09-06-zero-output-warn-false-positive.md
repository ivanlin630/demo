# `zero-output-warn.sh` 對六個角色恆誤報

status: NOTE（非 owned doc）
from: 影子 blueprint session（不發信、不寫 memory、不消費信箱）
to: **藍圖** → systems
measured_at: 2026-09-06 / HEAD `0cde1198`
急迫性: **高** —— 這支是新上線的守衛，**現在對每個角色都會誤報**。誤報會讓大家學會忽略它。

---

## §1 症狀（我這回合實際收到的）

```
Stop hook：[零產出] 近 20 分鐘有 3 個 commit，但沒有任何新的 status:open 信。
```

**而我這回合一個 commit 都沒有**（本 session 只跑唯讀查詢；上次 commit 是 08-26）。

觸發它的那三筆是**別人**的：
```
0cde1198  14:45  mailbox: 標 consumed(⑩核心+ROI 前提錯)
d9786f17  14:45  mailbox: 認我那條 ROI 裁定建在未讀 code 上
07f6f352  14:45  ⑩spec 撤回 ROI 除零那一整段: 前提是錯的
```

---

## §2 根因：`--author` 分不出 session

```bash
zero-output-warn.sh:22
  c=$(git log --since="20 minutes ago" --author="$(git config user.name)" --oneline ...)
```

`git config user.name` ＝ **`ivanlin630`**。
**六個角色 session ＋ 影子 session，全部共用同一個 git 身分。**

⇒ `--author` 篩不掉任何人，它實際數的是 **全 repo 在 20 分鐘內的所有 commit**。

**結構性後果**：
> **只要任何一個角色在 20 分鐘內 commit，其他所有角色在回合結束時都會被警告「你做了事沒送出去」。**

而在這個專案，**20 分鐘內有 commit 幾乎是常態** ⇒ **接近恆真的警告**。

---

## §3 為什麼這比「少一道守衛」更糟

它命中了本專案自己立過的兩條：

**① 恆真式**（`05_acceptance` 有一整節）
> 判準存在，但沒接到任何會失敗的機制 ⇒ 它印的東西不帶資訊。

這支的反面：**它幾乎恆為真**，所以「有警告」不再代表「有問題」。

**② 誤報摧毀守衛自己的可信度**
一個天天喊狼的 Stop hook，**下一次真的零產出時沒有人會停下來看**。
⇒ 它不只沒幫上忙，還**吃掉了原本那條規則的執行力**。

★ 而這支守衛正是為了 `fb9f4687`（「after three failed handback deliveries」）那次斷鏈而建的。
**現在它會在真事故發生時被當成噪音跳過。**

---

## §4 修法：記事實，不要猜

`--author` 沒救（身分共用），`--committer` 也一樣。**不要再找篩選條件——改成記錄事實。**

```
PostToolUse(Bash)
  偵測到 `git commit` 成功 → 寫時戳到 .claude/hooks/.committed.<session_id>

Stop hook
  只讀 .committed.<自己的 session_id>：20 分鐘內有沒有本 session 的 commit
```

- `CLAUDE_CODE_SESSION_ID` **現成可用**（`inbox-watch.sh` / `watchdog.sh` 已經在用）
- **零猜測、零誤報**
- `.gitignore` 加 `.claude/hooks/.committed.*`

★ 這是同一條通則的又一次應用：
> **能重算的東西，永遠不要相信別人宣稱的版本；不能重算的，就把事實記下來，不要用代理訊號猜。**

---

## §5 順帶：同一批的另一個守衛也是空真

`bash-guard.sh` 護欄②（**兼職互斥**：起 Godot 前若有別人的 busy beacon 就提醒別起）——

**實測 2026-09-06：`.claude/hooks/.busy.*` 一個都沒有。**

而 beacon 是 measurer / implementer **手動寫**的兩行。**沒人在寫。**
⇒ 護欄②的母體恆空 ⇒ **永遠通過，從來沒防到任何東西。**

**當場證據**：同一時刻**兩支 Godot 同時在跑**（起跑時間差 65 秒，合計吃 32.5% CPU）。
而護欄②的註解自己寫著理由：
> 「長跑吃滿 CPU，兩個角色同時起 Godot 會**互相拖慢並污染 perf 量測**」

⇒ **它正在發生，而守衛沒響。**

**修法同一個形狀**：不要依賴人手寫 beacon —— **讓 `tools/godot.ps1` wrapper 自己蓋章**
（起跑寫 `.busy.<role>`、結束刪）。wrapper 是所有長跑的唯一入口，不依賴人記得。

---

## §6 兩支的共同形狀

| 守衛 | 它掃的母體 | 為什麼恆空／恆滿 |
|---|---|---|
| `zero-output-warn` | 全 repo 的 commit | `--author` 篩不掉任何人 ⇒ **恆滿** ⇒ 恆誤報 |
| `bash-guard` 護欄② | `.busy.*` beacon | 沒人手寫 ⇒ **恆空** ⇒ 恆通過 |

★ **一個恆報、一個恆不報，但同一個病**：
> **守衛的判斷依據，來自一個沒被驗證過會不會有內容的來源。**

⇒ 上線任何守衛前該問一句：**「這個母體在什麼情況下會是空的／會是全部？」**
（`05_acceptance` 的「指標必須可能失敗」是同一條，只是這裡要反過來也問「**必須可能不觸發**」。）

---

## §7 誠實邊界

- 我**沒有**改任何 hook（影子 session + 凍改令）。本篇只是回報。
- §4 的修法我**沒實作驗證過**，只確認 `CLAUDE_CODE_SESSION_ID` 在 Bash 環境可讀（`inbox-watch.sh` 已在用）。
- §5 的「沒人在寫 beacon」是**當下快照**（2026-09-06 14:5x）。不排除某些時段有人寫過。
