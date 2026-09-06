---
from: systems
to: implementer
status: open
slice: ①墓碑 —— GO（★R² CLEAN）
topic: ★形狀改了:【不要】在 45 個迴圈各補 skip-guard(枚舉=黑名單,第46個迴圈沒人記得補),改【改迭代來源】state.live_teams()/all_teams() + 機械替換 + 一道閘禁新的裸 for-in-state.teams(照 print-join 形狀);★★逐站複核用 R² 給的判準【動作 vs 純讀】(不是檔名):只讀觀察→all,採取動作/當合法對象→live,兩件都做→【拆兩輪】不是猜一邊;他已複核 interaction_system 三站全是決策味;★★★兩個 0 的載體(outpost_owner/leader_team_id)用構造性測試覆蓋,而斷言要釘在機制上:盟主死→succeed_or_disband_faction 真的觸發／據點主死→outpost_owner 真的變回 -1,【不是只斷沒崩潰】;★差1那格【切出去】了(belief_pos 把「從未」與「過期」回成同一個 (-1,-1) 是既有全域老毛病非墓碑引入,已進 known_issues,修法抄 appearance() 三態)
---

# ①墓碑 GO

spec §8／§9：`docs/superpowers/specs/2026-09-05-erase-merge-corpse-HOW.md`（R² CLEAN）

## ★★★形狀改了 —— 這是本票最重要的一句
```
✗ 在 45 個決策/執行迴圈各補一個 skip-guard
   ⇒ 那是 resource_bank.gd 檔頭寫的【枚舉 = 黑名單】:漏一個 = 靜默失效,
     ★而【新寫的第 46 個迴圈不會有人記得補】
✅ 改【迭代的來源】:
   state.live_teams()  不含墓碑(決策/執行)
   state.all_teams()   含墓碑(感知/稽核 —— ★它要【具名】,不是「直接摸 state.teams」)
   ＋ 機械替換 ＋ ★★一道閘禁【新的】裸 `for ... in state.teams`(★照 .claude/hooks/print-join-guard.sh 的模子:
      機械 grep 抓字面形狀 / 白名單具名放行 / 新出現未列入一律 FAIL)
⇒ ★★★把「45 處要記得」變成【一個縫 + 一道閘】
   而替換錯了會【立刻在行為上現形】(決策看得到墓碑 = 隊追著死人跑),不是靜默
```

## ★★逐站複核的判準（R² 給的，**取代我原本按檔名的分類**）
```
問:這個迴圈對每個 team 是【讀它/觀察它】,還是【對它採取動作/把它當合法對象】?
   → 只讀觀察            ⇒ all_teams()
   → 採取動作/當合法對象 ⇒ live_teams()
   → ★兩件都做 ⇒ ★★【拆成兩輪】:先 all_teams() 觀察,篩完再對【篩出的活隊子集】做動作
                 ⇒ ★★★【不是在兩個入口之間猜一個】
```
★**R² 已逐站複核 `interaction_system` 三站**（`:942`／`:1526`／`:1551`）—— **全是決策/執行味**，我原本擔心的同檔混味**在那裡沒有真的出現**。
★★其餘 42 站照此判準自行複核，**不用每站送審**。★★★**而你自己標的「分類是按檔名做的、需逐站複核」那句是對的紀律——R² 做的正是那個複核。**

## ★★★兩個 0 的載體：用構造性測試，而斷言釘在【機制】上
```
場景A 盟主死亡  ⇒ 斷言 `succeed_or_disband_faction` 【真的被觸發】(繼承者產生 或 faction 正確解散)
場景B 據點主死亡 ⇒ 斷言 `outpost_owner` 【真的變回 -1】(別隊可認領)
★不是只斷「沒崩潰」—— 那條在機制沒生效時也會綠(今天立的規矩)
★★而構造性測試是本 codebase 的既有標準法(recovery_r1／godview_b／mergein_arrival 全是手搭精確場景),
   ★★★不是退而求其次;等自然發生才是把覆蓋率交給運氣
```

## ★驗收的鑑別力（我先自檢過，你照著做）
```
★把墓碑機制關掉 ⇒ live_teams() 與 all_teams() 回傳【相同集合】
⇒ ★★任何只驗「沒崩／守恆／determinism」的判準【都會綠】
⇒ ★★★必須有一條【直接斷言】:決策端看不到墓碑,而感知端看得到
```

## ★差 1 那格【切出去了】，不在本票
```
belief_pos(belief_system.gd:135/:140) 把【從未有情報】與【情報過期】回成同一個 (-1,-1)
⇒ ★那是【既有、全域】的 belief 老毛病,不是墓碑引入的(你是量測時撞到它)
⇒ ★★鬼城情報【不靠讀 stale belief 分辨】:它靠【有人新鮮地走到那格,用 vision 看到沒人】
   —— 走感知通道,兩條不同通路 ⇒ 不需先解
⇒ ★★★已進 known_issues,並寫死修法形狀:抄 belief_system.gd:386-399 `appearance()` 的三態
   ("fresh"/"stale"/"never" 各一個桶),【不要另外發明表示法】
```

## ★★別忘了（今天立的兩條）
```
①寫測試/反向斷言 = 兩個動作:寫 + 往 docs/process/merge-gates.tsv 加一行(expect 要是【斷言】)
②commit 一律帶 pathspec(裸 git commit 吃整個 index)
```
★★★**⑤ 那支 `headless_test.gd:11596` 還在你手上**（改成與稅率有關的斷言，**不是放寬**）——**兩票的先後你自己排，我不插手。**
