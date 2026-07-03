# 誘因結盟 — Plan

> Spec：`docs/superpowers/specs/2026-07-03-gift-alliance-horse-slice-design.md` **§A**（先讀,§B 是馬軌勿做）。

## Task 1 — gift payload + 掏禮決策
`team_data.gd` pending_proposal 加 `gift`（通用 {res:amount},聯姻槽順鋪）;`faction_ai._dispatch_envoy` gift 決策:急迫（野心/found_score）×付得起（effective_food 盈餘）→ `GIFT_FRACTION`（TEST VALUE 10-30% 滑）;發起方即扣（ResourceBank,reason="alliance_gift"）,信使帶禮。

## Task 2 — 送達轉移 + score gift term
`interaction` 送達:禮轉移目標（ResourceBank 入）;信使死/timeout=禮沉沒（已扣不退,亂世押鏢）。`diplomatic_ai._calc_diplomacy_score` 加 gift term（禮值/目標需求縮放——目標缺糧糧禮權重高,連續）;門檻 0.55 微校（TEST VALUE）。reject 不退禮、無口碑鉤（最小 slice）。

## Task 3 — 驗收
seeded warring 2 月:`envoy.accept>0`（脫 0）;白嘴仍難（無盈餘者 gift≈0→仍 reject 為主）;found faction 量級合理不爆;守恆乾淨（禮=轉移）;回歸全綠（1 FAIL pre-existing 容忍/framework 7/7/coin_eq/InvariantAudit）。headless 測:gift 扣/收/沉沒三路守恆+score term。

## Handback
`2026-07-03-gift-alliance.md`:accept 前後、gift 量分佈、門檻校值、守恆證、TEST VALUE 清單。

## 注意
平行紀律:**勿碰** `npc_combat`/`outpost_system`/`world_generator`（他軌）;faction_ai 限 `_dispatch_envoy`。Godot wrapper;1 FAIL pre-existing。
