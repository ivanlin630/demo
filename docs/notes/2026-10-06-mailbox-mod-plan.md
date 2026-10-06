# mailbox-mod：用 Claude Mods 把「寫信三件」變成機械動作

status: NOTE（影子藍圖排程；用戶 2026-10-06 說「我想用 mod」；HOW 全歸 systems）
from: 影子 blueprint session
to: systems（寫 mod）；正藍圖（知道這條在排）
date: 2026-10-06
前置: Claude Code ≥ 2.1.287（現機 2.1.290 ✓）。Mods 文件：https://code.claude.com/docs/en/plugins/mods/overview

---

## §0 為什麼是 mod 不是再一支 bash hook

現在的 hook 站在門外：事後喊（zero-output-warn），擋不住、改不了。Mod 跑在 Claude Code 程序裡，`tool.call` 可以在 Write 真的落地**之前／之後**順手做事，`turn.complete` 可以在回合結束時直接印判決，`$.store` 是全機器 session 共享的 key-value。

三個痛點各對一個原生鉤子，**不新增任何 bash 水管**：

| 痛點（9/17 討論） | 現在的做法 | mod 鉤子 |
|---|---|---|
| 寫信＝①寫檔②commit③敲門，三件缺一＝沒送到 | 靠人記得；zero-output-warn 事後吵 | `tool.call {tool:'Write'}` 路徑命中 `docs/superpowers/handbacks/*.md` ⇒ `next(e)` 讓它寫 ⇒ 讀 frontmatter `to:`／`status:` ⇒ `$.process.run('git', ['commit', …pathspec])` ⇒ `$.session.send(addr[to], "to:<role> 信在 <path>")` ⇒ `$.ui.toast` 回報三件各自結果 |
| 通訊錄要每人手跑 `whoami.sh demo-XX` | peers.sh ADDR 欄 | `session.start`：讀 `$.env.get('SESSION_ROLE')` ⇒ `$.store.set('addr.'+role, {session: $.session.id(), at: now})`；寄信時查 `$.store.get('addr.'+to)`。**收件人沒登記 ⇒ toast 紅字「<role> 未登記，信已寫但沒敲到」**——失敗要看得見，不能靜默 |
| 有 commit 沒信 | `zero-output-warn.sh`（Stop hook，20 分鐘窗） | `turn.complete`：本回合有 git commit 且沒寫過 handback ⇒ 回 `{ text: '⚠ 本回合有 commit 沒信' }`；寫過 ⇒ 不吭聲。**上線後退役 zero-output-warn.sh**（不要一直加閘：這是取代） |

## §1 檔案形狀（官方最小形）

```
mailbox-mod/
├── .claude-plugin/plugin.json      # name/version/description
└── hooks/
    ├── hooks.json                   # {"modules": ["./register.js"]}
    └── register.js                  # export function register(on) { on('tool.call', …) … }
```

鉤子清單（systems 定稿；只用這些，`claude plugin validate` 會列出來給人審）：

| 事件 | 做什麼 | 回什麼 |
|---|---|---|
| `session.start` | 登記通訊錄；註冊 `/mail`（列 `to:我 && status:open` 的信） | `next(e)` |
| `tool.call` `{tool:'Write'}` | 路徑在 `handbacks/` 且 `status: open` ⇒ 寫完 commit＋敲門＋toast | `next(e)`（不擋寫） |
| `turn.complete` | commit 無信 ⇒ 一行警告 | `{ text }` 或 `next(e)` |
| `session.receive` | 別人敲進來 ⇒ toast「📬 from <role>: <path>」 | `next(e)` |
| `command.run` `{command:'mail'}` | 列未讀 | `{ text }` |

**影子 session**（`SESSION_ROLE` 未設或 `shadow`）⇒ mod 不登記、不敲門、不吵，只留 `/mail` 讀。

## §2 怎麼弄（給用戶／systems 的步驟）

1. **讓 Claude 寫**：任一 session 打 `/plugin-authoring`，然後一句話：「寫一個 mod：攔 Write 到 docs/superpowers/handbacks/ 的檔，寫完自動 git commit 該檔並用 $.session.send 敲 frontmatter to: 那個角色；角色→session 對照存 $.store；turn.complete 時有 commit 沒信就印一行警告；SESSION_ROLE 沒設就全部不做。」Claude 會寫進 `~/.claude/dev-mods/<sid>/mailbox-mod/`，問你要不要 hot reload，選「Enable for this session」。
2. **搬出來**：複製到 `A:\GDS\demo\.claude\mods\mailbox-mod\`（進 repo，六個終端共用一份、git 管版本）。
3. **驗**：`claude plugin validate A:/GDS/demo/.claude/mods/mailbox-mod` ⇒ 看 `hooks:` 與 `calls:` 兩行跟 §1 表一致，多出來的 call 要問為什麼。
4. **測**：`tests/mailbox.test.ts` 用 `claude plugin test` 跑——陽性對照兩格：①Write 一封 `status: open` 信 ⇒ 斷言 commit 與 send 都被呼叫；②Write 一封 `status: consumed` ⇒ 斷言兩者都沒被呼叫。
5. **裝到六個終端**：`~/.claude/settings.json` 加
   ```json
   { "env": { "CLAUDE_CODE_PLUGIN_DIRS": "A:\\GDS\\demo\\.claude\\mods\\mailbox-mod" } }
   ```
   （Windows 多個用 `;` 分隔）。重開終端生效；跑中的 session 用 `/reload-plugins`。
6. **退役**：mod 跑穩一週後——`whoami.sh`／peers.sh 的 ADDR 欄改讀 `$.store`、刪 `zero-output-warn.sh` 的 Stop 掛點。看門狗照舊。

## §3 要知道的風險

- Mod 以你的權限跑、不進 sandbox，能讀所有檔、起程序、發網路。**只裝自己 repo 裡、validate 過的**。
- `$.fs.write` 非原子；跨 session 共享狀態一律放 `$.store`（4 MiB 上限，夠）。
- 鉤子單次 10 秒上限；`$.process.run` 預設 30 秒——git commit 夠，別在鉤子裡跑 godot。
- Remote Control／VS Code 聊天面板：鉤子照跑、畫面不畫（toast 看不到）⇒ 判決也要印進 `turn.complete` 的 `{text}`，不能只靠 toast。
- 文件自己說：事件與方法版本間會變，以載入時寫進 `.claude-plugin/types/` 的 `.d.ts` 為準。

## §4 不做

- 不碰 watchdog（它偵測「沒有事發生」，推播無法取代輪詢）。
- 不做 You Should Know 的替代品——那是 Anthropic 的，開關一行：`/plugin enable cc-plugin-you-should-know@builtin`。
- 不在 mod 裡自動 `consumed`（讀了≠處理了，那是人的判斷）。

## §5 誠實標

- `$.session.send` 的確切簽章（收件人用 session id 還是名字）我沒拿到——`$.session` 命名空間列了 `send`，簽章要看載入後生成的 `.d.ts`。
- `turn.complete` 判「本回合有 commit」的實作：讀 `git log --since=<turn.start 時戳>` 或 `$.session.messages()` 掃 Bash 工具結果，systems 挑。
- 我沒跑過任何 mod；以上全是讀文件推的形狀，步驟 1 讓 Claude 寫會比我手寫準。
