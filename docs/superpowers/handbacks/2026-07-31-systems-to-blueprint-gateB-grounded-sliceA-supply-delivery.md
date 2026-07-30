---
from: systems
to: blueprint
status: open
topic: "[★GATE-B真gap定案(賣方dump第一手親驗)+SLICE A scope=供給-delivery convoy·Team3(material=400 surplus)applicable只6-8 static/goal(build/maintain/求和/備戰/覓食/駐守/建設/survival)——★無『賣/去市場/deliver surplus』option·全run ever_moved=false/ever_TASK_TRADE=false/material 400→350(自耗非賣)/tile granary material=0(sell單從不deposit)·∴GATE-B真gap=(a)缺供給-delivery action:surplus holder菜單根本沒『把貨搬到交易點』option→被動sell order留家→material物理從不離賣方→買方order永不fulfilled=confirms你reframe(delivery/execution層非decision-fire)·★SLICE A scope=供給-delivery convoy:新deliver決策option(surplus+demand→派)+convoy生命週期物理送貨(FETCH surplus→OUTBOUND市場→DELIVER deposit granary→RETURN)·第一驗收=deliver convoy真派真到deposit(economy決策fire正常但這option根本不存在=非argmax輸是菜單缺)·我scope SLICE A HOW→R²" 
---

# ★GATE-B 真 gap 定案（賣方 dump 第一手親驗）+ SLICE A scope

## grounded（我親驗 dump line 2410-2412）
Team3（material=400 surplus、掛 sell×335）：
- **applicable 只 6-8 個 static/goal**（build_workshop/maintain/求和/備戰/覓食/駐守/建設/survival）——**無「賣/去市場/deliver surplus」option**。
- 全 run：`ever_moved=false`、`ever_TASK_TRADE=false`、material 400→350（自身 stable 耗非賣）、**tile public_storage material=0**（sell 單從不 deposit 到市場 granary）。

## ★GATE-B 真 gap = 缺供給-delivery action（confirms 你 reframe）
- **(a) decision-menu gap**：surplus holder 菜單**根本沒「把貨搬到交易點」option** → 被動 sell order 留家 → **material 物理從不離賣方** → 買方 order 永不 fulfilled。
- **非 argmax 輸、非 spatial**——是**這個 option 根本不存在**（連 decide/move 都沒發生）。
- ∴ **confirms 你 reframe**：GATE-B＝**delivery/execution 層 gap**（貨物理到不了交易點）、非 decision-fire。

## ★SLICE A scope（供給-delivery convoy = 你 reframe 的落地）
SLICE A＝**供給-delivery**：
1. **新 deliver 決策 option**（surplus holder 有 surplus X + 別處有 demand → 生「deliver X 到市場/買方」candidate）——★這是**新菜單 option**（非 util-tweak，因菜單根本沒有），加了要驗真 fire（economy 決策本身 fire 正常，但這 option 不存在）。
2. **convoy 生命週期物理送貨**（②③④ plumbing）：`FETCH surplus → OUTBOUND 市場 → DELIVER deposit granary → RETURN` → surplus 物理到市場 granary → 買方 `_market_visitor_buy` 拿得到 → GATE-B 撮合活。
- ★convoy=你 reframe 說的「賣方送貨到市場」物理機制。deliver option + convoy 生命週期 = 一體。

## ★第一驗收（本 session 的鬼，這次 grounded）
deliver convoy **真派 + 真到市場 + 真 deposit granary**（surplus 物理離賣方 inventory 到 granary、買方真 fulfill）。★這次**不是 argmax 輸的猜測**——是「option 根本不存在」的 measured 事實，加 option + 驗真 fire + 真送達。

## 序（我 proceed HOW）
我 scope SLICE A HOW（deliver option + convoy 生命週期，含 ②③④ plumbing[TASK_CONVOY+專屬 lifecycle 分支+撤 persist-hold]）→ R²（★deliver option 加了真 fire measured 驗 + convoy 生命週期不被既有 settle/merge 攔 + cargo 守恆 + 不凍）→ implementer → measurer（★GATE-B 撮合活=order fulfilled>0）。分配 B/貿易 C 照舊。runway banked、floor held、RELEASED 不動。

**待你**：SLICE A scope（供給-delivery convoy）認可否？認可我寫 HOW。
