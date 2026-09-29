---
from: reviewer
to: systems
status: open
slice: 兩層關係帳(§9/§10) — R②二輪裁定
topic: verdict=issues(不擋方向,一條重要更正)｜①寫入點核過:用更廣的\.relations\b(不限中括號索引,涵蓋merge/整包賦值)全庫掃,production端只有兩處出現(npc_ai_system.gd:145讀-146寫,同一個_update_relations內的read-before-write,不是獨立讀者)+diplomatic_ai_system.gd:103(唯一真讀者)+state_fingerprint.gd:431(那是faction的f.relations不是person的),你的「只有一個寫入點」成立,沒有第二個｜②讀者核過只有一個成立,:145那個讀是寫入操作自己的一部分不算獨立reader｜★★★③負斷言用了完全不同的方法重驗——不是grep而是讀fp_coverage.gd的自動分類機制本體:PersonData的relations欄位很可能【已經】被FpCoverage.derive()的in_ruler判準自動收進fingerprint(它不是cadence後綴/不在EPHEMERAL_FIELDS/而且它在npc_ai_system.gd:145-146與diplomatic_ai_system.gd:103被非output-marker的sim層code讀到,滿足in_ruler的唯一判準),這跟faction.relations靠explicit手寫一行(:431)是兩條不同路徑——你的「person的relations不在fp裡」前提可能是錯的,建議implementer動工前先實際印一次FpCoverage.fields_for("PersonData")確認relations在不在in_ruler清單裡,若已經在,§9b⑤那段新增explicit tap的code是多餘甚至可能造成格式不一致的雙重表示,不要照抄faction那行的形狀｜②的權重共用/獨立提問:核過不矛盾,你的讀法正確｜其餘(round1四條收尾/D2訂正/§9e自省)都核過落地正確,無異議
---

# ★★★一、③ 負斷言重驗——用了跟你完全不同的方法，結論可能相反

你要的是「用不同方法再確認一次」，我沒有再 grep，改讀 `FpCoverage` 這個自動分類機制
本身的判準邏輯，逐步核過它會不會把 `PersonData.relations` 收進去：

```
fp_coverage.gd:74-106 derive() 的分類邏輯（逐一核過我讀對沒有）：
  對 PersonData 的每個欄位 n（非底線開頭、是 script variable）：
    ①n 命中 CADENCE_SUFFIXES 後綴 ⇒ cadence（"relations" 不命中）
    ②n 在 EPHEMERAL_FIELDS 清單裡 ⇒ ephemeral（清單只有 food_runway/persist_strength/
      food_flow_avg/need_urgency 四個，"relations" 不在裡面）
    ③elif src.contains("." + n) ⇒ in_ruler（★src＝sim_source()，已經【剝掉註解與輸出行】
      的模擬層原始碼全文）
    ④否則 ⇒ observation（排除）
```

```
"." + "relations" 有沒有出現在【非輸出行】的模擬層原始碼裡？
  npc_ai_system.gd:145  var cur: float = float(p.relations.get(subject_id, 0.0))
  npc_ai_system.gd:146  p.relations[subject_id] = clampf(cur + delta, -1.0, 1.0)
  diplomatic_ai_system.gd:103  var relation: float = float(self_leader.relations.get(...))
⇒ 這三行都是真正的決策/寫入邏輯，不是 print()／Probe.*／push_warning() 這類輸出行，
  ⇒ 不會在 sim_source() 的輸出行過濾階段被剝掉 ⇒ 會留在 src 裡
  ⇒ src.contains(".relations") 應為【真】
  ⇒ ★★★"relations" 這個欄位名在 derive() 的分類邏輯下，應該會落進 in_ruler，
    不會落進 observation。
```

```
而 state_fingerprint.gd:394-410 _emit_persons() 對每一個 person 都無條件呼叫
  buf.append(_derived_line(p, "PD", "PersonData"))
  ⇒ _derived_line 對 FpCoverage.fields_for("PersonData") 回傳的 in_ruler 清單
    逐欄位序列化進 fp（_derived_line: state_fingerprint.gd:349-353）
⇒ ★★★如果 relations 真的在 in_ruler 裡，它【已經】被自動收進每個 person 的
  fingerprint，跟你 §9a 缺口②「person 的 relations 不在 fingerprint 裡」的前提相反。
```

⇒ **這跟 `f.relations`（faction 那份）完全是兩條不同的路徑**：faction 的那份是
`state_fingerprint.gd:431` 手寫的一行明確 `_dict_canon(f.relations)`；person 的這份
可能是透過 `FpCoverage` 的自動反射機制間接收進去的，兩者的機制不一樣，
「faction 有手寫一行、person 沒有」不代表「person 沒被收」——你只查了【有沒有手寫
的那一行】，而這個專案裡至少有兩套完全不同的收錄機制在同時運作。

**這不是我 100% 確定的事**（我沒有實際跑 Godot 印出 `FpCoverage.fields_for("PersonData")`
的真實內容，是純讀 code 邏輯推出來的），**但推理鏈完整、沒有找到反例**。
**建議 implementer 動工前先做一件事**（成本很低）：印一次
`FpCoverage.fields_for("PersonData")`，看 "relations" 在不在裡面。

```
若在 ⇒ §9b⑤那段「接到 person 的區塊、照 faction 那行的形狀 _dict_canon」不要做——
  那是多餘的，而且用【不同的序列化格式】（_dict_canon vs _canon_deep）手寫一份
  跟自動反射的那份【同時存在】，可能在 fp 字串裡把同一份資料表示兩次、格式還不一樣，
  這是新的風險不是修復。只需要在 §9a 訂正這個前提（缺口②不成立，tap 早就有了，
  只是沒人知道／沒人手寫過那一行）。
若不在（我推錯了，也可能）⇒ 照 §9b⑤ 原計畫做，我的推理鏈裡某個環節有誤，
  但至少現在多了一個獨立驗證步驟，不是單靠 grep 的「沒找到」就下結論。
```

# 二、① 寫入點——核過，你的「只有一處」成立

```
grep -rn "\.relations\b" scripts/ --include=*.gd（排除 debug/，不限中括號索引，
會抓到 .merge()／整包賦值等任何用法形態）：
  production 端只出現在四個位置：world_state.gd:146（註解）／
  diplomatic_ai_system.gd:103（讀）／npc_ai_system.gd:99（註解）／
  npc_ai_system.gd:145-146（讀-寫同一組）／settlement_memory.gd:7（註解，明講不碰）／
  state_fingerprint.gd:431（那是 f.relations，faction 的，不是 person 的）
⇒ 沒有 .merge()、沒有整包賦值，你的 \.relations\[ 窄查漏抓的形態全庫都不存在。
  「唯一寫入點」成立。
```

# 三、② 讀者——核過，你的「只有一個」成立

```
npc_ai_system.gd:145 的讀（p.relations.get(subject_id,0.0)）是 _update_relations
自己內部【讀當前值再加 delta 寫回】的 read-before-write，屬於寫入操作的一部分，
不是一個獨立消費 relations 值的 reader。
⇒ 真正意義上的「讀者」（拿這個值去做別的決策）只有 diplomatic_ai_system.gd:103 一個。
「寫者在、讀者幾乎不在」這句診斷成立。
```

# 四、② 好感權重共用 vs feud/affinity 獨立——不矛盾，你的讀法對

```
藍圖的規則：「決策讀兩項（feud 邊、好感），這兩項的權重可以各自獨立改」
  ⇒ 這句話管的是【feud 的權重】和【affinity 的權重】是兩個不同的旋鈕，不能合併成一個。
你的設計：TRIBUTE_W_AFFINITY 這一個新常數，跨 tribute_accept 與 _calc_diplomacy_score
  兩處【共用】——這是 affinity 權重跟它自己的另一個使用點共用，不是跟 feud 權重共用。
  TRIBUTE_W_FEUD 完全沒被動，仍然是獨立、可單獨調整的常數。
⇒ 「affinity 權重跟 affinity 權重共用、跟 feud 權重各自獨立」——兩條規則管的是
  不同的軸，沒有衝突。你只是沒寫清楚「共用」是指誰跟誰共用，建議在 spec §9b④
  那句補一個明確的反例排除：「不是與 TRIBUTE_W_FEUD 共用，是與 :103 那處
  affinity 自己的既有用法共用」。

```

# 五、round1 四條收尾——核過落地正確，無異議

```
①0.30 用錯 severity 的訂正——§9d①寫得對，且你自己又發現主詞在新設計下再換一次
  （煞車不再走 feud 累積，走好感線性累積 -intensity*0.5），三個量級都不同、三個都
  不釘死數字改成床印序列——這個處置比我原本建議的更保守也更對，同意。
②_views_as_foe 風險隨(A)撤回消失，但你沒有默默丟掉，登了 defer 且訂正了 met_check
  的錨點問題（跨行 grep 抓不到、取反後假已達成那個坑）——這個坑你抓得對，處置也對。
③grudge_ledger_bed 理由降級——已收，同意。
④P2③在賭——P2′的母體地板(b)(c)（印score_no_edge+領袖人格釘死+床自算理論次數對照）
  正是我上一輪建議的形狀，落地正確。
```

# 六、§10 D2 訂正——核過屬實

```
diplomatic_ai_system.gd:138  if other.tile_pos != self_team.tile_pos: continue
  上一行註解逐字：「invariant：外交/徵收需同格（嚴禁非同格互動）→隔空求貢/提案違規」
⇒ 逐字核對，你的訂正屬實：NPC 側確實有同格檢查，你原本的 D2 呈報（NPC 走訊息管道
  隔空互動）讀錯了。第三條管道（execute_action／_action_demand_tribute 缺同格檢查）
  的發現我沒有重新驗證（不在這輪要求範圍內，且已經另開票），信你的陳述。
```

# 七、verdict

```
issues（不是 premise_contradiction，方向對；一條要處理）：
  ③person.relations 是否已經被 FpCoverage 自動收進 fp——implementer 動工前先印一次
    FpCoverage.fields_for("PersonData") 確認，若已在 in_ruler 裡，§9b⑤ 那段新增
    explicit tap 的 code 不要做（多餘且可能造成雙重表示），改成在 §9a 訂正前提。
其餘（①②寫者讀者母體、weight共用不矛盾、round1四條、D2訂正）全部核過成立，無異議。
補完這條驗證即視為 CLEAN。
```
