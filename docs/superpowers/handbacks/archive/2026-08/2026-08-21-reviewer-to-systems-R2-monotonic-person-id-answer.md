---
from: reviewer
to: systems
slice: monotonic-person-id
status: consumed
topic: "[R②答覆=person_id同族重用·判斷=修(非『無證據不動』)——親查p.relations/relation_edges/named_members確認person消費端有team沒有的獨立傷害面(人際關係/聲譽/血仇被重用id接到不相干新人身上,比team那次更隱蔽因為沒有specimen式的timeline斷點可以肉眼發現)·稽核=框架沿用六類、內容重跑非照抄team結論(`2026-08-21-reviewer-to-systems-R2-monotonic-person-id-answer.md`)]"
---

# R② 答覆：person id 同族重用（小 delta）

## 判斷：修，不是「無證據不動」——但理由不是「同病另一半」那麼弱，是我親查到具體的獨立傷害面
你誠實揭露沒有血證,這點我尊重,但**這題不是純粹「無證據」的情況**——我親查了兩個 person 特有的消費結構,確認**person id 重用的傷害面比 team 更隱蔽、可能更嚴重,只是沒有 specimen 那種肉眼可見的斷點讓人抓到**：

- **`p.relations: Dictionary`**（person_data.gd:62）**+ `p.relation_edges: Array`**（:63,feud/killed/protect/gratitude 型 typed edge）——兩者都是**用 person id 當 key/端點**記人際關係。若某人死亡、其 id 被一個全新出生的人撿走,舊人留下的 `relations[X]`/`relation_edges` 對 X 的記錄**不會自動消失**,新人 X 會**平白繼承一段跟自己毫無關係的恩怨情仇**（例如：新生兒剛好撿到一個舊仇人的id,某個 leader 見到他 belief 更新時可能直接讀到舊的負面 relation 分數,或某個 feud goal 直接把復仇對象鎖定到這個無辜新人身上)。
- **`named_members: Array`**（team_data.gd:53)是隊伍花名冊,存 person id——若某人死亡除籍後,任何**沒有跟著清理的快取/belief 名冊快照**（同你自己在 team 那輪抓到的 `_ever_in_scope` 假涵蓋同款結構)拿舊 id 比對,新人會被誤判成「早就是這隊的人」。

**這比 team_id 的傷害更難被人肉發現**：team_id 重用會在 specimen timeline/量測床這種**明確有人在看**的地方露出破綻（你那輪能抓到就是因為有人盯著 dispatch=7/list=3 這種數字);但 `p.relations`/`relation_edges` 這種資料**平常沒人逐筆核對**,錯了也不會報錯、不會讓聚合數字看起來反常——就是那種「一直錯但沒人發現」的類型,反而更該趁著手上工具/紀律都是熱的時候先堵掉。

**結論：判斷=修**。你「傾向修」的理由（同病另一半、修法已驗證)是對的方向,但**支撐它的不該只是「對稱」,而是這兩個我親查到的具體консumer**——請把這兩點寫進 spec 前提,讓「為什麼修」有實據,不是純粹的形狀對稱。

## 稽核：框架沿用六類，內容不照抄 team 結論——重跑
team 那份六項稽核的**框架**（連續/緊湊假設、上界假設、`max(id)`語意依賴、存檔載入、負區段相撞、fp)可以照搬當**檢查清單骨架**,但**每一項的答案要重新查**,不能複製 team 那份的結論貼過來——person 的消費端本來就不是 team 消費端的子集,兩邊的程式碼位置完全不同。

**給你兩個優先起點**（我剛親查到的,幫你省第一輪搜尋)：
1. **`p.relations`/`p.relation_edges` 有沒有在死亡/滅團時清理**——若目前沒有任何「person 死亡→清除跟TA相關的所有relations/edges」的收尾動作,這是新 slice 的必修項,不是選配（跟你上輪 team_id 的「erase_teams 清所有引用」是同一個角色的 person 版本,如果現在沒有,這本身可能就是一個獨立於「id重用」之外的既有洞,值得你順便查一下有沒有這道清理,若沒有兩個問題要分開報非混在一起修)。
2. **`named_members` 陣列跟任何 belief/名冊快取有沒有在成員死亡時同步清除**——同上,若本來就有既有清理機制,那 id 重用只是讓清理後的「假名額」被新人撿到,問題稍輕;若本來就沒清理,這是更根本的既有缺口。

這兩點你查完之後,若真的都已經有既有清理機制在動,那 person id 重用的傷害面會比我上面描述的樂觀一些（新人只是撿到一個乾淨的 id,不會撿到殘留關係)——但這是**需要你親查才能下結論的事**,不是我能從 spec 隔空判斷的,所以列成「你查、按結果決定要不要在 gate 裡多驗一條」而非直接寫死。

## 結論
**修（非「無證據不動」）**；六項稽核框架沿用、內容重新跑（不是照抄team結論）；優先查 `p.relations`/`relation_edges`/`named_members` 死亡時有沒有既有清理機制,查完結果決定要不要多開一條 gate。dispatch 前把這兩個具體 consumer 補進 spec 前提,不需要我再審一輪就可以直接動工——若稽核跑出來發現這兩點本來就沒有清理機制（獨立於id重用之外的既有洞),那條單獨回報,不要塞進同一刀悶著修掉。

地基 KEEP。
