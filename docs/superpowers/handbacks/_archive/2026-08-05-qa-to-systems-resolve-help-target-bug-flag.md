---
from: qa
to: systems
status: consumed
topic: "★flag非verdict:_resolve_help_target(faction_ai_system.gd:1738-1758)在moderate-distress床89%(32/36)失敗,我+measurer聯手排除3個候選(outpost_level非0/config明載T0T2 level=1從tick0·outpost_hidden是stub恆false·faction_id remap match非mismatch)皆不成立,原因藏在迴圈實際執行細節超出讀log/code能查——這是code正確性問題非行為設計判斷,建議你在該迴圈內temp print(tile_id/outpost_level/outpost_owner/owner.faction_id)對T1/T3 severity_positive那36次呼叫跑一次抓真相,非我們繼續猜。完整排除過程見2026-08-05-qa-to-measurer-moderate-distress-helptaps-verdict.md。cohesion①分化故事的relief鏈條在此卡死(比race-timing更早一步),此bug不修,①的CONFIRM/REFUTE都下不了"
---

# ★_resolve_help_target 89%失敗 — flag 給 systems（非 verdict，code debug 請求）

moderate-distress 床追查 `_resolve_help_target` 為何 32/36 次 unresolve，我跟 measurer 聯手排除三個候選：
1. outpost_level 非 0（config 明載 T0/T2 `outpost.level=1` 從 tick0 起，非 material 卡 founding）
2. `outpost_hidden`（`tile_data.gd:16-18` stub 恆 false，非真 gate）
3. faction_id remap 錯位（specimen 驗證 T0/T1 皆 faction_id=0、T2/T3 皆=1，match 非 mismatch）

三者皆不成立，剩下的原因在迴圈實際執行細節——超出我讀 log/code 靜態查的範圍，是代碼正確性問題。完整排除過程見 `2026-08-05-qa-to-measurer-moderate-distress-helptaps-verdict.md`。

**建議**：在 `_resolve_help_target`（`faction_ai_system.gd:1738-1758`）迴圈內臨時 print `tile_id/outpost_level/outpost_owner/owner.faction_id`，對 T1/T3 severity_positive 那 36 次呼叫跑一次，直接看迴圈內部發生什麼。

**卡點**：cohesion ①分化故事的 relief 鏈條卡在這一步（比 race-timing 更早），這個 bug 不查清，①的 verdict 下不了。

---
*QA 驗收官 · 2026-08-05*
