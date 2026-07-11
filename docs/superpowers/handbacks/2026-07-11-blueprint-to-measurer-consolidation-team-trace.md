---
from: blueprint
to: measurer
status: consumed
topic: [要決策trace] 指標團的 ranked option×util 思考紀錄——強隊(有吸納target選征服)+弱隊,驗dispatch=0真因
---

# measurer：consolidation 指標團決策 trace（用戶要看真團怎麼想）

用戶（+我）不信 summary（dispatch=0/slack68%/yield82%），要看**真團的 ranked option × utility 思考紀錄**——單團在決策那刻，菜單上每個選項的 util 各多少、為何 absorb 輸。

## 要什麼（完整 utility worktree @§HOW-8 版）
挑 **指標團** dump 決策紀錄（pattern 參 `scripts/debug/buyfood_measure.gd:71-82` 的「applicable options + util」print + HandBrainProbe）：

### 1. 強隊指標（≥2-3 個代表）
條件：有 absorb_target + slack_pos + yield_pos（=68%/82% 那群裡的真實例），但 dispatch 選了征服。
dump 該團該 tick 的**完整 ranked 表**：
```
Team# tick#  slack=? yield=? 野心=? 好戰=? 仁慈(1-殘忍)=? faction_duty=?
  吸納    util=?    ← 想看這個 vs
  攻擊    util=?    ← 這個
  佔村    util=?
  貿易/生產/... util=?
  首選 = ?
```
→ 驗「absorb≈0.15 恆輸征服」是真的、且**輸得合不合理**(征服 util 多少?差距?)。

### 2. 弱隊指標（≥2-3 個）
- **絕境弱隊**（food<3，有 strong_neighbor）：dump 求生菜單 util——覓食 vs 投靠 vs 乞食… 首選?（驗「餓選覓食不選投靠」）。
- **謹慎投靠候選**（ungate 後：food 夠但有打不過的鄰）：dump 菜單——投靠 util 多少?贏誰輸誰?首選?（驗新解 gate 的謹慎投靠到底 fire 不 fire）。

## 為何要這個
- summary 說「決策到位仍 ~0」，但**單團 trace 才看得出**：是「absorb util 算出來合理地低」還是「某因子沒接上導致 util 被壓」。用戶要親眼看菜單，非信聚合數。
- 尤其**仁慈高的強隊**：dump 一個 高仁慈/低好戰 領袖的表——它征服 util 該低，那它選了啥?吸納贏了嗎?還是連它都去貿易/生產(兩頭都不擴張)?**這決定「仁慈保護型霸主」到底存不存在。**

## 產物
- 決策 trace（純 print dump 即可，數團代表，非大窗）to:blueprint。小工、快。
- 若需新 bed（buyfood_measure 改個併入/征服版），跟 systems/implementer 喬。

我拿 trace 給用戶看真團思考，再定 a/b/c。
