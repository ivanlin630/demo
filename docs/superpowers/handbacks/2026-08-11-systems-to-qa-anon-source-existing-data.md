---
from: systems
to: qa
status: consumed
topic: "[QA 讀既有數據定案 anon drain 真源(用戶指正:別重派量測、給 QA 讀既有 970-entry specimen+raw log)·背景:指標團 Team0 人手池(anon)day0-4 降 5→0 後 41 天不回補、下游 relief/care-scout/builder dispatch(綁 anon-specific 池 AnonTierSystem.total_pop、systems code-read 坐實)派不出·真源三度誤歸因(overflow-spinoff→被 measurer 自己 check_overflow tap 推翻:Team0 cap20/pop<6/首呼 tick240=從未 overflow)、get_stack caller tap 回空(caller=?:-1 沒抓到)·★但既有數據夠:raw trace 有 [Succession] Team4/5/6 從匿名晉升新領袖 P3002 log + specimen 970 entries(team4 tick180 起 pop=1 獨立覓食隊 leader_traits 異於 Team0)·★需 QA 讀既有數據定完整因果鏈(非重跑):①誰 spawn Team4/5/6(transfer_proportional from=Team0→4/5/6 各 1 anon 創新隊、event_system.gd:53-65 Succession 是給已存在 leaderless 隊晉升 leader≠創隊、故創建在別處、raw log 找 create/spawn Team4/5/6 前一步)②anon 池 41 天不回補真否(vs sharpened trace 說 2 隊 merge 回=named 回流、矛盾需 QA 核 raw log 到底 merge 回沒/回的 named 還 anon)③★用戶判準:此 anon 消耗=genuine 世界機制(anon 晉升獨立小隊/村壯大=合理弱勢)vs bug(無因/機械)——QA 中性報事實讓用戶判、別預設(池空≠bug 原則 feedback_resource_depletion_genuine_vs_blind)·★systems 認:我一直重派量測查真源=錯(用戶指正)、既有數據夠 QA 分析·序:QA 讀既有 specimen(docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.specimen.jsonl)+raw(同名-raw.txt/anontrace-caller-raw.txt/overflow-cap-trace-raw.txt)定案→回 systems→blueprint TG 推用戶·地基 KEEP"
---

# QA 讀既有數據定案 anon drain 真源（非重跑）

用戶指正：別重派量測、給 QA 讀既有 970-entry specimen + raw log。systems 認（我一直重派=錯）。

## 背景
指標團 Team0 anon 池 day0-4 降 5→0、41 天不回補 → 下游 relief/care-scout/builder dispatch（綁 **anon-specific** 池 `AnonTierSystem.total_pop`、systems code-read 坐實）派不出。真源三度誤歸因（overflow-spinoff 被 measurer check_overflow tap 推翻：Team0 cap20/pop<6/首呼 tick240=從未 overflow；get_stack caller tap 回空 `?:-1`）。

## ★既有數據夠（無需重跑）
- raw trace：`[Succession] Team4/5/6 從匿名晉升新領袖 P3002` log。
- specimen 970 entries：team4 tick180 起 pop=1 獨立覓食隊、leader_traits 異於 Team0。

## ★需 QA 讀既有數據定完整因果鏈
1. **誰 spawn Team4/5/6**（`transfer_proportional from=Team0→4/5/6` 各 1 anon 創新隊；`event_system.gd:53-65` Succession=給已存在 leaderless 隊晉升 leader **≠ 創隊**、故創建在別處、raw log 找 create/spawn Team4/5/6 前一步）。
2. **anon 池 41 天不回補真否**（vs sharpened trace 說 2 隊 merge 回=named 回流、矛盾需 QA 核 raw 到底 merge 回沒/回 named 還 anon）。
3. ★**用戶判準**：此 anon 消耗 = genuine 世界機制（anon 晉升獨立小隊/村壯大=合理弱勢）vs bug（無因/機械）——QA **中性報事實讓用戶判**、別預設（池空≠bug、[[feedback_resource_depletion_genuine_vs_blind]]）。

## 序
QA 讀既有 specimen（`docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.specimen.jsonl`）+ raw（同名-raw.txt / anontrace-caller-raw.txt / overflow-cap-trace-raw.txt）定案 → 回 systems → blueprint TG 推用戶。地基 KEEP。
