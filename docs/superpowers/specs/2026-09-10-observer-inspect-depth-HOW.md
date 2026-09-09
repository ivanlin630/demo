# HOW spec：觀察者 inspect 深度（★缺的比想像少 —— 五個欄位）

owner: systems ｜ 2026-09-10 ｜ **player_reachable: yes（觀察者）** ｜ 用戶原話：
「我需要的世界沙盒 UI 要全面資訊，例如選據點就能知道誰是擁有者、誰是居民團；
選隊伍能看到詳細目標而不是單純一個 tag」

## §1 ★現況（我 grep 過，而它比「面板沒掏給他」樂觀得多）

```
observer_query_api.query_team(:79) 已回傳：
   id label leader_name pop pop_named pop_anon pop_minor pop_captive
   food food_flow coin resources_nonzero rung rung_cap archetype plan_phase
   faction_id faction ★task ★task_reason ★solo_intent readiness fatigue wounded tile_pos tags is_beast
observer_query_api.query_outpost(:142) 已回傳：
   tile_pos outpost_type outpost_level ★owner_team_id ★owner_team ★owner_faction
   ★facilities_nonzero garrison ★resources_nonzero resource_cap
```
⇒ ★★**擁有者、設施＋等級、公庫存量、task、intent 都【已經有了】。**

## §2 ★★★所以缺的是【五個具名欄位】，不是「一個面板」

```
據點：✘ 居民團清單（誰住在這）
隊伍：✘ 目標【對象】（task 有了，target 沒有）
      ✘ goal 細節（用戶原話：「詳細目標而不是單純一個 tag」）
      ✘ morale
      ✘ 威脅感（threat_react / threat_id）
```
★**而它們的資料【全部在 state 裡】**（觀察者＝god-view，不受感知鐵律限制）
⇒ ★★這是**掏欄位**，不是**造機制**。

★**逐欄的來源（★實作前請各自 grep 確認，我只查到這一層）**：
```
居民團清單  ⇒ 對該 tile：`is_resident_static(state, t)` 為真的隊（★而它是【位置謂詞】——
              ★★★所以面板要印的是「【此刻】在這裡的居民團」,而不是「屬於這裡的居民團」,
              ★而那兩者不同,已記 known_issues「兩個位置謂詞」條）
目標對象    ⇒ `team.current_target` / task 對應的 target 欄（★實際欄名請查）
goal 細節   ⇒ decision 端的 goal/plan 結構（★★這一格【最可能長大】,見 §3）
morale      ⇒ team 的 morale 欄（★查實際欄名）
威脅感      ⇒ `DecisionContext` 的 `threat_react` / `threat_id`
              ★★★而 ctx 是【每 tick 重算的】,不是存在 team 上 ⇒ 面板要嘛重算一次,
                 要嘛讀最近一次的快照 —— ★這是本票【唯一的設計選擇】,見 §3
```

## §3 ★★兩個會讓本票長大的地方（★先劃線）

```
①「goal 細節」要多細？
   ⇒ ★本票的界線：印【引擎自己存的那個 goal 結構】,★★不新增「解釋文字」層
   ⇒ ★★★若印出來人看不懂,那是【票②（人話層）】的事,不是本票
②「威脅感」要不要重算 ctx？
   ⇒ ★重算＝觀察一次就跑一次 gather（★★而 gather 有副作用嗎？——【實作前必查】,
     ★★★今天已經有「觀測改變被觀測物」的血證）
   ⇒ ★建議：先查有沒有現成的快照；沒有的話【印「未快照」而不是重算】,
     並把「要不要存快照」留給下一張票。
```

## §4 驗收（blueprint 指定＝用戶當場用）

```
①點據點見：擁有者／★居民團清單／設施＋等級／公庫存量
②點隊伍見：當前 task ＋ intent ＋★目標對象 ＋★goal 細節／資源／pop／★morale／★威脅感
③★★而【五個新欄位】各要一格自檢：斷言【值真的來自 state】而不是空字串／預設值
   ★成對對照：構造一支【有目標】與一支【沒目標】的隊 ⇒ 面板上【看得出差別】
④★★★零機制改動：本票只讀不寫 ⇒ determinism fingerprint【不變】
   ★而若「威脅感」選了【重算 ctx】那條路 ⇒ ★★fp 可能會變（gather 若有副作用）
     ⇒ 那時【停下來回報】,不要自己吞掉
```

★誠實限：
1. 本票**只掏欄位**，不做排版、不做人話層（那是票②）。
2. ★**「居民團清單」印的是【此刻在這裡的】** —— 而那可能是 0-1
   （已坐實：`known_issues`「這個世界沒有村莊那一層」）
   ⇒ ★★**若用戶看到空清單，那不是面板壞了，是世界如此** —— **這句要印在面板上或寫進交件信。**

---

★**附掛【順手改】格**：裸 print 帶因（`[SoloAI]` 行 ＋ 派工失敗行）
⇒ `docs/superpowers/specs/2026-09-10-bare-print-carry-cause-CELL.md`
（blueprint 2026-09-10 裁：低優先、不單獨開工、本票或另一票**誰先動誰帶走並刪該檔**。）

---

## ★★★追加（blueprint 裁定 2026-09-10）：資訊完整性 —— 盲格 117 / 119

**量測**（implementer C1 §5）：`decision_context.gd` 的 `var` 欄位 ＝ **119**；
`player_query_api` 公開動詞輸出的鍵集 ＝ 208 鍵；**同名對得上 ＝ 2**（`food_days` / `population`）
⇒ **盲格 117**。

★**誠實限（原作者自寫，systems 覆核＝對）**：這是**名字**比對不是語意比對
⇒ 同量換名＝偽陰、同名不同義＝偽陽。它回答「有沒有一個同名的東西端出來」，
**不回答「玩家看得懂那個值」**。

### 裁定（WHAT，blueprint）

```
①【全要】＝預設。用戶原話「UI 需有所有資訊，否則我會沮喪」本身就是裁定，不再問第二次。
②117 格逐格開，呈現【按語意分頁】：生存／經濟／威脅／社交／記憶。
③★豁免僅限【對玩家零語意的純中間 scaffolding】，
  ★★且【具名清單呈用戶簽】——★★★不呈＝不豁免（沉默不是豁免）。
④blueprint 會在 CLI 給用戶否決窗。
```

### HOW 的三件事（systems）

```
①★分頁歸類要有【單一真源】：不要在 UI 端手寫五份清單。
  形狀＝在欄位旁標語意頁籤（或一張 field→page 的表），★UI 讀表、表是唯一入口。
  ★★理由＝119 會長大（gather 每加一個欄位就多一格），
     ★★★而【手寫清單不會跟著長大】——它會靜默地漏掉新欄位，
        而漏掉的症狀正好是「玩家看不到」＝我們這張票要修的病本身。
②★★豁免清單是【一份要簽名的文件】，不是實作時順手的判斷
  ⇒ 產物＝一份 tsv/md，逐格寫【欄位名／為何對玩家零語意】，呈 blueprint 轉用戶。
  ★不得由 implementer 自行勾掉任何一格（他這次的克制是對的，維持）。
③★★★覆蓋率守衛（否則這票會 rot）：一支閘，母體＝decision_context 的 var 欄位，
  判準＝每一欄【剛好】出現在「已接出」或「已具名豁免」一份表裡。
  ⇒ 形狀完全比照 `failure-feedback-coverage.sh`（同一種病：缺席不得是靜默的）。
  ★成對對照必備：假欄位⇒具名紅／同時在兩表⇒紅／乾淨⇒綠。
```

### ★★★④ 追蹤的數字【不能是 117】（implementer 自警，收，2026-09-10）

原作者對他自己產的那個指標提出警告，而它是對的：

```
117 是【名字比對】的產物 ⇒ 若它變成被追蹤的數字，
★★★它會在【真的補完之前】就先降下去——【改個名字就降】。
```

⇒ **規矩**：本票**唯一算數的讀數是覆蓋率表**
（每個 `decision_context` 的 `var` 欄位**剛好**出現在「已接出」或「已具名豁免」一份表裡），
**不是 117 這個差集**。

```
★差集(名字比對)      ＝ 診斷用，告訴我們「大概有多大一塊沒接」——★會被改名污染
★★覆蓋率表(逐欄具名) ＝ 驗收用，每一欄有主詞、有歸屬 ——★★改名不會讓它變綠，
                        因為那一欄仍然要出現在兩張表其中之一
⇒ ★★★這是「用會被優化的代理指標」與「用本體」的差別，
   而**提出警告的人正是產出那個代理指標的人**——這個形狀我記名一次。
```
