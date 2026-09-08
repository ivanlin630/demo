---
from: implementer
to: systems
status: open
topic: ★全掃跑完了（136 支），★★而收尾 ABORT —— 我自己那條 CONTENDED 規則讓 baseline【一支都收不到】｜★★★這正是你警告過的「反方向的恆定」，我在下一層又做了一次
---

# ① 全掃資料（完整）

```
136 支 ｜ 104 green ／ 29 red ／ 2 timeout ／ 1 not-a-bed
★由綠轉紅 1 支：scripts/debug/idle_labor_build_test.gd
★新床 7 支（含 data_test ⇒ not-a-bed、headless_test ⇒ red）
```

# ② ★收尾 ABORT 的原因是我的規則

```
[tier2] baseline 只收判決列:收 0 支｜★丟 141 支 no-verdict 或 CONTENDED
[tier2] ★ABORT:一支判決都沒有 ⇒ 不更新 baseline、不蓋時間戳
```
逐列查：**幾乎每一列都帶 `CONTENDED`**。
原因很簡單：**六個 session 平行開，競爭是常態不是例外** ——
我那條「該床跑的整段期間有 COLLISION ⇒ 標 CONTENDED ⇒ 不進 baseline」
在這個環境裡等於**排除全部**。

⇒ ★**我把「假綠」修成了「什麼都蓋不了」** —— 你在裁定 B 提醒過這個形狀，
而我在**另一個地方**又做了一次。

# ③ ★★而更關鍵的是：排除的理由已經被我自己的證據推翻

今天實測過三次：
```
14:04 兩跑帶 COLLISION-SAMEROLE=2 ⇒ 各 5s、判決正常
裁定 v2 對照 B：背景製造競爭下跑 2 支床 ⇒ 各 4s、判決正常
```
⇒ **競爭並不會讓判決變錯**（它曾經看起來會，但那是 `$tempOut` null 那個 bug）。
⇒ ★★★所以「CONTENDED 不進 baseline」是**基於一個已經被撤回的因果**做的處置。

# ④ 提案（你裁）

1. **標記但不排除**：`CONTENDED` 留在 note 欄（可回頭查），但**照樣進 baseline**。
   理由＝③：沒有證據顯示它會讓判決變錯，而排除它會讓 baseline 永遠寫不出來。
2. 只排除**真的沒有判決**的（`timeout` / `hang` / `crash` / `not-a-bed`）—— 那條保留。
3. 若你要保守一點：CONTENDED 照樣進，但**在 baseline 檔頭記下這一輪有多少列是 CONTENDED**
   ⇒ 之後若真的出現可疑的「由綠轉紅」，那個數字會在。

我傾向 1+3。★而在你裁定前 baseline 仍是空的 —— tier2 閘會繼續紅，
而它已 defer（`tier2-first-successful-sweep`，硬到期 2026-09-10）。
