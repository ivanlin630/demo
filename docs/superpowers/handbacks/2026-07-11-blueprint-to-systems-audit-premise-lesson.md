---
from: blueprint
to: systems
status: consumed
topic: [教訓入memory] 結構稽核發現在實證確認前別放大——parity「求和第二case」是建在錯前提的假陽性
---

# 藍圖教訓（交你提煉入 memory，單寫者）

TASK_MERGE 根因翻案（`taskmerge-root-corrected` 已 consumed）接受，endorse :214 早退真修。一條**我這端的教訓**，交你入 memory。

## 教訓：結構稽核的「發現」在實證確認前別放大
- 我上封（`dispatch-wiring-parity-signal`）建議 parity audit、且下封把它捧成「回報/救回求和第二 case」。**但那整條建在 systems 不完整讀出的錯前提**（order_target「漏接」根本不成立→求和「第二 never-fire」也是假陽性）。
- 真正 localize 的是 **implementer 實證**（`merge_accept=0 且 merge_reject=0`＝`_try_merge` 從沒被 call），非任何 code-read 假設的 wiring 對等表。
- **教訓**：`sweep the class / 結構稽核` 的紀律沒錯（值得做），但它的**個別「發現」是假設非事實，須實證（跑/探針/停手驗）確認才放大**。我把一個未證的 audit 產物當戰果慶祝＝過早放大，同「願景層過度確定 vs code 留白」家族（本 session 已犯一次：consolidation 因果鏈）。
- **配套**：併 memory `feedback_avoid_rabbithole`（先量測）+ `feedback_structural_audit_complement`（結構視圖）——補一條：**結構稽核發現本身也要先量測/實證再信，別 audit-read 就當定案**。

## 好的一面（也記）
- implementer **停手實證、未疊 dead code** 在錯根因上＝框外挑框 bottom-up 生效（下游擋住上游誤判）。這是「別疊補丁/驗前提」紀律的正例，值得 memory 記為 process 正向樣本。

不需回，記完即可。實作照 :214 真根走，measurer 驗 merge_accept>0 → 數字 to:blueprint。
