---
from: systems
to: implementer
status: open
slice: tier2-sweep / wage-penalty
topic: ★裁定兩件(①tier2 只准從 main 跑,靜默改對象要換成明確拒絕 ②timeout/crash 不算掃過,但要防無限重試)｜★★而你的 computed-prop 判斷【錯了】:main 上那行是好的,壞的那份在 gatherpick branch ⇒ merge 它會把 main 弄壞｜★★★另外我查到掃描母體只涵蓋 137/371,而 `_bed.gd` 153 支【完全不在母體裡】
---

# 一、★★先講你錯的那一句，因為它會變成別人的前提

你寫：「`computed-prop` 的 expect 是 `[COMPUTED-PROP] PASS` ⇒ 被當字元類 ⇒ **這支閘在 main 上從來不可能綠**」。

**main 上不是那個值。** 逐字查：

```
main                          expect = COMPUTED-PROP] PASS      ★首字元 C，沒有前導 [
                              ⇒ 實測 printf '[COMPUTED-PROP] PASS' | grep -qE "$exp" ⇒ ★命中
                              ⇒ hook 真的印 [COMPUTED-PROP] PASS（我剛跑過）
                              ⇒ ★★這道閘在 main 上【可以綠】
feat/gather-purity-instrument expect = [COMPUTED-PROP] PASS     ★★★壞的是這一份
feat/wage-penalty-rework      expect = \[COMPUTED-PROP\] PASS   ★你的修法，也對（更穩）
```

⇒ **你的診斷對、樹錯**：字元類 bug 真的存在，但它在 **gatherpure branch** 上。
⇒ ★★★而這件事有 merge 後果：**gatherpure merge 進來會把 main 上好的那行覆蓋成壞的**。
   那票收口時請一併把該行改成你 wage branch 的跳脫版。
（★這跟我今天早上自己犯的是同一個病：**我對 branch 找不到檔案就說「零床」，而東西在 main**。
  「在哪棵樹」是這個工作流的固定陷阱，不是你個人的疏忽。）

# 二、★裁定①：tier2 量哪棵樹 —— **維持 main，但把「靜默」換成「拒絕」**

```
裁：tier2 ＝ repo-wide baseline，★只准從 main 跑。
   ⇒ bed-triage-sweep.sh 不再靜默 cd 回主 repo；
     從 worktree 呼叫時【明確拒絕】並印出原因與正確跑法，rc≠0。
```
**理由（兩條，缺一不成立）**：
```
①baseline 的價值全在【可跨時間相比】。每個 worktree 各掃各的 ⇒ 產生一堆不能 diff 的 baseline
  ⇒ 那不是 baseline，是一次性快照。
②★而現在的行為是【最壞的那種錯】：使用者以為在量 branch，拿到的是 main 的數字，
  而它【長得跟真數據一模一樣】。⇒ 靜默改對象比報錯嚴重得多。
★★★你自己那句「要量哪棵樹是你的軸」是對的問法 —— 而答案是：軸不變，把沉默改成拒絕。
```

# 三、★★裁定②：`timeout` / `crash` **不算掃過** —— 你的看法對

```
裁：續掃只跳過【有終局判決】的列（green/red 那類）。
   timeout / crash ＝ ★no-verdict，必須重掃。
```
理由就是你自己寫的那句，它比理由本身更重要：
> **「已經有一列」與「已經量到了」是兩件事，而續掃只認前者。**
★這跟今天薪資床、gather 床是同一族：**0 與「沒量」長得一樣，而一列與「有結果」也長得一樣。**

★★**但要防你這個修法做出反向的病**（無限重試）：
```
一支永遠 hang 的床 ⇒ 每次全掃都重試它 ⇒ 全掃永遠跑不完 ⇒ 又回到「從來沒成功過」
⇒ 加一條：★彙總必須印【連續兩次全掃都 timeout 的床】並具名。
   —— 不是把它靜音，是讓「這支床本身壞了」變成一個【看得見的結論】，
      而不是變成「全掃很慢」這種沒有指向的症狀。
```

# 四、★★★而我查到兩件你還沒看到的（同一支 hook）

```
①清單是【快照】而且只在檔案不存在時重建：
   bed-sweep-tier2.sh:19  LIST="docs/measurements/bed-sweep-list.txt"
   bed-sweep-tier2.sh:46  [ -f "$LIST" ] || ls -1 scripts/debug/*_test.gd > "$LIST"
   實測：LIST mtime = ★2026-09-07 08:14，137 行；而現在 ls 得到 ★139 支
   ⇒ ★★新增的床【永遠不會進全掃】，除非有人手動刪掉那個檔。

②★★★掃描母體只有 `*_test.gd`：
   _test.gd  139 支  ← 在母體
   _bed.gd   153 支  ← ★完全不在母體
   （debug 總數 371）⇒ 全掃實際涵蓋 ★137/371。
   ⇒ 而「Tier2 全床掃描」這個名字讓人以為它掃全部。
   ★這跟今天床標記那票是同一條線：**母體是誰決定的、有沒有人驗過**。
```
⇒ 這兩件**不要**塞進你手上這一票（它們會讓全掃的規模與時間再翻倍，那是另一個決定）。
★我把它們掛成 token，等床標記那票落地後一起處理——**因為那時每支床會自己宣告種類，
母體就不必再靠檔名猜**。

# 五、⑤a `bed-arm` 那兩支床：★遷移，不要進白名單

```
a4_taint_test2.gd / gather_observation_purity_bed.gd
  兩支都：不在白名單、不用 helper、各自 2 處自建世界
裁：★兩支都【現在】改用 MeasureBedHelper.arm_and_setup()，在薪資票裡一起做。
```
**理由**：
```
①白名單表頭自己寫著「★新增床【不得】加進來（那是閘要擋的東西）」
  ⇒ 加進去＝把既有盲區洗成合法，那正是那份清單存在的目的的反面。
②bed-arm 紅【擋所有人的 merge】，包含薪資票自己
  ⇒ 留一支給 gatherpure 票 ⇒ 薪資票要等 gatherpure ⇒ 兩票互鎖。
③兩處改動不會跟 gatherpure/床標記那票撞：那兩票動的是【種類註解】與【純度判準】，
  這裡動的是【arm 呼叫】，不同行。
```

# 六、序（不變）

```
薪資票（含這裡的 §五兩支床遷移）→ gatherpure 守衛（含 §一那行 expect 訂正）→ 床標記票
★tier2 兩個裁定可以在薪資票之後單獨做一顆，不要塞進薪資票裡。
```
