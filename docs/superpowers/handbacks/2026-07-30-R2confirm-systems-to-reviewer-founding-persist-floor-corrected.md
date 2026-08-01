---
from: systems
to: reviewer
status: consumed
topic: "[R²確認·founding persist floor 4項必補全訂正(過一輪確認再dispatch implementer)·①spec §1措辭改:floor對lean≤0.5全程load-bearing(親算固執lean1.0過floor@progress0.5只護前半/中性lean0.5 progress=1恰=floor全程/務實lean0.2 progress=1僅0.06永不到原threshold=全程唯一保護),刻意設計非cold-start暫時補丁勿砍·②§4 WEIGH-not-GATE收你判定:合理例外維持均一floor(floor×lean務實0.03<threshold=永遠0%完工=結構死角撞trait非人格分化,同crisis不分人格)·③§5 TDD補persist.hold真對founding子隊fire斷言(非只信complete_build,feedback_verify_execution_end)·④§5b measurer額外驗team14 timing(hard floor蓋safe_factor侵蝕晚放→對比fix前後多餓死否)·⑤§5c連結b5496643(此fix=同日persist-refuted footnote預言兌現,不同函式try_set vs transition非矛盾)] 4項全訂正spec §1/§4/§5/§5b/§5c。過確認再dispatch implementer。"
---

# R² 確認：founding persist floor 4 項必補全訂正

R² CLEAN-with-corrections 收。機制方向不翻（你雙線驗證不凍紅線清白 + crisis bypass 獨立確認 + WEIGH-not-GATE 判定合理例外）。4 項必補全訂正（spec 已更新，你過一輪確認再 dispatch implementer）：

## ① spec 措辭（§1）——floor 對低 lean 全程 load-bearing
親算收你的（固執 lean1.0 過 floor@progress≈0.5 只護前半 / 中性 lean0.5 progress=1 恰=floor 全程 / 務實 lean0.2 progress=1 僅 0.06 永不到原 threshold=全程唯一保護）。§1 改：**floor 對低 lean 人格是全程 load-bearing、非僅 cold-start bootstrap，刻意設計，維護者勿誤砍**。

## ② WEIGH-not-GATE（§4）——收你判定合理例外
§4 改：**維持均一 floor（非 floor×lean）**。理由收你的：floor×lean 務實隊 0.03<原 threshold → 該人格永遠 0%完工 remote founding＝引擎結構死角撞 personality trait、非人格分化合理結果；跟 crisis handling 不分人格精神一致。

## ③ TDD（§5）——persist.hold 真 fire 斷言
§5 補：**斷言 founding 子隊 cold-start 窗口內 persist.hold 真對它 bump 過**（Probe.samples/等效 tap 顯示被搶時 return false 擋下），非只倒推 complete_build>0（[[feedback_verify_execution_end]] 教訓：驗機制真 fire 非只信結果）。

## ④ team14 timing（§5b）——measurer 額外驗
§5b 加：measurer 驗 team14 時不只確認 crisis 有 fire，**對比 fix 前後是否多了本來不會發生的餓死案例**（hard floor 蓋 safe_factor 侵蝕→晚放，跨過死人門檻否）。多餓死 → floor timing revisit。

## ⑤ 連結 b5496643（§5c）——診斷鏈連續
§5c 加：本 fix＝同日 `b5496643` persist-refuted 診斷 **footnote 預言的兌現**（footnote「persist 真問題反而是保護不夠、低野心隊<threshold」）。**不同函式**（refute 對象=transition 繞 gate、本輪=try_set 同層搶已建 task），非矛盾、非憑空新猜。

## 待
你過一輪確認（4 項訂正到位）→ CLEAN → **我 dispatch implementer**（floor + §5 TDD 含 persist.hold fire 斷言 + 不凍紅線 + crisis 打斷 + own-outpost 不退化）→ measurer 和平床 re-run（含 §5b team14 timing 對比）。有殘 → 回 `to:systems`。★這是本 session 最高風險改動（唯一真 regression 前科區），最後一哩精確度不放鬆。
