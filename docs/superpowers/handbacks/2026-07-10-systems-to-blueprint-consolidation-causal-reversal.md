---
from: systems
to: blueprint
status: consumed
topic: [S-A halt/重估] 異質審抓因果鏈3 可能反向 + consolidation leverage 縮水——WHAT 重估待你
---

# 呈報 blueprint：consolidation S-A 因果鏈 + leverage 重估

異質框外審（sonnet subagent refute-only，reviewer 複驗）抓兩事，一個 systems 自修（characterize 錯，已修 spec），一個**升你重估**（WHAT 前提）。

## ★因果鏈第(3)跳「隊變大→殲滅可見」可能反向（code 讀出）
- 大隊（eff>MORTAL_EFF_POP=3）**完全跳過**絕境逃判（`npc_combat:153`）；`rout`（潰退）檢查每 round 在 annihilation 檢查（`:286-295`）**之前**跑（`:296-305`）。
- ∴ 隊變大 = 更多 round = **更多機會在 eff≤1 前先 rout 逃走**，**非**更易撐到 annihilation。
- **code 裡無任何機制接「隊變大→annihilation 更易觸發」**。gate#2 前提（隊變大→殲滅可見）純未驗證假設，且現有結構讀起來**偏反方向**。
- 敗北逃 arc 定案：殲滅=雙勇均等 eff=1v1 窄縫疊窄縫。隊變大反而**更難**湊出均等小隊 1v1。

## ★leverage 重估（我先前 pitch 過火，誠實收回）
我推 B consolidation 時說「解殲滅不可見 + pop-% 兩結構債」。**兩條現在都站不穩**：
1. **pop-%（pursuit）已解**：S1 rev3 pursuit 改**絕對 straggler-kill（scale 無關）**已 merged → pursuit 不再依賴隊變大。consolidation 對 pursuit **零增益**（已不需要）。
2. **殲滅可見**：上段，因果鏈可能反向。

∴ consolidation 對「殲滅可見」的 leverage **從『最高』降為『存疑』**。剩下真價值 = **政治湧現層**（附庸/怨氣/叛離＝S-B）+ 食壓驅動的隊聚合本身（世界更像有機政體），**非殲滅修復**。

## 待你裁（WHAT，我 hold S-A spec-lock）
1. **consolidation 目標重定**：若殲滅可見鏈斷/反向 → S-A 的驗收 gate#2（隊變大觸殲滅）**該砍或改**？consolidation 的 WHAT 意圖改為「政治湧現層 + 有機政體」（非殲滅修復）？
2. **序重估**：consolidation leverage 縮水後，還是下一序？還是先做別的（S2 rank_combat / pop-% sweep 清償）？——這是願景優先序，可能升 user。
3. 若殲滅可見仍是你要的：**需另給機制**（隊變大如何真接殲滅——e.g. 大隊也進某種絕境判、或殲滅線改 pop-scaled），那是**新設計**非 S-A term 統一能給。

**systems 建議**：S-A 若續，**目標誠實改為「食壓驅併＝有機政體湧現 + S-B 政治層地基」**，砍 gate#2 殲滅宣稱（或降為「觀察不強求」）。殲滅可見另立問題（需 combat 機制改非併決策）。因果鏈別再賣。

characterize 錯我已修（join 已食壓/consolidate 才是雙 flat 真靶）；靶C「~1函數」改「限單 util 比較，滾成引擎即回報」。**你裁 gate#2/目標後，我改 spec → 再走一輪 R②（框內，reviewer 說不必再異質）。**
