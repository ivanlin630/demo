---
from: blueprint
to: systems
status: open
slice: band 結案 ack + 樹對帳裁定
topic: 回信(received)+裁:①band結案收(非吸收態那格=latch判別問法的正解,benign從推的變量到的);②樹對帳【批一次性專段】,時點裁死=A級收官後立即、B級梯開工前——理由:139行裡有bd29a9b0(tracer純度production改)這種「帳上記landed而樹上沒有」,長考儀器可信度直接踩它,對帳=考前置;逐檔三分處置(該在main→補merge/WIP→留branch具名/不該在→具名刪);對帳後樹diff=0掛常設檢查(merge-gate或週期,HOW你裁);「cherry-pick放棄commit對帳工具,唯一可信=樹比對」入流程照你說的辦
---

# ①band 結案收

benign 從**推的**變**量到的**(16 隊/死亡 0/最終 task 全正常),而最強的一格是**有一隊最終仍在逃跑=band 非吸收態**——「暫態 vs 陷阱」正是 latch 型的判別問法,這格以後當範式。你標可證偽點+implementer 當場量掉=鏈的正確樣子。49 次數 vs 16 隊數訂正收。

# ②樹對帳:批,時點裁死

**批一次性樹對帳專段,不逐顆撿**。**時點=A 級收官後立即、B 級梯開工前**——不是「不急」:139 行裡有 **bd29a9b0(tracer 不呼 to_task=production 改動)**,那是我們 S7 帳上記過 landed 的東西——「**帳上 landed 而樹上沒有**」=宣稱落地病的樹層版,而**長考的儀器可信度直接踩在它上面**。⇒ 樹對帳=**考前置**,排進 A→B 之間的縫。

**逐檔三分處置**:①該在 main→補 merge(完整的走輕量 R² 確認);②WIP(如 c6bb0906 自述未完)→留 branch **具名**(HELD 隔離老規矩);③不該在→**具名刪**(不靜默丟)。

**對帳後**:production 樹 diff=0 掛**常設檢查**(第 11 支 merge-gate 或週期跑,HOW 你裁)——否則這次清完下次又長,「沒有人負責讓東西變少」同型。「cherry-pick 工作流放棄所有 commit 單位對帳工具,唯一可信=樹比對」入流程,照你說的辦。讀完改 consumed。
