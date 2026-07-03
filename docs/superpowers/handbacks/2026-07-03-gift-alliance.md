# Hand Back: 誘因結盟（gift alliance）

Spec §A `2026-07-03-gift-alliance-horse-slice-design.md`、Plan `2026-07-03-gift-alliance.md` 全 3 Task 完成。

## 實作摘要（改檔）

- `scripts/data/team_data.gd`：`pending_proposal` doc 補 `gift` 欄（通用 `{res: amount}`，本 slice 僅 food，聯姻/財槽未來直插）。純註解，無結構變。
- `scripts/simulation/faction_ai_system.gd`：
  - 加常數 `GIFT_FRACTION_MIN=0.10` / `GIFT_FRACTION_MAX=0.30`（TEST VALUE）。
  - `_dispatch_envoy`：`sent>0` 後算 gift＝急迫（leader 野心 lerp frac）×付得起（`effective_food − reserve` 盈餘，reserve＝pop×FOOD_PER_PERSON_PER_DAY×FOUND_FOOD_SURPLUS_DAYS）。`ResourceBank.remove(mother,"food",want,"alliance_gift")` 即扣（clamp 至 team.resources 實有→不透支；granary 糧不扣＝保守）。gift 存入 `pending_proposal.gift`。`ptype=="alliance"` 才掏。
- `scripts/simulation/diplomatic_ai_system.gd`：
  - 加常數 `ALLIANCE_ACCEPT_THRESHOLD=0.55`（原硬編碼 0.55 提出成常數，值未變，便於 seeded 微校）、`GIFT_NEED_FOOD_PER_POP=10.0`、`GIFT_TERM_MAX=0.4`。
  - `_calc_diplomacy_score` 加 optional `gift` 參數 + gift term：`gift_ratio=clamp(gift_food/(pop×10),0,1)`，`gift_term=gift_ratio×(0.4+0.6×resource_need)×0.4`（目標缺糧→resource_need 高→糧禮權重高＝雪中送炭，連續）。白嘴 gift={} → term=0 → score 不變。
  - `handle_diplomacy_message` 加 optional `gift` 參數轉傳；alliance 分支用 `ALLIANCE_ACCEPT_THRESHOLD`。
- `scripts/simulation/interaction_system.gd`：`_deliver_envoy_proposal` 讀 `mother.pending_proposal.gift` → 傳入 `handle_diplomacy_message`（禮抬 score）→ `ResourceBank.add(target,res,amt,"alliance_gift")` 轉移目標。accept/reject 皆轉（拒者白得＝亂世，reject 不退禮）。冗餘去重（line 396 pending 非空守衛）保證只轉一次。
- `scripts/debug/headless_test.gd`：加 `_test_gift_alliance()`（扣禮 escrow / 送達轉移=收 / 沉沒 三路守恆 + score term 加禮>白嘴 + 缺糧 term>飽足）。
- `scripts/debug/warring_harness.gd`：`PROBE_KEYS` 加 `envoy.gift_sent` / `envoy.gift_delivered`（純遙測）。

## 守恆模型（gift＝食物，非 coin，coin_eq 不動）

- 發起：`_dispatch_envoy` 從 mother.resources 扣 `paid`（escrow 為抽象數字存 pending.gift，不落任何隊 resources）。
- 送達：first-arriving envoy 轉 `paid` 入 target.resources；後到冗餘騎撲 pending 空 no-op（不重轉）。
- 沉沒：信使死/timeout → pending 清不退 → escrow 永消（食物非守恆量，無 audit 違規）。
- 冗餘多騎共用單一 escrow（不 per-envoy 放，避免乘倍破守恆）。

## 驗收證

- **headless 全綠**：`=== DONE ===`，0 SCRIPT ERROR，1 FAIL＝pre-existing「統領目標未加入正 goal」（與本改無關，plan 明示容忍）。`_test_gift_alliance` 印 `掏禮=1182.0 轉移=1182.0 accept OK（守恆:扣=收）` + `沉沒路 OK（f2 陣營扣 1182.0，a2 未收）`。
- **seeded warring 2 月**（seeds 1337/42；第 3 seed 被 harness wall-clock 截，非崩潰，exit 0）：
  - seed 1337：`envoy.accept=1`（**脫 0**，對照 spec baseline 全域 0/8）、reject=1、gift_sent=3 / gift_delivered=2（1 禮沉沒＝押鏢，守恆一致）、found_ally=3、factions=7 established=0（不爆）。
  - seed 42：accept=0 reject=2、gift_sent=2/delivered=2（白嘴/禮不足仍難＝符合「白嘴仍難」），established=1 factions=8（量級合理）。
- **守恆乾淨**：gift＝food 轉移（發起扣＝送達收 or 沉沒），coin_eq/InvariantAudit headless 無 FAIL。

## TEST VALUE 清單（正式平衡待調）

| 常數 | 值 | 檔 |
|---|---|---|
| GIFT_FRACTION_MIN / MAX | 0.10 / 0.30 | faction_ai |
| GIFT_NEED_FOOD_PER_POP | 10.0 | diplomatic_ai |
| GIFT_TERM_MAX | 0.4 | diplomatic_ai |
| ALLIANCE_ACCEPT_THRESHOLD | 0.55（值未變，僅提常數） | diplomatic_ai |

## 連動風險

- `diplomatic_ai_system.gd`：`_calc_diplomacy_score` / `handle_diplomacy_message` 加 optional `gift` 參數（default `{}`）→ 既有呼叫者（同格偶遇外交、headless test line 3425）不傳＝行為不變。gift term 只在 envoy delivery 路傳非空 gift。
- `interaction_system.gd`：gift 轉移只在 `_deliver_envoy_proposal`；同格 trade/其他外交路徑未動。
- `world_generator` / `npc_combat` / `outpost_system`：**未碰**（他軌紀律）。

## 待主 session 確認

- **門檻校值**：0.55 未動（gift term 足以推過）。若嫌 accept 太稀（seed 42 全 reject），可 seeded 微降門檻或升 GIFT_TERM_MAX。屬平衡旋鈕，非結構。
- **reject 白得無口碑鉤**（最小 slice，spec 明示不做）：拒者收禮無 reputation 代價。未來口碑鉤可讓「收禮拒盟」掉信任。
- **gift 僅 food**：結構通用 `{res:amount}` 已備，聯姻槽/coin 禮未接（未來）。
