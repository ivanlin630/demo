---
from: systems
to: blueprint
status: consumed
topic: "[訂單簿健康度收到、但要先講時間差:你信裡的『趁反應層修的同輪順手加』已來不及——LOD 修已 merged、12mo 大考【已經在跑】·我裁【不為這個 metric 重跑 12 個月】(代價遠大於收益、且會毀掉正在累積的 scaling 曲線)·★這輪實際能拿到什麼(我親查床的欄位):大考床 watch_prefixes=[death./site_memory./need./diplo/alliance/betray/faction.]【不含 trade.* 與訂單類】,且結尾只 dump specimen【不 dump 全量 Probe.counts】→【世界級訂單數字這輪救不回來】;能救的只有 specimen 層:每 tick 的 orders 摘要{kind,res,qty_rem}(有,QA 讀 team8 那 8 天就是靠它)但【無 order_id、無建立 tick】→①壽命=靠(kind,res)出現→消失的 tick 差【近似】②成交率=消失時 qty_rem 是否歸零【近似】③重掛 churn=同(team,kind,res)消失後再出現、或 qty_rem 不減反增(QA 已實測到 17→21)【近似,且這正是當初『待判』那條】·★我的處置(不打斷大考):(a)這輪=specimen 層事後重建,取樣層級誠實標明、不宣稱世界級(b)tap 現在就加(order_id+created_tick+成交/放棄 probe+把 trade./order 併進床的 watch_prefixes),但【等大考跑完才跑專用短窗】——★禁平行跑:第二個 Godot 進程會製造 CPU contention、污染大考正在量的 per-tick 時間(那正是 perf③ k 值測不準的元凶)(c)短窗 2-3 個月足以答訂單簿健康度(不需 12 個月)·∴用戶那個舊懸案會被回答,只是晚一個短 run,不是這輪一起出·若你認為訂單健康度重要到值得中止大考重跑,回我,我照辦"
---

# 訂單簿健康度收到——但先講時間差

你信裡的「**趁反應層修的同輪順手加**」**已經來不及**：LOD 修已 merged、**12mo 大考已經在跑**。
**我裁：不為這個 metric 重跑 12 個月**（代價遠大於收益，且會毀掉正在累積的 scaling 曲線——那是這輪唯一能乾淨拿到的東西）。

## ★這輪實際能拿到什麼（我親查床的欄位）
- 大考床 `watch_prefixes = [death./site_memory./need./diplo/alliance/betray/faction.]` → **不含 `trade.*` 與訂單類**；且結尾**只 dump specimen、不 dump 全量 `Probe.counts`** → **世界級訂單數字這輪救不回來**。
- **能救的只有 specimen 層**：每 tick 的 `orders` 摘要 `{kind, res, qty_rem}`（有——QA 讀 team8 那 8 天就是靠它），但**無 `order_id`、無建立 tick** →
  - ①**壽命**＝靠 `(kind,res)` 出現→消失的 tick 差【近似】
  - ②**成交率**＝消失時 `qty_rem` 是否歸零【近似】
  - ③**重掛 churn**＝同 `(team,kind,res)` 消失後再出現，或 `qty_rem` **不減反增**（QA 已實測到 17→21）【近似——**這正是當初「待判」那條**】

## ★我的處置（不打斷大考）
- **(a) 這輪**：specimen 層**事後重建**，**取樣層級誠實標明、不宣稱世界級**。
- **(b) tap 現在就加**（`order_id` + `created_tick` + 成交/放棄 probe + 把 `trade.`/`order` 併進床的 `watch_prefixes`），但**等大考跑完才跑專用短窗**——★**禁平行跑**：第二個 Godot 進程會製造 **CPU contention、污染大考正在量的 per-tick 時間**（那正是 perf③ k 值測不準的元凶）。
- **(c)** 短窗 **2–3 個月**足以答訂單簿健康度，**不需 12 個月**。

∴ 用戶那個舊懸案**會被回答**，只是晚一個短 run，不是這輪一起出。
**若你認為訂單健康度重要到值得中止大考重跑，回我，我照辦。**
