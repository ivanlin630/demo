---
from: qa
to: implementer
status: open
slice: S2-root-reanchor
tier: behavior
topic: "★向你要逐tick specimen——你給的是聚合前後對照(舊根 vs 新根各一組終態數字),我判不了『為什麼排序會變』;要的是新根礦村隊(g1a那隊)25遊戲日內每次建設/採購決策的candidate/util/winner(含farming vs workshop vs mint互相競爭的那幾筆)+material/coin逐tick軌跡,才讀得出是征收假說(30h→24h料變多)還是別的;限制我照你標的接:單一fixture單一seed只能報這組下的故事,不能推廣"
---

# 要逐 tick specimen——聚合對照判不了因果

## 你給的材料 vs 我判故事性需要的材料
你給的是**兩個終態快照**（舊根 25 天結束時 vs 新根 25 天結束時的資源/設施總表）。
★**這答得了「結果不同」，答不了「為什麼不同」**——故事性稽核要的是 **motive→action→outcome 鏈**（`04_qa.md` 定義），
沒有逐 tick 的 candidate/util/winner，我只能看到兩個端點，看不到中間那隊每次評估時**想過什麼、選了什麼、為什麼**。
（這正是我剛答 systems 那題的同一條原則：聚合前後對照證不了因果，只有配對/逐筆才行——這裡不是配對值一致性，是決策鏈完整性，但道理相通。）

## ★要的東西
**新根（S2）**，g1a 那支礦村隊，**同一組 fixture／seed，25 遊戲日全程**：
1. 每次決策 entry 的 `candidates`（`opt`/`util`/`nd`/`要做的事`）——**尤其 `farming` 類 candidate 跟 `build_workshop`/`build_mint` 同時出現、互相競爭的那幾筆**。
2. `狀態` 段的 `material`／`coin`／`orders`（貢賦/貿易收支）逐 tick——**用來驗你那個「征收 30h→24h 讓料變多」的假說是否對得上時間點**（若料的增速真的在某個時間點跳動，且跟徵收週期改變的時間吻合，那是支持證據；若料增速平滑無跳動，那假說站不住）。
3. **若方便，舊根同隊同期也各出一份**（你信裡說舊根 worktree 還在）——沒有也沒關係，新根單邊我也能讀出「這組下故事說不說得通」，只是少了對照會更難分辨「這是新根特有的行為」還是「這條隊伍本來就會這樣選」。

## ★限制我照你標的接
你信裡已經講清楚：同 seed 但 fp 已變，兩邊是不同世界軌跡，**單一 specimen 能報的上限是「這組 fixture 下建造順序不同」，不能推廣成「重錨會讓所有領主改蓋農田」**。我判讀時會守這條界線，不會幫你把個案講成通則。

有了 trace 我才能判：新根建farming是「genuine 需求驅動」（跟我前兩票 wire-in/rich-visibility 判過的 material catch-22 同型）還是「征收假說」還是別的斷點。落地後 handback to:qa，exact path。
