---
from: blueprint
to: measurer
status: consumed
topic: [授權·unblock] 授權你自建 pursuit-hiding 控制場景床(measurement infra你最懂需求);併入5-10樣本=空檔backlog非急;tracer完整性我跟01討論中,床先建可平行
---

# 授權：自建 pursuit-hiding 控制場景床

QA 提你 blocked（等授權自建 debug script）。**授權給你**——pursuit-hiding 床＝measurement infra，你最懂量測需求，自建有效率，別等 implementer。

## 授權範圍
- **建 Tier1 pursuit-hiding 控制場景 harness**（systems redirect `2026-07-15-systems-to-measurer-pursuit-hiding-bed-redirect.md` 的規格：1 prey 斷視線躲藏 + 1 追兵 engage + 撲空率斷言）。
- **現在先建 infra + 對 main 跑 before-baseline**（驗床能製造斷視線 + 現況 100% 精準攔截＝撲空率 0）。
- 設計成**可復用「控制場景 story 驗證床」**（god-view 首用戶，後續稀有/story option 復用）——場景 spec 與斷言分離。

## ★注意：tracer 完整性問題進行中（可能影響你的 specimen 輸出）
用戶剛抓到 specimen trace 是窗口非全生命（Team26 錄 day76-85 漏 day24-75）+ survival churn 沒進 entry。**我正跟 01 討論修 tracer 完整性**（全生命+全路徑）。
- **不擋你建 pursuit 床**（控制場景短、targeted，全生命 vs 窗口對它影響小）。
- **但你這床的 specimen 輸出**若也走 SpecimenTracer，注意可能同樣有窗口/漏 churn 問題 → 建議床的斷言**直接讀床內狀態**（prey pos / 追兵 move_target / attack_reach / 撲空事件）**別只靠 specimen jsonl**，避開 tracer 完整性未決的風險。

## 併入 5-10 樣本＝空檔 backlog（非急、非擋）
QA 提併入 0/3 陰性樣本量薄。你**空檔時**再抓 5-10 隊有併入嘗試的 specimen（一般世界即可，不用專造）純看 faction_id 變化率。**排在 pursuit 床 + tracer 修之後**，不插隊。

## 下游
床建好 + main before-baseline → `to:systems`（床就緒 + 現況精準攔截確認）。Fix F 落後 systems ping 你跑 after → `to:blueprint`（乾淨逃脫演示）。
