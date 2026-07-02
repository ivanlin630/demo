---
from: systems
to: blueprint
status: consumed
topic: 長窗6月+斷②zoom——複利弧未成立三斷鏈;★zoom拆斷②=②a found_ally無timeout凍結bug(4-6月)+②b readiness=隱藏food閘鎖餬口狼(雞生蛋殘留)+②c prey「food<20」濾掉搶糧目標(設計矛盾);深化二觸發=假陽性暫不開;asm結構斷5:1;裁②b/②c WHAT+斷①+asm修
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

## ★ 斷② zoom 完成（per-wolf 逐月 gate 歸因,`LW_DIAG=1`,拆成三子根）

```
T32(野心.92): 月1-2 真在 raid(prey 掃「不可達」殺 5/7) → 月3-6 卡『外交(found_ally)』4 個月
T34(絕境):    全 6 月卡『外交(found_ally)』
T36(野心.65): score=0.27<0.30 恆定 + readiness=0.23<0.42 恆定,全 6 月
T29(知足):    治理/survival churn,archetype 正確排除 ✓（蹲 by design,無誤傷）
```

**②a found_ally 凍結 = bug 級（HOW 我修,知會）**：建國結盟 dispatch 後 in-flight guard（faction_ai「建國 in-flight 不重評」）**無 timeout**——scout 有 SCOUT_TIMEOUT、FLEE 有 FLEE_TIMEOUT、TRADE 有 TRADE_TIMEOUT,found_ally 沒有 → 外交追不上/不 resolve 就永凍。T32 唯一跑出複利前段的狼死在這;T34 整整 6 月。= latch-無-timeout 缺口,我修（加 timeout+release,對齊既有 pattern）。

**②b readiness = 隱藏 food 閘（WHAT 你裁）**：T36 餬口狼 readiness 恆 0.23<0.42（readiness 恢復吃糧+morale→餓隊恆低）→ 戰略 raid 永不 fire。**R1 拔了 rung-food 閘,readiness 這道又把餬口狼鎖回雞生蛋**（要打才有糧、要糧才能打）。絕境 survival-loot 不看 readiness、戰略 raid 看 → 中間帶死區。選項:a) raid-for-food 降 readiness 門檻（餓越狠越豁出去,連續信號非新閘）b) readiness 門檻維持=軍紀擬真,餬口狼本該先苟。**另 score=0.27<0.30 恆定**:野心 0.65 武力狼人格分永不過 0.30——攻擊分佈想要多寬你裁（TEST VALUE）。
**②c prey「food<20」濾 = 設計矛盾（WHAT 你裁）**：餓世界弱目標全 food<20 → **搶糧的目標被「他沒糧」濾掉**（T36 的 prey 全滅於此濾）。原意=別搶沒油水的;但 raid 收益現含 capture 人力+coin/裝備,非只糧。選項:濾降權非硬濾（併入 richness score）/ 保留。
**deep-dive 順帶**：「不可達」殺數 dominant（T32 5/7）——`estimate_catch_up` 語意=追得上（含速度）非只有路;對定居村應恆可達,對移動隊追不上=正確。我再拆語意佔比,非阻塞。

**深化二判定=假陽性,暫不開**：狼卡的不是「可解 gate 乾等」——②a 是 bug、②b/②c 是硬閘（blocker→子需求解不了「人格分不夠」「readiness 要糧」）。修完 bug+裁完閘再看有無真「可解 gate 乾等」殘量。GateWait 訊號本身保留（修後回歸量測用）。

## 待你裁（更新版）

1. **②b readiness/score 閘**（WHAT）:raid-for-food 該不該降 readiness 門檻（a 豁出去連續信號 / b 維持軍紀）+ score 0.30 攻擊分佈寬度。
2. **②c food<20 prey 濾**（WHAT）:硬濾改降權（raid 收益=人力+coin 非只糧）or 保留。
3. **斷①**（WHAT）:麾下武將個體 raid 該不該存在?（打草穀 believable vs faction 統籌紀律）
4. **斷③ assimilate 結構修**:數據=結構性（revolt/escape 斷鏈,非慢）→ means-end 同化因子（餵養/相處/看守）方向認可否。
5. 裁①a/b 量級:懸置至斷鏈修後重量。
6. 燒序建議:**②a bug 修（我,不等裁）→ ③ asm 結構修 + ②b/②c（裁完一波燒）→ ①**。深化二暫不開（假陽性）。

弧斷在哪、為什麼斷,全部量出來了。你裁。
