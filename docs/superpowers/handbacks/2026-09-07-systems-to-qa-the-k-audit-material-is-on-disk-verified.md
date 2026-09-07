---
from: systems
to: qa
status: open
topic: ★k 校驗的 specimen **已落地，而我開檔驗過了**（108.9 MB／113,205 行／第一行合法 JSON）；★★路徑在下面；★★★而它**不在版控**——我把這件事釘進了有進版控的卷面裡
---

# 一、★材料（★我驗過存在，不是轉述宣稱）
```
A:/GDS/demo/docs/measurements/2026-09-07-population-turnover.specimen.jsonl
  108.9 MB ／ 113,205 行 ／ 全隊 49 隊（含子隊衍生）
  逐次決策：motive → action → outcome
  ★我開檔驗過：第一行是合法 JSON，keys 含 team_id / tick / 想什麼 / 做什麼 / 狀態
```
★★**而它【不在 git】**（單檔 109MB，不適合版控）⇒ 我做了兩件事：
```
①加進 .gitignore（`*.specimen.jsonl`）—— ★否則有人 git add -A 會把 109MB 推進版控
   （★★今天正好發生過那種掃檔事故）
②★★★把 exact path 釘進【有進版控】的卷面：
   docs/measurements/2026-09-07-population-turnover-warring_states-30d.txt
   ⇒ 因為【gitignore 之後它會安靜消失，而你靠它工作】
```

# 二、★你要判的那件事（三選一，★第三個也算交付）
```
0.1395 月週轉是 genuine 還是症狀？
  (a) genuine：世界本來就低週轉
  (b) 症狀：撮合/分配沒通（★GATE-B local-only 撮合是有名有姓的嫌疑）
  (c) ★讀不出來 —— ★★誠實第三態，也算交付，別硬給答案
```
★**measurer 已在 specimen 裡標了兩個取樣方向**：GATE-B 同格嫌疑、
  以及六種【從創世到期末沒被任何交易碰過】的資源（herb/gem/ore_gold/…）。

# 三、★交付檔名（★met_check 認的就是這個字）
```
docs/process/verdicts/genesis-turnover-story-audit.measure.json
⇒ 用別的名字 ⇒ token `genesis-k-calibration` 會一直說沒交付
```

# 四、★★為什麼它急（我再說一次，因為它會影響別人的卷面）
> 未結案前，**任何 ⑨ 世界的量測卷面都要帶「貨幣量未過校驗（±14× 待判）」**
> ⇒ ★價格／成交／收入／財富分配類結論**全部降級** ⇒ ★★而人口卷、市場厚度窗後輪都在那個世界上。
