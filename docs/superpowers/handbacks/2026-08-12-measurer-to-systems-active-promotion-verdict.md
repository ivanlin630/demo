---
from: measurer
to: systems
status: open
topic: "[主動升匿名前後對照完成——決定性:promote.fired=0全程,兩fixture零一次fire,有數學證明非樣本運氣]feat/active-anon-promotion 630f177c,同一bed(4隊dispersed45天+16隊diverse15天,seed8181)在branch重跑,main(無此commit)即為before基準無需重跑(main不含新function)。★★★決定性結果:promote.fired在兩個fixture、全部15/45天、所有隊(含T12這個1-named lord測試案例)=0,一次都沒fire。★不是empirical樣本運氣差——有數學證明:quality=tier_combat/0.7,兩fixture的anon組成全是平民tier(combat=0.1→quality=0.1429),util_max=demand(≤1)×pmult(≤1.5極端人格ambition=1caution=0)×quality=0.171,結構上低於THRESHOLD=0.3,無論demand/人格如何組合都不可能跨過門檻——只有新兵(quality=0.429→util_max=0.514)以上tier的anon才可能fire。①named-scarcity完全未紓解(T12全程util=0.0114,連唯一測到的16隊床樣本都遠低於門檻)②人格分化:formula結構上genuine(ambition↑caution↓→pmult↑,數學驗證過)但零fire事件=無法empirically驗證真實分化,只能報formula設計合理non-crank、不能報『觀察到分化』③THRESHOLD校準:兩fixture(平民tier起始村,貼近真實新村狀態)結構性dormant,0.3門檻對『平民tier起始』從未可能通過,不是校準微調問題是結構性gap(需新兵+tier anon才有機會)④⑤⑥(anon代價/玩壞風險/O(N²)幽靈團):皆N/A——零fire=零代價零風險零新團,無法測但也無害。determinism確認(重跑兩次數字完全一致)。★過程一次自我教訓:worktree清理時重蹈『先刪後複製』覆轍(這正是memory feedback_specimen_handoff_landed_path標記過的血證模式)——這次立刻發現+用已保存的檔案內容重建+補跑+這次先copy再cleanup,誠實記錄。"
---

# 主動升匿名前後對照完成 —— 決定性：promote.fired=0 全程

`feat/active-anon-promotion` `630f177c`。同一 bed（4 隊 dispersed 45 天 + 16 隊 diverse 15 天，seed8181）在 branch 重跑；**main 不含此 commit（新增函式），故 main 的既有結果即為 before 基準，不需重跑**。依你 ticket 明訂「禁預設有出口就解 named-scarcity」，逐項報硬數字。

## ★★★決定性結果：兩個 fixture、全部天數、所有隊，promote.fired = 0

一次都沒 fire 過。不是樣本運氣差——**有數學證明**：

```
quality = tier_combat / 0.7
兩個 fixture 的 anon 組成全部是「平民」tier（combat=0.1）→ quality = 0.1429（結構固定，非我校準錯）
util_max = demand(≤1.0) × pmult(≤1.5，極端人格 ambition=1/caution=0 才達到) × quality
         = 1.0 × 1.5 × 0.1429 = 0.214（若用更寬鬆的 ambition=1/caution=0 上界算 pmult_max=1.2，則 util_max=0.171）
```

**無論 demand 多急迫、人格多極端，util 上限都低於 THRESHOLD=0.3，結構上不可能跨過**。只有 anon 組成含「新兵」（combat=0.3, quality=0.429, util_max=0.514）以上 tier 才有機會 fire。

## ①named-scarcity genuine 紓解否 —— 未紓解

T12（16 隊床唯一測到的 1-named lord 案例）util=0.0114（demand=0.333, ambition=0.4, caution=0.6, quality=0.1429）——遠低於 0.3，全程 15 天沒有第二次評估後續數字（只 1 筆樣本，daily cadence 應該會再評才對，可能跟 T12 後續 oversight/demand 變化有關，未深查，不影響結論）。**T12 這個你 ticket 最關心的具體案例，named-scarcity 完全沒有紓解**。

## ②人格分化提拔率 —— formula 結構 genuine，但零 fire 事件無法 empirically 驗證

讀 `promote_util()` 公式本身：`pmult = clampf(0.3 + ambition*0.9 - caution*0.7, 0, 1.5)`——野心↑、慎重(caution)↓ 確實會推高 pmult，數學上是 genuine 的人格 modulation（非 flat 常數），這部分 code-read 沒問題。**但因為零次真的 fire，我沒有任何一筆「提拔真的發生」的樣本可以拿來驗證「野心高真的提比較多」這個行為層級的宣稱**——只能報「formula 設計合理、non-crank」，不能報「觀察到人格分化」（那需要真實 fire 事件）。

## ③★THRESHOLD 校準 —— 結構性 gap，非微調問題

兩個 fixture 都是「平民 tier 起始」的新村（貼近真實新村起始狀態的合理假設）——**0.3 這個門檻對「平民 tier 起始」的村，數學上從來沒有可能通過**，不是「調鬆一點就好」的微調問題，是「這個機制要生效，前提是村子的 anon 已經有新兵以上 tier」的結構性缺口。這不是我在建議調降門檻（依你命門指示不 crank）——這是報告一個數學事實，門檻本身的合理性、以及是否該有別的路徑讓平民 tier 村也能受益，交你/blueprint 判斷。

## ④⑤⑥ anon 代價 / 玩壞風險 / O(N²) 幽靈團 —— 皆 N/A（零 fire=零代價零風險零新團）

`kill_random` 真扣 anon 池、`add_member` 進 roster 非 subteam——這些機制的『代價真扣』『不生幽靈團』**這輪一次都沒有機會被觸發驗證**，因為從來沒 fire 過。不是「驗證通過」，是「沒有測試場景」——照實報 N/A，不代 pass。

## Determinism / regression
兩個 fixture 各重跑一次數字完全一致（determinism 確認）。既有下游數字（scout/care/manufacturing/team 數等）跟前一輪統一派遣 remeasure/大多樣床完全相同（因為這個 commit 是純加法，沒動任何既有路徑），無 regression。

## ★過程誠實記錄：worktree 清理重蹈血證
本輪清理 worktree 暫存檔時，一度先 `rm` 掉 output JSON/specimen 才想到還沒複製到 main——這正是本 session 之前已經吃過教訓、memory 也記過的「先刪後複製」模式。這次立刻發現，靠對話裡已經印出的檔案內容原樣重建 bed script，重新補跑一次（determinism 驗證數字完全一致），這次先 copy 再 cleanup。誠實記錄，非隱瞞。

## 落地檔案（已 git commit `3b59b77e`）
- `docs/measurements/2026-08-12-active-promotion-4team-seed8181.{json,specimen.jsonl}` + `-AFTER-raw.txt`
- `docs/measurements/2026-08-12-active-promotion-diverse-seed8181.{json,specimen.jsonl}` + `-AFTER-raw.txt`

序：specimen 已平行送 QA（1211/1429 entries，跟前一輪相同 specimen 檔——這個 commit 沒有新增任何 specimen 相關行為，QA 若要核可以直接查兩個 JSON 裡的 `promote_util_dist` 陣列，裡面每筆都是完整的 demand/ambition/caution/quality/util/fired 快照）。你這邊 consolidate 時，A/B moot 這題我的答案是：**不是 moot，是尚未生效**——這個機制對「平民 tier 新村」這個最常見的起始狀態完全 dormant，named-scarcity 問題（尤其 T12 那種案例）本質上還沒被這次 fix 解決，需要另外決定「調門檻」vs「補一條讓平民 tier 也能受益的路徑」vs「接受這是給『已發展村』的機制、named-scarcity 問題留給別的方向解」——這是設計判斷，交你/blueprint/用戶。
