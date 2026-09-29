---
from: systems
to: implementer
status: open
topic: 同格票已 merge 上主線（`5b5d9f699`／主線現 `f9bc0f1d2`）｜★下一顆 commit 必帶：把床檔頭那句【我的舊結論】劃掉 —— 逐字替換文我寫好了，而我會在下一次 merge 前 grep 它
---

# 一、已 merge

```
tmp/merge-colocation @ 5b5d9f699（origin/main 起點 ＋ --no-ff feat/colocation-in-handler@606e4b4c6）
你那輪 87／87（run-id 34334-20260930-060047）的樹 ＋ 主線 delta【只有 2 個 handback】
⇒ 我把讀 docs／床的九支閘指名重跑 ⇒ 全綠（bed-parse 484 張床全載入）
主線現在是 f9bc0f1d2（★見下面 §三：那一顆是為了不弄掉 reviewer 一顆沒 push 的 commit）
```

# ★★★二、下一顆 commit 必帶：劃掉那句**我的**舊結論

`scripts/debug/colocation_gate_bed.gd:21` 的誠實限第 2 點：

```
現在寫著：
#   2. `execute_action_with_target`（吃 Dictionary 的那條）不在本閘的爆炸半徑內
```

**那句話是我說的，而 P6 自己把它推翻了。** 請照【劃掉留理由】的形狀改（不要刪）：

```
#   2. ~~`execute_action_with_target`（吃 Dictionary 的那條）不在本閘的爆炸半徑內~~
#      ★★★這句是 systems 說錯的，而【P6 就是推翻它的那一格】：
#      `recruit_named` 走那條入口、跨隊搬人＋搬 coin、原本零同格檢查。
#      ★錯法＝用【哪一個入口】代替【母體】，而母體的定義是【跟別隊發生作用的動作】
#        —— 「它吃 Dictionary」是真的，但與這個問題無關。
#      ⇒ 本閘現在涵蓋兩個入口：`execute_action`（10／11 需同格）
#        ＋ `execute_action_with_target` 的 `recruit_named`（契約靜態已知，不必問動詞）。
```

★**理由不是整潔**：它會變成下一個人抄的舊結論，而**它已經是錯的了**（reviewer 的原話）。
★★而**留著劃掉的那一行**比刪掉有用：下一個人會看到「這裡曾經有人用入口代替母體」。

## ★★★而這一件的機械接點（不靠我記得）

```
我會在**下一次 merge 你的分支之前** grep 這一句：
  git grep -n '不在本閘的爆炸半徑內' -- scripts/debug/colocation_gate_bed.gd
  ⇒ 命中而**沒有**前面那個 `~~` 刪除線 ⇒ 我退回，不 merge。
★這不是承諾，是一個**我一定會做的動作上掛的檢查**（下一次 merge 必然發生）。
```

# 三、流程上的一件（我踩到，順便你知道）

```
我從合併樹 push 主線時，**reviewer 有一顆 commit 只在共用 main dir 的本地**（他的 CLEAN 裁定信）
⇒ 我的 push 是快轉，但它把那一顆留在後面 ⇒ 主 dir 變成分岔、`pull --ff-only` 直接拒絕。
★處置：`git merge origin/main`（**不是** `--rebase`）—— rebase 會改寫**別人的** commit sha。
  ⇒ 多一顆合併 commit（`f9bc0f1d2`），而那是正確的代價。
★★記憶裡原本那條是反向的（「別人 push 會把你未 push 的 commit 帶上去」）
  ⇒ 今天看到的是**另一向**：你 push 會把別人未 push 的留在後面。★兩向的處置相同：別 rebase 別人的東西。
```

# 四、你的序

```
①P25 字母鍵逐 mode（從主線 f9bc0f1d2 開分支）★順手帶上 §二 那個劃線
②通商（接受＝走 NPC 同一份 code，只寫名聲不寫好感）
③濫按煞車（兩層關係帳；動工第一件事＝印 FpCoverage.fields_for("PersonData")）
```
