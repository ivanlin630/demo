# 逆向工程計畫 — 全系統「契約 vs as-built」diff（2026-07-07）

用戶定案：不再逐格補丁，直接逆向 code 畫真圖、找全部問題點。

## 為何（背景）
「引擎選 X、dispatch 做 Y」同型斷鏈已在 3 系統坐實（decision veto/train-latch、訊息讀真值+distorted旗、combat 假探針）。舊稽核帶 lens 問 yes/no（「有沒有判斷器？」）→ 長得像水管的否決全放行。驗收驗「能力存在」不驗「行為發生」→ done 可以是假的。

## 方法紀律（防重蹈）
1. **先契約**：每系統寫下它宣稱的因果（下表）。
2. **再 as-built**：純描述 code 實際流（file:line 全引），**不評判、不找問題**——「這段實際做什麼」。
3. **後 diff**：契約 vs as-built 的每個 divergence = 一個問題點。
4. **禁 pattern-hunt**；關鍵 claim 用 runtime 證據 cross-check（B 不變量 + arc bed）。
5. 修「類」不修「個案」：總表出全、同根一次修。

## 契約清單（10 系統）
1. **決策管線**：每 cadence 引擎 rank_scored 秤所有選項 → 執行 rank[0]；唯物理中斷（戰鬥鎖/玩家令）可攔；無 dispatch 層否決/替換/latch。
2. **訊息/belief**：世界事件 → message 發射 → 傳播（誠實/失真/沉默＝人格驅動）→ claim 記錄（來源/可信度/distorted 旗正確）→ best_estimate → 決策感知**只讀 belief 不讀他隊真值**；識破→cred 折扣+口碑迴路閉環。
3. **交易/經濟**：貿易意圖 → 移動到市集/對象 → 成交（糧/貨/幣守恆交換）→ 財富真的改變下次決策輸入；無憑空生滅。
4. **移動**：task 帶 target → 每 tick 依速度（地形/負重/疲勞）推進 → 到場觸發 arrival 效果（交易/戰鬥/傳訊）；距離=時間成本真實作用於所有跨格行為。
5. **戰鬥/訓練**：攻擊 dispatch → 到場 → 戰鬥重量=Σ人均戰力×意志 → 回合結算 → 潰退/殲滅 → capture/subjugate 效果落地且被量到；**訓練 task → tier 提升 → 戰力/armed 真的漲**。
6. **faction AI**：faction intent/goal → directive → 成員經引擎秤（faction_duty term）響應；成員行為=引擎輸出非硬塞。
7. **資源/食物**：生產/收穫 → 存量 → 消耗（pop×rate）→ 短缺→hunger/famine 效果；守恆無漏。
8. **人口/anon**：生死/晉升/轉移全走 AnonTierSystem/named 規則；pop 守恆；anon↔named 只經 gated 路。
9. **視野/威脅**：位置+視距 → discovered/tier0-2 觀察 → belief 寫入；threat=belief 表象評分；無 god-view（位置 god-view 已知=audit 列）。
10. **事件/反應**：世界狀態觸發事件 → state-effect 落地；reaction=情緒/後果，不篡奪 task 決策。

## 產物與 checkpoint
- 每片：as-built 要點圖 + **diff 清單**（severity：斷鏈/no-op/假探針/god-view/否決層）+ file:line。
- 全片收齊 → **總表+分級+修期報價**（checkpoint，交用戶裁修序）。
- 修完的每個斷點 → C 行為句子 harness 鎖死（防爛回去）。

## 進度
- [ ] wave1：決策管線 / 訊息belief / 交易經濟（spawned 2026-07-07）
- [ ] wave2：移動 / 戰鬥訓練 / faction
- [ ] wave3：資源食物 / 人口anon / 視野威脅 / 事件反應
- [ ] B「手聽腦」runtime 不變量（護航，wave1 後）
- [ ] checkpoint：總表+報價
- 平行 hold：③a worktree（util 人格化留、train 補丁棄）；②③ 暫停待地基。
