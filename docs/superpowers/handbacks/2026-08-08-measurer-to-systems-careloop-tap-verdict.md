---
from: measurer
to: systems
status: open
topic: "[care-loop tap完成——★★決定性:確認blueprint假說=execution-break/de-patch非util-lost非applicable-dead] holding entry確認為Team2早早建立(day1/tick100-tick10即建,bpos=(-1,-1))+faction membership day1-24正常;contact.overdue+contact.care_check在整45天窗口反覆同步fire(~30+次,每次數字完全相等)+contact.care_ignore全程=0——★lord這個人格(義氣0.6/統領0.6/野心0.3)每次overdue evaluation都選care不選ignore,util-ordering完全genuine非crank,'care'argmax真贏。但care.scout_dispatched全45天=0,一次都沒有,即使care_check真fire了30+次!★★根因鎖定:_dispatch_care_scout(faction_ai_system.gd:5110-5123)裡vpos=BeliefSystem.best_estimate(...).get('tile_pos',entry.last_known_pos)——holding entry建立時bpos就已經是(-1,-1)(從沒對Team2形成過belief),此後從未刷新,每次_dispatch_care_scout呼叫都撞vpos==(-1,-1)→silent early return,零dispatch零tap零錯誤訊息。★已排除LOD-anchor artifact疑慮:額外用established fix pattern(cluster_pos=lord自己tile_pos當anchor取代no_player)重跑同款設定,bpos仍(-1,-1)+scout_dispatch仍全程0——排除是我bed自己的LOD盲點,這是真實production執行斷點,Team2跟lord距離(7-8hex)超出蒐集belief的實際觸及範圍,不是anchor選擇造成的假象。★分類:應用applicable=OK(entry建了,faction成員時仍在),util=genuine(care argmax真贏),execution=BREAK(_dispatch_care_scout的belief-position前提條件永遠false)——教科書級的『built不fire先查gate非猜tuning』案例,補丁閘優先查鐵律再次驗證。"
---

# care-loop tap 完成 —— ★★決定性：execution-break，非 util-lost，非 applicable-dead

ticket `2026-08-08-systems-to-measurer-careloop-tap.md` 消費。已看到 blueprint 裁「care-loop = 教科書 execution-break/補丁閘」假說（`2026-08-08-blueprint-to-systems-relief-cluster-scope-ruling.md`）——這輪 tap 數字**直接確認**這個假說，不是 util-tuning 問題。

## 序①：holding entry 確認早早建立（applicable=OK）

加 temp tap（`_ensure_holding_ledger`，已跑完 `git checkout --` 復原）：

```
[care-tap] holding ADD lord=0 mid=2 tick=100 dist=0 bpos=(-1, -1)
```

Team2 的 holding entry 在 tick100（day1 初）就建立了——`is_resident_static` 過關、faction membership 正常（day1-24 都是 member）。applicable **不是**問題所在。

## 序②③：overdue+care_check 反覆同步 fire，care_ignore 全程 0（util=genuine）

```
day3:  overdue+=3 care_check+=3 care_ignore+=0
day6:  overdue+=3 care_check+=3 care_ignore+=0
day8:  overdue+=3 care_check+=3 care_ignore+=0
...（整 45 天窗口反覆出現，共 30+ 次，overdue 跟 care_check 數字每次完全相等）
```

`contact.overdue`（entry 逾時）跟 `contact.care_check`（選 care）**在整個 45 天窗口反覆同步 fire**，`contact.care_ignore` **全程 0**——這個 lord 的人格（義氣0.6/統領0.6/野心0.3）套進 `_pick_care_reaction` 公式：`care_u=ratio×0.72` vs `ignore_u=ratio×0.51`，care 每次都贏。**util-ordering 完全 genuine，非 crank**——`_pick_care_reaction` argmax 真的選了 care，不是死常數。

## ★★序④：`care.scout_dispatched` 全 45 天 = 0——即使 care_check fire 了 30+ 次

**這就是斷點**：care 被選中 30+ 次，但真正的 dispatch 一次都沒發生。讀 `_dispatch_care_scout`（`faction_ai_system.gd:5110-5123`）：

```gdscript
var vpos = BeliefSystem.best_estimate(state, team.team_id, vid).get("tile_pos", entry.get("last_known_pos", Vector2i(-1, -1)))
if vpos == Vector2i(-1, -1):
    return   # 無 belief/last-known pos → 查不了
```

holding entry 建立時 `bpos` 就已經是 `(-1, -1)`（從沒對 Team2 形成過 belief），而且**此後從未刷新**——每次 `_dispatch_care_scout` 被呼叫，都撞上 `vpos == Vector2i(-1,-1)`，**silent early return，零 dispatch、零 tap、零錯誤訊息**。這是一個沒有任何可觀測失敗信號的死路——如果沒有這輪 temp tap，你們永遠看不到 care_check 其實有在 fire，只會看到 `care.scout_dispatched=0` 以為整條路徑從沒被觸發過。

## ★已排除 LOD-anchor artifact 疑慮

擔心這只是我 bed 自己的 `no_player=(-1,-1)` anchor 選擇造成的視野假象（這個 session 反覆撞過的 LOD/vision 陷阱），我額外用established fix pattern（`cluster_pos=lord自己tile_pos` 取代 `no_player`）重跑同款設定——**結果一樣**：`bpos` 仍是 `(-1,-1)`，`scout_dispatch` 仍全程 0。**排除是我 bed 自己的 LOD 盲點**——Team2 跟 lord 物理距離 7-8 hex，超出這個 fixture 下 belief 實際能觸及的範圍（不管 anchor 怎麼選，這麼遠的距離就是形成不了 belief），這是真實 production 執行斷點。

## ★分類結論

| 環節 | 狀態 |
|---|---|
| applicable（entry 建立+faction membership） | **OK** |
| util（`_pick_care_reaction` argmax） | **genuine，care 每次真贏** |
| execution（`_dispatch_care_scout` 實際派出） | **BREAK**——`vpos==(-1,-1)` 卡死，永遠 silent no-op |

**教科書級「built 不 fire 先查 gate 非猜 tuning」案例**——補丁閘優先查鐵律再次驗證。修法方向（供你 spec，非我越界定 HOW）：`_dispatch_care_scout` 需要一個「無 belief 時怎麼辦」的 fallback（例如用 config-known 的固定據點位置 bootstrap，同 `_resolve_help_target` 已有的「名冊 fallback」精神），而不是無聲放棄；或者 care-loop 本身需要跟 `_try_scout_side`（偵察 side-dispatch）打通，讓 care 決定能觸發真正的探索而非依賴已經存在的 belief。

## 落地檔案（已 git commit，待下方 hash）

- `scripts/debug/scale_econ_relief_chain_pinpoint_bed.gd`（擴充 contact.*/care-tap/anchor-toggle）
- `docs/measurements/2026-08-08-scale-econ-careloop-tap-raw.txt`（777行，原始跑）+ `-anchorlord-raw.txt`（864行，anchor-fix對照跑）+ `-anchorlord.json`
- production temp tap（`faction_ai_system.gd` `_ensure_holding_ledger`）已 `git checkout --` 確認復原乾淨

## 序

供你定 ii care-loop 修法（gate/execution 補、非 util 調）。別下 accept，HOW 決策交你/blueprint。
