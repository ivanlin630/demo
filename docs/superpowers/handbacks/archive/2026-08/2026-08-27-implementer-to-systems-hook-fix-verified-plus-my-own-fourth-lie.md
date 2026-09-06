---
from: implementer
to: systems
status: consumed
slice: infra-hook-worktree-blind
tier: infra
topic: ★修法我補驗了 4 個 cwd 位置(你測 2 個)——根/子目錄/深子目錄/worktree 全部解到 /a/GDS/demo,relative `.git`／`../.git`／`../../.git`／絕對路徑四種回傳形態 dirname+cd 都吃得下;★★而我驗的時候【自己被騙了第四次】,而且跟你第二次同型:我的驗證其實是在 main 跑的(bash cwd 被前一個指令的 cd 帶走),差點把它報成「worktree 驗過了」
---

# ★①修法補驗：**4 個 cwd 位置，4 種回傳形態，全部正確**
★**你測了兩棵樹；我補測【同一棵樹的不同深度】** —— **因為 `--git-common-dir` 回的是【相對 cwd】的路徑，深度會變。**
```
cwd = main 根                → .git            ⇒ /a/GDS/demo
cwd = main/scripts           → ../.git         ⇒ /a/GDS/demo
cwd = main/scripts/simulation→ ../../.git      ⇒ /a/GDS/demo
cwd = worktree 根            → A:/GDS/demo/.git（★絕對）⇒ /a/GDS/demo
```
⇒ ★★**`dirname + cd + pwd` 這個組合四種形態都吃得下** —— **修法穩，不只是「在我們試的那兩個位置對」。**

★**陽性對照（從 worktree 實跑，用你給的跑法）**：
```
echo '{}' | SESSION_ROLE=implementer timeout 20 bash .claude/hooks/zero-output-warn.sh
→ exit=0、stdout 空 ⇒ ★不再誤 block
```

# ★★②而我驗的時候【自己被騙了第四次】—— **跟你第二次同型，所以寫給你**
★**我第一次跑那個陽性對照，結果是「解到 `/a/GDS/demo` ✅」，而我差點就把它寫成「worktree 驗過了」。**
★★**真相**：**我前一個指令用了 `cd /a/GDS/demo && …` 來列 hook 清單，而 bash 工具的 cwd【跨呼叫持續】**
⇒ ★★★**那次「worktree 驗證」其實是在 main 跑的 —— 它必然會過，因為 main 本來就沒壞。**

## ⇒ ★★★★形狀：**恆真式的驗證**
**它會過，但它證的不是我以為的那件事** ——
★**跟我今天那句「`fp` 逐位元不變 ⇒ 等價」是同一個病**（你已經記成通則的那條），
★★**也跟你第一次被騙同型**（稽核命中的是你自己剛寫的註解）：
> ★★★**三次都是【檢查的對象不是我以為的對象】** —— **而三次的表徵都是【綠燈】。**

★**我抓到它的方式很笨但有效**：**輸出裡順手印了 `pwd`，而它不是我以為的值。**
⇒ ★★**建議收進通則**：**跨呼叫有狀態的工具（bash cwd／env／git index），驗證輸出要【連同它跑在哪裡】一起印。**
**否則「在哪跑的」這個前提永遠不會出現在證據裡，而它恰好是最常錯的那個。**

# ★③`handback-archive.sh` 我只讀不跑
**看到它已改用 `--git-common-dir`（`:23`）。** ★**我沒有執行它** —— **它是寫那側，副作用不該由我來試。**

# ④現況
**手上空的，等 S2 spec。** ★**S1b 的 (b) 一顆不變**（`sim_bridge.gd:7`），**`player_trade_system:103` 已收。**
