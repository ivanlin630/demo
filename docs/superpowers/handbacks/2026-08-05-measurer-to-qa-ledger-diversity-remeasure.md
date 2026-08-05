---
from: measurer
to: qa
status: open
topic: "失聯帳本diversity re-measure(defensive/rescue fix驗證,baf2a670)結果混亂→QA故事稽核(specimen 3135 entries):重建原64bd293c/93b41a26驗證過的diverse-lord床(4組lord一特質0.9dominant),本輪結果與原版乾淨1:1對應不同——contact.ledger_add=29 overdue=11,react分佈redispatch=7(僅lord0/統領dominant命中)+defensive=4(來源竟是resident T3/T5自身herald overdue,非lord層convoy overdue)+writeoff=0+rescue=0。4類中只有2類真fire、且defensive的歸因對象不是原本設計要驗的『lord對overdue convoy的反應』,是resident對自己herald逾時的反應。請讀specimen判：①4類全真世界效果的story是否仍成立(defensive/rescue的真consumer機制本身)②diversity(統領→redispatch等)這次沒展現乾淨,是我重建的fixture沒抓對原始設計精髓,還是defensive/rescue fix改變了dispatch行為分布。"
---

# 失聯帳本 diversity re-measure（defensive/rescue fix驗證）→ QA 故事稽核

## 背景

工單要求驗證 `feat/missing-contact-ledger`(`baf2a670`,defensive/rescue fix R²CLEAN後) 的①4類反應全真世界效果②diversity仍在。原diversity fixture(`config/infonet_ledger_diversity.json`+`ledger_diversity_bed.gd`)先前(64bd293c/93b41a26)build完temp未persist、已刪除——本輪**從verdict handback文字描述重建**（非原始檔案，可能有細節出入，誠實聲明）。

## 做法

4組lord+resident pair(T0-T7)，每個lord一特質0.9(dominant)其餘0.2：T0(統領)/T2(野心)/T4(慎重)/T6(義氣)，resident starving(food=15,mountain terrain 0.4×倍率)逼lord派convoy+讓convoy實際travel慢於ledger flat估算觸發overdue。seed=4044,30天。已persist commit `af62dd33`（`.worktrees/missing-contact-ledger`）。

## 原始輸出（已ls/wc驗證落地）

- `docs/measurements/2026-08-05-ledger-diversity-remeasure-30d.txt`（13536行）
- `docs/measurements/2026-08-05-infonet-ledger-diversity-remeasure.json`（25行聚合）
- `docs/measurements/2026-08-05-infonet-ledger-diversity-remeasure.specimen.jsonl`（3135行specimen）

## 結果

```
contact.ledger_add=29  contact.overdue=11
react聚合分佈: redispatch=7  writeoff=0  defensive=4  rescue=0

per-lord歸因(temp bump_sample,已revert)：
  lord0(統領dominant): {redispatch: 7}   ← 命中預期
  lord2(野心dominant):  {}                ← 零活動
  lord4(慎重dominant):  {}                ← 零活動
  lord6(義氣dominant):  {}                ← 零活動
  team3(resident,野心lord的resident): {defensive: 2}   ← ★非lord!是resident自己
  team5(resident,慎重lord的resident): {defensive: 2}   ← ★非lord!是resident自己
```

## 誠實淨判

**這輪結果跟原本(64bd293c)乾淨1:1對應的結果不同**：

- 只有 **2/4 lord-pair** 有任何overdue活動（lord0產出redispatch；lord2/4/6全程零活動——它們的convoy可能從未dispatch過，或dispatch了但沒overdue）。
- `defensive=4` 的來源出乎意料——**不是lord對overdue convoy的反應，是resident T3/T5自己的herald逾時、resident用自己的（未特化）人格選擇了defensive**（我config裡所有resident的統領/野心/慎重/義氣都設成相同的中庸值0.3/0.2/0.5/0.5，非dominant分化——這是fixture設計的疏漏：我只把dominant-trait特化給了lord，沒想到resident自己的herald也會進入同一套`_step_contact_ledger`機制）。
- `writeoff=0`/`rescue=0`——這兩類這輪完全沒觀察到。

**我不確定這是**：(a) 我重建的fixture沒抓對原始設計的關鍵細節（例如原版可能刻意讓resident的herald不會overdue，只讓lord的convoy會）；(b) defensive/rescue fix本身改變了dispatch/overdue的行為分布；(c) 純粹運氣（seed4044這次convoy剛好大多數沒觸發overdue，這輪的樣本數(11)遠低於原本(28)）。**這超出我能從聚合數字判斷的範圍，請讀specimen trace幫忙判斷**。

## 4類真consumer機制本身（可信,已code-read確認,見前一封verdict）

defensive→`contact_vigilant_until`真設定；rescue→真scout dispatch到lost_pos；這兩個consumer本身**存在且非write-only**（`faction_ai_system.gd:4758-4769`），只是這輪rescue剛好0次觸發沒得驗證。

## 下游

QA讀specimen判斷①4類真效果的故事是否仍站得住②diversity這輪沒乾淨展現是否影響「defensive/rescue fix驗證通過」的整體結論，出verdict ref供systems判斷是否需要調fixture重跑或這樣的樣本數已經夠。

## 清理

- production code溫度計(`contact.react_sample` bump_sample)已 `git checkout --` revert確認乾淨。
- fixture persist commit `af62dd33`。
