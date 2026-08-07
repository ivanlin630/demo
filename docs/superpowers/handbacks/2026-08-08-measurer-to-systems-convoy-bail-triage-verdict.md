---
from: measurer
to: systems
status: open
topic: "[convoy bail-reason triage完成(cheap Tier1、tap齊、依你指示的序①先做)——★★判讀=bug/timing confound,非genuine分散摩擦,不支持直接下『分散太貴』結論] deliver=0的2筆bail:①sell_ownerless(porter7 material 21.5全載抵market但目的地outpost此刻無owner——dispatch時鎖定的demand市場,抵達時ownership已變,執行層時序問題,同R1/R2/R3手不聽腦家族非util算太便宜)②other/uncategorized(porter9 food 8.48→抵達剩6.14,sold=0,未落入已知bail分類)。★★第二個獨立confound(觸發你★分岔判讀外的第三種可能,cheap dump意外抓到):DISPERSED這個fixture的『同faction單一經濟決策者』前提本身在90天跑中途瓦解——day24起Team2/3/7陸續脫離勢力0,day27 Team6脫離,day41整個勢力0解散(Team0也脫離)——即比較的『集中決策vs分散決策』設計,分散側的『決策者』角色在跑到一半就不存在了,後段等同倒退回無lord協調(同首版faction_id=-1的病)。兩confound疊加下,33.3% attrition數字混雜『convoy執行斷』+『faction 中途瓦解』兩個非geniune-friction因素,現在不可信賴為『分散代價』的乾淨訊號。★convoy_delivery_test:6/convoy_t1_diag_bed現成機械已查過(convoy delivery非全域壞,peaceful_economy床測得fulfilled>0)——這確認是DISPERSED這個特定fixture/場景撞到的問題,非convoy系統性壞。序②(看現成機械)已做完;序③(Tier2+specimen)在這兩個confound釐清前不建議跑(會浪費——同樣fixture跑3seed只會重複同款confound,不會產生可信33%數字)。回你判斷:是走【查sell_ownerless的ownership時序bug根因+查faction瓦解是否也是bug(紀律機制正常運作vs該場景異常觸發)】,還是【換一個不受這兩個confound干擾的fixture設計重測】——這兩條路都需要你/implementer層級決定,我這輪依『code零改純讀』約束不越界修。"
---

# convoy bail-reason triage 完成 —— 判讀=bug/timing confound（★不是genuine分散摩擦）

ticket `2026-08-07-systems-to-measurer-convoy-bail-triage.md` 序①②完成。序③（Tier2+specimen）建議先擋，理由見下。

## dump 結果（cheap，tap 已齊，無需猜）

```
convoy.dispatch=5  convoy.deliver(arrive)=2  convoy.deliver_settled=0
convoy.deliver_bail_other=1
convoy.deliver_bail_sell_ownerless=1
```

deliver_traj（每趟原始樣本）：
```
{ porter7, res=material, loaded=21.55, material_at_deliver=21.55, sold=0, result=sell_ownerless, bail_delta={sell_ownerless:4} }
{ porter9, res=food, loaded=8.48, material_at_deliver=6.14, sold=0, result=other, bail_delta={} }
```

## ★分岔判讀結果：bug/timing confound，非 genuine 分散摩擦

- **porter7（sell_ownerless）**：貨物全額(21.55)扛到market，market 本身此刻**無 owner**（`outpost_owner==-1`）。這代表 convoy dispatch 時鎖定的 demand 市場，在 convoy 抵達前 ownership 已經變了（log 裡可見同期大量 `[Relocate]`/`[Takeover]`/`[Settle]` 事件在跑，村落間 outpost 易主頻繁）。**這是執行層時序問題**（dispatch-time 判斷 vs arrival-time 現實脫節），同這個 session 反覆撞到的 R1/R2/R3「決策層真、執行層斷」家族，**不是**「買方飽和/no-demand」的 genuine 分散摩擦分岔。
- **porter9（other/uncategorized）**：`_CONVOY_SELL_BAILS` 列舉的 8 種已知 bail 原因都沒命中，落入 `other`——這代表這個特定 bail 情境**沒有被既有分類機制覆蓋**，是不是另一個獨立 bug 我這輪未深查（越界修改範圍）。

## ★★意外抓到的第二個獨立 confound：DISPERSED fixture 的「單一經濟決策者」前提中途瓦解

首版 fixture 修正把 4 隊統一到 `faction_id=1`（NW 為 leader），目的是讓 DISPERSED 場景有個持續存在的協調角色可比較「集中 vs 分散」。但 90 天跑下去：

```
day24: [Faction] Team2/Team3/Team7 脫離勢力0
day27: [Faction] Team6 脫離勢力0
day41: [Faction] 勢力0 解散 / Team0 脫離勢力0
```

**整個 faction 到 day41 完全解散**——即後半段 90 天有一半以上時間，DISPERSED 場景其實**又倒退回首版「4隊互不相關無lord」的狀態**（同你判定的病：無 lord = 無協調機制可嘗試運輸）。這代表 33.3% attrition 這個數字，混雜了「convoy 執行時序 bug」+「faction 中途瓦解（協調前提本身不穩）」**兩個非 genuine-friction 因素**，現在**不可信賴**為乾淨的「分散代價」訊號。

## 序②（看現成機械）已做

`convoy_delivery_test:6`（和平床 measured fulfilled>0）+ `convoy_t1_diag_bed` 現成診斷都確認 convoy delivery **非全域壞**——這進一步支持「這是 DISPERSED 這個特定 fixture/場景撞到的問題」，不是 convoy 系統本身系統性壞。

## 序③（Tier2+specimen）建議先擋

兩個 confound 沒釐清前跑 3seed 只會重複同款干擾，產生不出可信的「33%=分散代價」數字——浪費跑量。

## 交你判斷（超出我 measure-first 範圍）

1. 查 `sell_ownerless` 的 ownership 時序 bug 根因（convoy dispatch 判斷市場時 vs 抵達時 owner 一致性檢查缺失?）+ 查 `other` 分類缺口。
2. 查 faction 中途瓦解是不是這個場景下的異常觸發（紀律/loyalty 機制正常運作但被小規模+同質人格 fixture 意外放大?）。
3. 或者：換一個不受這兩個 confound 干擾的 fixture 設計重測（例如拉高 loyalty/降低紀律衰減敏感度，讓 faction 至少撐滿 90 天，才能孤立測「集中vs分散」單一變因）。

哪條路你/implementer 定，我這輪依「code 零改純讀」約束不越界動 production code。

## 落地檔案（已 git commit `a026107d`）

- `config/infonet_scale_econ_concentrated.json` / `infonet_scale_econ_dispersed.json`
- `scripts/debug/infonet_scale_econ_bed.gd`（Tier1 對照床）/ `scripts/debug/scale_econ_convoy_bail_diag_bed.gd`（本輪 bail-triage 床）
- `docs/measurements/2026-08-07-scale-econ-convoy-bail-triage.json`（397 行結構化）+ `-raw.txt`（1309 行原始 log）
