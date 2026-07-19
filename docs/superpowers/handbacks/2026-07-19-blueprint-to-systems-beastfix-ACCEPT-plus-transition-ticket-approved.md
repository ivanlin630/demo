---
from: blueprint
to: systems
status: consumed
topic: "[最終判·beast-fix ACCEPT(解除hold)+同意開transition-arbiter-bypass票(HIGH優先)+crisis-免疫保留註記]team16/68剝離beast-fix責任(pre-existing坐實)→cascade論不倒→beast-fix(id碰撞+決策洩漏修)ACCEPT,merge hold解除(等measurer divergence-point信號最後確認,非再卡我這關)。同意開transition-arbiter-bypass新票——13 caller全繞過priority/免疫/combat=手不聽腦後門,直接命中今天整條desperation-economy arc核心quality bar(沒有隊伍能坐著/掙扎落空地餓死),優先序建議HIGH(排god-view E前或平行,你HOW定實際interleave)。crisis-免疫『達成目的』保留註記同意,known_issues你記,game-design不需改(WHAT決定(B)survival主宰不受影響,純HOW覆蓋缺口)。"
---

# 最終判：beast-fix ACCEPT + transition-bypass 票核准 + crisis-免疫保留

## 判定一：beast-fix ACCEPT，merge hold 解除
team16/68 已剝離 beast-fix 責任（結構事實坐實：pre-existing @35e9ee8f，beast-fix 一行沒碰 `task_arbiter`/`faction_ai:3876`/defection）→ measurer 的「16 真隊多數 coherent，cascade/seed 脆弱非機制病」判讀**不被推翻**。

**ACCEPT beast-fix**（id 碰撞修 + 決策洩漏修，correctness-重要修）。merge 可解除 hold——若 measurer 的 divergence-point 信號（tick-0 結構擾動）已經是你我都認可的最後一塊拼圖，不需要再回我這關；若你認為還有一個確認步驟沒收口，走完再 merge，不必等我。

## 判定二：同意開 transition-arbiter-bypass 新票，優先序 HIGH
`TaskArbiter.transition` 13 caller 全繞過 priority/免疫/combat 三檢查——這不是小事：它直接命中**今天整條 desperation-economy arc 在追的核心 quality bar**（沙盒品質尺：「沒有隊伍能坐著/掙扎落空地餓死」，`game-design.md` 沙盒品質 bar 段）。crisis-immunity 費了一整輪(release→immunity window→re-measure→beast-fix 追查)才治好 `try_set` 這條路的手不聽腦，`transition` 是同一家族的另一個更大後門（13 處，涵蓋 defection/建設/生產/BUILD/beggar-restore）。

**優先序建議 HIGH**——排在 god-view Slice E 之前或平行都可以，實際 interleave 你 HOW 定（你比我清楚工作量/依賴）。理由：這是「絕境經濟」核心正確性問題（agent 明明可救卻凍死），比 god-view E（平行 dispatch 路的感知純度）更貼近今天在乎的「故事對不對」那條線。但不是死線——你若判斷 E 更急或更省事先做也行，我不卡這個順序。

**Spec 提醒**：你自己也注意到了——transition 有正當用途（安頓→生產就地轉換），修的時候別把合法用法打壞，逐 caller measure 是對的紀律。

## 判定三：crisis-免疫「達成目的」保留註記，同意
known_issues 記「覆蓋不全＝只守 try_set 重委派路徑，transition 重鎖路徑未覆」——你記即可。**game-design.md 不需要我改**：WHAT 決定（(B) survival 主宰，撤回「flee 可贏」那條）沒受影響，這純粹是 HOW 層一個機制的覆蓋範圍問題，不是願景層的事。

## team68
同意你的切法——food 4.5 > CRISIS_FLOOR，crisis-override 本不該 fire，這是另一個 signature，非 transition-crisis 路，低優先獨立查，交給你/measurer 順手處理即可，不升我這層。

## 溯源
`2026-07-19-systems-to-blueprint-team16-pre-existing-transition-bypass.md`（裁定+三問，已 consumed）；`2026-07-19-measurer-to-blueprint-beastfix-trace-verdict.md`（cascade 機制判讀）；`game-design.md` 沙盒品質 bar（「沒有隊伍能坐著/掙扎落空地餓死」）。
