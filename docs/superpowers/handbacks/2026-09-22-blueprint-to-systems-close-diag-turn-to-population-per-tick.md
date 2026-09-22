---
from: blueprint
to: systems
status: open
slice: 凍結線轉向 — 裁定
topic: ★**①診斷票結案（沒有單一元凶；排名富集＝尺寸效應，佔比 17–20% 恆常）**｜★★**②轉向「母體」：開一張量測票——每 tick 必印（不只 >100ms）「本 tick 決策隊數／幀總時」，回歸凍結幀 vs 全體；兩條岔路預註冊在下**｜★**③equip_mobilize 開「整體變快」票，名目寫清楚不治凍結，排在②之後，單位整場 %、驗收 p99/median**
---

# 一、①結案：收，票身路徑收

# 二、②母體量測票（預註冊，數字前）

```
量：每 tick 一行（★不設 >100ms 門檻，全 17280 幀）：tick、frame_total_us、n_deciders（本 tick 進 gather/rank 的隊數）、n_teams_alive
   ⇒ 母體＝全幀；凍結幀（>2s）是子集，不再只跟昂貴幀比
兩顆種子、12 天、HW-2／世代 6；樁成本要低（兩個整數一行）；樁開/關 fp 逐字相同（不變量 #7）
判準（岔路）：
  (A) 凍結幀的 n_deciders median ≥ 1.5 × 全幀 n_deciders median
      ⇒ 凍結＝【決策擁擠】：同一 tick 太多隊一起決策（cadence 對齊/同相）
      ⇒ 修法方向＝把決策攤開到不同 tick（cadence 相位錯開），不是降單價；驗收看 >2s 幀數與 p99 同降、median 不動
  (B) 凍結幀 n_deciders 與全幀差不多（< 1.2×）
      ⇒ 凍結＝【單次決策昂貴】：某些 tick 的決策各自更貴（候選多／地圖大／belief 多）
      ⇒ 下一格＝凍結幀內 per-decision 成本分佈（frame_total ÷ n_deciders）vs 全幀，看是不是同幾隊反覆
  (C) 1.2×–1.5× ⇒ 兩者混合 ⇒ 先做 (A) 的攤開（便宜、可逆），再量 (B)
★n_deciders 的定義要釘死：「進入 gather() 的隊數」（跟 U₇ 那套 memo 的 begin_gather 同一個計數點，零新語意）
```

# 三、③equip_mobilize「整體變快」票

```
它佔每個昂貴 tick 的 17–20%，恆常 ⇒ 是整體成本不是凍結；開票但名目＝「整體」，驗收＝p99／median（雙 checkout 同機），不看 >2s 幀數
排在②之後；預註冊照模板四欄，單位整場 %，門檻 U ≥ 4.76% 整場（等價於先前 10% gather 那條，同代價類別）
第一格＝它內部什麼在放大（隊數 vs 動員人數 vs 裝備種類）—— 讀 code 給結構，量給數
```

# 四、順序（實作端單線）

```
對照臂結果（在跑）→ freeze_sample_bed 加分位數＋②的兩欄（同一支床、同一次改）→ 12 天兩顆種子重跑 → 依 (A)/(B)/(C) 開票 → ③
subteam-idle 前置量測（已降級）與這條平行，量測員做
```
