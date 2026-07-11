---
from: measurer
to: blueprint
status: consumed
topic: consolidation 指標團決策trace——5場景dump，攻擊碾壓吸納(4-5x)不因仁慈而變、絕境選覓食不選投靠(4.78差)、謹慎投靠確實fire但險勝
---

# 量測回報：指標團決策 trace（真團菜單 dump）

工單：`2026-07-11-blueprint-to-measurer-consolidation-team-trace.md`。純 print dump，非大窗，用完整 utility worktree `.worktrees/consolidation-s-a @076b237`。床：`scripts/debug/consolidation_decision_trace.gd`（新建，5 場景，手構最小 WorldState，直接呼叫 `DecisionContext.gather`+`DecisionEngine.rank_scored`，同 `buyfood_measure.gd` pattern）。完整 log：`tools/orchestrator/runs/consolidation-decision-trace.log.txt`。

## 場景 A：強隊，高好戰(0.8)/高殘忍(0.75,仁慈0.25)，有 absorb_target=weak_prey 同一鄰
```
攻擊   util=1.0500
掠奪   util=0.7150
吸納   util=0.1980   ← 輸攻擊 5.3 倍
建設   util=0.1600
```
**首選=攻擊**，贏第二名(掠奪)0.335。吸納排第三，被攻擊碾壓。

## 場景 B：同弱鄰，但領袖低好戰(0.15)/高仁慈(殘忍0.1)——測「仁慈保護型霸主」是否真選吸納
```
攻擊   util=0.9486   ← 好戰/殘忍砍半，攻擊 util 只掉 10%（1.05→0.95）
吸納   util=0.2682   ← 仁慈確實墊高吸納(0.198→0.268)，但幅度遠不夠翻盤
建設   util=0.2000
掠奪   util=0.1950   ← 掠奪對殘忍敏感得多（0.715→0.195，砍到 1/4）
```
**首選仍=攻擊**，贏吸納 3.5 倍。**「仁慈保護型霸主」在此 utility 結構下不存在**——好戰/殘忍對「攻擊」term 的影響幅度遠小於對「掠奪」的影響，仁慈領袖不劫掠但仍然打仗（攻擊 term 主要吃別的驅力，非純人格）。

## 場景 C：獨立絕境弱隊（food_days=1.5，無 faction）
```
覓食   util=6.0000
紮營   util=0.7380
```
**首選=覓食**，遠贏第二名 5.26。獨立隊天然無 `consolidate_target`（該欄位只服務 faction member），驗證「乞食」在此設定下未 applicable（本例無 aid_target，非驗投靠本身）。

## 場景 D：faction member 絕境（food_days=1.5），同 faction 內有效 absorber 存在（併入真 applicable）
```
覓食   util=6.0000
併入   util=1.2240   ← 併入確實 fire（不是死路），但輸覓食 4.78
紮營   util=0.7920
```
**首選=覓食**。回答 blueprint 問題「餓選覓食不選投靠」= **確認為真**，且不是「併入死路」的問題（併入本身有算出正 util、真的 applicable），是覓食 term 量級（6.0）遠壓過併入（1.22）——**覓食本身太香，非併入太弱**。

## 場景 E：faction member，food 夠（10天，非絕境），但有打不過的外部強鄰（測「謹慎投靠」ungate 是否 fire）
```
survival   util=1.0000
併入       util=0.8160   ← 謹慎投靠確實 fire！非絕境也能觸發
備戰       util=0.5700
```
**首選=survival（通用求生 fallback）**，但**併入緊追在後，只差 0.184**——ungate 後的「謹慎投靠」路徑是真的活的、非死碼，只是在此人格組合下險負給更泛用的 survival option。若領袖再慎重一點或威脅再高一點，這場很可能翻盤。

## 綜合判讀（我只出數字，方向判斷你裁）
1. **absorb ≈0.15-0.27 恆輸征服，輸得「合理」但輸很大**：不是 util 算錯或被壓到 0，是攻擊 term 本身量級就是吸納的 3.5-5.3 倍，人格調整幅度不夠撼動這個差距量級。
2. **仁慈高的強隊不會變成「仁慈保護型霸主」**：它砍掉的是「掠奪」不是「攻擊」——仁慈領袖仍然打仗，只是不趁機搜刮。
3. **絕境弱隊選覓食不選投靠是「覓食太香」而非「併入太弱/死路」**：併入在 D 場景裡有效 applicable 且 util>1，只是覓食 util=6 這個量級把所有 survival 選項都比下去（C 場景同理，紮營也被覓食完封）。
4. **謹慎投靠（ungate 後）真的會 fire，且是接近半數的競爭者**（E 場景 0.816 vs 首選 1.0，差距僅 18%）——這條路並非死路，只是通常贏不了更泛用的 survival option。

## 順手記錄的機制細節（供 systems 參考，非本次判準）
- `_find_absorber`（弱隊找 absorber）要求 `d>1`（同格/鄰格被排除，需真有段路程）——與 `_find_absorb_target`（強隊找可吸弱鄰）的距離語意不同，構造 trace 時踩到過一次。
- `consolidate_target_of` 的 `small_b`/`small_c` 用 `int()` 截斷（`int(cap*0.3)`），邊界值會因截斷產生 off-by-one（pop=3 卡在 `int(13*0.3)=3` 不嚴格小於）。
- `ctx.threat`（併入 ungate 用）與 `ctx.threat_react`（迎戰/備戰用）是兩個不同欄位/公式：前者過濾掉 reputation≥neutral 的對象（只算「已知敵對」），後者不過濾（純 approach+hostility+power_ratio）。`_find_strong_neighbor` 又要求 `rep>0.3`（排除已公開敵對者，只算「還沒翻臉但打不過」）——三者交集窄（rep 需落在 (0.3, 0.5) 之間）才能同時觸發「謹慎投靠」的 has_strong_neighbor + threat 兩個條件。

## 產物
- 床：`.worktrees/consolidation-s-a/scripts/debug/consolidation_decision_trace.gd`
- log：`tools/orchestrator/runs/consolidation-decision-trace.log.txt`
