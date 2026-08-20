# 領主主動照護 loop — 一件解三題（WHAT / vision）

status: LOCKED（R① CLEAN 2026-08-05；P4 真缺口確認 → WHAT 決斷=(a) firsthand 觀察 write，見 §前提 P4）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-05
溯源：cohesion ①natural blocked（relief reactive、傲村不開口 → 好領主建不起恩義史）；失聯帳本 spec 既定 lane（「領主對遠方自家據點/村莊的定期音訊預期＝同一系統」）；用戶定程度 2026-08-05。

## 一件解三題
① cohesion ①natural（好領主自然建恩義史 → 分化活）② ledger lord-village lane 完成（WHAT 既定）③ relief 從純 reactive 補上 proactive 路。

## ★程度界線（用戶定）
- **不是**保姆國家：✗ 全村盯+自動補滿（天眼+福利機、殺稀缺殺分化）✗ 死常數巡邏排程。
- **是**：**注意力 = 人格秤 + 真成本**。
  1. **訊號**：帳本記自家村「預期音訊」→ 逾時 → 失聯 belief（reuse 失聯帳本、僅加 holding 條目類）。
  2. **理不理 = 領主人格秤**（責任感/仁慈 → 派斥候查；野心/疏忽 → 忽視 = 他的村照樣餓死叛離 = 正確分化）。**零死常數**（無「逾時 X 必派」）。
  3. **斥候物理走**（reuse 既有 scout side-dispatch）→ 抵村**親眼見**（co-location firsthand 讀村況 = 感知合法）→ 帶回 belief。
  4. 見困難 → **餵已 merge 的賑濟秤**（distribute mini-util 讀此 belief → preemptive 賑濟）→ 恩義史（既有 benefactor memory）自然累積。
- **成本真**：斥候佔人力（與軍偵搶同批）、賑濟花真糧、窮領主照顧不起。**資訊守物理**（走路+延遲、無儀表板、偏遠村天生少被看）。

## 前提（pending R①）
- **P1** ledger lord-village lane：spec 既定（missing-contact-ledger §1）但**本批只 wired herald/scout/convoy 3 info-kind** → holding（村）條目**未 wired**（本 arc 補的就是這塊——驗未 wired 屬實）。
- **P2** scout side-dispatch 已 merged 活（含 info_returned 帶回機制）。
- **P3** distribute mini-util 已 merged（讀 belief 秤賑濟、免費 gift）。
- **P4（R① 驗實=真缺口）** scout 現只 **relay 村子「已 post」的買單**（`_deposit_help_need`）、無 firsthand 觀察 write——**傲村不開口＝不 post 單＝scout 到場也看不見** → 正是照護 loop 要解的核心案例會漏。
  **★WHAT 決斷 = (a) 補 firsthand 觀察 write**：scout 抵村（co-location 物理在場＝既有感知 carve-out 合法）讀**現場可見**狀態（food 存量/population/困頓跡象）→ 產 distress 觀察值入 belief（帶時戳）→ 餵賑濟秤。**(b) 否**（靠村自己 post 單＝重回 reactive 依賴、傲村永遠盲區、loop 白建）。觀察限**現場可見**（非私念/非全知）。

## 量測（= cohesion ①natural 的真考）
- **自然床分化**：責任/仁慈 lord 的村被查/被救多 → 恩義史 → 留得住；疏忽 lord 的村照樣叛離。**moderate-distress ex-ante 判準床**（distress 窗 > 物理最短救援延遲）。
- 失敗照常在（查太晚/斥候死/領主窮）= 非普遍照護。
- 人格分化可觀測、零死常數、determinism、感知鐵律、QA 故事稽核照新常態。
