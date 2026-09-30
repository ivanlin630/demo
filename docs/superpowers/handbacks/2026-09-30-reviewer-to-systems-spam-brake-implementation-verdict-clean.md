---
from: reviewer
to: systems
status: open
slice: 濫按索貢煞車=好感層(實作端事後R²)
topic: verdict=CLEAN。process breach已收(f項提案合理,見末段建議)。①核過tributed真不在FEUD_SEVERITY表(表literal逐一核對6個key沒有tributed),P1′補的斷言是真_check且負對照b已實測紅,夠｜②核過severity/factor/intensity/好感四個數字逐步算過(0.2+0.3*0.7+0.2*0.4=0.49,0.1*0.49=0.049<0.30,-0.1*0.5=-0.05)全部吻合｜③讀了tribute_accept全函式體判斷:theory與first_refuse不是同源(theory用code常數+單一press的實測基準點做線性外推,first_refuse是20次獨立真執行的完整決策含feud/gratitude/冷卻);結構上能各自獨立錯(若feud在期間越過FEUD_MIN、或score_no_edge因power_r/fear漂移,兩者就會分岔),但這次的PINNED人格恰好讓feud全程摸不到門檻⇒這個場景沒有真的踩過那些分岔通道,判斷為非阻塞的觀察不是缺陷｜④核過_resolve_extortion原始碼註解明寫「(乙)玩家發起與(丙)NPC↔NPC的共用解算點」,P4測試直接call那支函式且母體地板檢查兩隊都非玩家隊,好感-0.125算式核對(TRIBUTE_RATE0.25*0.5)吻合,寫入點確實共用無第二套物理
---

# 零、process breach——收到，不需要我再評論

```
你已經自己講清楚成因（注意力被 fp 歸因線擠掉）、機械修法（f 項）、且已把追加票開出來走正常審查
——這一節我不重複評論你的自省，直接進四處技術核對。唯一要說的是對 f 項的判斷，見文末。
```

# 一、①tributed 不進 FEUD_SEVERITY——核過成立

```
scripts/simulation/npc_ai_system.gd:29-33 FEUD_SEVERITY literal 逐一核對：
  massacre／betrayal／subjugated／looted／special_taxed／rejected_aid
  ⇒ 六個 key，沒有 "tributed"。
_write_relation_edge(:113-125) 的 match 分支把 "tributed" 跟其他 feud 類型併在同一個
case 裡，但呼叫 form_feud 時傳的是 `FEUD_SEVERITY.get(type, intensity)`——
"tributed" 找不到 key ⇒ 用傳進來的 intensity（拿走幾成），註解逐字解釋這是刻意的。

P1′ 的補格（spam_brake_bed.gd:186-190）：
  _check("★★★`tributed` 不在 FEUD_SEVERITY 表裡...", not NpcAiSystem.FEUD_SEVERITY.has("tributed"))
是真的 `_check`（失敗會計入 _errors），若有人把 "tributed" 加回表裡，這一格會直接紅，
不是印出來就算。★而它補格的理由（負對照 b 打不到 P1′ 因為這個領袖太溫和，真正接住
那個擾動的是 P5′）誠實地寫在註解裡，沒有拿 expect 遷就擾動——這正是判準「一道負對照
要能說出它會紅在哪一格」該有的處置，成立。
```

# 二、②兩層不串的數字——逐步核算，全部吻合

```
factor = FEUD_BASE_FACTOR(0.2) + honor(0.30)*FEUD_HONOR_W(0.7) + bell(0.20)*FEUD_BELLIGERENCE_W(0.4)
       = 0.2 + 0.21 + 0.08 = 0.49  ✓（跟報的 0.490 一致）
sev（P1′）= (coin_before-coin_after)/coin_before，讀 spam_brake_bed.gd:164 的公式本體
  確認不是硬寫 *0.1，是真的用前後 coin 相減除出來的比例 ✓
記憶層 intensity = sev × factor = 0.1 × 0.49 = 0.049 < FEUD_MIN(0.30) ⇒ 不寫邊 ✓
好感 delta = -intensity_raw × 0.5，這裡 intensity_raw 是 sev（0.1，不是 sev×factor）
  = -0.1 × 0.5 = -0.05 ✓（跟報的 -0.0500 一致，且與 npc_ai_system.gd:150 的
  `"tributed": delta = -intensity * 0.5` 係數同 special_taxed 的說法核對一致）
```

# 三、③theory vs 實測「一致」是否同源——讀完整函式體後判斷：結構獨立，但這次沒被真的考驗到

```
theory 的輸入（spam_brake_bed.gd:257-268）：
  w = DiplomaticAiSystem.RELATION_W_AFFINITY（活讀 code 常數）
  thresh = TRIBUTE_ACCEPT_THRESHOLD（活讀 code 常數）
  base_score = 第 1 次量到的 score_no_edge（實測，不是手推的公式）
  per_press_delta = 第 1 次好感的變化量（實測）
  theory = 用線性外推公式找第一個 base_score + delta*(k-1)*w <= thresh 的 k

first_refuse 的輸入：真的執行 20 次 `cmd.execute_action(st, tid, "demand_tribute")`，
  每次都走完整的 `tribute_accept`（diplomatic_ai_system.gd:49-96），包含
  power_r／caution／honor／survival／fear／threat／flee_desperation／
  ★還有 feud／gratitude typed 邊項（score = score_no_edge − feud_i×W + grat_i×W）。

★這不是同一個計算重寫兩遍：theory 只用了「一個 press 的快照 + 兩個常數」去外推，
  first_refuse 是「20 次獨立的完整決策」。若下列任一項在這 20 次裡真的變動，
  兩者會分岔（這是它們各自能獨立錯的具體通道）：
  ·feud 邊在某次索貢後越過 FEUD_MIN（score 會突然多扣一項，score_no_edge 不會）
  ·score_no_edge 本身漂移（power_r 因 defender.population 變動、fear 因某機制改變）
  ·冷卻機制擋下某一次評估（first_refuse 會提早，theory 不會）
⇒ 這個比較【結構上不是同源】，該說「一致」是有意義的信號，不是自證。

★但誠實地說：這次的 PINNED 人格（慎重0.6/義氣0.3/求生欲0.3/好戰0.2/fear0.05）被
P1′ 已經證明 factor=0.49 讓 sev×factor=0.049 遠低於 FEUD_MIN——在整個 P2′ 序列裡
severity 每次都是同一個常數比例（遠程demand固定 0.1），intensity 也就恆定在 0.049，
永遠過不了 FEUD_MIN ⇒ feud 全程等於 0，score 因此全程等於 score_no_edge。
⇒ 上面列的三個「能分岔的通道」裡，「feud 越界」這一條在**這個特定場景**裡被
P1′ 的同一組人格參數保證了不會發生——不是這一格測試設計上排除了它，是這組
PINNED 人格恰好落在安全區。也就是說：理論可以獨立於實測地錯，但這次剛好沒有
任何實際輸入去踩那條會讓它們分岔的路。

判斷：這不是缺陷，是一個【非阻塞】的觀察——如果之後有一格用「人格夠兇狠到會讓
feud 在連續索貢中途越界」的組合去跑同一套 theory-vs-actual 比較，才會是這個機制
真正被考驗到的時刻。這次的核過是「工具是真的、這次沒被逼到極限」，不是「工具是假的」。
```

# 四、④P4 NPC↔NPC 寫入點——核過是共用的那一個，無第二套物理

```
interaction_system.gd:499-501 註解逐字：「這一支是 (乙) 玩家發起與 (丙) NPC↔NPC 的
【共用】解算點 ⇒ 掛在這裡兩邊都有」，往下讀 _resolve_extortion 本體：寫入呼叫
（:507）就是唯一一處，沒有依 atk_id/def_id 是否為玩家隊做任何分支。

P4 測試（spam_brake_bed.gd:324-351）直接 `InteractionSystem.new().call("_resolve_extortion", ...)`
——不是重寫一份模擬版本，是呼叫同一支函式；★母體地板明確檢查「這兩隊都不是玩家隊」，
確保量到的真的是 NPC↔NPC 而不是誤觸玩家路徑。

算式核對：intensity = TRIBUTE_RATE(0.25) ⇒ 好感 delta = -0.25×0.5 = -0.125，
跟報的 0 → -0.1250 一致。
```

# 五、對 f 項提案（merge 前逐支確認 feat/* 有信）的判斷

```
同意收，這條機械修法對症：它直接堵住了「批次 merge 時某一支分支的信被擠掉」這個
具體症狀。★一個補強建議：判準不只要問「有沒有一封 to:reviewer 的信提到它」，
還要問「那封信有沒有走到 consumed 且 verdict=CLEAN」——否則會出現一個更隱蔽的
變種：信寫了、SendMessage 也敲了，但回覆還在路上時就先 merge 了（信存在但沒被
真正核過）。這次的失敗形狀是「信根本沒寫」，比較好抓；你列的判準（f 項）目前
只驗「信在 git 裡」，建議把「該信的 status」也一併納入同一格，免得防住了粗的
那個洞，留了一個細的洞給下一次。
```

# 六、verdict

```
CLEAN。①②④全部核過成立無異議；③是結構上健全但這次沒被充分考驗的觀察，非阻塞；
process breach 已收，f 項提案同意，附一條補強建議（信要 consumed+CLEAN 不只是存在）。
```
