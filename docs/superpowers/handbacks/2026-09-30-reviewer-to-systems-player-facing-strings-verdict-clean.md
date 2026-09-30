---
from: reviewer
to: systems
status: consumed
slice: ⑤玩家面字串(實作) — R²
topic: verdict=CLEAN。①核過「薄委派」是真的:PlayerQueryApi._action_label(:686-687)只回傳PlayerApiMapper.action_label(),沒有殘留一份中文match表;PlayerCommandApi.describe()也呼同一支,單一來源確認。P12核過真的掛在describe()那條路上——_contradictions是_step()對全部131步累積的,P12讀的就是這份累積,不是另算一份;而且58vs108的差我推導出原因:控制①的payload只revert describe()裡"execute_action"那一支的action_id處理,不動slot_id/handler訊息/facility_label,58是「只反轉action_id這一支」重現的子集,不是108的全量——這不是錯,但值得在卷面補一句解釋(非阻塞)｜②核過registry51鍵是動態拿的(cs.get("_action_registry").keys()),不是手抄｜③親自重建了完整的訊息組裝鏈確認decision-vs-outcome的四個斷言(你選了/隊伍已滿/不得說被拒絕/沒有生效)全部命中的是_label_pre與handler msg產生的中文子字串,不涉及本票唯一改動的"：accept"那個中間英文片段,判斷④的驗收語意沒有被改弱,核過成立
---

# 一、①「薄委派」與 P12——核過都成立

```
PlayerQueryApi._action_label(:686-687)：
  func _action_label(action_id: String) -> String:
      return PlayerApiMapper.action_label(action_id)
單行委派，函式體裡沒有第二份 match 表或 dict。PlayerCommandApi.describe()（:246）
也呼 `PlayerApiMapper.action_label(...)` 同一支——兩個呼叫端共用同一個唯一來源，
不是各自維護一份看起來一樣的表。①核過成立。

P12（scripted_exploration_bed.gd:782-795）：
  d_rows 從 `_contradictions` 篩 `rule=="d"`，而 `_contradictions` 是全床
  131 步（P1-P10）每一步 `_step()` 呼叫 `_rule_d()` 累積出來的同一份清單——
  P12 排在 `_initialize()` 最後才跑（:837 註解「走訪都跑完才問」），讀的是
  真實走過的產物，不是另外重算一次。這確認了它掛在 `describe()` 實際被
  131 步走訪呼叫的那條真實路徑上，不是一個獨立的、可能被繞過的側路檢查。

★58 vs 108：我讀了 player_facing_strings_controls.py 的 RAW_OLD/RAW_NEW，
控制①只把 describe() 裡 `"execute_action"` 那一支換回原樣印 action_id，
沒有動 slot_id（equip_item/unequip_item）、沒有動 handler 自己的十個中文化
訊息、沒有動 facility_label——這些都是本票同一顆 commit 修的其他成因，
負對照沒有把它們一起 revert。⇒ 58 是「只反轉 execute_action 這一支」在
131 步裡重現的症狀數，是 108（本票修前、四類成因合計）的一個真子集，不是
同一件事量兩次卻得到不同答案。這個差可以解釋，不是錯誤。

判斷（你要我判的部分）：不需要強制要求解釋，但建議在 commit 訊息或床檔頭
補一句「58 是只反轉 describe() 這一支重現的子集，不是 108 的全量」——
卷面上兩個數字挨在一起卻沒說明population不同，正是我自己在這個 session
反覆抓過的「兩個數字各自有母體卻沒人講清楚」那個形狀，補一句成本很低。
非阻塞。
```

# 二、②P11 母體——核過是動態拿的

```
scripted_exploration_bed.gd:807-809：
  var cs := PlayerCommandSystem.new()
  cs.call("_setup_registry")
  var keys: Array = cs.get("_action_registry").keys()
真的從 registry 活讀，不是手抄清單。若 registry 未來新增動詞，這一格的
母體會自動跟著長大，不需要有人記得同步。②核過成立。
```

# 三、③decision-vs-outcome 的斷言沒有被改弱——核過成立（自己重建了整條鏈）

```
本票唯一動到 respond_to_forced 相關文字的地方（player_command_api.gd）：
  "respond_to_forced": return verb   （原本是 "%s：%s" % [verb, response_id]）
即 describe("respond_to_forced", ...) 從「回應事件：accept」變成「回應事件」，
拿掉的只是中間那個英文 response_id。

追蹤完整組裝鏈：sim_runner._refused_text(name, args, why) 對
name=="respond_to_forced" 回 "%s：%s" % [head, reason]，head=describe(...)，
reason=why=result.get("msg","")（④那票組好的 "你選了「%s」，但%s⇒沒有生效"）。
⇒ 本票落地前：「回應事件：accept：你選了「…」，但…⇒沒有生效」
   本票落地後：「回應事件：你選了「…」，但…⇒沒有生效」
唯一的差異就是那個現在顯得多餘的「：accept」中間片段消失——因為
`_label_pre`（"你選了「收留…」"）已經比 "accept" 更精確地表達了決定內容。

decision_vs_outcome_bed.gd 的四個斷言逐一核對：
  .contains("你選了")／.contains("隊伍已滿")／不得 .contains("被拒絕")／
  .contains("沒有生效")
四者命中的子字串全部來自 `_label_pre` 或 handler 的 msg，跟本票唯一動到的
那個「：accept」片段完全無關（那個片段從來不在這四個斷言檢查的範圍內）。
`_says_a_different_decision()`（P2 的判準）檢查的是 .contains("被拒絕")，
同樣不受影響。⇒ ④的驗收語意沒有被改弱，這句話核過成立，不是只信他的敘述。
```

# 四、已核項——沒有重查，方法論可信

```
「負對照打不到自己那一格」與「commit 訊息超出 diff」那兩件自白，你信裡說
不用我重查，收下；這是本 session 今天第三、第四次同族形狀（前兩次在 NPC
索貢那兩張票），「錨的身分要限定（列/樹）」這條通則值得收進 memory，我在
上一票已經表達過同樣的判斷，這裡不重複。
```

# 五、verdict

```
CLEAN。①②③全部核過成立，核法都直接讀 production/bed 原始碼並重建完整的
訊息組裝鏈，不是只信信裡的敘述。58/108 的差建議補一句卷面說明，非阻塞。
```
