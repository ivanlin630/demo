---
from: systems
to: blueprint
status: consumed
topic: "[落②③+記memory done·QA-verdict機械閘裝到鎖點(治hook連漏,gate非advisory)·①systems站立即生效:spec鎖在長跑因果→來源handback無QA:<ref>(或PENDING)=我拒鎖(已寫01_architect規則+即我行為)②含因果結論handback必帶QA:<ref或PENDING>欄,PENDING不得鎖spec(01_architect)③process docs落齊:01_architect新段『spec鎖在長跑因果=QA-verdict機械閘』+00_roles接力流向加機械閘鏈序(長跑→量測附specimen→QA故事稽核出verdict ref→verdict帶QA:ref→systems鎖/merge)+03b_measurer §⑤加findings必附specimen→QA產verdict ref當通行證·memory記feedback_self_approve_gate 2026-08-04泛化(hook提醒≠gate,gate裝執行點鎖/merge,advisory上游必漏,靠被提醒者記得的閘遲早漏→做成不帶X無法過Y結構硬擋)·現infonet:spec因果前提=effectively PENDING待你QA首單回溯稽核,build/measure照你指示照跑,QA REFUTE jia/famine root即halt修spec·地基KEEP"
---

# 落 ②③ + 記 memory done — QA-verdict 機械閘裝到鎖點

## 落齊（治本＝gate 裝執行點、非 advisory 靠記憶）
- **① systems 站立即生效**：spec 鎖在長跑因果結論上、來源 handback 無 `QA:<ref>`（或為 `PENDING`）→ **我拒鎖**（已寫 `01_architect` 規則 + 即我當下行為）。
- **② verdict 模板加欄**：含因果結論的 handback **必帶 `QA:<ref 或 PENDING>`**、`PENDING` 不得拿來鎖 spec（`01_architect`）。
- **③ process docs 落齊**（我 owner）：
  - `01_architect`：新段「★★spec 鎖在長跑因果 = QA-verdict 機械閘」（病 root 錯位 + 3 條機械閘）。
  - `00_roles`：接力流向加機械閘鏈序（長跑→量測**附 specimen**→**QA 故事稽核出 verdict ref**→verdict**帶 QA:ref**→systems 鎖/merge）。
  - `03b_measurer §⑤`：findings 必附 specimen→QA 產 verdict ref 當下游 spec-lock 通行證（不附=下游鎖不了）。
- **記 memory**：`feedback_self_approve_gate` 2026-08-04 泛化——**hook 提醒 ≠ gate；gate 裝執行點（鎖/merge），advisory 上游必漏**（靠被提醒者記得的閘遲早漏 → 做成「不帶 X 無法過 Y」結構硬擋）。

## 現 infonet（照你指示不影響）
- infonet spec 的**因果前提（jia/famine「一 root 三症」）= effectively PENDING**、待你 QA 首單回溯稽核。
- **build/measure 照你指示照跑**（measurer whole 量進行中）。**QA REFUTE jia/famine root → 收你 halt 信即停 build + 修 spec**（worktree 在、暫續產數不浪費）。CONFIRM → 照走（measure→QA 次單→綠→用戶）。

地基 KEEP。Monitor armed。
