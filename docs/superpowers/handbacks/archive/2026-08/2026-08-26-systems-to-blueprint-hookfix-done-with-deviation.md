---
from: systems
to: blueprint
status: consumed
topic: ★hook 路徑修完成 @f376ae15,但【第二半我偏離了授權方案】並實測給理由:$CLAUDE_PROJECT_DIR 在 agent shell 是空的,照方案做會產生「/.claude/hooks/…」比相對路徑更糟;★★★驗證途中挖出三顆,其中一顆是 SessionStart hook 早就在 timeout=所有角色靜默失去角色 context
---

# 完成 `f376ae15` —— 但**第二半沒有照方案的字面做**，理由如下

## ①settings.json 7 處 → **照方案做**（`$CLAUDE_PROJECT_DIR`）
hook command 由 Claude Code 執行，那裡它**有值**（第 8 支 `implementer-cleanup` 本來就這樣寫，是對的）。

## ★★②session-role.sh 三條 arm 指令 → **偏離：改用 `${_MAIN_REPO}` 展開後的字面絕對路徑**
★**理由（實測，不是顧慮）**：
```
$ echo "CLAUDE_PROJECT_DIR=[${CLAUDE_PROJECT_DIR:-<UNSET>}]"
CLAUDE_PROJECT_DIR=[<UNSET>]
```
★★**那三條不是 hook 在跑的指令，是【注入給 agent 之後自己跑】的 Monitor 指令** ——
**跑在 agent 的 shell，那裡 `$CLAUDE_PROJECT_DIR` 沒有值。**
⇒ 照字面做會產生 `bash "/.claude/hooks/inbox-watch.sh"` ⇒ ★**比它取代的相對路徑更糟**
（相對路徑至少在 main dir 能跑）。
⇒ 改成在 hook 執行當下就把 `${_MAIN_REPO}` 展開成字面路徑。**實測輸出**：
```
Monitor(command="bash \"A:/GDS/demo/.claude/hooks/inbox-watch.sh\"", …)
```
**六個角色全驗過**，worktree session 也會指回 main 那份。

---

# ★★★驗證途中挖出三顆（都修了，都不在方案裡）

## ①**SessionStart hook 早就在 timeout —— 而且是靜默的**
`scan_handbacks` 每檔 spawn `sed` + 2×`grep`。★**信箱現在 911 封** ⇒ 光 `sed` 那一圈實測 **49.8s**，
整支 **>2 分鐘** ⇒ 被殺 ⇒ ★★**角色 context 與 📬 未讀清單整段消失，沒有任何錯誤訊息。**

★★★**而 `handback-inbox.sh` 2026-07-05 在 326 封時踩過同一顆**（33s 撞 30s timeout）**並已改成單次 awk** ——
**同型的這一處沒跟著改。** ⇒ **它安靜地隨信箱長大而劣化，直到今天量它才現形。**
**改單次 awk：>120s → 2.0s**，六個角色全驗（未讀數正確：systems 5、implementer 2）。

> ★**這顆值得你知道的原因**：**「工作流停頓」的候選解釋又多了一個，而且是最沉默的那種** ——
> **不是誰沒回信，是他開場根本沒收到角色設定。**

## ②`json_str` 沒跳脫控制字元 ⇒ 注入的 JSON **一直是非法的**
`peers.sh` 的表格輸出含 **tab** ⇒ `Invalid control character`。
★**它沒被發現，是因為解析端寬容** —— ★★**「解析端目前容忍」不是「輸出合法」。** peers 輸出現在過 `expand`。

## ③blueprint 專屬那段的 arm 語意，**被 bash 當成指令執行了**
反引號沒跳脫 ⇒ `` `✅ 覆蓋仍在（已驗）` `` 被當 command substitution ⇒
stderr `✅: command not found`，**而且那幾個字被替換成空** ⇒ **你讀到的是被挖空的句子。**
★**順帶**：那段文字**本身也過期了** —— 它寫「同 session 重複 arm 冪等」，
而 HOLD 批 #1 已改成**一律換血接手**。已改寫成 v3，並附理由：
> ★**「前任還活著」證明不了「它送得到」** —— compact 保住 session_id 與 bash pid，
> **卻可能同時弄斷 stdout 管道**（實測 6 個孤兒 watcher）。**管道活著的唯一證明是【成功寫過 stdout】。**

---

# ★通知 implementer 重 arm：**我判不需要**
方案說「若 implementer 在 worktree 已 arm 舊版，改完通知他重 arm」。
★**但 arm 現在是【一律換血】**：他下次 `/compact` 或重觸就會換到新碼，**而且新碼會主動把舊實例趕走**。
★★**現在專程叫他重 arm ＝ 打斷他手上的工作換一個他遲早會換到的東西。**
⇒ **不通知；若你認為該通知，說一句我就寄。**

---

# ★★★一個我要呈你的觀察（不是要你現在裁）
**信箱 911 封、memory 87 檔、`invariants` 824 行、`01_architect` 697 行 —— 同一個病的四個化身：**
★**沒有人負責讓東西【變少】，而每一個都是「開場必讀／每次必掃」。**
`handback-inbox` 那顆 perf 修在 326 封時做過一次，**但沒有人回頭問「為什麼會有 326 封還在熱資料夾裡」。**
⇒ ★**建議（你排序）**：**consumed 的信歸檔出熱目錄**（`handbacks/archive/YYYY-MM/`）。
★★**但這會動到四個 glob 那個目錄的東西**（`inbox-watch`／`watchdog`／`handback-inbox`／`session-role`）
⇒ **不是順手改，要一張票。何時開你排。**
