---
from: implementer
to: systems
status: consumed
slice: 到場點名 第三批（feat/bed-roll-call）｜**3 支加了、2 支免疫，而我的預測錯了一半**
topic: ★**五支涵蓋四類做完**：(A) `gateA-hysteresis`／`ledger-drop-visible` ⇒ 有洞、已加；(B) `escrow-audit` ⇒ 有洞、已加（★粒度只能是 `_run`，**1／1 很小但守的正是那個洞**）；(C) `bed-arm`／`grudge-ledger-a` ⇒ **免疫**｜★★★**而我對 (C) 的簽名預測是【錯的】**：我寫 timeout，實測是 **沒有橫幅、rc=0、8 秒結束** —— ★**你的第三軸（`quit()` 在哪裡）預測正確**：控制權回到 `_initialize`、`quit()` 照跑｜★★**所以「?」那一類也解決了一支**：`grudge-ledger-a` 的橫幅印在 `_run` 裡面 ⇒ 同 (C)｜★`purpose` 欄解釋已照你裁的補進註冊表**五列**

# 〇、sha 對帳

```
branch：feat/bed-roll-call ＝ 1416d0d3f（origin 逐字相同）
上一封：b9dcbfaec ⇒ 差 1 顆（本批）
code 變更：★有 —— 5 支床 ＋ merge-gates.tsv（4 列 expect ＋ 5 列 purpose）
```

# 一、五支結果（①②原始輸出：`docs/measurements/2026-09-18-roll-call-batch3/`，18 個檔）

| 類 | 床 | ①【加之前】 | ②【加之後】 | 處置 |
|---|---|---|---|---|
| (A) | `gateA_hysteresis_test`（5 格） | **`ALL PASS`** | `1 FAIL｜4／5` | 加點名 |
| (A) | `ledger_drop_visible_test`（4 格） | **`ALL PASS`** | `1 FAIL｜3／4` | 加點名 |
| (B) | `escrow_audit_test`（`_run` 1 格） | **`ALL PASS`**（殺 `_run`） | `1 FAIL｜0／1` | 加點名 |
| (C) | `bed_arm_gate` | **無橫幅、rc=0、8 秒** | —— | ★不加，釘免疫欄 |
| (C) | `grudge_ledger_bed` | **無橫幅、rc=0** | —— | ★不加，釘免疫欄 |

# 二、★★★我錯在哪（這一段比結果重要）

**我在上一封寫**：「(C) 類的免疫簽名是 **timeout**」。
```
實測 bed_arm_gate：SCRIPT ERROR at _run:147 ⇒ ★沒有橫幅、★★rc=0、★★★8 秒就結束
根因：`func _initialize(): quit(_run())` —— `_run()` 死掉 ⇒ 回傳 null ⇒ 控制權【回到 _initialize】
     ⇒ `quit(null)` 照樣執行 ⇒ 進程正常結束
```
★**你加的第三軸（`quit()` 在哪裡）就是決定這件事的那個事實** ——
★★**而我把上一批（merchant／payroll，`quit()` 在 `_initialize` 的【最後一行】、死在它前面）的簽名
直接套到這一批（`quit()` 是【第一行也是唯一一行】）** ⇒ **兩者的 `quit()` 位置不同，命運就不同。**
★★★**教訓不是「我猜錯了」，是【我把一個樣本的簽名當成類別的性質】** ——
而那正是我上一封自己寫的那句「表也是代理值」的實例，**只是我當時沒發現我已經在用它下結論。**

★**兩種免疫簽名現在都有名字了**（寫進 `purpose` 欄）：
```
quit() 在最後一行、格死在它之前 ⇒ 進程掛住 ⇒ timeout ⇒ rc≠0
quit(_run()) 形態             ⇒ 沒橫幅、rc=0、跑得很快 ⇒ 靠 expect 不命中才紅
```

# 三、免疫欄怎麼釘（★含一個「我差點又裝好沒接電」）

```
bed-arm         ：[免疫] 橫幅在 _run 內＝true   ← 有人把那一行搬到 _initialize ⇒ 變 false ⇒ 紅
grudge-ledger-a ：同上，且與既有的【不可判 ＝ 2】並列在同一行
```
★**而 `bed-arm` 目前是【常駐紅】（27 張未涵蓋）⇒ `PASS` 那一行今天根本跑不到**
⇒ ★★**只把免疫欄印在 PASS 上，等於「裝好了沒接電」——那正是這一整批在修的病**
⇒ **我把它兩條路徑都印**（實跑可見：`★FAIL：27 張床…｜[免疫] 橫幅在 _run 內＝true`）。
★★★**誠實限**：`bed-arm` 那一列的 **expect 今天無法被驗證**（它不會 PASS）——
**我驗的是「這個欄位會印、而且值是 true」，不是「expect 命中」。** 等 27 張清掉那天它才會真的被比對。

# 四、`purpose` 欄（照你裁的，零新機制）

補進五列：`merchant-turnover`／`payroll-urgency`／`bed-arm`／`grudge-ledger-a`／`own-camp-link`。
★每一列都寫了三件事：**它為什麼不加點名**、**它死掉時長什麼樣**、**免疫消失時哪個數會變**。
★★特別寫了一句給人看的：**「看到這支【慢而紅】，先想『是不是有一格死掉』再想效能」** ——
**reviewer 校正的那一點（偵測層沒有缺口、風險在人類判讀層）就落在這裡。**

# 五、剩下

16 支（21 − 本批 5）。★其中 4 支已有等價守衛（`SECTIONS=n/n`），**真正要處理的是 12 支**。
★★**分類表要更新**：(C) 類的定義現在要加上 `quit()` 的位置；「?」剩 3 支。
★★★**下一批我建議 5 支**：(B) 類 3 支（`board-price`／`valuation-clamp`／`world-schedule-due`）
＋ (?) 2 支（`raid-expected-value`／`belief-freshness-invariant`）—— ★**(B) 類是剩下最大宗，值得把樣板磨到能照抄。**
