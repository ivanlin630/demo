---
from: measurer
to: qa
status: consumed
topic: "[GATE-A 故事·認自家食物源·返家接上但殘留在外] branch 7a2e22b0 vs baseline 0bf1fed9。★故事:productive-home 隊被驅動返家(返家補給 chosen 1248-2638)、forest 仍正確離家買糧(買糧 560-640 未誤鎖)、無新餓死、total end-絕境降 25→15/31→26。★但 GATE-A bucket 仍主體(58-73%,絕對 14→11/19→15)=返家 chosen 高卻 end-snapshot 仍在外(選了返家但到不了家/又離/被 override)。settled 薄利 harvest 20-35% 未觸及。你判故事:『返家決策接上、假飢餓部分消、但返家未真閉(到不了家補飽)』coherent?forest 未誤鎖對否?判完 to:systems(判 merge-partial vs 追殘留)。⚠本輪 aggregate(decision.opt+分類),無逐 tick jsonl specimen(需可補跑)。"
measured_at_head: "branch 7a2e22b0 vs baseline 0bf1fed9"
---

# GATE-A 認自家食物源 故事 → QA

GATE-A 工單 measure。branch 7a2e22b0、seed42/1337 3mo。full verdict → systems（`2026-07-23-measurer-to-systems-gateA-verdict`）。

## 故事：返家決策接上、假飢餓部分消、但返家未真閉
- ✓ **productive-home 隊被驅動返家**：`返家補給` chosen **1248（seed42）/ 2638（seed1337）**——機制強 fire，產糧家隊確實想返家採飽。
- ✓ **forest 仍正確離家買糧**：`買糧` chosen 560-640——forest/non-productive 隊**未被 GATE-A 全鎖**（能離家貿易買糧）。
- ✓ **無新餓死**（starve 1）、**total end-絕境降**（seed42 25→15 -40%、seed1337 31→26 -16%）。
- ✓ farming 建 0→8-11、non-food 0→2-4（specialize 微起色）。

## ★但：GATE-A 仍是殘留主體（返家未真閉）
- end-state 絕境分類 **GATE-A 仍 58-73%**（絕對 baseline 14/19 → branch 11/15，只 -3/-4）。
- ★**返家補給 chosen 很高（1248-2638）卻 GATE-A 殘留** = 隊**選了返家但 end-snapshot 仍在外**——疑：返家途中未到家 / 返家後又離 / 被 combat/faction 令 override 再離。**「決定返家」接上了，「真回到家並補飽」未閉**。
- settled-on-productive 20-35% 仍餓（薄利 harvest，collect≈burn，蹲家也慢餓——另議）。

## 你判什麼 → 判完 to:systems
1. 「返家決策接上（返家補給 chosen 高）、假飢餓部分消（total -16~-40%）、但返家未真閉（GATE-A 殘留 58-73%，返家 chosen 卻到不了家）」——**故事 coherent 嗎**？
2. **forest 未誤鎖**（買糧仍 560-640 fire）——你認同 GATE-A 沒錯鎖該離家的 forest 隊否？
3. GATE-A「洩壓進度但未全閉」——算**增量**否？殘留（返家到不了家 + settled 薄利）留後續刀 coherent 否？

## ⚠ 本輪範圍
aggregate（decision.opt chosen + end-state 分類 + funnel/facility/doom），**無逐 tick jsonl specimen**（此輪抓 before/after 聚合對照為主）。若你要逐隊 motive→action→outcome（哪隊選返家、到沒到家、為何殘留）可補跑 SpecimenTracer。

## 溯源
raw：`docs/measurements/2026-07-23-gateA-{1337,42}.txt`。baseline 重用 `nooutpost-*`（0bf1fed9 code-同）。無 production 探針改、branch clean、determinism a6b736fb。
