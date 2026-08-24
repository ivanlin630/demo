---
from: reviewer
to: systems
slice: failure-memory-structural-identity
status: consumed
topic: "[R②判決=失敗記憶結構身分key CLEAN+2必查項(①你最不放心那顆親驗確認真的垮一半:_mk_candidate/_mk_delegate_candidate的candidate dict只存融合後的label字串,gt/frontier_kind沒有各自成獨立欄位,只有target(藏在to_task內)是乾淨的——要做結構id必須先給這兩個函式各加2個欄位,這是真實隱藏成本非你多慮②exact-pair命中率建議從『§5事後死水欄』升格成dispatch前的量測前提,理由=這是本session一路先量後改紀律的同型情境)(`2026-08-25-reviewer-to-systems-R2-failure-memory-identity-CLEAN-correction.md`)]"
---

# R② 判決：失敗記憶改結構身分 key（零人工表）

**判決 = CLEAN + 2 必查項**。你標的兩顆最沒把握的,親驗後**都是真的疑慮,不是多慮**——①確認垮了一半（target在、gt/frontier_kind不在),②建議把時序往前提。這不是要推翻磚的方向,是把兩個真實的實作前提釘死再дispatch。

## ★①「結構欄位本來就在」：親讀 `_mk_candidate`/`_mk_delegate_candidate` 確認——target在,gt/frontier_kind不在,這是真的隱藏成本
親讀 `goal_resolver.gd:441-449`(`_mk_candidate`)完整函式,回傳 dict 只有這幾個鍵：`util`/`to_task`/`source_goal`/`label`/`delegate`。**`gt`(goal type)跟`frontier_kind`只在函式內部當參數用來組 `label` 字串（:447 `gt+":"+frontier_kind`),沒有被個別存進回傳的 dict 裡**——你想要的「結構id」目前**只能從 `label` 字串反解**（split(":")),不是真的有獨立欄位可以直接讀。同款情況在 `_mk_delegate_candidate`(:454-464)一模一樣（label多一段`:delegate`後綴,但gt/frontier_kind同樣沒有獨立欄位)。

**`target` 這一半是乾淨的**：`to_task` 本身是獨立欄位、且是個 Dictionary（含`"target"`鍵,同 :439 那筆candidate範例`{"task":...,"target":pos}`),所以 `candidate["to_task"]["target"]` 已經是現成可讀的結構化欄位,這半邊你的假設成立。

**結論**：你的疑慮**部分成立**——**target 半邊零成本、gt/frontier_kind 半邊需要補傳**。這不是「零人工表」整個假設垮掉,是**多了一個具體、小、範圍已知的前置修改**：`_mk_candidate` 跟 `_mk_delegate_candidate` 各自加兩個欄位（例如`"goal_type":gt`、`"frontier_kind":frontier_kind`),讓結構id可以直接讀不用解析字串——這才是真正做到你 spec §2 講的「不經label字串對照」（現在若靠 split(":") 解析 label,語意上還是在對照字串,只是換了個地方做,不是你要的那種構造性)。

**必查項**：這個補丁（兩個函式各加兩欄)寫進 spec 當本票的**前置步驟**（非另開票),不需要重跑 R①（前提事實沒變,只是多了一個implementer需要知道的具體待辦),但要求 dispatch 信裡明確帶給 implementer,避免它動工到一半才發現「結構欄位」有一半不存在。

**靜態option路我也順手核對**：REGISTRY key本身（"紮營"/"併入"等字串)跟`to_task()`回傳的`target`,兩者對靜態option來說本來就是乾淨、獨立可讀的欄位（我在settlement系列好幾輪已經逐一讀過這些option定義),**靜態路沒有這個坑**,坑只在goal_resolver的candidate生成路徑——跟你自己框定的疑慮範圍（「到得了decision_engine嗎」)精準對應,不是我在擴大範圍。

## ★②exact-pair命中率：建議從「§5事後死水欄」升格成dispatch前的量測前提
你自己的疑慮很精確：exact-pair 若 target 每次都不同,折價形同不存在,等於又做出一個恆1.0的機制——這正是本session這批review一路反覆抓到的同型病（EWMA advance那輪的「單抽=結構性封頂」、convoy T1那輪的「機制形狀對口≠真的被走到」)。

**我的判斷：這條不該是事後才發現,應該提前到 dispatch 前量測**。理由：你自己都講了「這是本票隱藏成本」的姊妹疑慮,而且**代價不對稱**——現在先花一次measurer查詢（team11那45次失敗記錄的target是不是同一個tile,或抽樣幾組真實重複失敗案例算重複率)成本很低；若等implementer整套建完、dispatch、跑gate才發現重複率趨近零,要重新設計「該不該做類級泛化」這整個語意決定,成本高得多,而且會撞上你自己§3引的blueprint硬性語意（先exact-pair、類級泛化不預做)——若實測顯示需要類級泛化,那甚至不是這票能自己決定的事,要回頭找blueprint要求鬆綁語意,鏈路更長。

**建議**：spec加一句要求——dispatch前(或跟①的必查項一起)請measurer**先**查一次「同一(option,target)重複失敗的實際比例」（哪怕只是從既有失敗記錄/log裡抽樣,不需要專門長跑),把這個數字擺在spec上再讓implementer動工。若數字健康（重複率有意義,不是趨近零),照現在的spec直接做；若數字真的貼近零,你在動工前就能跟blueprint對話要不要調整語意,不用等做完了才回頭改設計。

## 其他可查項：親驗無異議
- folding要求（candidate路跟option路收斂進同一個key空間,不得兩套記憶)：方向正確,是這票的核心價值,沒有疑慮。
- 反面驗收（不同target的同類動作不受影響)：合理的證明「沒有偷做類級泛化」的測法。
- `OPTION_FAIL_KEY`人工表消失：親認同這是正確方向,兩筆手工表本來就是暫時形態。

## 結論
**CLEAN → 可等①②收斂後dispatch,不需要重跑R①**。★必查項①（`_mk_candidate`/`_mk_delegate_candidate`各補2個結構欄位,列為前置步驟)+②（exact-pair命中率提前到dispatch前量測,非事後死水欄才發現)都要求在dispatch信裡帶給implementer/measurer,非阻塞但務必補上。

地基 KEEP。
