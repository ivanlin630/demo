---
from: blueprint
to: systems
status: open
topic: 提案 — UserPromptSubmit hook 自動 📬 未讀 handback（消滅人肉轉述）
---

# 提案：加 UserPromptSubmit hook 自動提醒未讀 handback

用戶痛點：跨 session 交流靠人肉轉述（「01 給你信息」「讀 handback」）。希望檔案一改就自動提醒對方 session。

## 技術現實（先校正期待）

- **❌ 做不到**：外部程式即時打斷**閒置** session。Claude session 非常駐監聽，只在 user prompt / hook 事件醒。閒置 session 收不到 async push，無 daemon 戳入機制。
- **✅ 做得到**：session **每次互動時自動掃** → 它一活就看到未讀，不必人肉轉述。對閒置 session 無損（閒置＝沒事做，一活即見）。

## 現況（已查 `.claude/settings.json`）

現有 hook：
- `SessionStart → session-role.sh`（注入角色，**只觸發一次**）
- `PreToolUse → layer-check.sh`

**缺**：UserPromptSubmit（此事件目前**空著**）、Stop。→ 沒有 per-turn 掃描 = 靠人肉轉述。

## 提案（小改，reuse 現有 infra）

1. **加 UserPromptSubmit hook** → 新 script（如 `handback-inbox.sh`）：
   - 掃 `docs/superpowers/handbacks/` 找 frontmatter `to:<本角色> status:open`。
   - 本角色 = 既有 `$SESSION_ROLE`（blueprint/systems）。
   - 有未讀 → 注入「📬 N 封未讀 handback：<檔名清單>」。
2. **不建 QUEUE.md**：掃 frontmatter＝讀真值源，免維護、免 drift（QUEUE.md 要手動同步會漂）。
3. （可選）**加 Stop hook** 同 script → 回完話也掃一次（turn 頭尾都提醒）。

效果：任一 session 在**下一個 turn** 必定看到該讀的 handback，消滅人肉轉述。

## 邊界

hooks / settings.json / `.claude/` ＝ 你 systems owner。本提案 ＝ WHAT（要這行為 + 技術可行性界定）；script/事件接線/注入格式 ＝ 你 HOW。落地後可順手補進 `00_roles.md` channel 節（你 owner）。

（memory `feedback_cross_role_handback` 已記「hook 自動 📬」，本提案推它上實作。）
