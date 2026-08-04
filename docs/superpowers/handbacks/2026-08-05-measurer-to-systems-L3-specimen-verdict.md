---
from: measurer
to: systems
status: consumed
topic: "L3 focused specimen for QA已落地:rep床(config/infonet_faction_rich_rep.json,同8-deal那床)seed2024 45天,SPECIMEN_TEAM_ID=0,1,2,3,4,5(全6隊)產出2717 entries,attrition18.03%/trade.deal8/market_arrive17(與上輪verdict數字一致,重跑穩定)。specimen每筆含『做什麼』(task/target/winner_opt)+『想什麼』(candidates含每option util陣列+intent+threat)+『狀態』(faction_id/coin/food/leader_traits人格/pop等)——已檢視樣本entry確認直接含per-option util陣列(可讀商人motive→決策)+leader_traits(可讀人格差異T0慎重0.5野心0.75 vs T5求生欲0.9貪婪0.5等對照)+task/target逐tick(可讀travel/at_market/撮合鏈)，滿足QA要的『商人motive→訪市決策→travel→撮合→資訊帶回』故事素材+人格分化故事。已回systems handback:2026-08-05-measurer-to-systems-L3-specimen-verdict.md，純觀測,別下accept，QA讀後verdict ref回"
---

# L3 focused specimen for QA — 已落地

## 做法

- rep 床（`config/infonet_faction_rich_rep.json`，同上輪 8-deal 那床）seed2024、45天。
- `SpecimenDumpHelper` canonical hook（temp 掛，跑完 revert）+ `SPECIMEN_TEAM_ID=0,1,2,3,4,5`（全 6 隊，小 fixture 全收，涵蓋 founding 路 T0-T3 + vassal 路 T4/T5，兩種 faction 形成路徑都在故事裡）。

## 結果確認（跟上輪 verdict 數字一致，重跑穩定）

```
attrition=18.03% final={teams:16, factions:1}
trade.deal=8 trade.deal_market=8 trade.deal_merchant=1 trade.deal_resident=7 g1.market_arrive=17
[SpecimenTracer] write_jsonl → docs/measurements/2026-08-05-l3-rep-specimen.jsonl (2717 entries)
```

## specimen 內容檢視（確認滿足 QA 需求）

抽樣看了實際 entry 結構，每筆含三段：
- **`做什麼`**：`task`/`target`/`winner_opt`（真選了什麼、去哪）。
- **`想什麼`**：`candidates`（★每個 option 的 util 陣列，含市集訪視 option）+ `intent`+`threat`——**這就是「per-option util」故事素材，可直接讀出商人 motive（為什麼選訪市 vs 其他 option）**。
- **`狀態`**：`faction_id`/`coin`/`food_private`/`pop`/**`leader_traits`**（慎重/野心/求生欲/貪婪/好戰 全人格值）——**可直接對照不同隊人格差異**（例：T0 慎重0.5/野心0.75 vs T5 求生欲0.9/貪婪0.5），逐 tick task/target 序列可讀出 travel→at_market→撮合的完整鏈。

範例（T4 tick10）：`候選 [{建設 util0.57},{覓食 util0.33},{駐守 util0.18}] → 選建設`；（T0 tick10）：`候選[{駐守0.28},{建設0.12},{貿易0.008}]→選駐守（貿易util低未選，可讀出當下未到訪市時機）`——這種逐 tick 記錄可讓 QA 追出「什麼時候貿易 util 開始超車、隊真的動身去訪市」的完整因果鏈。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-l3-rep-specimen.jsonl`（2717 entries）
- `docs/measurements/2026-08-05-l3-rep-specimen-run.txt`（12342行，完整跑 log 對照）

## 清理狀態

- `warring_harness.gd` temp SpecimenDumpHelper hook 已 `git checkout --` 還原確認乾淨。
- temp `l3_rep_specimen_bed.gd` + 借測用 `config/infonet_faction_rich_rep.json` + worktree 內重複的 jsonl 副本皆已刪除。

純觀測，未動 production code。別下 accept，QA 讀後給 verdict ref，回 systems 判 merge。
