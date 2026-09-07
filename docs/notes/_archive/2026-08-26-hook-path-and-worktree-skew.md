# hook 相對路徑 → worktree 版本歪斜

status: NOTE（非 owned doc）
from: 影子 blueprint session（不發信、不寫 memory、不消費信箱）
to: **systems**（`.claude/settings.json` owner）
measured_at: 2026-08-26 / HEAD `e5b3c91f`
⚠ `settings.json` 屬工作流 ⇒ **凍改令範圍**。

---

## §1 症狀（用戶回報原文）

```
PostToolUse:Bash hook error
  Failed with non-blocking status code: bash: .claude/hooks/longrun-qa-gate.sh: No such file or directory
PreToolUse:Bash hook error
  Failed with non-blocking status code: bash: .claude/hooks/bash-guard.sh: No such file or directory
```

---

## §2 直接原因：`settings.json` 用相對路徑

```
.claude/settings.json 共 8 支 hook：
  :67  bash "$CLAUDE_PROJECT_DIR/.claude/hooks/implementer-cleanup.sh"   ← 絕對，正確
  其餘 7 支  bash .claude/hooks/xxx.sh                                    ← 相對，cwd 一離開 main 就斷
```

**為什麼只有那兩支噴**：`bash-guard`(PreToolUse) 與 `longrun-qa-gate`(PostToolUse) **每次 Bash 呼叫都跑**，
而 `session-role`(SessionStart) / `handback-inbox`(UserPromptSubmit) 在 cwd 還是 main 的時刻就跑完了。

**表面影響**：error 是 `non-blocking`，不會擋工作。
**實質影響**：那幾道護欄在該 session **完全沒作用**（`bash-guard` 的 `add -A` 警告、`longrun-qa-gate` 的 QA 硬規則全沒跑）。

---

## §3 ★真正嚴重的是這個：worktree 跑舊版 hook

worktree 的 `.claude/hooks/` 是 **checkout 當時那個 branch 上的快照**。實測：

| 位置 | hook 數 |
|---|---|
| main | **20** |
| `.claude/worktrees/feat+wire-in-specimen` | 20（同步） |
| `.claude/worktrees/feat+workshop-followthrough` | **14** |
| `.worktrees/threat-oracle-s2` ／ `weaponsmith` ／ `wtclean` | **無** |

`workshop-followthrough` **缺的 6 支**：
```
commitment-field-scan.sh   decision-entry-scan.sh   doc-line-cap.sh
dormant-module-scan.sh     test-ran-floor.sh        zero-output-warn.sh
```

★★ 而且它的 `inbox-watch.sh` 是**舊版** —— grep「換血 / 一律搶佔」**命中 0**。

⇒ **如果有 session 在那個 worktree 裡 arm inbox-watch，它跑的是「不讀 lock 歸屬、永不讓位」的舊版。**
**那正是 2026-08-25 跨代殭屍的製造機**（`fb9f4687`「after three failed handback deliveries」的來源）。

⚠ 也就是說：`#1 一律換血`（HOLD 批已做）**只修了 main 那一份**。worktree 裡的舊版沒被觸及，而它們**照樣能搶 lock**。

---

## §4 修法：一個檔，7 處

把 `settings.json` 其餘 7 支改成跟 `:67` 一樣：

```json
"command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/xxx.sh\""
```

**效果**：
1. cwd 在哪都能找到 → error 消失
2. ★**永遠跑 main repo 那一份** → **worktree 的舊版 hook 從此不會被執行**
3. ⇒ 版本歪斜這一整類問題被消滅在源頭，**不需要去同步每個 worktree**

---

## §5 剩餘風險（修完仍在）

`settings.json` 只管**hook 註冊**。**Monitor 是 agent 手動 arm 的**：
```
Monitor(command="bash .claude/hooks/inbox-watch.sh", ...)
```
⇒ 這條**也是相對路徑**，而且它寫在 `session-role.sh` 注入的文字裡。
**在 worktree 裡 arm ⇒ 仍會跑該 worktree 的舊版。**

⇒ 建議一併改：`session-role.sh` 注入的 arm 指令改成
```
Monitor(command="bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/inbox-watch.sh\"", ...)
```
（同理 `watchdog.sh`、Telegram poller。）

★ 否則 §4 只堵了一半 —— **hook 走絕對路徑，Monitor 還走相對**。

---

## §6 這是同一族的第 N 次

> **一份東西有兩個來源。**

| 案例 | 兩個來源 |
|---|---|
| 讀單 | `00_roles` 導覽表 vs `session-role.sh` CTX |
| 規則 vs 判例 | `invariants` 條文 與 血證同居 |
| 索引 vs 檔案 | `MEMORY.md` 索引行變成內容 |
| **本篇** | **main 的 hook vs worktree 的 hook 快照** |

差別在：前三個是**寫作問題**，這個是**執行問題** —— 它會真的跑到舊的那一份。

---

## §7 誠實邊界

- 我**沒有**確認 `workshop-followthrough` 目前有沒有活的 session 在跑。它只是**具備**跑舊版的條件。
- `.worktrees/*` 那三個沒有 `.claude/` 的，在裡面跑 Bash 會**全部 hook 失效**（不只那兩支）。
- 沒量過改成絕對路徑後有沒有別的副作用（例如某些 hook 是否依賴 cwd 做相對解析）。**動手前逐支確認一次。**
