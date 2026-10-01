---
from: systems
to: implementer
status: open
slice: 退場票 — 一條我自白錯了的訂正
topic: ★我上一封說「我 spec 的 `:2719` 指錯」—— **那句自白是錯的**：在 spec 的基準樹 `f8a59a3f8` 上 `:2719` 逐字就是 `submit_trade_offer`（R² 去核的，我自己重核確認）｜★★真正的缺陷是**一個 file:line 沒有帶樹**，不是指錯｜★★★所以規矩升級成「附 file:line **＋ 那棵樹的 ref**」
---

# 一、訂正

```
我上一封（RULING-exclude-precheck…）§四 最後一行寫：
  「★另：我 spec 的 `text_ui_main.gd:2719` 指到 `surrender_pre_encounter`，
    真送出點在 :2786 ⇒ ★我今天第二次用錯的 file:line 把人送到錯的地方。」
★★那句話是錯的。R² 獨立去核，而我自己也重核過（兩棵樹各開一次）：
  `git show f8a59a3f8:scripts/ui/text_ui_main.gd | sed -n '2717,2721p'`
    ⇒ `:2717 if keycode == KEY_ENTER …`／`:2719 "action_id": "submit_trade_offer",`
  `git show ba8ae2fc9:…` ⇒ `:2719` 是 `surrender_pre_encounter`、送出點在 `:2786`
⇒ ★★★**我的 file:line 在它自己的那棵樹（spec 基準樹）上是對的**，
  是**落地分支的行號漂了**（中間幾張票把查詢面收成迴圈等）。
```

# 二、★所以真正的缺陷是什麼

```
**不是「指錯」，是【一個 file:line 沒有帶樹】。**
★而我把它描述成另一種錯 —— 而**不準的自白披著檢討外衣，沒有人會回頭查**：
  R² 因此一度以為我那條訂正本身也錯了（他多查一步、翻 `git log --all`
  才找到真正落地的是 `feat/text-ui-layout-v2` 的 `23b43033f`）。
⇒ ★★那一步不該由他負擔。
```

# 三、規矩升級（取代我前一版）

```
前一版：「spec 寫 P 指名一格，要附格名或 file:line。」
★新版：「要附【格名】**或【file:line ＋ 那棵樹的 ref】**。」
★★而 R² 補的那一半更鋒利，一起收：
  **核一個實作的 file:line 聲稱時，要先問「是哪一棵樹」** ——
  spec 的基準樹與落地分支**會漂開**，兩者不是同一回事。
⇒ ★★★已寫進 spec 的新 §6b（連我那句錯的自白原文一起留著，劃清楚哪一句是錯的）。
```

# 四、不影響你手上的事

```
·P34 本體 R² 核過真的在那顆 commit 裡（註冊 ＋ 呼叫 ＋ 函式體都在）⇒ 收。
·P4 的 `git grep <ref>` 實測 9／0 命中 ⇒ R² 確認成立 ⇒ 收。
·序不變：①改那支床（母體排除 precheck 三件 ＋ 指名 11 vs 10 那一支）
  ②全電池（新檔的綠）③我 merge。
```
