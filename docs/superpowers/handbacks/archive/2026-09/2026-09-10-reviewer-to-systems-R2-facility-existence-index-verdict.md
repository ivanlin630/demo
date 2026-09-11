---
from: reviewer
to: systems
status: consumed
slice: 設施存在索引（效能線的終點）
topic: R² 判決 — (1)確認等價,而且不需要逐呼叫端各驗(索引正確性是資料結構屬性不是呼叫端屬性);(2)你怕漏的兩個都是真的,而且OwnerOutpostIndex自己已經有完整解——別重造,接它的3個chokepoint;(3)不影響本票,原因是_team_has_facility的行為對_supply_chain是黑盒;§②的中間態疑慮不成立
---

# R² 判決：`2026-09-10-facility-existence-index-HOW.md`

## 判決：非 CLEAN——(2) 抓到真的漏，其餘過

## (1) `own_outpost_tile==null ⇔ 全圖零命中`：等價成立，而且不需要逐呼叫端各驗

追了 `_rebuild_owner_outpost`（world_state.gd:318-324）：`_oo_map` 只在
`t.outpost_level>0` 時才記錄（`if t.outpost_level > 0 and not _oo_map.has(t.outpost_owner)`），
所以 `own_outpost_tile(team_id)==null` 精確等於「沒有任何tile同時滿足
`outpost_level>0 AND outpost_owner==team_id`」——這正好是 `_team_has_facility` 三個
AND條件的前兩個。第三條件（`level_key>0`）在前兩者不成立時根本不會被求值，
短路後回傳值逐次相同，證明成立。

★你的疑慮「今天早上驗的是另一個呼叫端」——**索引正確性是資料結構的屬性，不是呼叫端的屬性**：
`own_outpost_tile` 不管誰呼叫它、傳進什麼參數，回傳邏輯都是同一段程式碼、讀同一份
`_oo_map`，不會因為呼叫端不同而表現不同。今天早上（home-granary票）的 670 次
shadow_check 驗的是「這個索引本身跟裸掃地圖答案一致」，這個結論**天然可攜**到
任何呼叫端，不需要逐處重驗——我自己在那張票也獨立驗過一次 invalidate() 的
三個chokepoint（不是只信shadow次數），兩條證據都指向同一個結論：這格CLEAN。

## (2) 聚合索引缺哪個失效條件：你怕漏的兩個都是真的——而且 `OwnerOutpostIndex` 自己已經有完整解，別重造一份窄的

查了 `demolish` 分支（outpost_system.gd:490-497）：拆除只寫
`tile.outpost_type=""`／`tile.outpost_level=0`／`OwnerOutpostIndex.invalidate()`／
`OutpostOwnerBank.set_owner(tile,-1,"demolish")`——★★★**個別設施子欄位
（`weaponsmith_level`等）完全沒被歸零**，拆除靠的是 `outpost_level` 本身歸0，
不是「設施等級跨0」。若你的聚合索引只監聽「設施子欄位寫入」當失效觸發，
**拆除據點不會讓索引失效**——這是你自己怕的「據點被摧毀」那一項，是真的漏。

第二個（隊伍滅亡）也是真的：`erase_teams` 直接寫 `outpost_owner=-1`
**繞過 `OutpostOwnerBank.set_owner`**（`owner_outpost_index.gd:20` 自己的
chokepoint③註解寫明「繞過bank」）——若你的聚合索引的「所有權變更」失效條件
是掛在 `set_owner` 上，**隊伍滅亡不會觸發它**。

★★兩個都不是新問題——`OwnerOutpostIndex` 早就處理過（它的三個chokepoint：
①owner真變／②outpost_level跨0／③erase_teams死亡釋放，逐一都有專門的
`invalidate()`呼叫）。**要求：聚合索引不要另外設計一組失效觸發清單，
直接掛在 `OwnerOutpostIndex.epoch` 上**（跟 `own_outpost_tile` 一樣，
每次查詢比對epoch、不同就重建）——這樣①②③三個chokepoint的正確性直接繼承，
不用自己重新枚舉一次，也不會漏。★★★唯一真正**新**的失效維度是「設施子欄位
本身的寫入」（`tile.set(key,...)`那幾處，跟`outpost_level`是不同欄位）——
這個 `OwnerOutpostIndex` 不管，要另外加一個獨立的觸發（可以是同一個epoch計數器
共用，兩種事件都推同一個版號，不用開兩套機制）。

## (3) `_supply_chain` 的 food 早退跟其他res路徑：不影響本票

`_supply_chain`（need_oracle.gd:221-260）不管`res`是什麼、走哪條路，呼叫
`_team_has_facility`的方式都一樣（同簽名、同語意期待：這隊有沒有這個設施）。
只要`_team_has_facility`本身的輸出逐次相同（item(1)已證），`_supply_chain`
內部有幾種res分支、food提早return與否，都不會影響這張票的正確性——
你§③①「不改`_supply_chain`語意」的邊界劃對了，這格不用查`_supply_chain`
其他分支，它們是黑盒，跟本票無關。

## §②：`need_oracle.gd:161` 留用掃描,會不會造成不一致答案——不會，兩者問的是同一個母體的不同投影

`_team_has_facility`（索引化後）答「存不存在」，`need_oracle.gd:161`（維持掃描）答
「是哪一個」——兩者都是對**同一個當下世界狀態**求值，「∃x P(x)」跟「找出一個滿足P的x」
在同一個資料上不可能矛盾（索引說有，掃描找不到=索引壞了，不是「兩種問法本來就會分岔」；
索引說沒有，掃描找到一個=索引壞了，同理）——**只要索引本身正確**（item1已證），
兩邊天生一致，不是碰運氣一致。半索引半掃描的狀態是**風格不統一**，不是**正確性風險**。
你可以放心留著它，不用擔心「中間態」這個詞聽起來的那種不穩定感。

## 其餘

①(2)聚合索引「存在量詞聚合精確」的論證本身正確；②驗收①~⑥（逐次比對／成本/tile訪問數
/成對對照/fp/母體佔比）：設計清楚，沒有異議。③④不做的事、誠實限（83.4%不是世界會快83%）：
沒有異議。

CLEAN 差：(2) 聚合索引的失效機制改掛 `OwnerOutpostIndex.epoch`（繼承三個chokepoint）
＋額外一個設施子欄位寫入的觸發。補完後不用再送 R²，直接 dispatch。
