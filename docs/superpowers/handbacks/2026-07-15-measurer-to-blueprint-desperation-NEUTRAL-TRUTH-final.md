---
from: measurer
to: blueprint
status: consumed
topic: "[量測完·中性世界真相] desperation@5fcb68e3——★confound真除(三跑world-level byte一致,僅specimen自身輸出差);★thrash真相=之前是觀測假象,真實世界Team26同快照56次仍在;★但真世界下Team26真死了(連貫窮死74entries給QA)+Team18仍活(A/B確認);買糧真出貨;determinism/憲法/sanity全綠"
---

# desperation 中性世界真相報告（release 真門檻）

`measured_at_head: 5fcb68e3`（confound修已含）。**本封是真門檻——所有數字來自confound已除的中性世界。**

## 一次量完（鐵律6）

## 0. ★confound 真除：三跑 world-level 驗證通過
`SPECIMEN_TEAM_ID=20` / `=26` / 無-specimen 三跑，`[Survival] Team26` flip 次數：**88 / 88 / 88**（三者一致，取代上輪的 0/71/88）。進一步逐行 diff（排除 specimen 自身輸出段落）：**世界層級零差異**，唯一差異是 specimen 專屬的候選/狀態/裁定文字段落（預期內，非世界岔開）。**★confound 確認根除，本輪數字可信。**

## 1. ★★thrash 真相：之前的「修好」確實是觀測假象——真實世界 thrash 仍在
中性世界 Team26：**88 次總 flip、56 次同快照重複**（與我上輪在擾動世界下「意外撞見」的數字完全一致——證實那不是巧合，是真相）。集中在 tick~5660-6307（day~24-26），`貿易↔掠奪`/`掠奪↔idle` 反覆同快照震盪，與原始 blood-evidence 同款。

**這代表**：A/B/A-2 三刀合計，對 Team26 這個個案的**早期危機階段（day24-26）沒有根治**，thrash 在那裡依然存在。

## 2. ★★但——中性世界下 Team26 的完整命運不同：它真的死了（連貫窮死，74 entries）
`docs/measurements/2026-07-15-desperation-neutral-seed1337-Team26.jsonl`（decision_count=74，死 tick=20419，取代上輪「存活至尾」的擾動世界結果——**confound 之前連「活/死」這個最基本結論都測錯了**）。

完整故事（tick18230→20419，day76→85）：
1. **遷移找糧→覓食**（18230-19040）：food 5.2 慢降，中途有小恢復（4.3→7.1），持續嘗試覓食。
2. **掠奪**（19620-20360，主段）：material 穩定爬升 13.6→20.2（掠奪機制確實生效，非幻覺），**但 food 完全不受掠奪影響、持續下滑 7.1→0.0**——掠奪換得物資而非糧食，對這隻隊沒解到真正的危機（結構性：這個絕境選項給錯資源類型）。tick20340-20360 出現 coin 0→3.3（小額交易），但已太遲。
3. **併入**（20380-20410，臨終）：food=0 後 pop 開始 3→2→1，仍嘗試併入求生，trace 結束於 pop=1，9 tick 後（20419）真正團滅。

**判讀**：這是**連貫窮死**——奮力嘗試遷移/覓食/掠奪/併入四種路徑、非守著單一幻覺不放、非 idle 死，符合 QA 要的「真掙扎後死」敘事。**但根因診斷**：早段（day24-26）的 56 次同快照 thrash + 晚段「掠奪得物資不得糧食」的資源錯配，兩者共同導致這支隊終究撐不過——**A/B/A-2 讓它死得有尊嚴（連貫），但沒讓它活下來（thrash 仍間接促成死亡）**。

## 3. Team18：A/B 確認持續有效（中性世界，決策數 59 vs 上輪擾動世界 60，接近但非同——世界確實不同了，符合預期）
- **買糧真出貨**：`active_buy_food_qty` 隨 tick 遞減（6→5→4...），確認訂單真在被填，非掛著不動的幻覺單。
- **遷移找糧**：tick7440 首筆即「遷移找糧→覓食」。
- **囤貨恢復**：33/59 決策是「囤貨」，最終穩定致富（同上輪判讀，模式未變）。
- **併入**：本輪只 5 次選中（非 40 次 loop），target 未紀錄長期糾纏——**Team18 在中性世界下併入不是 loop 型**（原本就不是，A-2 對它從來就不必要）。

## 4. 不回歸：全綠
- **determinism**：中性世界獨立雙跑 Team26 jsonl SHA256 byte-identical。
- **憲法閘**：PASS sites=29 removed=0。
- **sanity headless_test**：與所有先前輪一致的 2 FAIL+3 SCRIPT ERROR（pre-existing），零新增。

## 待 blueprint 裁（真相已定，判斷題交還你）
1. **thrash 未完全根治**（Team26 早段 day24-26 仍 56 次同快照）——但**最終死法連貫**（非幻覺 loop 死，是四處嘗試後力竭死）。這是否已達「求生決策不製造假死」的驗收標準？還是早段 thrash 本身也要根治（開新一刀）？
2. **掠奪的資源錯配**（material 賺很多，food 完全沒解）——是否是另一個真根（絕境隊該搶的是「食物」不是任何資源，目前掠奪不分資源類型）？值得開 follow-up 或算 tuning 範圍？
3. 若接受「連貫死+局部thrash」為足夠——QA 讀 `2026-07-15-desperation-neutral-seed1337-Team26.jsonl`（死隊，主故事）+ `2026-07-15-desperation-neutral-seed1337-Team18.jsonl`（存活對照）判故事性；若不接受，回 systems 開新診斷。

---
measured_at_head: 5fcb68e3
