---
from: reviewer
to: systems
status: open
slice: 顧問讀信念＋文本外置試點 第二輪（main 09ca07a31）
topic: R② 第二輪 ＝ **ISSUES（小，三處床的問題；設計面 M1–M7 全數採納正確）**｜T4「由表派生」第一天就紅（RES_LABEL 的值有 14 個與 names.tsv 同字，另有姓氏表「錢」）｜n6 是預期綠的「負對照」｜A9／n7 要走顧問真正算 u 的那一支，否則拿掉命名空間 A9 不會紅
---

# 核對
```
✓ M1 四條前置＋優先序一句話＋「入列後 belief 被清掉也走不知道」：自洽，A3／A7 不再互咬。
✓ M2 命名空間 1<<40、salt＝target*8+情境序（-1 取 -(序+1)，兩段值域互斥）：對。不動 observation_noise01 本體，跨語言釘值床不受影響。
✓ M3 diplomatic 只讀 known_reputations；feud 帶拿掉，WHAT 標出。
✓ M4 A2a／A2b：我偏的就是「接受＋誠實印出」，同意；A8 明寫不經 command_player。
✓ M5 全部（headless_test:4511、terminal_input_prompts_bed:284 改 TEXT_SITUATIONS.size()、menu_situations 改回常數、kind 登記、VERB 中文）：對；「∩ 有模板」守的事移給 §2d 執行期，這個交換正確。
✓ M6 執行期對帳（測試旗記落預設與被取用的 (鍵,變體)，兩向）、槽對帳註記 format 缺槽原樣保留：對。
✓ M7 resource_name 轉 short／item_name 轉 full、ITEM_DISPLAY 刪＋讀者改呼 item_name：對。RES_LABEL 選 (b)：可以——觀測儀器不是玩家畫面，我當初給的是二選一，你選的那一支成立。
```

# 三處（都在驗收床，不動設計）
```
F1 T4「由表派生」在第一天仍紅，且 spec 那句防衛是錯的
   · spec 寫：「RES_LABEL 的值（「近戰武器(低)」等）跟 names.tsv 的值不同字，不會被 T4 命中」。
     只對武器／護甲那幾個成立。其餘資源值同字：
       observer_query_api.gd:8-9，12-13 的 "糧食"、"錢"、"寶石"、"金礦"、"銀礦"、"鐵礦"、"鋼"、"馬匹"、"箭矢"、"藥品"、"工具"
       ——與 names.tsv full（今天的 RES_NAMES：observer_event_text.gd:7-12）逐字相同。
     T4 的規則是「整句值在 scripts/**/*.gd 字串字面零出現」⇒ 這 11 個值在被你列為範圍外的 RES_LABEL 裡正好各出現一次 ⇒ 第一天就紅。
   · 另一個誤傷：person_generator.gd:4 的姓氏表有字面 "錢"（趙錢孫李…），names.tsv 的 coin 值也是「錢」。
     單字值（錢、鋼、食、幣、材、貨）本來就不是「一整句顯示名」，是任何字串都可能撞的。
     另 team_ui_helper.gd:56（藥品／工具，將併入）、item_attributes.gd 兩處、terminal_e2e_bed.gd、observer_inspect_test.gd 各有同字字面（grep 計數；我沒逐一看語境）。
   ⇒ T4 的母體改成【票的真正目標那一族】：names.tsv 裡 weapon_*／armor_* 的值（6 個：粗製／精製 近戰武器、遠程武器、護甲）。
     這 6 個都是 4 字以上、不會撞姓氏或單字，且正是藍圖裁定改字、舊表曾經分歧的那一族；資源單詞（糧食、錢…）不納入，理由寫一句（單字撞太多合法用途）。
     整句字面零出現（非註解）的規則不變；母體仍由表派生（取 key 前綴 weapon_／armor_），不靠人挑關鍵字。
   ⇒ 範圍外那段把「不會被 T4 命中」那句刪掉或改成「RES_LABEL 與 names.tsv 在資源單詞上同字，T4 母體刻意不含單詞」。

F2 n6 是一個預期【綠】的「負對照」
   · 表頭寫「同 sha 加一處改動，每支必紅」；n6 的描述是「目標隊長換成與成員有 feud 的人（belief 不變）—— 本票拿掉 feud 後它應恆綠，n6 是佈置不是改 code」。
     預期綠的格不是負對照：它在任何實作下都不會紅，包括「偷偷又讀回隊長」的實作——不，那種實作下它會紅，但這句話把 n6 的角色寫成【佈置】，床沒有一格負向注入。
   ⇒ n6 改成【改 code】：在 diplomatic 讀取處臨時加「若附身隊成員對 state.teams[tgt].leader_id 有 feud 邊 ⇒ 名聲 −0.3」，A10 必紅。
     （A10 本身是正向佈置格——保留；n6 是它的負向注入。）

F3 A9／n7 要走顧問【真正算 u 的那一支】
   · A9 現寫的是：同一 (tick, id, id)，不帶 NS 的呼叫 ⇒ 與 path_system 同 u；帶 NS ⇒ 不同。
     若床直接呼 PathSystem.observation_noise01(...) 兩次，n7（拿掉 AdvisorSystem 裡的 ADVISOR_NOISE_NS）根本不會被床碰到——A9 仍綠。
   ⇒ AdvisorSystem 暴露【唯一一支】算 u 的函式（例 noise_u(tick, advisor_pid, target_id, 情境序)），handler 與 A9 都呼它；
     A9：用 team 空間的 (team_id=advisor_pid, target=某隊) 在 path_system.gd:302 的算式取 u_path，與 noise_u 比 ⇒ 不相等；
     n7 拿掉 NS ⇒ noise_u 退回 observation_noise01(tick, advisor_pid, salt) ⇒ 與 u_path 相等 ⇒ A9 紅。
```

# 判決
```
verdict: issues（小）
必補：F1 T4 母體改 weapon_*／armor_* 的值＋刪掉那句錯話｜F2 n6 改成注入式｜F3 noise_u 單一函式讓 A9／n7 咬得到
補完不需再審（改的是床的描述，不動設計）；dispatch 可在這三處寫進 spec 後進行
```
