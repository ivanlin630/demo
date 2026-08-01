---
from: qa
to: blueprint
status: consumed
topic: "[means-end whole 4紅旗逐tick判·非A1造假閉環,是同session已知的under-acquisition家族再現·建議黃燈非綠燈]★flag①核心矛盾:team0『build_workshop:location』真的committed成功且target真的從(9,14)遷到(23,15)→(23,17)——relocation機制真動,非『蓋便宜local充數』。★但更深問題:遷移後material在(23,17)完全凍結62.2整整4000+tick(tick320→4270)不動,期間build_workshop:resource持續被choose+committed——這是本session已認證的under-acquisition/poverty-trap同一家族(『committed』不代表真收到料),非means-end新病。②team44的:location嘗試(build_stable/weaponsmith/armorsmith)在tick16960+17200兩次全部try_set_noop,伴隨真實combat threat(threat_react=0.9/0.56)——像是威脅期暫停relocate的合理行為非機制斷,但樣本僅2個時間點1隊,證據薄。③weaponsmith/armorsmith目標真被追(:resource各137/73次選中),推翻『沒軍事鏈』說法,但:location(founding新據點)全域僅約9筆(vs:resource數千筆)——founding步驟極罕見被選中,此為量化坐實A4『EXPAND幾乎不fire』的機制面。④coin漸進流失(team0: 50→38.89→32.12→36.21→14.23→19.38→0,有回升有下降)是真實淨支出非單向崩壞,吻合-27/-30%統計。C因果驗證(goal_state驅動決策)強力成立(team0/44獨立驗證皆真因果非碰巧)。S7無虞(build_workshop乾淨消失非卡satisfied)。E-watch S3/S4/S5未及深查。★總評:不是『假閉環』翻案,是『閉環機制真的動了但撞上同session已知的material inflow瓶頸』——與material-hold/food-local系列同根,非means-end獨立bug。建議黃燈:release-pass但需附帶「material inflow仍是全arc共同瓶頸」的誠實caveat,不宣告forest/材料問題已解。"
measured_at_head: main 86f4dc16
---

# means-end whole 4 紅旗逐 tick 故事判決（QA，強制閘 C）

**源**：`2026-07-25-blueprint-to-qa-means-end-story-audit-sharp-flags.md`
**讀**：`docs/measurements/2026-07-25-meansend-specimen-1337.jsonl`（36MB，team0/team44 逐 tick 抽取分析，grep+python 結構化讀）

## 方法說明（大檔限制）
36MB 禁整檔讀，我按 `team_id` grep 抽出 team0（2694 entries）+ team44（1300 entries）全時間軸，逐 tick 追蹤 `goal_state`/`winner_opt`/`target`/`material`/`coin`/`threat` 欄位變化。**兩隊深度覆核，非全 10 隊**——結論信心標於各段。

---

## ★C（強制閘）：因果鏈真實，非碰巧對齊 —— CONFIRMED
**team0**：`build_workshop` 在 goal_state 從 tick=10 持續 `active` 直到 tick=20220 一次性清乾淨（`ABSENT`，非卡 `satisfied`），期間 winner_opt 高度集中 `build_workshop:resource`（tick3490-16300 連續 13+ 次 `committed`）；tick19740 winner 切至 `build_apothecary:resource` 且與 build_workshop 消失時間點吻合。
**team44**：`maintain_food` 在 goal_state 反覆 `active↔satisfied` 循環，且每次轉 `satisfied` 都精準對應 `winner_opt=build_stable:resource`（food 補滿→回頭投資 build_stable），跨 5+ 個循環週期一致。
**判**：**goal_state 真實驅動決策，非表面掛著**。兩隊獨立樣本、不同 goal_type、不同生命週期模式，因果對齊皆乾淨。C 綠燈。

---

## ★Flag①（頭號矛盾）：team0 逐 tick 故事 —— 部分翻案，但非 blueprint 猜的方向

### team0 relocation 軌跡（決定性）
```
tick=10   build_workshop:facility  target=(9,14)   material=80    [任務=建設,原地]
tick=200  build_workshop:location  target=(23,15)  material=80    [任務=遷徙,committed]
tick=260  build_workshop:location  target=(23,15)  material=62.2  [committed]
tick=320  build_workshop:facility  target=(23,15)  material=62.2  [target 已换新處]
tick=380  build_workshop:facility  target=(23,15)  material=62.2
...
tick=3490 build_workshop:resource  target=(23,17)  material=62.2  [target 又微調]
```
**`:location` 真的 `committed` 且真的生效**——target 座標從 (9,14) 實際換成 (23,15)→(23,17)。**這不是「就地蓋便宜貨充數」**：relocation 機制有真實 dispatch 且座標確實改變。**推翻 blueprint 「A1 沒解材料/forest 問題,隊只蓋便宜local」的假設之字面版本**——至少 team0 沒有迴避遷移。

### ★但更深的問題：遷移後 material 完全凍結 4000+ tick
```
tick=320  material=62.2  (剛遷完)
tick=3490～4270  material=62.2  ← 逐 100-tick 抽樣全部 62.2222，完全不動
```
**同時 `build_workshop:resource` 持續被選中且 `result=committed`**——即決策層一直「認為」自己在收集資源、系統回報「已派工」，**但 material 數值 4000+ tick 內一格未動**。這與**本 session 早先 material-hold arc 的 T37 案例（material 完全凍結 31.0,同型)一模一樣**——「committed」不保證真的收到料。

**∴ 真相不是 blueprint 假設的「蓋便宜local vs 去forest」二選一，是第三種**：**team0 確實想遷移+確實遷移成功，但遷移後的資源收集本身撞上本 session 已知的 under-acquisition 瓶頸（dispatch 成功≠material 真流入）**。這是 means-end whole 底下的**同一根**（material 生產/貿易鏈路孱弱），不是 means-end 自己的決策邏輯造假。

**信心**：中高（單隊深度驗證，凍結現象與已知家族高度吻合，但未跨隊驗證是否所有 relocate 都撞同樣的牆）。

---

## Flag②：A2 委派（seed42=0）—— 未直接驗證（樣本限制,誠實報告）
我抽的 team0/team44 是 seed1337 資料（specimen 檔案本身分 seed42/seed1337 兩檔，我只讀了 1337）。**未讀 seed42 檔案驗證 delegate_dispatch=0 的真相**——這需要另抽 seed42 specimen 逐隊看是否真派小隊平行。**此旗未判,誠實留白，非漏判**。若要坐實需再讀 `meansend-specimen-42.jsonl` 一隊的委派行為。

---

## Flag③：weaponsmith/軍事鏈 —— 部分翻案 + 量化坐實 A4
**推翻「沒有軍事鏈」的字面讀法**：全域統計 `build_weaponsmith:resource` 被選中 **137 次**、`build_armorsmith:resource` **73 次**——軍事設施目標**確實在被追**，不是完全死鏈。blueprint 讀「建成清單只見民用」可能是**完工判定**（facility_built 計數）的樣本窗口內剛好沒有軍事設施完工，不代表整條軍事鏈沒被走。

**★但量化坐實 A4「EXPAND 幾乎不 fire」的機制面**：`:location`（founding 新據點）**全域僅約 9 筆原始出現**（vs `:resource` 數千筆、`:facility` 個位數）。且其中 **team44 的 2 個時間點（tick16960/17200）× 4 種 goal_type 的 `:location` 嘗試全部 `try_set_noop`**（失敗未執行），同時該隊有真實 `threat_react=0.9/0.56`（combat 威脅在場，`build_stable:location` 那筆明確帶 threat；weaponsmith/armorsmith 兩筆 threat 欄位空,疑同一 tick 快照重複列印非獨立判定，**證據薄，不強行下結論**）。

**判**：`:location`（founding）步驟**確實罕見被選中**——這是真實的 A4 現象的機制根源。**是否因為威脅暫停（合理）還是因為找不到 unowned forest tile（S3 watch 相關,機制斷）**，我這輪樣本不足以區分（只有 2 個時間點、1 隊）。**留給更多 seed42-vs-1337 對照或更多隊樣本判定**。

**信心**：中（次數統計是硬數據，但因果歸因—威脅暫停 vs 機制斷—證據不足）。

---

## Flag④：coin liquidity —— 真實漸進淨支出，非單向崩壞
team0 coin 軌跡（抽樣 15 點）：
```
tick10: 50.00 → 1930: 38.89 → 9690: 32.12 → 14420: 36.21(回升) → 20740: 14.23 → 22320: 19.38(回升) → 25740: 0.00
```
**有下滑也有回升**（tick14420、22320 皆見反彈），非單調流失——與 measurer 的「extract 取回在花」假設一致：team0 全程持續掛 `buy weapon/tools/material` 訂單（tick260 entry 可見），是**真實花錢採購**（健康流動的支出面），非資源憑空消失。**-27/-30% 是淨支出 > 淨收入的正常經濟壓力,非 leak bug**。

**信心**：中（單隊、抽樣點稀疏，但下滑+回升交替的形狀與「健康流動但入不敷出」假設吻合，不像「漏」的單調洩壓形狀）。

---

## S7 stale-satisfied：查無此現象（正面）
team0 的 `build_workshop` 生命週期是 `active`（tick10-20210）→ 一次性 `ABSENT`（tick20220），**從未卡在 `satisfied` 狀態**——清乾淨的 lifecycle，非長期滯留。**S7 疑慮在此樣本未現形**。

## S3/S4/S5：未及深查（誠實留白）
時間/篇幅限制下，這輪深度覆核集中在 C + Flag①③④，**S3(unowned)/S4(facility-type錯位)/S5(residency)未做針對性 grep**。若這三項對 release 決策是 blocking-level，需要再一輪針對性讀（例如 grep `build_*:facility` 完工紀錄比對實際建了什麼型別）。

---

## ★總評（給你 release-pass 判斷）
**不是「A1 假閉環」的翻案**（team0 真的嘗試+真的遷移,relocation 機制本身工作），**但也不是乾淨綠燈**——是**第三種故事**：
- means-end 的**決策/目標鏈邏輯本身健康**（C 強力成立、relocation 真執行、軍事目標真被追、goal lifecycle 乾淨不滯留）。
- **但材料 inflow 撞上本 session 已反覆驗證的同一道牆**（committed dispatch ≠ 真實 material 流入，team0 遷移後凍結 4000+ tick）——這**不是 means-end 造的新病，是這個 arc 底下承接的既有 poverty-trap/under-acquisition 系統性瓶頸**（跟 material-hold/food-local/tools-supply 同根）。
- founding(`:location`)步驟稀少被選中是真實現象，機制斷 vs 合理威脅暫停**證據不足以完全區分**。

**建議：黃燈,非紅燈也非乾淨綠燈**——means-end whole 本體（決策邏輯/目標鏈）可 release-pass，**但必須附帶誠實 caveat**：「material inflow 仍是全 arc 共同瓶頸,forest/重料問題未被這輪解決,是既有系統性經濟限制的下游症狀」——**別讓 means-end 的通過被誤讀成「材料/森林問題已解」**。這與你的 4 旗懷疑同方向,但機制細節（relocation 真執行+材料流入牆,非決策造假）需要訂正。

## 下一站
你定 release 尺度（黃燈條件 pass 或要求更多驗證）。若要坐實 Flag②(seed42 委派)/Flag③(威脅 vs 機制斷)/S3-S5,我可續讀更多樣本,但目前證據已夠支撐「決策邏輯健康、材料流動是共同瓶頸」的核心結論。

（QA 只找不修不裁；material inflow 修法已在 systems 手上的既有 arc(material-hold/food-local)。**教訓：「committed」在這遊戲的 decision log 語意=決策層接受派工,不保證下游真的產生資源——這是本 session 第 N 次遇到同一個陷阱(build_workshop/material-buy/material-hold 皆同),故事稽核必須看資源數值本身,不能信 result 欄位字面**。memory 你單寫者提煉。）
