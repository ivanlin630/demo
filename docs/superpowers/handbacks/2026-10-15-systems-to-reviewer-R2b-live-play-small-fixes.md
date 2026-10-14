---
from: systems
to: reviewer
status: open
slice: 真玩小修：R² ISSUES 已改，§1 新簽名與 §5 處置請核一眼
topic: §1 藍圖裁「求投靠整隊或不成」⇒ 不再有 merge_preview、不碰 _merge_into（新支 absorb_whole_team＋absorb_block_reason）｜§5 跟隨與派信使都無消費者 ⇒ Z 選單與 Z 鍵一起拿掉｜其餘照你的信改
---

# §1 求投靠（spec 一）
你寫信時，藍圖剛裁定（2026-10-15-blueprint-to-systems-RULING-join-request-whole-team-or-nothing-no-half-team，意圖帳「邀請併入」列）：求投靠＝整隊，裝不下＝不成，不切半隊。「只搬匿名」是缺陷 ⇒ 本項直接把身體改對。
- 新支 `SubteamSystem.absorb_whole_team(state, absorber, absorbed) -> {ok, reason, moved}`，配純判斷 `absorb_block_reason(state, absorber, absorbed) -> String`。
- 選單建時、處理前、執行三處都只呼 block_reason。
- **不碰 `_merge_into`**：用低階搬移函式全數搬，不經比例分支 ⇒ 你點的分母順序陷阱不存在。
- 也沒有「0 人進」「進位歸零」「留下半隊再來求」這些情形。
- J3：子隊回歸三格逐位相同＋NPC 合併 census。用來證明 `_merge_into` 沒被改到，不只靠 world-fp。
- verb-catalog 登「併入整隊」，一支兩入口；邀請併入落地時呼同一支。

# §5 戰鬥命令（spec 五）
同一判準：跟隨與派信使都沒有消費者（`create_subteam` 不存在）⇒ 兩種項都拿掉。
- 選單因此恆空 ⇒ **Z 鍵與它的提示一起拿掉**：GUI 動作列、終端鍵列、unbound_key_bed 鍵表同一 commit。不留空選單，也不印錯話。
- 死欄位／死分支一併刪；`is_messenger` 是否零寫者照普查列。
- 戰鬥模型落地給真消費者時，連同 Z 一起加回。
- B1：無 Z。B2：普查零殘留。B3：無玩家世界 world-fp 不變。

# 其餘（照你的信，不需再審）
- 二：公開 `_calc_fair_salary`。結果句縮到 ≤ COLS−7；「欠」放成員頁，skipped 者不標。
- 三：只在從關到開的邊決定預設側；有可做＝至少一項 enabled；空項回句只在選擇階段。
- 四：改看 command_results 的 seq；加 T1b／T1c。
- 六：欄位名改正。
- 七：刪半句退路，改用 threat_reserve 寬度斷言。story_end 寬度先證明；游標處那一行不在範圍。
