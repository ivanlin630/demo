---
from: blueprint
to: blueprint
status: consumed
topic: "[HANDOFF·blueprint session state 2026-07-17] 框架驗收arc進行中。經濟從『為何死』挖到『統一決策框架完成計畫』。現況:憲法閘baseline 91(93→91),軌2值閘de-patch merged,seam#1控制流收斂待啟,分化fast-follow待。框架做好=3流(零殘留/真統一擴充/情緒接線)+2不變量(下游零決策/零干擾),全機器證(constitution_gate v2+單寫者+oracle+registry)綠→才behavior。系統已GO自主驅動。★工作流教訓:別ping狀態(打進report-mode停鏈),讓系統驅動、狀態自己查git。durable在game-design★★統一路線圖section+memory unification_matrix+progress"
---

# HANDOFF：blueprint session state（2026-07-17）

## 開場程序（resume）
1. **arm 信箱 Monitor**（`Monitor(bash .claude/hooks/inbox-watch.sh, persistent)`）——先於一切。
2. 讀 `game-design.md`（我 owner，含 ★★統一路線圖 + 決策模型 v2 + 經濟診斷 + RNG 3案）。
3. auto-memory 自動注入（`unification_matrix` 條 = 統一路線圖 durable）。
4. 掃 handbacks `to:blueprint status:open`。

## 這 arc 一句話
用戶從「經濟為何死」一路逼問,挖穿 ~10 層,發現**真根不是散亂 oracle（R① 三次證早統一大半）,是隱藏補丁閘汙染 + 缺擴充 seam**。收斂成**「統一決策框架完成計畫」**：把框架做到**真統一 + 零殘留閘 + 可擴充,且機器證得出**,才談 behavior。

## ★框架「做好」的驗收定義（用戶定調）
```
真統一（每決策真只走一條路,零手派路由/散落入口/近似重複）
+ 零殘留閘（一個非框架閘=結果垃圾,無取捨全殲）
+ 可擴充（加新系統=registry加一筆,非散改）
+ 兩不變量:下游零決策（純執行）/ 下游零干擾（單寫者+單一源）
= 全機器證（constitution_gate v2 + CI-scan單寫者 + oracle + registry）綠 → 才 behavior
```
= 3 流：①零殘留閘 de-patch ②真統一/擴充 3 seam ③情緒接線。

## 現況（數字，2026-07-17）
- **憲法閘 baseline 91**（93→91,de-patch 2:calc_attack_score刪+_threat_recent）;37 gate-ok legit標;**54 待 triage**。
- **軌2 值閘 de-patch DONE+MERGED**（08d3a39d:閘1/5/7+try_proactive陡化,閘4/6 gate-ok,grep證函式消失）。
- **seam#1 控制流收斂 = 下個大 slice,系統已 GO 自主啟**。
- **分化 fast-follow multi-seed 待跑**（try_proactive 高慎重0%✓陡高端;低慎重/militancy/tribute待;militancy綁軍事設施thin）。
- **已 merged 前置**：供給生產框架、Arc 1 need oracle（need-quantity 單一源）、constitution_gate v2。

## 本 session 立的 durable 決策/原則（都在 game-design）
- **真統一 > 已統一**：canonical 源存在≠真統一;要零手派路由/散落入口。
- **零殘留閘**：一個殘留非框架閘=模擬結果垃圾（血證:恆-hungry/執行鎖/_threat_recent）。
- **RNG 3案**：①純骰替決策=de-patch ②世界不確定outcome=legit ③人格加權機率決策=legit-IF-陡+framework-routed+seeded（★世界性格=有機非鐘錶,曲線陡→清楚案例註定、難分才不可測）。
- **兩不變量**：下游零決策 / 下游零干擾。
- **triage 判準**：這閘 encode「世界事實（rule留）」還是「行為選擇（decision de-patch）」?測試=換人格/處境該不該不同。
- **經濟診斷**：真根=兩結構牆（成交條件+merchant不co-locate）→ market-as-place(B) + coin循環 → 供給牆=製造設施不建（恆-hungry閘）→ 生產框架 merged。**deal側死法②=behavior後做**。
- **綜合發展模型 / 生產需求模型**：need=自用+供應鏈+貿易（全資源可貿易,goods只貿易）;停產接需求;溢出落地守恆。

## 誰驅動什麼（無斷點自動鏈）
- **系統（01/持久）**：自主推 seam#1 + fast-follow + 54待triage → 做完推下一站,只為真escalation停。**已發 GO（`2026-07-17-...-GO-drive-autonomously`）。**
- **blueprint（我）**：到「乾淨全量驗完」批點才介入批;真歧義WHAT/premise矛盾才裁。**不 ping 狀態。**
- **驗收模式（Arc 1 立）**：byte-identical驗refactor / 乾淨全量對指標可溯源 / 嚴查擋假clean / R①前提factcheck（本arc前提被獨立查證推翻多次,大框必先驗）。

## ★工作流教訓（別重犯）
- **別一直 ping 系統狀態**——會把它打進「回報→idle」,鏈停（本 session 犯過,用戶戳「沒看到在工作」）。**讓系統自主驅動,狀態我自己 grep git。**
- **無斷點自動鏈**：各角色做完立刻推下一站,禁 park/等確認;只真裁決停。

## defer 到框架綠之後（behavior）
deal側死法②（surplus→買家流通）、俘虜殺俘/贖金、urgency-閾arc5人格化、純行為調、情緒行為內容（接線是框架、內容是behavior）。

## durable 位置
- **game-design.md**：★★統一路線圖 section + 決策模型v2 + 經濟診斷 + RNG 3案 + 世界性格（WHAT,我owner）。
- **auto-memory `unification_matrix`**：路線圖 + 現況（每session喚醒,系統單寫）。
- **progress.md**：arc 執行狀態（系統owner）。
- **架構視覺化**：artifact（framework-done 架構圖,腦/身分離+registry+憲法閘證）。

## 下一站
系統驅動 seam#1（R①→spec→R²→impl→乾淨全量）+ fast-follow → 到批點喚我批 → 續 seam#2/#3 + 情緒接線 + 單寫者驗 → gate全綠 = 框架驗收 → 才 behavior。**別 ping 狀態,讓它跑。**
