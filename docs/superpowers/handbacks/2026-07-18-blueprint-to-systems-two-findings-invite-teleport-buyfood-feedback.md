---
from: blueprint
to: systems
status: consumed
topic: "[2發現·同病『機制存在但套用不一致』] 用戶戳出兩個:①邀請安頓=隔空:_try_invite_nearby_exile 註解『視野內』但code跑team_discovered累積名單+無距離gate+瞬間accept→據點可邀地圖另端流亡團→橫跨地圖走去安頓(半路餓死=team19源頭之一)。修:改當前視野/近距 + 邀請走使者非瞬間(或至少距離gate)。②買糧缺失敗回饋:join有join_rejected/外交有reject_cooldown/乞討有annoyance,但買糧gate只checkhas_buyable_food快照、無『最近買失敗』歷史→聽說有糧就永遠重選(team14/27)。②真修=escalation(我裁,backstop)+買糧補失敗回饋(對稱join)。★大規律:①survival優先序②失敗回饋③邀請對象=全『機制存在但沒一致套用』=統一arc靶。"
---

# 2 發現：同一種病「機制存在但套用不一致」

用戶情境走查戳出兩個，grep 坐實：

## ① 邀請安頓 = 隔空（believability + god-view 味）
`_try_invite_nearby_exile`：註解「邀**視野內**流亡團」，**但 code 迭代 `state.team_discovered`（累積已發現名單）+ 迴圈內無距離檢查 + `handle_diplomacy_message` 瞬間 accept**。
- ∴ 據點可邀**很久前見過、現在已在地圖另一端**的流亡團，遠隊瞬間答應 → **橫跨整張地圖走去安頓**（半路餓死＝team19 的處境來源之一）。
- 註解「視野內」名不副實（用「曾發現」非「當前視野」）＝同 O(N²) 那個 team_discovered 累積 god-view 味。
- **修方向**：邀請對象改「當前視野/近距」（非累積名單）；邀請理想走**使者遞送**（非瞬間 action-at-a-distance），至少加距離 gate。believability：沒人隔著半個大陸瞬間招募+對方瞬間答應橫越送死。

## ② 買糧缺失敗回饋（不對稱）
決策**設計上有**失敗回饋，但只給部分 option：
- 投靠有 `join_rejected`+`_recently_rejected`；外交有 `diplomacy_reject_cooldown`；乞討有 `annoyance/recent_begs`。
- **買糧沒有**：gate=`餓+市集+錢+has_buyable_food`，`has_buyable_food` 只查「聽過某處賣糧」快照，**無「最近買失敗」歷史** → 聽說有糧就永遠重選、買不成也不學（team14/27 卡 33 天）。
- **② 真修 = 我裁的 escalation（backstop）+ 買糧補失敗回饋（對稱 join/外交）**：買不成→暫時降權/別再選→自然升級到搶/乞。**只做 escalation 不補回饋＝根還在**（買糧仍假 applicable）。合 [[feedback_symptom_vs_root_retry]]（X 結構性不成功→別死鑽）。

## ★大規律（三合一）
①survival 優先序（unified 對/solo 漏）②失敗回饋（join 有/買糧漏）③邀請對象（該當前視野/用了累積名單）——**全是「對的機制存在、對某些 case work，但沒一致套到所有 case」**＝散落/不一致套用＝**統一 arc 的靶（收單一源、一致套用）**。修這類別 whack-a-mole 補單 case，要問「這機制哪些 case 漏了、能不能一處套全」。

## 溯源
grep `_try_invite_nearby_exile`(team_discovered/無距離gate) / options.gd 買糧 gate(has_buyable_food 快照) / context join_rejected+reject_cooldown；用戶情境走查 2026-07-18；[[feedback_symptom_vs_root_retry]]；[[project_unification_matrix]]。
