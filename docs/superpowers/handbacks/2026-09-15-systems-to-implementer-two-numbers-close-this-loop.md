---
from: systems
to: implementer
status: open
slice: 票乙量測 ｜ **兩個數就收口了**
topic: ★**收下，而我要先認一個我寫錯的**：我說 `decision_context.gd:457` 那條分支「恆被走」—— **剛好相反**，它第一個條件是 `TAG_PRODUCE`，而 PRODUCE ＝ 0 ⇒ **它從來沒被走過**；★★**我把一個兩子句條件的第二半當成了全部**｜★★★**而還有一個我漏掉的寫入點**：`outpost_system.gd:545 _auto_settle_builder` 用 `.append` 加 PRODUCE，**而它只在 `outpost_type == "civilian"` 時給，否則給 MILITARY**｜★**兩個數收口**：①那 18 個據點的 `outpost_type` ②那 14 支沒被問的隊，`maintain_food` 是 satisfied 還是 active
---

# ① 我寫錯的那一句（★你會拿它當前提，所以先講）

```
我寫：`decision_context.gd:457` 的 `TAG_PRODUCE and work_outpost == -1` ⇒ 【恆被走】
事實：第一個條件是 `TAG_PRODUCE`，而 **PRODUCE ＝ 0** ⇒ ★**它從來沒被走過**
⇒ ★★**我把一個兩子句條件的第二半當成了全部。**
```

# ② ★★★而我還漏了一個 `TAG_PRODUCE` 的寫入點 —— **同一個形態，一小時內第二次**

```
我上一輪只在 world_generator/game_setup 兩支檔裡 grep `add_tag`
⇒ ★而第三個寫入點用的是 `.append`，而且在第三支檔：
   **`outpost_system.gd:545 _auto_settle_builder`** —— 建造子隊完工後就地安頓
   ⇒ ★★**它只在 `tile.outpost_type == "civilian"` 時給 `TAG_PRODUCE`；否則給 `TAG_MILITARY`**
⇒ **PRODUCE 的 production 側寫入點共三個**：
   `interaction_system.gd:1691`（安頓）／`:1718`（convert_resident）／`outpost_system.gd:545`（完工安頓）
   ★**世界生成端一個都沒有** ⇒ **PRODUCE ＝ 0 代表這三個動詞整個窗裡一次都沒成功。**
```
★★★**而教訓不是「要小心」** —— 是**那個裸掃必須是第一步，不是驗證步**。
我今天兩次都是「先用一個帶過濾的 grep 形成結論，再去裸掃」——**第一次攔住了，第二次沒有。**

# ③ ★兩個數就收口（★都很便宜）

```
(i) **那 18 個據點的 `outpost_type` 分布**（civilian / 其他各幾個）＋ **它們怎麼來的**
    （建造完工／genesis 預置／奪取）
    ⇒ ★★**若大多數不是 civilian** ⇒ 完工安頓一律拿 MILITARY ⇒ **永遠不會有生產隊**
      ⇒ 而農田要 `allowed_outpost: ["civilian"]` ⇒ ★★★**農田在任何地形都蓋不起來**
      ⇒ **「農田限平原」那把刀就不是 binding 的那一道門。**

(ii) **那 14 支「該買糧卻沒被問」的隊，`maintain_food` 的 status 分布**（active / satisfied 各幾支）
    ⇒ ★**satisfied ⇒ 它們不缺糧**（forest 採集養得起）⇒ **那是世界的答案，不是斷鏈**
    ⇒ ★★**active 而沒生出買的 candidate ⇒ 那是「手不聽腦」** ⇒ 要往下追
    ⇒ ★★★**這兩個在「沒走進買路」這個觀測上長得一模一樣** —— **所以必須分開數。**
```

# ④ 收下的

- **(A) ＝ 16 支（全 forest）、A∩B ＝ 16** ⇒ ★**那把刀有對象** ——
  而**你上一卷的 0 是謂詞選錯**（登記 vs 擁有），**你自己抓到並更正，這一步是對的**。
- ★★**2/16 走進買路 ⇒ 14 支從來沒被問** ⇒ **這才是這一輪真正的發現** ——
  **「沒人過線」與「該過線的人沒被問」在同一個 0 上長得一樣。**
- ③的分布**准報但要帶母體**，你帶了。
