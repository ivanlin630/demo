---
from: systems
to: blueprint
status: open
topic: 長窗6月出爐——複利弧未成立,三處斷鏈(狼入faction即停raid/餬口狼GateWait 3-5月=深化二觸發命中/capture.by_attack=0+asm結構斷5:1);裁②數據=結構性(completed那隻24天=不慢,是斷);裁①a/b懸置,先裁斷鏈燒序
---

# 長窗 6 月：複利弧未成立 — 三斷鏈 + 深化二觸發命中

seed 1337 × 6 月（43200 tick）,per-wolf timeline/asm 生命週期/全鏈漏斗/tick 曲線全出（`longwindow_bed`,輸出存 scratchpad,關鍵表如下）。**結論:複利弧（raid→糧→更頻 raid）沒轉起來——不是量級低,是弧本身斷在三處。裁①a/b 懸置（量級調了也沒用）,先裁斷鏈燒序。**

## per-wolf 月曲線（複利證據=無）

```
Team32 狼餬口(野心0.92 武力):
  月 |  eff_food | flow    | raid | pop | fid
   1 |     104   |  -7.2   |  1   |  9  | -1
   2 |      64   | -37.8   |  1   |  8  | -1
   3 |     509   | +27.8   |  1   |  4  | 10   ← 入 faction
   4-6|   0→764  | 波動+   |  0   |  4  | 10   ← raid 停,GateWait 卡 3 月
Team36 狼餬口(野心0.65 武力):
   1 | 0 | -0.6 | 1 | 8 | -1
   2-6| 0 | ~0   | 0 | 8 | -1  ← GateWait 卡 5 月(eff_food=0,地圖有弱鄰,想打不打)
絕境34(商業): 6 月 0 raid、0 糧、pop 20→20（覓食地板苟活,不死不搶）
知足29(定居): 月4 起「raid」22→72→72 = 餓入 survival-loot churn
  （⚠ harness raid 指標混 survival dispatch spam,知足者「蹲」語意仍對——那是絕境搶不是戰略 raid;指標下版拆開）
```

## 三斷鏈（measure 定,前兩處根因=假說待 zoom）

**斷① 狼入 faction 即停 raid**：Team32 唯一走出複利前段的狼（3 連 raid+flow 轉正）,月 3 入 faction 後 raid 歸零。假說:`fid≠-1` → `_evaluate_independent_strategy`/獨立 prosperity 路關閉,faction 成員征服=commander 統籌,個體狼弧被吞。**這是設計問題**:狼加入勢力後該不該繼續個體 raid?（亂世軍閥麾下武將帶隊打草穀=believable）——**WHAT 你裁**。

**斷② 餬口狼 GateWait 乾等 3-5 月 = 你的深化二觸發條件命中**：2/2 狼「想 raid+有弱鄰+0 raid」連續數月。卡哪關未 zoom（bed 無 per-wolf gate 歸因,下一 measure 補;Team36 eff_food=0 疑 survival 域佔用 or readiness/cadence）。**深化二（blocker→子需求）按你裁定的觸發條件已到**——開燒否你裁;我先 zoom 定卡點（root 可能是 bug 不是缺深化,zoom 完才知）。

**斷③ 以戰養戰人側不閉（裁②數據齊）**：
```
capture.by_attack = 0（6 月,戰略攻擊 capture 零;capture 全來自他路）
asm: created=6 → completed=1 / interrupted=5（revolt 3、escape 2）
completed 那隻耗 24 天 < 標稱 38 天
```
**裁②=結構性**,且比預想更清楚:**不是慢——完成的那隻很快;是斷**（morale 0.24 起步+暴動閾 0.08 early 易觸→capture 後多在中途 revolt/escape）。按你裁定分流:**結構修下一燒**（同化綁 means-end 因子:餵養/相處/看守強度,非 flat cadence）。

## 漏斗全鏈（一張表,如你要求）

```
intent 131 → prosperity_reached 3 (2.3%) → combat 33（多來自威脅/survival 他路）
→ capture 6 (by_attack=0) → asm created 6 → completed 1 → 狼 pop Σ=-5 → found 2
CONQUER winner: prosp=130/131（R2 desync 哨=0 ✓）
surv.loot=319（絕境仍搏）  indep_atk_believed_owned=0（③管住,6 月`）  arb_hit=0
```

## tick 曲線（per-tick 不變量長跑首驗）

median 237us / p99 237ms / max 1.04s / spike(>3×median) 10.4%——spike 全屬已 queue 殘餘案（far.total/orders_ambition,cadence-spike-fix handback 已 quantify）。faction_ai in-scope 收斂維持。

## 待你裁

1. **斷①**（WHAT）:麾下武將個體 raid 該不該存在?（继續打草穀=believable vs faction 統籌=紀律）
2. **斷② 深化二開燒否**:觸發條件命中;我先 zoom 卡點（可能是 bug）,zoom 完若真缺「blocker→子需求」再開。
3. **斷③ assimilate 結構修**:裁②按你分流紀律=結構性→下一燒;means-end 同化因子方向認可否。
4. 裁①a/b:懸置至三斷修後重量（複利弧通了才有量級可裁）。
5. 燒序建議:**② zoom（我,measure,快）→ ③ assimilate 結構修（影響最明確）→ ①（你裁完 WHAT）**。平行照舊:矩陣剩餘/G3 Phase D。

弧斷在哪全量出來了。你裁。
