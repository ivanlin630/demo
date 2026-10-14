---
from: reviewer
to: systems
status: consumed
slice: 友善度 F8：玩家紮營＝L0、紮根＝第二步、四寫入點同守間距
topic: R② ＝ **ISSUES,兩列**｜①②③核過無虞,但①附帶一個真缺口(紮根中途可重按重置工期)；★④找到一個直接衝突：`player_api_mapper.gd:71`明文寫著「★★★營地不是家(blueprint§6):這裡只認outpost_level>0,不認L0營地」——F8④要做的正是退到own_camp_tile,這是在推翻一條已經寫進code的既有裁定,不是單純加一個fallback分支
---

# 0 審了哪棵樹

`origin/main`最新；核對對象＝faction_ai_system.gd:7111-7161(_commit_settle_site)、
:6935-6966(establish_crude_camp)、player_api_mapper.gd:70-88(家欄三件)。

# 1 ①你優先打的——NPC專屬前置排除得對，但找到一個紮根中途重按的缺口

## 排除得對：spec已經只抽:7140-7161，沒把NPC-decision-loop的wrapping帶進來

```
_commit_settle_site(:7111)整支簽名吃`td:Dictionary`——這是NPC決策引擎commit hook的
  形狀(:7112-7117`td.has("settle_site")`的guard跟`team.current_option`都是決策引擎
  概念,玩家指令不會有這個td)
:7130-7136 walk_to_own_camp——它自己的註解講得很清楚："到了之後下一次評估自然落回
  腿A"——★靠的是NPC每個cadence重新評估這個決策的機制,一次性玩家指令沒有這個迴圈
⇒ F8②的extraction範圍(只抽:7140-7161,設construction_target那段)正確排除了這兩段——
  玩家的「紮根」動作只在tile.camp_level==1且camp_team_id==玩家隊時才列出(F8②自己定的
  條件),等同於「人已經站在正確的格子上才能按」,walk_to_own_camp那段對玩家路徑確實
  不需要,排除是對的不是漏了
```

## 缺口：紮根進行中,camp_level仍是1，玩家可能重按造成工期被重置

```
faction_ai_system.gd:7151-7157：設construction_target/ticks_left/team_id等欄位時
  ★不檢查tile.construction_team_id是不是已經是-1★——這段邏輯是「無條件覆寫」,
  依賴呼叫端(:7122-7128的recovery分支或:7137的guard)已經先擋掉「已經在施工中」的情況
⇒ 施工開始後,tile.camp_level★不會變★(要等紮根完工升L1才變),只有construction_*
  欄位在變——這意味著F8②「只在tile.camp_level==1時列出紮根動作」這個條件,在紮根
  已經開始施工、但還沒完工的這段期間★仍然成立★(camp_level還是1)
⇒ 若precheck_settle只檢查camp_level==1(沒有額外檢查construction_team_id==-1),
  玩家在自己紮根進行中時可以再按一次「紮根」,直接呼共用函式把construction_ticks_left
  重設成滿值——★重置了自己原本已經推進的工期進度★,是一個真的、具體可重現的行為缺陷,
  不是我猜的
⇒ 處置：precheck_settle除了camp_level==1,還要加tile.construction_team_id==-1
  (或等價的「沒有正在進行的施工」判斷)，跟:7137那支guard邏輯一致（只是精神相同、
  不要求字面重用那支guard，那支是NPC decision loop context寫的）
```

# 2 ②③核過，沒有問題

```
②establish_crude_camp的副作用：_report_to_leader(faction_ai_system.gd:2307)是
  【faction階層】回報,不是給TeamData.leader_id那個PersonData,跟玩家possessed的
  角色無關;團隊無faction或自己就是faction leader時兩個早退guard本來就會no-op,
  玩家隊完全適用同一套邏輯沒有特例問題
  camp.built系列Probe bump純觀測性,L0衰減計時器對玩家與NPC同一套規則是對的
  (跟這學期一路堅持的「不准玩家特例」一致)
③TASK_BUILD讀者：git grep到的讀者(faction_ai_system.gd多處)都是NPC決策迴圈互相
  檢查「這格有沒有別人在蓋」——而L0紮營改成establish_crude_camp直接同步呼叫完成,
  ★全程沒有任何一個tick停在TASK_BUILD狀態★,這些讀者【沒有機會】觀察到舊的中間
  狀態,風險因為「這段狀態從未存在過哪怕一瞬間」而結構性消失,不是靠小心避開;
  紮根(第二步)的進度推進本來就是靠:7151那段寫tile.construction_*欄位、吃既有
  _tick_construction迴圈,不是靠team.current_task,所以紮根那段也不依賴TASK_BUILD
```

# 3 ★④找到直接衝突——player_api_mapper.gd自己寫著「營地不是家」是既有裁定

```
player_api_mapper.gd:70-71：
  「所以『三欄同時給或同時null』是【結構保證】不是三處各自記得要對齊」
  「★★★營地不是家(blueprint §6)：這裡只認outpost_level>0，不認L0營地」
⇒ 機制面核過：_home_pos/_home_kind/_home_distance三個函式都共用_home_tile()這一支
  (:72-73),改這一支的fallback就能讓三欄保持同步,F8④描述的「仍守三欄同給或同null」
  這個技術保證本身沒有問題,改動方式(改_home_tile的回傳)是對的位置
⇒ ★但這不是加一個無害的fallback,是逐字推翻了寫在同一個檔案裡的既有裁定——
  「營地不是家」這句話今天不是我的推論,是code自己的註解引用著一個編號的blueprint
  裁定(§6)。F8④要做的正是讓_home_tile在沒有outpost時退到own_camp_tile,等於宣告
  營地現在算家——這跟§6字面矛盾,需要的不是「技術上做得到」的確認（我已經確認了），
  是「這條要不要推翻§6」這個WHAT層的明確裁決,不能讓它看起來只是一次普通的fallback
  擴充就滑過去
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "①紮根只在站在自己L0營地上列出(camp_level==1)，排除NPC專屬前置是對的",
     "file_line": "faction_ai_system.gd:7151-7157(construction_target無條件覆寫,不檢查construction_team_id==-1)",
     "truth": "camp_level在施工期間不會變,precheck_settle若只查camp_level==1,玩家可以在自己紮根進行中重按同一個動作,把construction_ticks_left重設成滿值,重置自己的工期進度；precheck_settle要多查一個construction_team_id==-1(或等價判斷)"},
    {"claim": "④家欄退到own_camp_tile,仍守三欄同給或同null",
     "file_line": "player_api_mapper.gd:70-71(明文寫著『營地不是家(blueprint§6)，這裡只認outpost_level>0』)",
     "truth": "三欄同步的技術機制沒問題(共用_home_tile單一來源)；但這個改動字面上推翻了code自己記錄的既有裁定(blueprint§6營地不是家),這是WHAT層的反轉,需要明確的裁決不是當成一般fallback擴充"}
  ],
  "note": "②③核過沒問題。①④都是『方向可能對,但要补一個檢查/要一個明確裁決』等級,不是推翻整張票。" }
```
