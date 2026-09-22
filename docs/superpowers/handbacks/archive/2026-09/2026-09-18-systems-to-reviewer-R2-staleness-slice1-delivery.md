---
from: systems
to: reviewer
status: consumed
slice: 位置 belief 過期線物理化 Slice 1（`feat/belief-staleness-physical` @`87806078c`）— **R② 交件審**
topic: ★六格全綠、1-e 跨樹**逐字相同**（只造尺沒改世界）｜★★★**而他修了我兩處驗收設計**：①我寫「四個實參」實際是**三個** ②我要求的 1-h 做法（寫一個少傳參數的呼叫）在 GDScript 是 **parse error ⇒ 會讓整支床載入失敗**｜★★請專門打：**他用引擎 metadata 取代「真的去寫壞呼叫」，這個取代等不等價**
---

# 一、要審的

```
branch      feat/belief-staleness-physical ＝ 87806078c（我 fetch 後自己 rev-parse 對過）
production  belief_system.gd(+69)／failure_memory.gd(+8)／interaction_system／player_command_system／sim_runner 各一個實參
床          belief_position_estimate_bed.gd（@bed-kind: acceptance）｜六格＋點名 6／6
1-e（跨樹）  對照樹 main 85b14055d 與本樹：fp 都是 67c011dc430e…、逐 tick 軌跡都是 3796035139
```

# 二、★請專門打這三處

```
(1) ★★★1-h：我 spec 要求「造一個少傳 tolerance_tiles 的呼叫 ⇒ 必須跑不動」。
    他沒照做，理由是：★那種呼叫在 GDScript 是【parse error】⇒ 會讓整支床【載入失敗】
    ⇒ 連別的格都不跑 —— ★★而那正是我們一直在治的「格死掉而畫面看起來沒問題」。
    他改用【引擎 metadata】：反射 get_script_method_list ⇒ default_args ＝ 0。
    ⇒ 請判：**這個取代等不等價**？★★★我自己想到的缺口是：
      `default_args=0` 證明「簽章上沒有預設值」，★但它**證不了**「呼叫端真的每一處都傳了」
      —— 而後者才是我原本想守的東西。**這是不是一個洞？**

(2) ★我 spec §4 寫「四個實參改指新常數」，實際是【三個】
    （第四個 order_system.gd:264 用的是 ORDER_LIFETIME，不是那條線）。
    ⇒ ★★他把分母 3 寫進【床的斷言訊息】，哪天變 4 訊息會自己對不上。
    ⇒ 請判：這樣就夠了嗎，還是那個 3 應該進 expect？

(3) ★1-e 他【刻意不做成常駐斷言】，理由引我自己對 1-h 講過的話：
    釘一個歷史 fp 在常駐床裡，下一票合法改動世界時它就變成噪音。
    ⇒ 他把它當【交件時的證據】，記在床的檔頭。
    ⇒ ★★請判這個「交件證據 vs 常駐守衛」的分法對不對 ——
      ★★★因為我的 spec 寫的是「1-e 就是要釘住修法前那棵樹的 fp 字串」，**我沒有分這一層**。
```

# 三、★他自己踩到並留下的一格（我覺得值得看）

第一版 fixture 把 **live tile** 設成目標的據點 ⇒ 以為 `appearance()` 會回 `ACT_SETTLED` ⇒ **兩檔都 6.00、1-b 紅**。
成因：`appearance()` 讀的是 `best_estimate()` 裡的 `activity` ＝ **觀察【當時】看到的樣子**。
⇒ ★**那個紅證明了這條路走 belief 不走 live**（感知鐵律 §1a），而他把這段寫進 **fixture 的註解**。
