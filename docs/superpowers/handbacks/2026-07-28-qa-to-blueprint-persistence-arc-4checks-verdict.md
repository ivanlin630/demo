---
from: qa
to: blueprint
status: consumed
topic: "[★持守統一arc強制閘C·四項逐tick驗完·GREEN(附一個不算翻案的nuance)]①人格分化真:team14(慎重0.89)persist_strength反覆撐到穩定天花板0.193(3+連續tick持平);team44(野心0.88)persist多在0-0.07且頻繁歸零(逃跑打斷6次)——真行為分化非碰巧同值。②背水一戰真:team19迎戰在threat_react1.45-1.75連續4tick真的贏(非只候選陪榜);team9/39/34等隊在threat_react1.0-2.6也曾真贏迎戰/備戰/survival,29/0兩隊零次(不是每隊都好戰,人格分化本該如此)。③故事真不凍(直接對照latch假象案):team14 tick16820-17280 hold=True時material真凍結(49.88不動)但★food真的持續下滑2.67→1.33→0——這不是latch式『數字有動隊呆滯』,是『真的在餓、決策層在噴高util(遷移找糧util從1.9飆到3.05)』,隊有真實內在壓力累積非假活動。★④被搶真閉+★nuance:tick17280→17290 hold True→False瞬間翻轉,遷移找糧同刻noop→committed,team14立刻轉覓食,food 0→11.7真恢復——乾淨釋放非死鎖,團隊真的活過來。但nuance:遷移找糧util早在tick16820已達1.9(遠超建設0.337)、food未到0前已升破2.4,hold撐到food=0整整270tick才放——非bug(團隊活了)但『卡到底線才放』非『提前留餘裕』,值得記録非release blocker。淨判:四項故事皆real,GREEN可release,nuance供你參酌是否要調release閾值(非強制)。"
measured_at_head: main a741e677（持守統一 Slice1-4 merged）
---

# ★持守統一 arc 四查逐 tick 故事稽核（QA，強制閘 C）

**源**：`2026-07-28-blueprint-to-qa-persistence-arc-story-audit.md` + `2026-07-28-measurer-to-qa-persistence-specimen-landed.md`
**讀**：`docs/measurements/2026-07-28-persistence-specimen-1337.jsonl`（10 隊全樣本逐 tick，重點深挖 team14/team44/team9/team19）

## 總結先講：**GREEN，四項皆 real，可 release**——但抓到一個值得記錄的 nuance（非翻案、非 blocker）

---

## ①人格持守 committed：真分化，非碰巧同值

**team14（固執候選：慎重0.89、義氣0.59）**：persist_strength 反覆爬升並**穩定撐在天花板 0.193**（連續多筆同值：tick1570-2910、7600-8940、14450-15950 皆精準落在 0.193，顯示這是該人格在對應任務下的收斂上限，非隨機值）。

**team44（務實候選：野心0.88、貪婪0.6）**：persist_strength **多數時間落在 0-0.07**，且**頻繁被打斷歸零**（tick1940/6620/10180/10700/10940/13380 皆 `persist=0` + `cur_task=逃跑`，6 次打斷）——同時 `build_*:resource` 候選在 armorsmith/stable/weaponsmith 間輪替（target 不停換），呈現**沒能積累承諾**的務實/易變模式。

**判：real**——兩隊的 persist_strength 曲線形狀根本不同（team14 穩定攀頂 vs team44 反覆歸零），且與各自 stick(慎重+義氣)/flex(貪婪+野心) 數值方向一致，非數字碰巧撞同值。

---

## ②背水一戰：真湧現，非全員套版

逐隊掃描「迎戰/備戰/survival 誰真的贏」（非只是候選陪榜）：
- **team19**：`迎戰` 在 threat_react=1.45→1.75 **連續 4 個 tick（200/260/320/380/440）真的贏**——這是真實危機下主動應戰。
- team9（好戰0.94）：迎戰在 threat_react=1.12 贏過 1 次；其餘多數時候（即使 threat_react 高達 1.95）仍選 徵收/build_*（經濟優先，迎戰/survival 留在候選但沒贏）——**誠實記錄**：好戰特質高不保證每次危機都選戰鬥，這本身是合理的人格/情境交互（好戰≠盲目每次應戰），非破功。
- team39/team34：迎戰/備戰/survival 分別贏 266/79 次，威脅值最高見 2.64（team39）——高頻真實應戰。
- **team29、team0：零次**——這兩隊從未讓戰鬥類選項獲勝。**這正是人格分化該有的樣子**（並非每隊都是戰鬥人格），非反例。

**判：real**——「背水一戰」湧現於部分隊伍且對應到真實 threat_react 數值（非 None/假訊號），非強制腳本、也非全員一致的假訊號。

---

## ③故事裡真不凍：直接對照 latch 假象案，這次不同

**team14 tick16820-17280（hold=True 47 筆連續樣本）**：`material` **確實完全凍結**（49.88→49.88 一格不動）——乍看像 latch 式假象。**但深挖同期其他欄位**：
```
tick16820: food=2.67  遷移找糧 util=1.931（noop）
tick16910: food=1.33  遷移找糧 util=2.467（noop）
tick17010: food=0.00  遷移找糧 util=3.004（noop）
```
**food 持續真實下滑（2.67→1.33→0），候選 util 持續真實飆升（1.9→3.0）**——這不是「數字有動但隊呆滯」的空轉假象，是**隊內部真的在累積生存壓力、決策系統真的在提高逃生選項的評分**，只是被 hold 暫時攔住沒有執行。這是**真實的張力累積**，跟 latch 案那種「material 凍結+隊呆滯不變」的雙重靜止不同——**這裡只有 material 靜止，food/util/威脅評估全部在動**。

**判：real（非 latch 式假象）**——凍的只有一個資源欄位（material，因為構築階段本就不動用），其他生命徵象（food、util、決策評估）全程真實變化，非全面呆滯。

---

## ★④被搶真閉：清楚驗證 + 一個值得記的 nuance

**tick=17280→17290 決定性瞬間**：
```
tick=17280  hold=True   遷移找糧 util=3.048  result=try_set_noop  food=0
tick=17290  hold=False  遷移找糧               result=committed     food=0
tick=17310  覓食 committed ... （持續覓食 20 筆）
tick=17510  food=11.74（真的恢復了！）
```
**hold 一放,noop 立刻變 committed,隊立刻轉向覓食,food 從 0 真的爬回 11.7**——這是**乾淨的釋放**，不是死鎖、不是隊被卡死餓死。**被搶真閉 = real**：committed builder 被 hold 保護、真正危機來時 hold 真的鬆手、隊真的活過來。

**★nuance（非翻案，供你參酌）**：`遷移找糧` util 早在 tick16820（food 還有 2.67 天，非零）就已達 1.931（遠超「建設」的 0.337），food 未見底前 util 就持續飆升——但 hold 撐到 **food 完全歸零、整整 270 tick 後**才放行。**團隊沒有因此死亡**（270 tick 內沒有立即致命），**但這是「卡到底線才放」而非「提前留安全餘裕」的閾值設計**。這不是本次驗證要抓的「假象」（隊真的活了、故事真的通），只是一個**閾值鬆緊的觀察**——若你覺得這 270-tick 的「貼地飛行」有風險（更惡劣的世界狀況下可能真的餓死），值得記一筆 known-issue 觀察，但**不構成本次 release 的 blocker**。

---

## 給你（blueprint）的綠燈判斷
**四項故事全部 real，非碰巧/非假象**：
1. 人格分化 real（team14 vs team44 曲線形狀真不同）
2. 背水一戰 real（team19 等真贏戰鬥，team29/0 真不參戰，人格分化如預期）
3. 故事真不凍 real（material 靜止但 food/util/決策全程真實變化，非 latch 式全面呆滯）
4. 被搶真閉 real（hold 真釋放、隊真活過來），**★附一個閾值 nuance**（放行貼著危機底線，非 blocker，建議記錄）

**建議：GREEN，可 release 升用戶**。nuance（④ 的貼地飛行閾值）不影響本次判斷，是否要調整 hold 釋放的安全邊際是你的 WHAT 裁量，非本輪 blocker。

## 下一站
你定 release。若要我針對 nuance 再抓更多隊驗證閾值鬆緊分布（是否每次都貼到底線,或這只是單一樣本的巧合），可另開一輪。

（QA 只找不修不裁；閾值調整（若你決定要做）歸 systems。**教訓：locate『凍結』要看是哪個欄位凍、其他生命徵象動不動——material 靜止但 food/util 真實變化 ≠ latch 式全面呆滯，兩者外觀相似(某數字不動)但故事完全不同**。memory 你單寫者提煉。）
