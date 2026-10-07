---
from: reviewer
to: systems
status: open
slice: 勒索煞車為什麼沒咬（XB 靜態核）
topic: R② 靜態核回覆｜★你優先打的兩處都核對正確；★還有第四處——而它不是另一個數字小的問題,是一個結構性的早退：拒絕路**完全不呼**`_resolve_extortion`,所以今天拒絕勒索【零寫入】,這正是藍圖新裁要修的那個洞,位置在兩條獨立的分岔(NPC同格掠奪＋玩家直勒索)都各有一份,不是一處｜readiness當基底：技術上成立(本來就是tribute_accept自己的threat輸入,有既有clamp,沒有新常數)
---

# 0 審了哪棵樹

`origin/main` ＝ `a0563839e`（信裡最新那顆，含藍圖XB①直修裁定）。

# 1 你讀的兩處——核對都對，而且第二處是精確值不是估計值

```
①coin_before>0閘：interaction_system.gd:491,504
  `coin_before := def.resources.get("coin",0)` → `if coin_before>0.0 and atk.leader_id!=-1:`
  才進write_memory那段——核對為真,coin_before==0時整段跳過,零寫入
②每次-0.019對門檦0.1：追完整條算式,★這不是『大概0.25』的估計,是精確代數恆等式——
  interaction_system.gd:493 `tribute = coin_before * TRIBUTE_RATE`（TRIBUTE_RATE=0.25）
  ⇒ :508傳進write_memory的intensity = gained.coin/coin_before 必然恆等於TRIBUTE_RATE=0.25
    （只要coin_before>0,這個除法結果不會是別的數,因為分子就是分母乘上同一個常數）
  npc_ai_system.gd:150 `"tributed": delta=-intensity*0.5` ⇒ 好感每次固定-0.125
  diplomatic_ai_system.gd:76 `score += affinity*RELATION_W_AFFINITY(0.15)` ⇒ score每次固定位移
    -0.125*0.15=-0.01875≈-0.019——跟你讀的數字逐位對上,而且是算出來的常數不是測出來的近似值
```

# 2 ★第四處——找到了，是結構性早退，不是第三個小數字

```
resolve_extortion_direct(interaction_system.gd:1480-1487,玩家為勒索方那段)：
  if not DiplomaticAiSystem.tribute_accept(...): return {...}   ← ★拒絕在這裡就return了
  var gained = _resolve_extortion(...)                          ← accept才會走到這裡
  ⇒ 拒絕時_resolve_extortion整支【沒有被呼叫】,write_memory當然也沒有——
    不是coin_before的問題,是這條路拒絕時根本沒進到那個函式裡
同一個形狀,NPC同格掠奪那段(interaction_system.gd:446-451)：
  if DiplomaticAiSystem.tribute_accept(...): _resolve_extortion(...)
  elif _should_attack(...): start_combat(...)
  else: ...noop...
  ⇒ 拒絕(tribute_accept回false)時走elif/else分支,一樣不呼_resolve_extortion
⇒ ★這正是藍圖新裁「每次勒索到達對方(接受或拒絕都算)就寫tributed」要修的那個洞,
  而它不是一處是兩處：玩家直勒索(:1480-1487)跟NPC同格掠奪(:446-451)是兩段獨立的
  if-accept-then-X分岔,各自都要補拒絕分支的寫入——「寫入點收成一處」指的應該是這兩段
  各自改呼同一支共用函式,不是全repo只剩一個呼叫點(呼叫點本來就該有兩個,各自的拒絕分支)
```

# 3 readiness當基底——技術上成立，附帶一個既有相鄰機制你們可能要順手看一眼

```
技術核對：readiness確實已經是tribute_accept自己的threat參數,兩個呼叫點都這樣傳：
  interaction_system.gd:446 `tribute_accept(state,b,a,a.readiness)`（NPC同格，勒索方readiness）
  :1482 `tribute_accept(state,to_t,from_t,from_t.readiness)`（玩家為勒索方，同樣傳自己的readiness）
  ⇒ 用它當「被威脅基底」沒有發明新概念,是重用同一個已經在决定accept/reject的輸入,
    clamp 0..1——readiness本身的值域要不要另外驗證我沒查,但兩個呼叫點傳法一致,技術上成立
附帶：demand_tribute(索貢)的拒絕路今天【已經有】一個不同的既有機制——
  diplomatic_ai_system.gd:222-230 response=="refuse"時寫的是"tribute_refused"(固定intensity 0.2)
  ＋雙方reputation各自-0.1/-0.05,不是"tributed"。§XB③要demand_tribute跟勒索走同一個秤,
  implementer動手前要先決定：demand_tribute被拒時改成也寫"tributed"(取代現有這段),還是
  兩個不同的既有機制並存——這是WHAT層的一句確認,不是我能代裁的,標出來讓你們順手問一句
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "靜態已核的兩處＋還有沒有第四處",
     "file_line": "interaction_system.gd:446-451(NPC同格掠奪的accept/reject分岔)；:1480-1487(玩家直勒索的accept/reject分岔)",
     "truth": "有第四處,是結構性的：兩條獨立的if-accept-then-X分岔在拒絕分支完全不呼_resolve_extortion,今天拒絕勒索是零寫入,不是coin的問題;『寫入點收成一處』落地時要記得這是兩段各自的分岔都要補,不是只改一處就夠"}
  ],
  "note": "你讀的兩處都對,第二處是精確代數恆等式不是估計。readiness基底技術上成立。demand_tribute的既有tribute_refused機制跟新裁的tributed要不要合流,標了一句給你們裁，不佔用這張票的判決。" }
```
