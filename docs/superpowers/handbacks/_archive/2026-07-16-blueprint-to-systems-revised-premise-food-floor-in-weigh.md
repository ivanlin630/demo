---
from: blueprint
to: systems
status: consumed
topic: "[premise訂正·R①推翻天真de-patch]R①手算證:拆hungry override後,普通地力下餓隊會選蓋工坊餓死(workshop score>farming除非地力近max);override是承重的(補償壞公式防餓死)。+means-end斷鏈(建設option不會真蓋設施,faction_id=-1隊生產永久斷)。∴修正WHAT:非「拆override讓人格選農田」,是①把食安地基誠實編進秤(deficit要生存急迫度量級,別flat clamp[0,1]→快餓死須量級輾壓自然選農田,食安後才輪人格選發展)②給所有隊真means-end建設路。常數訂正:0.8代謝物理不動、只7人格化。序:score修好才准拆override(否則餓死)。R①CLEAN後再spec"
---

# premise 訂正：食安地基要「真實在秤裡」，非拆 override（R① 推翻天真 de-patch）

R① 用異質模型手算推翻我的核心 premise。**感謝這道閘——天真 spec 會讓隊餓死,比現狀更糟。** 修正如下。

## R① 推翻了什麼（我 premise 錯處）
1. **「拆 hungry override → 人格自然選 farming」＝假**：`_facility_score=地利×(1+deficit)×人格` 手算——普通~良好地力,餓隊會選 **workshop**（4.40）> farming（2.30~3.45）,只有地力近 max（≥1.91/2.0）farming 才贏。**deficit clamp[0,1] 使「快餓死」與「略缺」都=1.0,無量級區分;workshop 鄰森林×2.0+新隊零庫存恆滿壓過農田。** override 其實承重（補償壞公式防餓死）。
2. **means-end 斷鏈**：「建設 option 接手蓋工坊」全 codebase 不存在;facility 建造只由 `_evaluate_infrastructure`（僅迭代 `state.factions`）發起 → **faction_id=-1 獨立定居隊永無路建設施**,P1 濾掉生產後永久斷。

## 修正 WHAT（食安地基要真實在秤裡）
**不是「拆 override」,是讓地基在秤裡真正壓倒性:**
1. **食安急迫度要有量級**：deficit（或等效項）別 flat clamp[0,1]——**「快餓死」須量級輾壓 workshop/軍事,自然選農田;食安後急迫度降,才輪人格選發展維度**。這樣 food-floor 從秤裡湧現（非硬 override）,override 才能安全退役。
2. **means-end 真回路**：所有隊（含 faction_id=-1 獨立定居隊）都要有「想 goods → 需設施 → 能發起建設施」的真路徑,非只 faction 隊。
3. **序（關鍵）**：**score 修好（地基真進秤）才准拆 override**——否則拆了隊真餓死。A2（死碼/precondition/tap）可先（那條不碰求生）;A1 override 退役 gated on 地基編進秤。

## 常數分層訂正（R① 抓的）
- **`FOOD_PER_PERSON_PER_DAY=0.8`＝代謝物理常數,絕不人格化**（否則「慎重的人比較不餓」荒謬）。
- **只「7」（安全天數視野）該人格化**（慎重的人備更多糧視野）。
- **`TARGET_PER_POP` 雙重身分**（manufacturing 配方排序 key + workshop deficit 目標）——混雜物理/決策,**別簡單二分**,spec 明文拆開釘死哪部分物理、哪部分決策。

## 不變（仍守）
- 框架=規則、思考=引擎+人格;決策移引擎、機制留規則。
- 全程人格化（決策常數）、世界物理留 flat、新路接 tap。
- **食安地基 → 多維人格化發展** 的 WHAT 不變——只是地基要**編進秤**（急迫度量級）,非硬 override 假裝。

## HOW 全交你
- deficit 怎麼給生存急迫度量級（脫 clamp / 乘急迫度）、means-end 怎麼接（`_pick_facility` 進引擎讓所有隊能發起 / 給獨立隊 infra 評估路）、常數怎麼拆物理vs決策、切幾 slice ＝你 HOW。
- 我只要結果：**餓隊真選農田活下來 + 食安隊按人格建製造/軍事 + 所有隊有建設施路 + 製造 no-op 可觀測 + 無殘補釘 + 行為人格分化**。

## 下一站
systems 依訂正 premise 設計（地基進秤 + means-end + 常數拆層）→ **重送 R①**（核修正後 premise 手算成立否）→ CLEAN → spec → R②（審設計）→ impl → measurer（餓隊活+設施成長+surplus+deals+人格分化）→ 我批。
**R① 救了「拆 override 餓死」的塌陷。地基要真進秤,不是拆保護。先 score 後拆 override。**
