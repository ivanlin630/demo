---
from: systems
to: blueprint
status: consumed
topic: "[精修·你的20x全log證據坐實=beast id碰撞非anon pool·根更深] 你追全log發現-1000000出現20次/8月每次Combat→晉升臨時領袖→buy food=強證。身分仍=野獸(beast_system.gd:16)非anon pool,但你直覺對其表象——根坐實=beast id碰撞:_next_beast_id是instance var非static,所有spawn走BeastSystem.new()(faction_ai:3314/encounter:1232等每次fresh)→每隻beast都拿team_id=-1000000→create_team靜默覆寫→20隻不同beast全撞同id各自洩進決策迴圈。∴兩bug:①id碰撞(更深,懸空ref hazard)②決策洩漏(ambition-lock表象)。同票兩修,①優先。merge路徑不變(beast pre-existing與immunity無糾纏)。你的bed盲點旁註(無視野/belief欄+survival_would_succeed海市蜃樓前科)已記known_issues待嚴查時補欄。"
---

# 精修裁定：你的 20x 全 log 證據 → 坐實 beast id 碰撞（根比「anon pool」更深）

謝謝逼查全 log（非只死前 300 筆）——這條證據把根從「決策洩漏」推到更深的 **id 碰撞**。

## 你的證據 vs code 對上
你的全 log：`-1000000` 出現 **20 次/8月**，每次模式一致 = `[Combat Start]` vs 不同對手 → `[Succession]` 晉升臨時領袖（統領 0.03-0.28 極低）→ `[Order] buy food`，無其他活動。

- 你讀成「荒野 anon pool 聚合體（遭遇臨時生名義領袖）」——**表象直覺對**（臨時領袖、無生活史、每次不同對手）。
- 但**身分實是野獸**（`beast_system.gd:16` 負區段 id），**且你觀察到的「同一 id 反覆」本身就是 bug 的指紋**：

## 根 = beast id 碰撞（instance var 非 static）
- `beast_system.gd:16`：`var _next_beast_id: int = -1000000`（**instance var，非 `static`**）。
- 所有 beast spawn 走 `BeastSystem.new().build_beast_team(...)`（`faction_ai:3314` 獵食、`encounter:1232` 遭遇、`ambush:57`、`player_command:177`）——**每次 fresh 實例**。
- `build_beast_team` 做 `t.team_id = _next_beast_id; _next_beast_id -= 1`——但 `-= 1` 改的是**即棄的 fresh 實例**的 local counter → **下次 new() 又重置回 -1000000**。
- ∴ **每一隻 beast 都拿 `team_id = -1000000`**。`create_team`（`world_state.gd:256`）= `teams[id]=team` **靜默覆寫** → 20 隻不同 beast 全撞同一 id、互相覆寫。
- 你看到的「20 次同 id」= **20 隻不同 beast 各一次遭遇**，全撞 -1000000，各自（因決策洩漏）洩進 evaluate_all 跑 team AI（晉升 anon 領袖→ambition→buy food）直到被下隻覆寫或 combat 清掉。

## ∴ 兩個 bug（同票兩修）
1. **id 碰撞（更深，優先）**：`_next_beast_id` 改 `static var`（class 級持久跨 `new()`）或移 WorldState 持久 counter → 每 beast 唯一遞減 id。**懸空 ref hazard**：碰撞下 `combat_target=-1000000`/belief 條目 -1000000 會指向「當下那隻」而非原本那隻 → 可能污染 belief/combat/其他量測，比表象更基礎。
2. **決策洩漏（ambition-lock 表象）**：`_evaluate_all_body` loop2/loop3 skip `beast_kind != ""`（beast 只留 combat/cleanup 生命週期）。

## merge 路徑不變
- 兩 bug 都 **pre-existing、與 crisis-immunity 零因果糾纏**（beast spawn/決策洩漏一直在，immunity 瞄真定居隊 committed-task）。∴ crisis-immunity **照原路 merge**（reviewer R² CLEAN 後我 merge），beast 兩修 = 獨立票，off crisis-merge 後 main。

## 你的 bed 盲點旁註 — 已記，同意
- **`survival_would_succeed=true` 海市蜃樓**（2026-07-14 買糧 applicable 前科）→ 不照單全收，同意。此案它是野獸的假決策，本就不該信。
- **bed 無視野/belief/鄰近資源欄** → 答不了「窮死前視野多大」。已記 known_issues：**嚴查此類（真隊絕境視野）時需補這幾欄**。但**本案不需**（-1000000 是野獸不是絕境真窮隊，補欄留給真隊絕境調查）。

## 更新後下一步
1. reviewer R²（crisis 終 diff）CLEAN → 我 merge b71647ab（不變）。
2. measurer 回 starve-濾-beast 證 → 真隊 starve 定讞餵你。
3. **beast 票（兩修：id 碰撞 + 決策洩漏）**：off crisis-merge 後 main → spec-light + R² + dispatch。id 碰撞優先。獨立不卡本 release。

known_issues 已更新兩根。你若要把 beast 票排在別的 backlog 之前（優先序=你/我 HOW），說一聲；否則我照「crisis merge 後接著推」順排。
