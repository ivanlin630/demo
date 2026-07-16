---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 統領日常成長已build但B2依舊100%卡死——查leader週轉率vs tenure累積曲線交叉，implementer單元測試孤立場景可能未覆蓋organic現實
---

# 統領日常成長無效——查leader週轉 vs 成長速率交叉（第四層雞生蛋?）

## 背景
`command-tenure-growth` slice 已build+merge流程走完，determinism CLEAN，但**organic 12月×2seed驗收：B2 gate_fail_b2_command 依舊與gate_b1_ok 100%全等，established依然恆0**。與implementer單元自驗（孤立單一leader續50 INTERVAL，統領0.25→0.265，推算12mo≈+0.10該爬過門檻~0.35）**完全矛盾**。見`2026-07-12-measurer-to-blueprint-command-tenure-growth-acceptance.md`。

## 待查（measurer候選假說，非代判，需你file:line/數字交叉驗證）
**leader死亡/更替速度可能快於統領成長速率**——本世界早期(月1-3)attrition慘烈(前幾輪已測~45%人口在頭3個月沒了)。若leader頻繁陣亡被替換，新leader從基礎技能重新累積，個體統領值可能從未有機會累積足夠tenure天數爬過門檻。implementer單元測試是**孤立場景**（單一leader持續50 INTERVAL無死亡干擾），可能沒覆蓋「organic世界leader常換人」這個現實條件。

## 查什麼
1. **leader更替機制**：leader陣亡/team解散後，新leader怎麼選出？統領技能是否從新leader的初始值(~0.25 mean)重新起算，或有繼承/加成？file:line。
2. **leader平均在任時長**（tenure）——這題可能要measurer量測（本世界leader平均能活/在任幾天/幾個INTERVAL），比對「爬到~0.35門檻需要幾個INTERVAL」（implementer單元測試給的速率反推）。若平均tenure << 所需INTERVAL數，即坐實候選假說。
3. 若坐實，這是**第四層雞生蛋**（同session pattern：farming→A門人口→B2繁榮閘→現在是leader週轉吃掉成長時間）——修法方向可能是：leader陣亡時統領技能部分繼承給接任者（非砍到重練），或加速日常成長速率到能在典型tenure內達標，或兩者皆需。**這需要你先給數字交叉驗證，我才能判方向，非猜。**

## 為何優先查
這是established=0調查鏈最新一環，已經第四層深。若不查清，下一輪brainstorm會繼續開錯藥（重蹈同一種「修了但沒觸及真根」）。

## 序
零跑+可能請measurer補leader tenure分布量測 → 交叉驗證候選假說 → to:blueprint 判方向 → 若需改設計語意用戶裁 → brainstorm→對抗→spec。
