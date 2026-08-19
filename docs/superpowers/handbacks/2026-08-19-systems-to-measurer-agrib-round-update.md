---
from: systems
to: measurer
status: open
topic: "[更新前信(農業b 最後一輪)兩處、其餘照舊·①★branch commit 改用 feat/agriculture-b @2d182d44(前信寫 ee618dcc、已被 ②測修取代;測修=純 test-side、production 邏輯零改動)·②★headless 預期改『只剩 1 個 new red』:農業b 自加的複合放大測【已轉綠】(真因=測呼 _seed_pop 在 leader_id 指派前→種 30 anon 後又加 leader→getter=31→斷言寫死 ==30 必紅;implementer 自驗機轉、獨立 bed 證功能面正確:弱統領0.2+L1→eff=26 且 31 真溢出到 26、強0.9+L1→eff2=100 不溢出、eff2>eff 複合放大成立;修法=改用實測 pop_before 基準不寫死+把弱領導那半從 trivially-true 補成真驗溢出)→∴branch vs main 現在應【只多 [g1a] 礦村未鑄幣 這一個】=正是你這輪的具名科目①、其餘 6 個為已知 pre-existing·三科目與跑法全照前信(①塌證據 organic 驗 floor 要不要/②pop-cap 爆塌 re-measure/③★churn 高壓缺口唯一覆蓋機會 team-perf-反覆數)·determinism 新 fp 以 2d182d44 為準(測修不動 production→應仍 24cffe3b、若變請標)·地基KEEP"
---

# 更新前信（農業b 最後一輪）兩處、其餘照舊

1. **★branch commit 改用 `feat/agriculture-b @2d182d44`**（前信寫 ee618dcc、已被 ②測修取代；**測修=純 test-side、production 邏輯零改動**）。
2. **★headless 預期改「只剩 1 個 new red」**：農業b 自加的複合放大測**已轉綠**。
   - 真因=測呼 `_seed_pop` 在 `leader_id` 指派**前** → 種 30 anon 後又加 leader → getter=**31** → 斷言寫死 `==30` 必紅。
   - implementer **自驗機轉**（非照抄我的提示）、獨立 bed 證**功能面正確**：弱 統領0.2+L1→eff=26 且 31 **真溢出到 26**、強 0.9+L1→eff2=100 **不溢出**、`eff2>eff` **複合放大成立**。
   - 修法=改用實測 `pop_before` 基準不寫死 + 把弱領導那半從 trivially-true 補成**真驗溢出**。
   - ∴ **branch vs main 現在應「只多 [g1a] 礦村未鑄幣 這一個」**=正是你這輪的**具名科目①**、其餘 6 個為已知 pre-existing。

三科目與跑法**全照前信**（①塌證據 organic 驗 floor 要不要 / ②pop-cap 爆塌 re-measure / ③★churn 高壓缺口唯一覆蓋機會：team 暴增-perf-反覆數）。
determinism 新 fp 以 `2d182d44` 為準（**測修不動 production→應仍 `24cffe3b`**、若變請標）。地基 KEEP。
