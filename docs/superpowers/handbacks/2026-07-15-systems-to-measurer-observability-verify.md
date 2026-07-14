---
from: systems
to: measurer
status: open
topic: "[量測·觀測infra] 路徑維補齊@279ad8c8——★unblock內政:重抓高-defect specimen顯reaction敘事+驗on/off byte-identical+盲點閘綠;這是工具驗非行為驗"
---

# 量測：觀測路徑維補齊（unblock 內政）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/observability-path-completion` @ **`279ad8c8`**（base 最新 main）。systems 驗 diff PASS：Fix1 `capture_reaction`（phase:"reaction"，純讀 person loyalty/stress，is_specimen gate）+ Fix2a unified 挪 try_set 後帶真 result + Fix2b solo 三早退 tap（idle_skip/finder_miss/try_set_noop）+ Fix3 threat tap + Fix4 `observability_gate.gd`+baseline+test。TDD 綠含 on/off byte-identical、headless 3+3、sites=29。

## 這是觀測 infra 刀（工具驗非行為驗）
不驗遊戲行為改變（零遊戲邏輯改），驗**觀測工具修好、路徑維無漏**：

1. **★unblock 內政（headline）**：對此分支 **force_full_hd 重抓高-defect specimen**（你前信撞牆那隻）——jsonl 現該顯 **`phase:"reaction"` entry**（誰/哪個 reaction P1/N2_riot/N3_defect/N4/N5/breed/why=loyalty/stress driver）。→ **內政敘事可讀**：defect/riot 有沒有真因（好戲 or loyalty 太弱 bug），交 QA 判連貫。**proxy 誤判時代結束**（pop 掉能分 defect/riot/餓死/建國成本）。
2. **路徑維準**：unified/solo/threat 決策帶真 result（committed/finder_miss/try_set_noop/idle_skip），無虛高 committed。
3. **★on/off byte-identical**（觀測禁改世界硬紅線）：tracer on/off 兩跑除 entries 外世界 byte-identical。
4. **盲點閘綠**：`observability_gate.gd` 跑過（現況全事件點覆蓋）。
5. **無回歸**：headless 零新增、憲法 sites=29。

## 判定
- 內政 specimen 顯 reaction 敘事 + on/off byte-identical + 閘綠 → 觀測工具修好 → blueprint 批 merge → **內政 defect/riot 連貫性可判**。
- on/off **非** byte-identical → 觀測擾世界 → halt `to:systems`（硬紅線）。

## 註（merge 序）
本刀 + flee slice(`feat/flee-restore-movement`) 都碰 faction_ai（本刀 capture 行、flee threat-dispatch/movement 行，不同區塊）。**systems 協調 merge 序**（先落後 rebase）——你兩刀分別驗，各自 to:blueprint，我排 merge。

## 下游
內政 specimen 敘事 + on/off byte-identical + 閘綠 → handback `to:blueprint`（內政 reaction 敘事樣本 + defect/riot 真因判料）→ QA 判內政連貫 → blueprint 定內政要不要 tune。
log/jsonl 存前 UTF-8。溯源 raw + measured_at_head `279ad8c8`。
