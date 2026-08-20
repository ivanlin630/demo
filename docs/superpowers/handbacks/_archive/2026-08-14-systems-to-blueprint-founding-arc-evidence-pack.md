---
from: systems
to: blueprint
status: consumed
topic: "[★founding arc 完整證據包(六組 file:line 硬證、evidence-only)·用戶鬼城邏輯全坐實=結構缺口:死亡不釋放+兩動詞對無主營皆隱形+founding免費無viability→~300鬼城永久無法認領·A鬼城可見性:①occupy(_find_occupy_target:4987)掃 team_discovered 活團(:4992)+團須活[teams.get≠null :4994-4995]+站自家outpost[outpost_owner==tid :4998-4999]=掃活resident非掃outpost→鬼城無活resident結構隱形②settle(_convert_to_resident本身不gate、_tick_solo_settle gate):鬼城owner=死id≠-1→teams.get(死id)=null→非same-faction不convert+outpost_level>0→establish_crude_camp fail(要空地)→release空手=也隱形③無主營踢:occupy@4994-4995(死)+4998-4999(非自營)、settle@_tick_solo_settle(owner≠same-faction)+crude_camp(level≠0)·B死亡所有權:erase_teams(world_state:286-)body★零 tile.outpost_owner處置→死團owner留懸=死id(非-1);set_owner(-1)★只relocate_abandon(faction_ai:1935)自願棄、死亡不釋放→鬼城owner=死id(measurer dump ~300分布死id/-1/活確認)·C founding:establish_crude_camp(4688-)viability=★只terrain!=mountain、無pop/labor門檻(1人可蓋坐實)+cost=★免費(只outpost_level=1+food cap bump、無material/time/labor、即時糧2026-06-16已移除)=狂魔推手+選址純farmable geography·D反饋=★零(return true、無outcome-eval/belief/memory寫入=fire-and-forget、用戶零反饋坐實)·E①overflow_split=機械閾值(pop溢出→自動切流亡team idle prio0、非決策=碎裂機械源)②F1硬persona-gate(貪婪+野心≥1.1)★已修soft weight(:4019-4049連續無懸崖)③軍事/防禦選址=★grep零命中確認不存在·F margin:對零防守pop_est=0→own_armed≥0×0.1×1.3=0必過(用戶對)但鬼城從不被掃→target-scan(活resident-only)才是gate非margin·★∴founding arc設計地基=死亡釋放(erase清outpost_owner→-1)+宣稱動詞(occupy/settle認領-1/ghost營=撿現成)+founding cost/viability(免費spam根)+碎裂源控(overflow/defect)·序:measurer補B owner-dist+C④ 272 pop分布→你跟用戶收設計定案·地基KEEP"
---

# ★founding arc 完整證據包（六組 file:line 硬證、evidence-only 禁 fix）

**用戶鬼城邏輯全坐實 = 結構缺口：死亡不釋放 + 兩動詞對無主營皆隱形 + founding 免費無 viability → ~300 鬼城永久無法認領。**

## A 鬼城可見性
- **① occupy**（`_find_occupy_target` faction_ai:4987）：掃 `team_discovered` **活團**（:4992）+ 團須活（`teams.get≠null` :4994-4995）+ 站**自家 outpost**（`outpost_owner==tid` :4998-4999）= **掃活 resident 非掃 outpost** → 鬼城無活 resident → **結構隱形**。
- **② settle**（`_convert_to_resident` 本身不 gate；gate 在 `_tick_solo_settle`）：鬼城 owner=死 id≠-1 → `teams.get(死id)=null` → 非 same-faction 不 convert + `outpost_level>0` → `establish_crude_camp` fail（要空地）→ release 空手 = **也隱形**。
- **③ 無主營踢**：occupy @:4994-4995（死）+ :4998-4999（非自營）；settle @`_tick_solo_settle`（owner≠same-faction）+ crude_camp（level≠0）。

## B 死亡所有權
- `erase_teams`（world_state:286-）body **★零 tile.outpost_owner 處置** → 死團 owner **留懸=死 id**（非 -1）。
- `set_owner(-1)` **★只** `relocate_abandon`（faction_ai:1935）自願棄、**死亡不釋放**。
- → 鬼城 owner=死 id（**measurer dump ~300 分布 死id/-1/活 確認**）。

## C founding 決策
- `establish_crude_camp`（faction_ai:4688-）：viability=**★只 `terrain!=mountain`、無 pop/labor 門檻**（1 人可蓋坐實）；cost=**★免費**（只 `outpost_level=1`+food cap bump、無 material/time/labor、即時糧 2026-06-16 已移除）= **狂魔推手**；選址純 farmable geography。
- **272 次觸發 team pop 分布 = measurer**（幾成 pop1-3 碎片蓋的）。

## D 反饋迴路
- **★零**（`return true`、無 outcome-eval/belief/memory 寫入 = fire-and-forget、用戶「零反饋」坐實）。

## E 情境 2/3
- **① overflow_split** = **機械閾值**（pop 溢出→自動切 流亡 team idle prio0、非決策 = **碎裂機械源**）。
- **② F1** 硬 persona-gate（貪婪+野心≥1.1）**★已修 soft weight**（:4019-4049 連續無懸崖）。
- **③ 軍事/防禦選址** = **★grep 零命中確認不存在**（選址純 farmable geography）。

## F notweak margin
- 對零防守 pop_est=0 → `own_armed ≥ 0×0.1×1.3=0` **必過**（用戶邏輯對）；**但鬼城從不被掃** → **target-scan（活 resident-only）才是 gate、非 margin**。

## ★∴founding arc 設計地基（evidence 指向、禁 fix 提案）
- **死亡釋放**（erase 清 `outpost_owner`→-1）+ **宣稱動詞**（occupy/settle 認領 -1/ghost 營=撿現成）+ **founding cost/viability**（免費 spam 根）+ **碎裂源控**（overflow/defect）。

序：measurer 補 B owner-dist + C④ 272 pop 分布 → 你跟用戶收設計定案。地基 KEEP。
