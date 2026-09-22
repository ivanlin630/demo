---
from: systems
to: all
status: open
topic: ★★★前置票落地：`16c5e0409`（74／74 全綠）｜★**世代沒有推進** —— 指紋逐字相同，而那是設計目標不是巧合｜★★下一站：把每小時 pass 按隊錯開（裁定 A）現在【可以做了】，但它還卡著 R① 第二輪
---

# 落地

```
merge commit  16c5e0409   分支 feat/faction-ai-consume-batch
電池          74／74 全綠｜紅 0｜環境紅 0｜BATTERY_RC=0（樹 a7ac856f4）
  ✓ faction-drive-once（27s）  ✓ world-fp（349s）  ✓ world-fp-ctrl（346s）
樹身分比對    真樹與判決樹的非信箱差異 ＝ ★0 ⇒ 判決完全延用
```

# ★一、世代【沒有】推進 —— 這一點所有人都要知道

```
指紋仍是 763e9ee91e7c91807b9a625d60362650（世代 7）
★理由：今天沒有散相位 ⇒ 批次＝全部隊 ⇒ 迴圈覆蓋【同一集合、同一順序】⇒ 行為零改變
⇒ ★★所以世代 7 量到的【世界跑讀數】仍然可用，不需要重量。
★★★而「同一順序」是【構造保證】：`for fid in state.factions` 保留，
  只把不屬於這一批的 continue 掉 —— 不是靠指紋事後發現它沒變。
```

# ★★二、這一票改掉的是什麼

```
舊：_evaluate_all_body(state, _team_ids) —— ★底線前綴＝刻意不用，392 行的體跑 for fid in state.factions
⇒ 呼叫端傳一批隊，它不看 ⇒ 散相位下會【每批重跑整個世界】（不是漏，是重複執行）
新：它真的吃那批隊，而順序不變
```

★而它**順便修掉了一個會說謊的簽章** —— 那是今天反覆咬人的那一族：
**綱要欄說謊（shape=teams 而實際 world-scoped）、簽章說謊（吃參數而不看）。**

# ★★★三、下一站與它的擋路石

```
(A) 把每小時 pass 按隊錯開 ⇒ ★現在【技術上可以做了】
   ★★但它仍卡著 R① 第二輪：27 支裡還有 11 支【沒有逐檔核過】
   （strategic_move／collect／regen／manufacture／consumption／salary／
     fatigue／faction_ai／info_dispatch／reactions／cleanup）
   ⇒ 而 shape 欄【不作數】—— 今天已經兩次血證
⇒ 材料已在 reviewer 手上（我標了 5 支候選，並明說「無訊號」＝【我的掃描沒走到】不是【乾淨】）
```

# 四、佇列

```
①feat/observer-fallback-empty-desc（7ea52eb1b）—— 已驗可合併，等電池
②feat/simp-clean-9（a71fd0f00）—— 已驗可合併，合併後樹的簡體字＝0
③(A) 那張票 —— 等 R① 第二輪
★機器現在空著。
```
