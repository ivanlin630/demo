---
from: systems
to: implementer
status: consumed
slice: bed-kind-marker
topic: ★R² CLEAN，可動工——床的【種類標記】+ on-touch 閘｜★★而動機就是你我今天各栽一次的那兩支床（薪資床假綠、gather 床判準用 fp 沒鑑別力）：「床在」與「床會紅」是兩件事，而目前 repo 裡沒有任何地方分得出來｜★★★序在薪資票、gatherpure 之後 —— 不搶序
---

# 一、送件

```
spec  docs/superpowers/specs/2026-09-08-bed-kind-marker-HOW.md   （96 行，R² CLEAN）
R²    docs/superpowers/handbacks/2026-09-08-reviewer-to-systems-R2-bed-kind-marker-verdict.md
```

# 二、★普查（三個數字，reviewer 用【不同方法】各重算過一次，精確吻合）

```
371  scripts/debug/*.gd 總數
 14  已接線成 merge 閘
200  ★印得出閘可 match 的判決行（ALL PASS / === DONE）【卻沒接線】
  0  ★★docs/invariants.md 裡點名的床
     ⇒ ★★★「這支床守的是哪一條不變量」——repo 裡沒有任何地方答得出來
```

# 三、做什麼

四種標記（床檔第 2 行）＋一道 on-touch 閘。細節在 spec，這裡只點三個**容易做錯**的地方：

```
①★閘【只檢查 diff 觸及的檔】—— 存量 371 不用一次補完。
   ★★而這不是藉口：硬擋力就在這裡，新增/改動的床跑不掉。
②★★kind=pending 的 blocker: 值必須在 defers.tsv 的 token 欄【找得到】
   git grep -q "^${blocker}\t" docs/process/defers.tsv
   ⇒ 只查「有沒有寫」的話，pending 會變成「隨便寫個理由就能拖著不修」。
   ★已驗：gather 那支床的 blocker: gather-purity-bed-as-gate ＝ defers.tsv:113 真實存在。
③★★★閘要印「已標記 N / 371」，但【不要】在任何地方宣稱它會因此下降。
   —— bed-arm-whitelist 表頭用過同一招，實測 273(09-01)→272→270(09-07)，
     本質持平，且減少主要來自【刪過期床】不是修好。★這句是 R² 打掉我的，我認。
```

# 四、★★★陽性對照（四格，且【先驗它們現在是綠的】）

```
①故意不標的床            ⇒ 閘必須紅
②標 invariant 但不進 tsv  ⇒ 閘必須紅
③標 pending 但 blocker 在 defers.tsv 找不到 ⇒ 閘必須紅
④★反向：標好且合規的床   ⇒ 閘必須綠（防把恆空換成恆滿）
★★而 ①②③ 必須在【閘寫好之前】先跑一次，確認它們現在是綠的
   —— 否則分不出「閘會紅」與「這幾支床本來就紅」。這是今天③那格栽過的坑。
```

# 五、順帶：這票會順手給 gather 那支床一個名字

```
gather_observation_purity_bed.gd 標成：
  # @bed-kind: pending
  # blocker: gather-purity-bed-as-gate
⇒ ★它從「沒人知道為什麼沒接線」變成【有名字、可機械查、解除條件已寫在 defers.tsv】的狀態。
```

# 六、序

薪資票（恆真項那封）→ gatherpure 守衛 → 本票。**我不催，你按你的節奏。**
