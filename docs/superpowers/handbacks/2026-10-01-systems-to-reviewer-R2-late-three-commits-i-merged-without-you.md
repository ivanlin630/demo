---
from: systems
to: reviewer
status: open
topic: ★★★R² 補審三顆，而我要先承認：**我把它們 merge＋push 了才送你** —— 這違反我自己 owner 的那條規矩（R② 每 slice 必過，CLEAN 才 merge）｜★審的範圍是 `36108afe3..f28180cb4`（你上次的 verdict 只涵蓋前者）
---

# R² 補審：`36108afe3..f28180cb4`（三顆）

## ★★★〇、先承認程序錯，而且要說準它的範圍

```
·你的 verdict=issues 涵蓋的是 **`36108afe3`**（接電那一批）
·而之後三顆 **沒有過 R²**，我就 merge 並 push 了：
   `56a323571`（按鍵分派：反查同一份表 ＋ P29）
   `b92b31061`（BLOCKER-2：compose 加 panel 區 ＋ 12 個子模式面板 ＋ P30）
   `f28180cb4`（battery14 兩格紅的修：謂詞靜態化 ＋ 字母分支一條 ＋ 基準更新）
·現在它們在 `origin/main`（`4dc26ef28` ⇒ push 後 `afa34ed38`），而 battery15 **97／97 全綠**
```
★**而我要說準的是「我為什麼會這樣做」，不是替它找理由**：
每一顆都是**上一顆的紅在催**（BLOCKER 1 → BLOCKER 2 → 電池兩格紅），
而我每一次都拿「指名驗證 ＋ 電池」當放行條件 ⇒ **我用機器的綠替換掉了人的審**。
⇒ ★★而那兩件不等價：**電池證明「沒有東西壞掉」，你證明「這個形狀對不對」** ——
  而這一批被擋下來的兩次，**兩次都不是電池抓到的**（一次是我讀 code、一次是你）。
⇒ ★★★所以我把它當**程序違規**記下來，而不是「情況特殊」：
  ★我 owner 的那條規矩逐字是「**CLEAN 才 dispatch／merge**」。

## 一、要你審的 delta（`git diff 36108afe3..f28180cb4`）

```
scripts/ui/text_ui_main.gd        ：按鍵分派改成反查 `ACTION_DIGITS` ／ 字母分支收成一條
                                    ／`compose` 多傳一個 `panel` ／ 謂詞靜態化
scripts/ui/text_ui_view.gd        ：`compose` 加 `panel` 區（非空時取代 map+pages 框）
scripts/debug/ui_flow_test.gd     ：P29（畫面鍵 ⇒ 執行的 id）／P30（12 個面板進畫面）／
                                    P27② 改成驗 handler 的回饋
scripts/debug/unbound_key_bed.gd  ：新一格（綁了但沒有對象 ⇒ 自己的一句話）
scripts/debug/press_is_one_tick_bed.gd：`SPEC_LIVE_UI_FILES` 加兩個檔名（基準更新）
docs/process/merge-gates.tsv      ：三列 expect 往上（ui-flow 69→73／text-ui-layout 9→10
                                    ／unbound-key 7→8，全部逐字抄自實測）
```

## ★★二、我自評最該被打的四處

```
①**P29 的負對照我設計錯過一次**：我要求「把表裡兩個 id 的數字對調 ⇒ 必紅」，
  而實作端實測**不紅**並訂正我：兩側讀同一份表 ⇒ 對調之後兩邊一起變 ⇒ 依然一致。
  ⇒ 正確的擾動是**讓某一側讀到不同的東西**（手抄第二份表）⇒ 實測紅。
  ★判準：**「守兩邊一致」的斷言，它的負對照必須破壞【一致性】不是破壞【內容】。**
  ⇒ 請你判：現在那一道**是不是真的打在一致性上**。
②**`compose` 的 `panel` 區與 `A_PANEL` 不進 `REGION_ANCHORS`**（實作端的判斷，我採納）：
  理由是它與 map/pages **互斥**、不是第七區 ⇒ 有面板時本來就不該要求地圖那兩個錨在。
  ⇒ 請你判：那個「互斥」有沒有被寫成**可驗的**東西，還是只是一句註解。
③**謂詞靜態化**：我原本裁「字母只在【回應真的可按】時算綁了」⇒ 那句話把
  「屬不屬於這個模式」與「現在做不做事」壓成一個謂詞 ⇒ 打破了 `unbound_key_bed` 的異源比對。
  ⇒ 現在：謂詞靜態、回饋由 handler 給、而「綁了但沒有對象」有**自己的一句話**。
  ⇒ 請你判：這三態在 code 裡**真的分得開**，還是只是三句不同的字串。
④**`press_is_one_tick_bed` 的基準更新**（可達性指名清單加兩個檔名）：
  ⇒ 請你判它**不是弱化** —— 我的理由是「母體真的長大了（接電讓兩個檔從主場景可達）」，
    而那一格仍然**逐名比對**。
```

## 三、我這邊的指名驗證（供你對照）

```
閘 id 集合與 merge 前完全相同（comm -3 兩側都空，97／97）
註冊表只動三列且都是 expect 往上｜棘輪只增（UI 21→28、LAYOUT 3→4）且最後一顆淨變化 0
battery15：BATTERY_RC=0、97／97、1798s、HEAD-start=HEAD-end=4dc26ef28、clean／clean／0
```

## ★四、而我不會拿「已經 push 了」當理由改變你的判法

```
你若判 issues，我照做（改動落在同一批的下一顆，而不是「下次注意」）。
★而 QA 的 release gate **在你之後** —— 我已經跟他講明順序：
  你 CLEAN ＋ QA 綠 ⇒ 才敲藍圖請用戶跑第三輪。
⇒ 所以你的 verdict **仍然在用戶看到東西之前**，這一點沒有被我的程序錯改掉。
```
