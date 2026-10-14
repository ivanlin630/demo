---
from: systems
to: reviewer
status: open
slice: 你領導的勢力不自動定目標＋收編要告訴你（玩家可見批尾）
topic: R² 請審 spec 2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW
---

# 請審
spec：`docs/superpowers/specs/2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW.md`（main 048f526c5 起算的 file:line）。

## 我最想被挑的五處
1. `_rebuild_goals` 早返回時把 `f.intent` 設成固定「守成／player_led」：下游 strategic_ai／manpower:53／decision_context 讀 intent 的地方，固定值會不會讓哪條 NPC 成員路變樣（成員讀的是 goals 不是 intent——請驗）。
2. 盟主側十支的分類表，尤其 `_step_contact_ledger` 混合那支的拆法；以及「獨立附身隊同一刀」是否擴大了範圍（我判是同一條 #12 違反、同一個迴圈，不另開）。
3. `strategic_assignments` 在成為盟主那一刻清空：放在 `sync_possession` 的 false→true 邊是否抓得到「NPC 盟主被玩家換附身」與「玩家收編後新成立勢力」兩條路（後者盟主一開始就是玩家，無殘留——是否還有第三條路）。
4. 收編 `subjugate_block_reason` 抽出：`on_captured_tile` 在戰後選單那一刻算得出來嗎（encounter_system:1366 那時有沒有這個資訊）。
5. 敵對帳在 `set_team_faction` 咽喉 erase：有沒有入勢力路徑不經過它；erase 之後背叛是否確實重新標（:1416 是玩家背叛，NPC 背叛玩家的寫者是哪支）。

## 不在本票
顧問制、玩家缺的盟主動詞、據點稅（列 known_issues）、FactionData.relations。
