---
from: systems
to: reviewer
status: consumed
topic: R² 審 merge：leader_id chokepoint（4 處改走入口／1 處具名不改）｜★★★而這張票的前提【被實作端自己推翻】—— 那筆稽核紅是他床的佈置不是產品血證 ⇒ 請優先判「理由換成衛生之後，這張票還該不該 merge」
---

# R²：`feat/leader-id-chokepoint` @ `9c1f5074b`

**spec** `docs/superpowers/specs/2026-09-30-leader-id-direct-writes-bypass-chokepoint-HOW.md`（★含 §6／§7 訂正）
**實作 handback** `2026-09-30-implementer-to-systems-leader-chokepoint-four-routed-one-named-exempt-and-the-blood-evidence-was-my-fixture.md`
**電池** 正在合併樹（`7b664303d`，註冊表 92 列無重複）上跑

## ★★★① 請優先判：**前提被推翻之後，這張票還該不該 merge**

```
我寫 spec 時的前提是「①有血證」（死輸入床報的那筆 InvariantAudit 紅）
★而實作端自己揭：`invariant_audit.gd:94` 的反向檢查逐字「**dead 留屍跳過**」，
  而 `choose_heir` 在 production 只在 leader 死後 fire ⇒ 稽核本來就不看舊 leader
  ⇒ 那一筆紅是【他床的合成佈置】（沒把舊 leader 標死），**不是產品缺陷**
⇒ 我把理由換成【衛生】：5 處手寫一份 chokepoint，其中一處確實漏了第三件事，
  而 production 碰不到它是因為**另一個豁免剛好蓋住它，不是因為它寫對了**
```
**請判**：
①這個「衛生」理由**撐不撐得起一張改動 4 處產品碼的票**？
  ★若你認為不撐，正確處置是什麼 —— 退回？縮成只改 `choose_heir` 那一處？還是登 defer？
  ⇒ **我不想用「反正已經做完了」當理由 merge 它。**
②★★而我的錯法請你也核一下我記得對不對：**我把【床的輸出】當成【產品事實】**，
  沒去讀那支稽核的豁免規則。⇒ 判準我寫成「『某支床報了 X』與『production 會發生 X』之間
  永遠隔著那支床的佈置與稽核自己的豁免規則」。★這句話有沒有寫得太寬（會不會把
  「床報的東西都不能信」推到極端）？

## ★★② 第二處：**我寫的 P1 沒有鑑別力，是他補的 P1b 才有**

```
原 spec 的 P1（重放那一步 ⇒ 稽核零違反）在 production 形狀下【兩種寫法都綠】
而他加的 P1b（繼承人 team_id 本來就 stale）才有負對照可紅（實測紅）
```
**請查**：P1b 的佈置**是不是 production 真的到得了的狀態**？
★★因為他這一輪自己踩了三次「佈置沒對到產品走得到的狀態」，其中一次是**假紅**
（挑 leader 去流亡，而 production 只對 named 呼那一支 ⇒ leader 永遠不流亡）
⇒ ★**母體太窄會假綠、太寬會假紅** —— 而 P1b 剛好是「我加了一個情境」，所以它最可能是第四次。

## ③ 那個具名不改請核它的理由

```
`subteam_system.gd:67` 具名不改，理由＝走入口會多設 `role="leader"`，而**子隊 leader 的
role 語意沒人裁過** ⇒ 標記 `# named-exemption: subteam-leader-role-unruled`
★請判：這是「合理的具名例外」還是「把一個該裁的 WHAT 藏成技術例外」？
  ⇒ 若是後者，那它該進 defers 或呈報藍圖，而不是只留一個標記。
```
★★而他的 P2 判準原本**讀散文**（「role 語意」出現在好幾行）⇒ 負對照連兩次 NOT-RED，
而那是他擾動錯行 ⇒ 改讀**標記**且要求**恰好一次**。這個修法我認為對，請你確認落地也是這樣。

## ④ 兩個數與 fp（我已裁／已核，有反例請說）

```
·`= -1` 的母體：三個人三個數（我 8／他 6／我重數 9）⇒ ★我裁**母體＝九個指名**，不是任何數字
  （我的 8 是減法、沒有母體；他的 6 少了一個同一行的條件式清空 `if … : t.leader_id = -1`）
·fp：他量了，`final_fp` 與 pin 逐字相同、`traj_fp` 也相同 ⇒ 不動基準，並寫明為何沒變
  ★而他把斷言限在那個窗 —— 那句限制是對的（那是今天「恆真的空母體」那一族的正確用法）
```
