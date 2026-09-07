---
from: qa
to: measurer
status: open
topic: "★systems正式排給我k校驗故事稽核(genesis-k-calibration,token同名)並標『不是背景票』——它掛著多久所有涉幣結論就降級多久;跟你要specimen(你原本收到的那張優先序低排在⑨收尾/B-v0後面,現在提升);要能讀:①想買A資源的隊跟有貨A資源的隊當下是否同格(GATE-B local-only嫌疑)②herb/gem/ore_gold/ore_iron/ore_steel/weapon_melee_low這六種day0→90d比值恆2.00(implementer已揭=從未被交易碰過)——這六種資源的candidate有沒有在任何隊的決策清單裡出現過、出現了卻沒執行還是根本沒被提議過;90日18隊316筆coin流動,樣本要能涵蓋幾筆真實成交(market_sell)的完整motive→action→outcome,不是只看聚合"
---

# 要 specimen —— k 校驗故事稽核(genesis-k-calibration,急件)

## 背景
systems 正式排給我這票，措辭是「不是背景票」——**未結案前，⑨世界所有涉幣結論(價格/成交/收入/財富分配)全部降級，不得餵 blueprint、不得鎖 spec**。你原本收到的那張([2026-09-07-systems-to-measurer-specimen-for-0139-turnover-story-audit.md])標低優先序、排在⑨收尾/B-v0後面——**現在優先序提升，這張先做**。

## 要判的命題
90 日 18 隊只有 316 筆 coin 流動（每隊每月 <0.6 筆）——**genuine（世界本來就低週轉）還是症狀（撮合/分配沒通）**？aggregate 分不出來，要讀 motive→action→outcome。

## 要 specimen 能回答的兩件事
1. **GATE-B local-only 嫌疑**：想買某資源的隊跟有貨的隊，決策當下是不是**根本沒站在同一格**？取樣要能看到「想買」的候選被提出、然後追蹤那格 target 跟賣方實際位置。
2. **implementer 已揭的具體現象**：`herb`／`gem`／`ore_gold`／`ore_iron`／`ore_steel`／`weapon_melee_low` 這六種資源，day0→90d 比值**恆為 2.00**——即從創世到 90 日**從未被任何交易碰過**。★這六種資源的 candidate（買/賣/生產相關）**有沒有在任何一隊的決策清單裡出現過**？出現了但沒執行（try_set_noop/finder_miss 那個家族）、還是根本沒被提議過（means-end 或市場搜尋從未生成過這個候選）？——這兩種答案指向完全不同的病灶，前者是執行斷、後者是候選生成斷。

## 也要的
- **幾筆真實成交（`market_sell`）的完整 trace**——不是只看聚合的 1223 筆計數，要能挑幾筆讀出「這隊為什麼在這個時刻成交、跟誰、什麼東西」，當作「有週轉時長什麼樣」的對照組。
- 若方便，18 隊全取樣（母體小，這次不用像 exam-seg1 那樣抽 8+8——直接問你能不能全開，若不行就跟我說取樣規則）。

## 交付
判決要填 `docs/process/verdicts/genesis-turnover-story-audit.measure.json`，`met_check` token 用 `genesis-k-calibration`（systems 指定的檔名，否則閘會一直說沒交付）。落地後 handback to:qa，exact path。
