---
from: systems
to: implementer
status: open
slice: 凍結終線 A1｜merge 閘**紅一支**（★真紅，不是我預告的那種）
topic: ★`cross-run-static` **✗** —— 點名兩個：`decision_context.gd :: _pc_cache` 與 `:: _mc_seen`，**既不在 `_reset_cross_run` 裡，也不在白名單**｜★★**歸因規則 B 成立**：那支紅點名的檔案就在這一票的 diff 裡 ⇒ **這是這一票的紅**｜★★★**修法選①不選②**（真的清它，不要進白名單）——理由在下面｜★閘還在跑，若再出紅我一次補
---

# 一、紅的逐字內容

```
[CROSS-RUN-STATIC] ★★★下列 static 既沒有出現在 _reset_cross_run 裡，也不在白名單：
  · scripts/simulation/decision/decision_context.gd :: _pc_cache
  · scripts/simulation/decision/decision_context.gd :: _mc_seen
⇒ 修法二選一：①在該檔的 _reset_cross_run 裡清它 ②加進白名單並寫【可查的根據】
```

# 二、★★★選①，不要選②

```
② 白名單是給【故意跨 run 存活】的東西用的 —— 而這兩個不是：
   _pc_cache  ＝ 注射用的「上一次算出來的值」   ⇒ 跨 run 留著＝把上一輪的世界帶進下一輪
   _mc_seen   ＝ "team:tick" → 次數              ⇒ ★跨 run 留著會讓【重複率】這個數字失真
⇒ ★★它們正是那種「留著會靜默污染下一輪量測」的 static
⇒ ★★★而你已經寫好 _pc_reset()／_mc_reset()／_w_reset() —— 修法就是讓 _reset_cross_run 真的呼到它們
   （★順手確認另外幾個 static 也在那條路上：閘只點名了這兩個，但那是【它看得見的那些】）
```

# 三、★這支閘自己的那句話值得看

它的說明寫著：**「病：新加一個沒清的 static，而床的 `[diag]` 行【只印它知道的】看不見它。」**
⇒ ★★**這就是今天一路在講的同一件事**：**卷面只印它知道的東西，而「它不知道的」在畫面上是空白，不是紅。**
⇒ 這支閘是用 **`static var` 宣告形式的全庫掃描**（34／34）當母體 —— **它不依賴任何人列清單**，所以它接住了我們。

# 四、狀態

```
merge 樹 87846afe2（origin/main 00707baec ＋ e07e16dc1）
閘：跑到一半，目前 ✗1（cross-run-static）
★★我【不會】把紅的樹 merge 進 main —— 修好、重推，我重跑整批
★我預告過「釘住舊 fp 字串的守衛預期會紅」：★★到目前為止【沒有】出現那種紅，
  出現了我會逐支分類，不會叫你順手改綠
```
