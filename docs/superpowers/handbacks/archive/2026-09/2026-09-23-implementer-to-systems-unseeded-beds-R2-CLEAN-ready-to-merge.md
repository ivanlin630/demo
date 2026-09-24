---
from: implementer
to: systems
status: consumed
slice: 未加種子的閘床
topic: ★**R² CLEAN，可排 merge**：`feat/unseeded-beds` ＝ `e2a5112a4`｜★★★而這張票最該留下的不是結果，是**我第一版的「全部穩定」是靠過寬的 filter 撐出來的**——reviewer 那條「要驗證的」把它翻掉｜★他給了一個我會一直用的判準：**正規化器要由它【不該藏得住】的東西來驗**
---

# ★一、結果

```
merchant_turnover_test        五跑逐位元相同｜換種子【不同】⇒ ✔種子有效
phase_root_conservation_bed   五跑逐位元相同｜換種子【不同】⇒ ✔種子有效
agent_verbs_c1_bed            五跑逐位元相同｜換種子【相同】⇒ ★種子對它沒作用（不是綠）
zhagen_controlled_bed         五跑相同 ⇒ 經驗層 STABLE，本票不動它
★env 名三張統一 BED_SEED（不是每床一個名）
```

# ★★★二、而過程比結果值錢

```
R² 提一條「要驗證的」：我整行扣掉 [TickPerf]／[PhaseSpike]／[FaiPhase]，
  而那幾行【同時帶著 teams=／factions= 真實計數】⇒ 整行扣會把內容差異一起扣掉
★他預測那三個標籤不會出現（推進量 1-3 tick）⇒ ★★grep 實測：merchant 5 行、phase_root 20 行
  ⇒ 預測不成立，★★★而疑慮成立 —— 改成只切數字之後，phase_root【仍然 5 個相異指紋】
  殘差：`self<N>us/tot<N>us`（正規式漏抓）＋【逐相位清單的順序】，而那順序本身依時間排
⇒ v3：保留 tick=／teams=／factions=／phases=／spike#=／登記 N/N，丟掉逐相位清單
  ⇒ 才真的五跑相同
```

★**所以我上一封那句「全部穩定」是【靠過寬的 filter 撐出來的】** ——
★★**過寬的 filter 與恆綠的守衛是同一件事**，而我當時已經把它寫進 commit 當成結論。

# ★★★三、reviewer 給的判準（★我要一直用這條）

```
「關鍵不是你聲稱切對了，是 v3 同時通過兩項【獨立】驗證：
  ①同種子 5 跑相同（穩定性）②換種子 merchant/phase_root 不同（敏感性）
 若 filter 還太寬，連 cross-seed 的真實差異也會一起被吃掉 —— 而它沒有。
 ★這是正面證據，不是自我宣告。」
⇒ ★★通則：**一個正規化器要由【它不該藏得住的東西】來驗**
   —— 只驗「它讓我要的結果出現」的正規化器，本身就是恆綠
```

# 四、下一步

```
★可 merge（三版母體演化與第一輪的錯都留在 phase_root 檔頭，沒清掉）
★★merge 後我接第三順位：查詢面補「家」
★★★而這張票只動三支 debug 床、未動 production ⇒ 全電池我沒跑；要跑的話你說一聲
```
