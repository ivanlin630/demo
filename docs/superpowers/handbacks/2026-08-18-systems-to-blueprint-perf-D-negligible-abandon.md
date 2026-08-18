---
from: systems
to: blueprint
status: open
topic: "[perf刀2=D quantify negligible→你Phase2 owner裁(建議abandon)·★D gain=噪聲範圍(平均+1.7~4.5% < 同側兩跑波動11-16%、n=2分不出真效果、非顯著gain非退化)·原因:①plains 52.1%最大bucket D只砍半(forest/mountain砍70-82%但若查詢大宗落plains平均收益低)②★terrain=='' 路徑D走keys()複製全tile-id陣列overhead(baseline直接for tid迭代免複製)部分抵銷·correctness已證byte-identical(86c2fe82)但gain是噪聲·★★perf-arc meta血證:刀B(memo)+刀D(spatial index)=Phase1建議的兩個frontier掃描優化皆negligible/dead、真win是trivial順手刀A(_hex_dist static砍FactionAISystem.new()alloc ~8-13%)——真成本是alloc churn非掃描演算法(profiling指frontier掃、實為alloc)·★我建議(你裁):(a)abandon D(negligible+複雜度+terrain=''overhead、刀A已收win、discard不merge死複雜度)→刀3 C(gather de-dup 8+處另值)or(b)refine D(只具體terrain走index、terrain=''保原全掃免overhead、但需先量query terrain分佈知值不值=再一輪)·我lean(a)abandon(D不earn複雜度、alloc才是根、C/剩alloc-hotspot更值)·hold D merge等你裁·perf方向若轉=剩FactionAISystem.new()/其他alloc churn掃(刀A同族真根)可能比frontier掃更值·地基KEEP"
---
# perf 刀2=D quantify negligible → 你裁（建議 abandon）
## ★D gain=噪聲範圍
平均 +1.7~4.5%（wall/ctx_total）**< 同側兩跑波動 11-16%**、n=2 分不出真效果=非顯著 gain 非退化。原因：①plains 52.1% 最大 bucket、D 只砍半（forest/mountain 砍 70-82% 但若查詢大宗落 plains 平均收益低）②**★terrain=="" 路徑 D 走 keys() 複製全 tile-id 陣列 overhead**（baseline 直接 `for tid` 迭代免複製）部分抵銷。correctness 已證 byte-identical（86c2fe82）但 gain 是噪聲。
## ★★perf-arc meta 血證
刀B(memo)+刀D(spatial index)=Phase1 建議的兩個 **frontier 掃描優化皆 negligible/dead**、真 win 是 trivial 順手**刀A**（_hex_dist static 砍 FactionAISystem.new() alloc ~8-13%）——**真成本是 alloc churn 非掃描演算法**（profiling 指 frontier 掃、實為 alloc）。
## ★建議（你裁）
- **(a) abandon D**（negligible+複雜度+terrain=="" overhead、刀A 已收 win、discard 不 merge 死複雜度）→ 刀3 C（gather de-dup）or **轉掃剩 alloc churn**（刀A 同族真根、可能比 frontier 掃更值）。
- (b) refine D（只具體 terrain 走 index、terrain=="" 保原全掃免 overhead、但需先量 query terrain 分佈知值不值=再一輪）。
**我 lean (a) abandon**（D 不 earn 複雜度、alloc 才是根）。hold D merge 等你裁。地基 KEEP。
