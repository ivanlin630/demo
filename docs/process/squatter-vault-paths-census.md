# 數路：一支隊站在【非自己、同勢力】的據點格上，對那格公庫的每一條讀寫路

owner: systems ｜ 2026-09-10 ｜ 觸發：用戶「55 跑進 17 家除了工作外有沒有偷拿公庫等」
方法：裸符號全庫掃 `public_storage`（production 87 處／15 檔）＋逐處看它上面有沒有 owner 檢查。

---

## ⓪ ★★★一句話結論

```
★**「白拿」沒有發生** —— 所有【拿】的路都有 owner 檢查（自己的才拿得到）。
★★而**有兩條路對同勢力【明文開放】**，且是**設計過的**（有註解、有 probe）。
★★★真正沒有檢查 owner 的只有一條，而它的方向是【反的】：
   **房客採集的東西，會存進【地主】的公庫** —— 房客白幫地主打工。
```

---

## ① 【拿】的路：★全部有 owner 檢查

| 路 | file:line | 檢查 | 房客 |
|---|---|---|---|
| 吃糧／有效糧 | `resource_system.gd:584-588 own_granary_tile` | 腳下 ＋ `outpost_owner == 自己` | ★**無權** |
| 返家補給 gate 讀家糧 | `decision_context.gd:1002` → `own_outpost_tile` | 自己擁有的據點 | ★**無權** |
| 建造撥款／升級 bootstrap（食物、料） | `faction_ai_system.gd:4686`／`:4714`／`:4792`／`:4820`／`:4923`／`:5160` | 每處都是 `outpost_owner == team_id` | ★**無權** |
| 倉庫巡視（取貨去賣） | `faction_ai_system.gd:4615` | `outpost_owner != team_id ⇒ return` | ★**無權** |
| 買馬 | `faction_ai_system.gd:765-767` | `outpost_owner != team_id ⇒ return` | ★**無權** |
| 金銀資產估值 | `faction_ai_system.gd:4461-4463` | `outpost_owner != tid ⇒ continue` | ★**無權** |
| 領主投資判斷讀料 | `faction_ai_system.gd:2751-2752` | `outpost_owner == team_id` 才算 | ★**無權** |

---

## ② ★★對同勢力【明文開放】的兩條（★設計過的，不是漏）

```
①**代工投料**：`manufacturing_system.gd:204-214 _team_works_tile`
     if tile.outpost_owner == team.team_id: return true
     ... return owner.faction_id == team.faction_id and team.faction_id != -1
   ★★而它自帶註解與 probe：「Task1 A 探針：**同 faction 代工放行**
     （治權隨旗後村民代 owner 生產＝收益鏈點火）」＋`Probe.bump("yield.works_tile_pass")`
   ⇒ ★★★**這是【刻意的】，而且它是有人量過的**（有 tap）。
   ⇒ 效果：房客可以**用地主公庫的原料**做工 —— 而產出也進地主公庫（`:239` 同一格）。
②**同勢力升級**：`outpost_system.gd:791-799 _faction_owns`
     自己 ／ 母隊 ／ **同 faction** ⇒ 皆算「擁有」
   ⇒ 用在 `_subteam_upgrade_level`（`:807`）等路 ⇒ 同勢力隊可以**替那座村升級**並花它的公庫。
```

★**所以用戶問的「白用」＝存在，而它的質地是【同族互助】不是【偷】** —— 這與用戶自己的判詞一致。

---

## ③ ★★★沒有 owner 檢查的那一條（★而它是反向的）

```gdscript
# resource_system.gd:413-418（採集入庫）
if res in PUBLIC_RESOURCES or res == "food":
    var dst_tile: HexTileData = state.world.tiles.get(_pos_to_tile_id(team.tile_pos))
    if dst_tile != null and dst_tile.outpost_level > 0:        # ★★★只看 level，不看 owner
        var _dep: float = TileBank.deposit(dst_tile, res, gain, "harvest_intake_vault")
```

```
⇒ ★房客在地主的村格上採集 ⇒ **收成直接進【地主】的公庫**，房客自己拿不到
  （★★而 §① 已經證明：房客【讀不到】那個公庫）。
⇒ ★★★所以這條的後果不是「偷」，是 **房客做白工**：
   它把東西放進一個【它自己永遠拿不回來】的池子。
⇒ 而註解自己的說明是「food 進糧倉 ＝ 等義『自己存自己村庫』（採集者即 owner→自存村庫）」
  ★**那句話的前提是【採集者就是 owner】** —— 而房客這個情形正好打破那個前提。
```

---

## ④ 其他問到的：稅／救濟／anon 池

```
★**稅**：`resource_system` 的一般稅走 `gained` split ⇒ 而 food 走上面那條【不入 gained】
  ⇒ ★★房客採的糧**既不進自己私產、也不走稅**，直接進地主倉 ⇒ 稅制對它不適用。
★**救濟／anon 池**：本卷未查（`public_storage` 掃不到它們）⇒ **標【未查】，不假裝答完**。
```

---

## ⑤ 誠實限

```
①★本卷是【讀 code】不是【跑世界】：「有這條路」不等於「它真的常常發生」
  ⇒ ★★③那條要有真實頻率，得看 `harvest_intake_vault` 這個 reason 的 tap 分佈（未跑）。
②★★★本卷只掃 `public_storage`：**設施加成／勞力池**是另一組欄位（`farming_level`／anon 池）
  ⇒ 用戶問的「用不用 17 的設施加成」**部分**在 §②① 回答了（代工投料放行），
    而【產能加成怎麼算】要另掃 —— **標未查**。
```
