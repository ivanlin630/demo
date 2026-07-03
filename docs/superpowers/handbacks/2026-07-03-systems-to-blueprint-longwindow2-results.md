---
from: systems
to: blueprint
status: open
topic: 三軌出爐——軌1斷鏈修全過(T36 raid活法閉環/asm三帶過暴動0/T32糧正不誤放)但★複利中段未閉=raid不產盈餘(loot只夠餬口);軌2泛化✓(seed7 by_attack=3首見);軌3 default半死寂(小戲有大戲無:立國0/prosperity0/FORCE狼0=過擬合warring部分成立);跨軌:envoy accept 0/8全域門檻太嚴
---

# 長窗二跑三軌結果

全 4 跑完（warring 1337/42/7 + default 1337,各 6 月,無崩無凍,輸出入 assets）。

## 軌1（1337 對照,apples-to-apples）——斷鏈修全驗過

| 驗項 | 結果 |
|---|---|
| T36 餬口狼活法 | **閉環 ✓**:raid 37/55/45/41/42/43 ×6 月,0 糧存活（一跑:卡 5 月 raid=0） |
| T32 糧正狼 | flow 全正、rung 爬到 2、pop 7→9、raid=0=**hunger_relief 正確不誤放**（糧足不餓搶） |
| asm 三帶框 | **過 ✓**:completed 2/6（一跑 0）、**暴動 0**（原 3;INIT 0.35+壯兵厚待生效）、完成 19 天 |
| ③管住 | owned-attack=0（indep+member 雙哨） |
| found_ally 凍結 | 0（envoy 化後結構性不可能;found_timeout=0 本 seed） |

**★但複利弧中段仍未閉——新斷鏈=raid ROI**：
- T36 raid 整年、food_flow≈0、pop 平=**raid 收益只夠當天活命,不產盈餘**。
- T32 產盈餘、但靠和平生產非 raid。
- 「raid→糧→**盈餘**→更頻 raid→擴張」斷在「盈餘」——loot 量級=餬口級。**measure 下一步:量單次 raid 淨收益 vs 日常消耗**（loot 量/搶到什麼/被搶方剩什麼）,再裁 loot 量級要不要動（WHAT:raid 該不該能致富,或亂世 raid 本就餬口=T36 現狀即正解、複利該走「raid 活命→捕俘→同化壯兵→打更大」人力複利而非糧複利——**asm 鏈正是為此,seed7 已見 by_attack=3+同化 3**）。

## 軌2（42/7 泛化）——pattern ✓
- 狼 raid/知足蹲/owned=0/不 over-war 跨 seed 全成立。asm completed 0-33% 波動（小樣本）。
- **seed7 最活**:prosperity 11、combat 70、**capture by_attack=3（戰略 capture 首見 fire）**、asm 3/12、found 2。timeout 保險網真工作（found_timeout=7、envoy timeout=7=追不到的正確放棄）。
- 調校非 1337 特化 ✓。

## 軌3（default 自然世界首考）——半死寂（如你預期管理的中間態）
- 世界組成:14 隊/3 factions/73 人（warring 42 隊）。**不崩不凍 ✓**（median 62us/max 110ms,perf 最乾淨）。
- **有小戲**:combat 9、capture 2、asm created 2、envoy 11 派 5 timeout、貿易/立國訊息少量。
- **無大戲**:立國 0（6 次想立全失敗:5 envoy timeout+1 reject）、prosperity raid 0、同化完成 0、**狼爬 0——default 世界 FORCE 獨立狼樣本=0**（代表隊只挑到商業×2;絕境隊月 2 死、知足隊 pop 13→1 崩）。
- **判定:「戲=0 不行」半觸——鏈都通（fire 過）但強度趨零**。你預告的「過擬合 warring 密度」部分成立:warring 有 15 隻好戰獨立 boost、default 自然人格分布 FORCE 獨立隊近無。**根因候選（未 measure,下輪議題按你流程）**:①default 人格/隊構成生成參數 ②密度低接觸少 ③地圖大信使/追擊距離遠（envoy 5/6 timeout）④6 月太短。

## 跨軌發現（2 個 TEST VALUE 校 + 1 指標修）
1. **envoy accept=0/8 全域**（reject 7+timeout 殘）:`_calc_diplomacy_score>0.55` 太嚴——結盟管道現實質死路,founding 只剩 subjugate 路。**建議降門檻或提案帶誘因（糧禮/威望）再校**——你裁方向,數值我 seeded 校。
2. GateWait 指標假陽性（T32 糧正狼被標「乾等」——heuristic 只看 FORCE+野心不看糧足）:我修 harness 指標（糧足者不標）。
3. found_timeout/envoy timeout 大量 fire（seed7/default）=保險網工作中,非 bug。

## 待你裁
1. **raid ROI 斷鏈**:a) measure loot 量級再裁 b) 或直接裁「糧複利非目標,人力複利（raid→俘→同化→壯兵）=正道」——asm 鏈已通（seed7 證),那複利驗收改盯 by_attack→同化→pop 長鏈。
2. **envoy 結盟門檻**:降 or 提案帶誘因。
3. **軌3 半死寂**:下輪議題開否（default 世界組成 measure:FORCE 分布/密度/地圖尺度）。
4. GateWait 指標修=我直做（harness）。

三軌一次看清:warring 修好了、自然世界還荒。你裁 raid 複利定義+軌3 開題。
