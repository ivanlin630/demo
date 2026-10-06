# 信箱 mod：把「寄信三件」變成一個工具（HOW）

```
票源 ＝ 用戶 2026-10-06「我想用 mod」（影子藍圖排程 `docs/notes/2026-10-06-mailbox-mod-plan.md`，
  正藍圖以藍圖身分正式轉來並落裁定 `657debd97`）
用戶裁 ＝ **裝，只限這個專案**（設定放專案層，★不動 `~/.claude/settings.json`）
序 ＝ 進貢迴圈 → `play.py` → 票 #2（故事結束）**之後**
```

## §0 ★★★它要解的是哪一件事（不是「自動化」）

```
今天的真缺陷 ＝ **寄信是三個獨立動作而只做了其中幾個**（①寫檔 ②commit ③敲門）
  ·血證①「落地≠通知」：東西寫進 repo 沒寄信 ⇒ 下游不會醒
  ·血證②「通知了≠送到」：只敲門沒寫檔 ⇒ relay 丟掉，兩端都沒訊號
  ·血證③「落地本身只做了一半」：寫了檔也敲了門而**那封信只在磁碟上沒 commit** ⇒ 讀 git 的信箱看不到
⇒ ★所以 mod 的價值不在「省事」，在**讓三件變成一件**（做不到的那幾件要指名叫出來）
⇒ ★★而 `zero-output-warn.sh` 站在門外事後喊，擋不住也改不了 ⇒ mod 是**取代**它，不是再加一支閘
```

## §1 做什麼（★只做第一個鉤子）

```
鉤子 ①`tool.call {tool:'Write'}`：路徑命中 `docs/superpowers/handbacks/*.md` 且 frontmatter
  `status: open` ⇒ `next(e)` 讓它寫 ⇒ 讀 `to:` ⇒ commit 那一封 ⇒ 敲收件人 ⇒ **逐件回報**
★其餘四個鉤子（`session.start` 通訊錄／`turn.complete` 有 commit 沒信／`session.receive` toast／
  `/mail`）**先不做** —— 每個鉤子都是一個**會安靜停掉的地方**，而我們現在只買得起一個。
檔案形狀（官方最小形）：`.claude/mods/mailbox-mod/{.claude-plugin/plugin.json,hooks/{hooks.json,register.js}}`
安裝 ＝ **專案層**（用戶裁）：專案的 `.claude/settings.json` 設 `CLAUDE_CODE_PLUGIN_DIRS`
  ⇒ ★六個終端共用一份、git 管版本；★★**不動用戶全機設定**
```

## §2 ★★★★四條硬條件（我裁，藍圖全收 —— 每一條都來自本專案的血證）

```
H1 ★★★**不准直呼 `git commit`** ⇒ 必須呼 `bash .claude/hooks/git-commit-retry.sh -F <msgfile> -- <path>`
   ·血證①共用 main dir 的 `.git/index.lock` 瞬鎖（那支 wrapper 就是為此存在；2026-10-06 我自己還吃到
     一次「★第 2 次才成功」）②★**pathspec commit（暫時 index）** —— 不用 pathspec 的話，
     **別的 session staged 的 WIP 會被一封信的 commit 帶走**
H2 ★★★**必須認得「電池在跑」並在那時不自動 commit**
   ·理由 ＝ 電池期間在主 dir 落檔會動到【閘自己會讀的東西】⇒ 那一輪**失去主詞**
   ·★而這個失效**完全無聲**（卷面只會是一輪奇怪的紅或綠）
   ·★★正確形狀不是「禁止」而是「**不可無聲發生**」⇒ 擋下來時要**印出它擋了什麼**（見 H4）
   ·判法 ＝ 讀 `machine-busy.sh` 那套（★不要自己發明第二套「忙不忙」的定義）
H3 ★★**退役條件要機械化**：`zero-output-warn.sh` 的 Stop 掛點**不准**在 mod 上線同時拆
   ·拆的條件 ＝ **mod 寄出的信數 ＝ `handbacks/` 新增的 `status: open` 檔數**，連續一週對得上
   ·★理由：mod 自己就是它要偵測的那三件事的**執行者** ⇒ **執行者不能是自己唯一的偵測器**
H4 ★**失敗要紅不要 toast**：三件裡任何一件沒成功 ⇒ `turn.complete` 的 `{text}` 必須印出來，
   且要**指名哪一件**（寫了沒 commit／commit 了沒敲到／收件人未登記）
   ·理由（NOTE §3 自己承認的）：Remote Control／VS Code 聊天面板**鉤子照跑、toast 不畫**
   ·★★只給一個 toast ＝ **一個沒接電的閘**
W1 ★**藍圖加的一條 WHAT**：mod 對角色**逐件回報三件各自成敗**，★**不給一個總綠**
   ·（它跟 H4 同向：一個總綠會把「其中一件沒做到」藏起來）
```

## §3 ★不做

```
✘ 不碰看門狗 —— 它偵測【沒有事發生】，而推播無法取代輪詢
✘ 不做 You Should Know 的替代品（那是 Anthropic 的，一行開關）
✘ ★★不在 mod 裡自動把信改 `consumed` —— **讀了 ≠ 處理了**，那是判斷不是搬運
✘ 不在鉤子裡跑 Godot（鉤子單次 10 秒上限、`$.process.run` 預設 30 秒）
```

## §4 驗收（P）

```
P1 [三件都真的發生] Write 一封 `status: open` 的信 ⇒ ★貼三樣東西：檔在、`git log` 有那顆、
   收件人那端**真的收到**（★不是 mod 說它送了 —— 要收件端的訊號）
P2 [★不該動的不要動] Write 一封 `status: consumed` 的信 ⇒ commit 與敲門**都沒發生**
   ⇒ ★★負對照：把 `status` 判斷拿掉 ⇒ P2 必須紅
P3 [★★H1 真的走 wrapper] 製造一個 `.git/index.lock` 存在的狀態 ⇒ mod 的 commit **仍然成功**
   ⇒ ★而它成功的原因要印出來（retry 第幾次）—— 否則「成功」分不出是 wrapper 還是運氣
P4 [★★★H2 真的擋] 在「機器忙」的狀態下 Write 一封信 ⇒ **不 commit**，且 `{text}` 印出它擋了什麼
   ⇒ ★負對照：清掉忙的狀態 ⇒ 同一個動作必須 commit（否則 H2 變成「永遠不 commit」）
P5 [★H4／W1 逐件] 人為讓敲門失敗（收件人不存在）⇒ `{text}` 要印「寫了✓ commit✓ 敲門✗」
   ⇒ ★★**不准只印一句「失敗」** —— 三件各自的狀態是這張票的全部意義
P6 [不新增水管] `claude plugin validate .claude/mods/mailbox-mod` 的 `hooks:`／`calls:` 兩行
   與 §1 一致；★多出來的 call 要**逐個說為什麼**
P7 [★pathspec] mod commit 之後 `git show --stat` 只有**那一封信**一個檔
   ⇒ ★★負對照：先在別處 `git add` 一個檔 ⇒ 它**不得**出現在 mod 那顆 commit 裡
```

## §5 ★★收尾兩件（用戶逐字：「全弄好後 一樣幫我提取備份到 workflow-template-v 並更新讀我」）

```
a 同步到 **https://github.com/ivanlin630/workflow-template-v**（★剔除專案內容）
  ·形狀照 2026-08-21 那次（`1cca53a`）：`docs/process/` 全套＋`.claude/hooks/`＋mod＋安裝說明
  ·commit 訊息要寫**對應本 repo 的 sha**（★否則模板與它的來源之後對不起來）
  ·★★★**它是一個外向動作**（push 到另一個公開 repo）⇒ 推之前**逐檔確認剔乾淨**：
    `tools/telegram/config.local.sh` 持有**真 token** 且 gitignored ⇒ 模板裡不准有它的任何殘影
b README 更新：**信箱第三版 ＝ mod**（一、二版的退役理由留著 —— 那是這份模板真正的內容）
c 兩件做完敲藍圖
```

## §6 已實測的前置（★不是讀文件推的）

```
`claude --version` ＝ **2.1.291**（NOTE 寫 2.1.290 ⇒ ★一天內又動一版，
  正好是它 §3「事件與方法版本間會變」的實例 ⇒ **以載入後生成的 `.d.ts` 為準**，不要抄文件）
`claude plugin --help` ⇒ **`validate <path>`** 與 **`test [dir]`** 兩個子命令存在 ⇒ P6／測試步驟可執行
★還沒拿到的：`$.session.send` 的確切簽章（收件人用 session id 還是名字）—— 載入後看 `.d.ts`
```

## §7 ★★★第二刀：看門狗原生化（藍圖裁 2026-10-06，★排在第一刀跑穩之後，不插隊）

```
用戶問：「看門狗不碰？不是有機制能看 session 狀態嗎」
藍圖裁 ＝ 列第二刀，目標兩件：
  ①本 session 回合結束時檢查「我是否還有 open 信／做到一半的物件」，有就**擋停**
    ＝ 假停止守衛原生化
  ②若 Mods 拿得到其他 session 的 idle/busy/waiting（就是 `ListAgents` 那份）
    ⇒ 藍圖端零 token 輪詢，只在「角色閒置＋有未收信」才喚醒 ⇒ 取代推論式看門狗
  ★先驗②拿不拿得到；拿不到就只做①
```

### ★★★★★②的答案：**拿不到，而有一條更好的路**（我實測＋讀官方方法表）

```
實測（2026-10-06）：`C:/Users/I12/.claude/dev-mods` 不存在、全機找不到任何 mod 的 `.d.ts`
  ⇒ ★**本機今天量不出來**（沒有載入過的 mod �⇒ 沒有生成的 typings）
官方方法表（`.../plugins/mods/reference`，自稱涵蓋 v2.1.289）：
  `$.session` ＝ `messages, cwd, root, model, turns, id, repo, surfaces, usage,
                 version, compact, send, append, authorize`
  `$.agent`   ＝ `register, spawn, list`  ← ★`list` 是**子代理型別**，不是 session
  ⇒ ★★**沒有任何方法列出別的 session 或讀它的狀態** ⇒ ②照字面**做不到**
⇒ ★★★而 `$.store` 是「**每個 session 都共享**」的 key-value（4 MiB）
  ⇒ **改成「每個 session 自己報」**：各自的 mod 在 `session.start`／`turn.start`／
    `turn.complete` 把自己的狀態＋**心跳時戳**寫進 `$.store`，藍圖端讀那份
  ⇒ ★它比「拿到別人的狀態」更好：**自報**、事件驅動、零輪詢、分得出 waiting 與 idle
  ⇒ ★★★★而它有一個必須寫在同一行的限制：**掛掉的 session 會停止上報**，
    而那個停止**長得跟 idle 一模一樣**（＝「會死掉的看門狗」那個血證的原形）
    ⇒ 所以讀的那端**必須把過期當【不知道】，不准當 idle** —— 心跳時戳是強制欄位
★★★★★而上面這一整段的權威是**文件**不是本機實測 ⇒ 第一刀跑完會生成 `.d.ts`
  ⇒ **那時用 `.d.ts` 重核一次**（文件自己說：兩者不一致時以你那版生成的為準）
  ⇒ ★這就是為什麼②排在第一刀之後：**第一刀會順手把②的量測工具生出來**。
```

### ★①的入口要換：不是 `turn.complete`，是 `classic.Stop`

```
`turn.complete` 的回傳只有 `next(e)` 或 `{ text }`（**印一行**）⇒ ★它**擋不住停止**
而設定檔那一族的每個事件都以 `classic.<Event>` 暴露給 mod（官方 reference 逐字）
  ⇒ `classic.Stop` 才是**能擋**的那個 —— 而那正是 `zero-output-warn.sh` 今天掛的位置
⇒ ★★所以①的真實形狀 ＝ **把現有那支 Stop hook 搬進 mod**（它是**取代**，不是新增閘）
  ⇒ 而那與 §2 的 H3 直接相接：H3 說的「拆掉舊 Stop 掛點」就是①做完的那一刻
⇒ ★★★而①能做到今天 bash 版做不到的事：bash 看不到「這個回合有沒有寫過 handback」，
  它只能數 commit；mod 在 `tool.call` 已經知道了 ⇒ **判準從「數 commit」換成「看那三件」**
```

### ★★★★★★藍圖裁（2026-10-06）：**那句限制要進【常駐輸出】**，不是只進 spec

```
逐字：「第二刀改『各 session 自報進共享 store＋心跳』，讀端把過期當【不知道】
  不當 idle，**這句進 spec 常駐輸出**。」⇒ 收，而它要落成一格：
P8 [★★第二刀｜常駐輸出] 讀 `$.store` 的那一端，**每一次輸出都要逐字印出**
   「★過期 ＝ 【不知道】，不是 idle（心跳 <age>）」，且**每一個角色那一列都要印**
   ⇒ ★**不是印在表頭一次** —— 只讀自己那一列的人會推論出一件那一列沒說的事
   ⇒ ★★負對照：把那句話拿掉 ⇒ 這一格必須紅
★★★而它為什麼必須是常駐輸出不是 spec 的一句話：
  這一族的謊**寫在「沒有人說它不涵蓋」的那個空白處** —— 結論通常誠實（那一列是舊的），
  而**讀者自動補的那句**才是謊（所以它閒著）。那句話沒有作者 ⇒ 沒人會推翻它，
  也**沒有任何一格會因它而紅** ⇒ 唯一的攔法是把範圍限定**逐字寫在每一個相關的格裡**。
  ⇒ ★驗法：問「**只讀這一格的人會不會推論出一件我沒說的事**」。
```
