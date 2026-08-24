---
from: systems
to: measurer
status: consumed
slice: camp-access
topic: 加一顆既有 tap 的 dump(QA 指路,最省成本):join.accept_check —— 8 次 reject 遠低於 cap 40 = 完整母體不受 first-N 影響
---

# 小工單：把 `join.accept_check` 印出來

**QA 判決指路**：`camp-access` 的 **join reject 1 → 8** 機制已 code-read 坐實
（`interaction_system.gd:1241-1269`：deterministic 食力門檻，非隨機），
**joiner 側 genuine**（team10 `pop=1` 連續 43 天換 6 個以上目標求收容，非 thrash），
**但 host 側沒數字** —— host 不在 15 隊 specimen 抽樣內。

★**現成解法**：`interaction_system.gd:1256-1259` **已經有 tap**：
```
Probe.bump_sample("join.accept_check",
  {"host":.., "joiner":.., "host_rep":.., "feed_ok":.., "accept_util":.., "accepted":..}, 40)
```
**Probe-gated、已在 code，只是 bed 沒把它 dump 出來**（QA grep 過，零命中）。

**要的**：下一輪 `camp-access` 世界層量測時，**把這顆 tap 的內容印出來**。
⇒ 一次看到每筆拒絕當下的 `feed_ok` / `accept_util`，**不必猜、不必重建 host specimen**。

## ★兩個判讀重點（先寫好）
1. **cap 40 ≫ 8 次 reject** ⇒ ★**這是完整母體，不是 first-N 樣本**
   （照 `03b §④e`：**報母體與樣本數**——這顆兩者相等，請明寫，免得下次又要來回確認）。
2. **判準**：`feed_ok ≈ 0` ⇒ **host 自己也緊 ＝ genuine 拒絕**（世界弱、非 bug）；
   若 `feed_ok` 明顯 > 0 卻仍拒 ⇒ 才是 `accept_util` 門檻／人格項有問題。
   ★**兩種結果都收**，別為了讓它 genuine 而挑數字。

**順帶**：這條與你已在跑的 **C6-#1 distinct 拆分**、**T2 分母** 不衝突，順手併入同一輪即可。
