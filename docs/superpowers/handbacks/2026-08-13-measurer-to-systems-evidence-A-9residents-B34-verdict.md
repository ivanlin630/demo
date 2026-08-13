---
from: measurer
to: systems
status: open
topic: "[證據包A完成——9 resident全數facility=False恆定,生產option從未applicable(非輸argmax);TASK_PRODUCE全月零出現;camp/settle/occupy三路皆capture=0,真resident化機制未查出;occupy reachability濾94.1%同prey83.3%跨機制同型]+B③④紮營26/2037entries出現,每次都輸(gap0.11-1.25),對手多為maintain_food/覓食/徵收/佔村,genuine性未查(deferred)"
---

# 證據包A(9 resident逐項) + B③④(紮營候選比分) —— 全部純讀+既有tap，零 production 改動

## ★證據包A —— 9 個 resident team 逐項（`team_id` = 30/45/47/58/70/83/87/109/111）

**①有無 manufacturing facility**：**9 個 team，全部出現的每一天，`has_manufacturing_facility=False`，無一例外。** 0/33 個「team-day」樣本有 facility。

**②TASK_PRODUCE 在不在 candidate**：「生產」option 的 applicable = `has_own_outpost AND has_manufacturing_facility`。這 9 隊 `has_own_outpost` 全部 True，但 `has_manufacturing_facility` 全部 False——**「生產」這個 option 對這 9 隊從頭到尾一次都不 applicable，不是「進了候選但輸給別人」，是根本沒資格進候選。**

**③labor pool（TAG_PRODUCE）**：全部 True，全程——9 隊都掛著 TAG_PRODUCE 標籤（結構上算「producer 類」），但這個標籤本身不影響 applicable gate（②已經先擋住了）。

**④current_task 逐日序列**：33 筆 team-day，**TASK_PRODUCE 出現次數 = 0**。實際分布：`return_home`(返家補給，30 筆，壓倒性多數)、`治理`(駐守，只需 has_own_outpost 不需 facility，早期幾天出現，之後轉 return_home)、`逃跑`(1 筆，team30 剛變 resident 那天，食糧已見底)。**這 9 隊變 resident 之後幾乎全程都在「回家找糧」，一天都沒有真正生產過。**

**⑤gate 擋在哪**：不需要另外查 per-team `produce.appl_kill_nofacility` 計數器——①②已經用純讀直接坐實：擋的就是 `has_manufacturing_facility`，100% 一致、零例外，這題不需要更間接的證據。

**⑥第三路 resident 化路徑 —— camp/settle/occupy 三路全部排除，真機制這輪未查出**：

```
occupy.scan_outpost_target = 22683
occupy.scan_kill_unreach   = 21347  (94.1%)  ★跟 prey.unreachable(83.3%)同型態
occupy.scan_kill_notweak   =  1250  ( 5.5%)
occupy.scan_kill_margin    =    12
occupy.scan_passed         =    74
occupy.applicable          =    48
occupy.dispatch            =     7
occupy.capture_flip        =     0   ★★★
```

**`occupy.capture_flip`=0**——佔村這條路徑這個月一次都沒有真的完成翻旗。加上先前已確認的 `camp.fire`=0、`settle.convert_to_resident`=0，**三條我能想到/tap 到的「變成 resident」路徑全部是 0**，但 resident_n 月底仍然從 0 長到 9。**這 9 隊怎麼變 resident 的，這輪沒有查出真正機制**——結構線索：9 隊裡 6 隊 `is_subteam=True`，且全部從「出現在我的 trace 裡」那天起 `has_own_outpost` 就已經是 True（不是逐漸取得的），比較像是「subteam 被派去一個自家/同 faction 已經擁有的據點」而不是「新佔領/新建立」，但這只是結構觀察不是坐實的因果，交你 code-read 判斷（可能是某種 GOVERN 派遣或 world-gen 繼承機制，這輪沒追）。

★附帶發現：`occupy.scan_kill_unreach`=94.1%——跟 prey funnel 的 `prey.unreachable`=83.3% 是同一種型態（reachability 是主導濾網，不是 belief 或 weakness）。這是這輪第二個獨立機制印證「移動/可達性」是這個世界多處候選篩選的共同瓶頸，值得標記為跨機制主題。

**額外印證**（非 ticket 直接問，但強化整體故事）：這 9 個「resident」自己的 `food_days` 也在崩——多數逼近或等於 0（team30/58/70/83/87 到月底都是 0.0 或接近），只有 team47 相對穩定在 2.6-3.5。**連好不容易變成 resident 的這一小撮隊伍，自己也快餓死，沒有餘裕生產——就算 facility 齊了，這批隊的處境也未必撐得到生產。**

## ★證據包B③④ —— 紮營候選比分（沿用既有 1 月窗 specimen，未重跑）

`2037` 筆 specimen entries 裡，紮營出現在候選清單的只有 **26 筆（1.3%）**——本身就很罕見。**這 26 筆裡，紮營一次都沒贏過**（gap 全部為正，範圍 0.114–1.247）：

| 對手（贏家） | util 範圍 | 出現次數（26筆中） |
|---|---|---|
| `maintain_food:resource` | 0.17–0.92 | 6 |
| `徵收`（tribute） | 0.80–0.97 | 8 |
| `覓食` | 0.79–0.83 | 3 |
| `佔村` | 0.58–3.06 | 9（含 team42 後段暴衝到 3.06） |

紮營自己的 util 範圍 0.161–1.808（同一隊 team42 隨劇情推進從 0.302 一路漲到 1.808，但同時間贏家佔村漲得更快 0.823→3.055，gap 反而擴大）。team6 那組（tick7000-7200）比較特別：紮營 util 穩定在 ~0.684、對手徵收 ~0.797，兩者差距一路從 0.235 縮到 0.114（紮營在追但沒追上）。

**④對手 util genuine 與否——這題誠實答不了，需要 code-audit 非純測量**：我可以確認「紮營每次都輸、輸給誰、輸多少」這個純觀測事實，但「徵收/覓食/佔村/maintain_food 這些贏家的 util 公式本身合不合理（真實期望值 vs 死常數灌水）」需要逐一讀對應 term 公式的輸入變數是否 genuine（同你已經開始查的紮營 camp_drive flat 1.0 那種手法），這不是我這輪能單靠聚合/specimen 判斷的，交你 code-read 或另開一輪 formula-level 稽核。

## Determinism

沿用同一 seed1337/1月窗，`specimen.jsonl` 逐位元跟前一輪一致（2037 entries 不變）。這輪 bed 擴充**全部是純讀（呼叫既有 static 函式）+ 既有 production tap 監看**，**零新 production tap、零 production code 改動**——`git status` 確認 `scripts/simulation/` 目錄全乾淨，沒有東西需要 revert。

## 落地檔案（已 commit `94c0eda8`）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.json`（補 `resident_detail` 逐日逐團欄位 + occupy funnel）
- `docs/measurements/2026-08-13-phase3-evidenceA-synthesis.txt`（本信引用數字的 python 解析輸出）
- `docs/measurements/2026-08-13-phase3-campB34.txt`（紮營候選比分逐筆列表）

specimen 沿用已附批次；這輪結論（facility=False 恆定/TASK_PRODUCE 零出現）是逐團逐日 state 直讀，非推論，QA 若要核可直接比對 `resident_detail`。

routing：這題現在有非常乾脆的答案——**9 個 resident 不生產，根不在 task-assignment（argmax 選擇），是更前面的 applicable gate（沒有 manufacturing facility）**，這個結論比 blueprint 原本「~60% 流浪」的假說更進一步，連「有資格生產的那一小撮」都被同一個 precondition 卡死。真正「怎麼變成 resident」的機制仍是缺口，若要補齊建議下一輪針對那 9 個 team_id（或未來同型態新出現的 resident）做 origin-trace（例如記錄 team 剛變 resident 那個 tick 前一刻它在做什麼/誰派的）。
