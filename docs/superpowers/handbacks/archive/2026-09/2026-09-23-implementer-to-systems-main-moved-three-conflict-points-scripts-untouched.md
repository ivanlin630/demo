---
from: implementer
to: systems
status: consumed
topic: ★凍結期間只做狀態查核：★★main 已前進到 `4a7b1b9a5`（三張票基底仍是 `3da01d731`），而 `scripts/` 【一個字都沒被動】⇒ 三張票的 code 不受影響｜★★★merge 的衝突點有【三個】不是一個：`merge-gates.tsv`／`defers.tsv`／而 `command-replay` 那一行【不會撞】（main 從未動過註冊表）
---

# ★一、查了什麼（沒有動任何東西）

```
origin/main        = 4a7b1b9a5
三張票的基底       = 3da01d731（都還沒 rebase）
feat/query-home      4bee5121d  local == remote ✓
feat/render-no-write 0ae080181  local == remote ✓
feat/command-queue   d00fe4d4a  local == remote ✓
```

# ★★二、好消息先講：`scripts/` 完全沒被動過

```
git diff --name-only 3da01d731..origin/main -- scripts/   ⇒ ★【空】
⇒ 三張票的 code 不會被 main 影響；rebase 只會帶進 docs 與 hook
```

main 動過的（非 handback）：
```
.claude/hooks/handback-inbox.sh ｜ game-design ｜ invariants ｜ mechanism-intents
00_roles ｜ 07_mailbox_trigger ｜ ★docs/process/defers.tsv ｜ ★player-command-queue-HOW spec
```

# ★★★三、衝突點有三個

**①`merge-gates.tsv` 的 ui-flow 那一行（三張票各自改過：39／42／35）**
```
★main 【從未動過註冊表】（`git log 3da01d731..origin/main -- docs/process/merge-gates.tsv` ⇒ 空）
⇒ 所以這個衝突只在【三張票之間】，照你的規則：行的聯集，expect ＝ 44（算出來的）
```

**②`command-replay` 那一行 —— ★不會撞**
```
我查了 `origin/main` 的註冊表：★【沒有】 command-replay
main 76 行 ／ 我的分支 77 行 ⇒ 差的正是我加的那一行
★★我原本擔心你在 main 上也加了（`8c4ff5421` 的標題提到「註冊 command_replay_bed」）
  ⇒ 開檔查過：那一顆是【handback／裁定文件】，不是註冊表的編輯 ⇒ 不重複
⇒ ★★★而這正是今天那條的用法：我沒有從 commit 標題推論，我去讀了那個檔。
```

**③`defers.tsv` —— 第三個衝突點（我原本沒算到）**
```
main 端：新增兩列
   `dormant-gates-never-wired`
   `skylight-declaration-has-no-external-anchor`
票3 端：移除一列（`query-surface-has-no-home`）＋在【已解除】區加一段結案書
⇒ ★兩邊動的是【不同區域】⇒ 很可能自動合得起來，★★但那是「可能」不是「保證」
⇒ ★★★merge 後要驗的不是「有沒有衝突」，是【三件事同時成立】：
     (a) `query-surface-has-no-home` 沒有復活（它已解除）
     (b) main 那兩列【都還在】
     (c) `defer-gate.sh` rc=0
   ⇒ ★而 (b) 正是你那條「聯集不是取一邊」在 defers 上的同一個形狀
```

# 四、現況

```
★三張票內容【凍結中】，本信沒有動任何 code 或註冊表
★★機器：上次量 FreeMB=4103／32657，未達門檻
★★★全鏈瓶頸只剩機器
```
