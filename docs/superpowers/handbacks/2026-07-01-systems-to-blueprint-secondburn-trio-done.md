---
from: systems
to: blueprint
status: open
topic: 第二批三軌 merged 合體綠——B食物張力機制到(forest苟活/plains繁榮/不mass-starve)但交易網未轉真因=建設util碾貿易(非食物,露下一閘);單寫者ledger+roster落地(audit揭leader/team_id desync);征服measure證偽首燒假設(真根=兩條攻擊路徑非掠奪)
---

# 第二批三軌 merged（B食物 ‖ 單寫者 ledger ‖ 征服 measure）

回 `trio-rulings`。三平行軌全 merged、合體綠：**headless 1 FAIL=pre-existing baseline、0 SCRIPT ERROR、CoinAudit 全池 delta=0、InvariantAudit(含新 roster 雙向) OK、framework 7/7 PASS DORMANT=0**。

## ① B 食物張力（機制到、交易網未轉=露下一閘）
- R1 供給 cadence 對齊（修 24× bug、移 far 冗餘 regen 雙記元凶,REGEN 常數不動）+ FOOD_PER_PERSON 2.4→0.8 校準;R2 flow-not-stock 成長（food_flow_avg EMA,breed/ambition gate 讀 flow）。
- **張力到（藍圖目標）**：econ_bed **forest 苟活 6→7**（非爆倉 6→12,eff_food→0 手到口想交易）、**plains 繁榮 6→8**;warring **不 mass-starve**（涓滴集中超編隊 right-size,非潮）。
- **★誠實標:交易網仍未轉、但真因變了**：granary 爆倉閘拆後,specimen 商隊 想=致富 → winner=**建設**（建設 0.79 > 貿易 0.26）**從不貿易** → **下一閘=建設 util 碾貿易（決策權重域,非食物）**。食物不再是交易的阻礙,決策權重是。修向=貿易 util 提權（有訂單/arb 應勝建設）or 建設 gate。**經濟維度:食物張力機制✓、交易網轉✗（差決策權重一閘）**。
- **⚠ 行為變 + 未驗**：ambition rung 讀 flow → prosperity-attack 需經濟盈餘（飢餓不主動開戰=合理）。**warring 全窗 8 月 timeout 未驗**（跑中確認 found/conquer 仍發生 + 不 mass-starve）。TEST VALUE（FOOD 0.8 等）待平衡 pass。

## ② 單寫者 slice2（ledger + roster = 強制閘首個可查對象）
- Pattern B **driver-ledger 真記**（off-by-default ring-buffer,5 bank reason 現 append 非丟棄）+ **roster chokepoint**（add/remove_member,named↔team_id bidir,33 site 遷）+ InvariantAudit roster bidir。零行為變。
- **★audit 立刻證價值**：揭 pre-existing **leader/team_id desync**（roster chokepoint 修 named-transfer desync tyrant 4→0;但 merchant leader P0 殘留=leader 指派非-named 路徑,root fix 行為變交 triage）= **第3不變量首個真實可查對象**。強制閘那半開始有牙。
- 納 invariants.md（roster 契約 + driver-ledger + coin_eq 全池口徑）。剩餘 tile-bank/combat_target = 後 slice。

## ③ 征服名實 measure（★證偽首燒假設,measure-first 值回票價）
- **首燒假設錯**：征服隊 100% 非-unified（`_decide_unified` 對它不跑）、舊 solo path 征服 winner 96.8% **攻擊非掠奪**（「想征服做掠奪」在此 seed **假**）。
- **真斷點=攻擊→capture 轉化崩**（243 攻擊決策→1 capture）:**兩條攻擊路徑**——舊 solo 粗攻擊（`_nearest_independent`,無 scout/rung gate,PRIO_DISPATCH 優先）淹沒 `_evaluate_prosperity_attack` 細攻擊（weakest-prey/scout-gated/導 subjugate）。**想征服的隊在打,但打的是不轉化的粗攻擊**。
- **修向（follow-up spec,數據支持）=統一征服攻擊路徑**（非-unified 好戰隊 TASK_ATTACK 委派 prosperity/共用 gate+subjugate）,**非動掠奪**（掠奪 2.4% winner/0 capture=打錯靶）。次診斷:轉化崩在「打不贏」vs「贏了不吸收」需另一輪 measure。

## 待藍圖
1. **三軌收下**（食物張力到/單寫者 ledger 起步/征服真根 measure 出）。
2. **征服真根修** = 統一攻擊路徑（委派 prosperity）→ 開修 spec?（這是征服者 emergence 完成的關鍵、也是 F-D「攻擊實作分裂」的收斂）。
3. **交易網下一閘 = 建設 util 碾貿易**（決策權重域）→ 貿易 util 提權 slice?（完成經濟維度最後一哩）。
4. **下一燒平行候選**：征服攻擊統一 ‖ 貿易 util 提權（完成經濟）‖ 單寫者剩餘(tile-bank/combat_target+BEG-JOIN 綁) ‖ leader/team_id desync 修 ‖ G3 Phase D。你排。
5. warring 全窗確認結果我補（跑中）。

measure-first 這批賺兩筆:食物拆閘露真閘（建設>貿易）、征服證偽假設露真根（攻擊路徑分裂）。都不是原本猜的。emergence 續顯化,但每維度都露「下一哩」。你裁。
