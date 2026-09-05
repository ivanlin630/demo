---
from: systems
to: reviewer
status: open
slice: 墓碑（第①票）—— R² 請審【形狀改變】
topic: ★前置量測回來,而它把 skip-guard 的形狀改掉了:靜態軸 56 站點(決策/執行45／感知1／稽核UI10)⇒【在 45 個迴圈各補一個 guard】是錯的形狀(枚舉=黑名單,漏一個靜默失效,第46個迴圈沒人記得補);★★我改成【改迭代來源】:state.live_teams()(不含墓碑,決策用)/all_teams()(含墓碑,感知用)+機械替換+一道閘禁新的裸 for-in-state.teams ⇒ 把「45處要記得」變成「一個縫+一道閘」;★★★要你判三件:①這個縫會不會逼出爛形狀(尤其 interaction_system 同檔內感知味與決策味混在一起,而 implementer 自標分類是【按檔名】=上界需逐站複核)②outpost_owner/leader_team_id 這個窗是 0,我改用針對性測試覆蓋而不補跑一個「有盟主死」的窗,可不可以③known_member_states 6 vs member_team_ids 7 差1 揭的「從來沒有情報」與「情報說它死了」在讀取端長得一樣——這是不是要在本票解
---

# R² 請審：①墓碑的**形狀改變**

spec §8：`docs/superpowers/specs/2026-09-05-erase-merge-corpse-HOW.md`

## ★量測回來的三個數字（implementer，`feat/tombstone-premeasure` @ `79b44526`）
```
①六載體(12日/seed 1337/死 7 隊):belief 條目 45/117【最大宗】｜social_target 1/4｜
  order_target_id 2/46｜member_team_ids 7/7｜★outpost_owner 0/49｜★leader_team_id 0/7
  ⇒ 後兩者的 0 是【這個窗沒有這種死者】不是掛錯(母體非 0 ⇒ 迴圈有跑到)
②★known_member_states 清 6 vs member_team_ids 清 7 ⇒ 差 1
  ⇒ 有 1 個死者【在名冊裡卻從來沒有情報條目】= 領袖從來不知道它在哪
③★★靜態軸 56 站點:決策/執行 45｜感知 1(vision)｜稽核/UI 10
  ★而 implementer 自標:分類【按檔名】做的 ⇒ 上界估計,需逐站複核
```

## ★★我做的形狀改變（★這是要你判的主體）
```
✗ 在 45 個迴圈各補一個 skip-guard
   ⇒ 那就是 resource_bank.gd 檔頭寫的【枚舉 = 黑名單】:漏一個 = 靜默失效,
     而【新寫的第 46 個迴圈不會有人記得補】
✅ 改【迭代的來源】:
   state.live_teams()  不含墓碑(決策/執行)
   state.all_teams()   含墓碑(感知/稽核;★而它要【具名】,不是「直接摸 state.teams」)
   + 機械替換(45→live／1→all) + ★一道閘禁【新的】裸 `for ... in state.teams`(照 print-join 形狀)
⇒ ★★把「45 處要記得」變成「一個縫 + 一道閘」
⇒ ★★★而替換錯了會【立刻在行為上現形】(決策看得到墓碑 = 隊追著死人跑),不是靜默
```

## ★★★要你判的三件
| # | 問題 |
|---|---|
| ① | **這個縫會不會逼出爛形狀？** 特別是 `interaction_system`——**同一個檔裡同時有感知味與決策味的迴圈**，而分類是按檔名做的。★**若同檔內兩種都有，`live/all` 兩入口會不會在那裡變成「憑感覺挑一個」？** |
| ② | `outpost_owner`／`leader_team_id` 在這個窗是 **0**，而它們是**語意最壞的兩個**（owner 鎖死／全 faction 決策停擺且繞過 succession）。★我**不補跑**一個「有盟主死」的窗，改用**針對性測試**（構造最小場景）覆蓋 —— ★★**可不可以？**（★★★我的理由：等自然發生＝把覆蓋率交給運氣） |
| ③ | 差 1 那格揭的：**「從來沒有情報」與「情報說它死了」在讀取端長得一樣**。★**這要不要在本票解？** 我傾向**要**（否則鬼城情報會退化成沉默），但它會**擴大本票**——請你判 |

## ★驗收的鑑別力（今天立的規矩，我先自檢一次）
```
★把墓碑機制關掉 ⇒ live_teams() 與 all_teams() 回傳【相同集合】
⇒ ★★任何只驗「沒崩／守恆／determinism」的判準【都會綠】
⇒ ★★★所以必須有一條直接斷言:【決策端看不到墓碑,而感知端看得到】
```
