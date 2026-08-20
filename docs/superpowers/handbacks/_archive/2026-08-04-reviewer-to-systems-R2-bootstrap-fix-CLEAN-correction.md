---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+必訂正④] bootstrap fix——①②③⑤親驗坐實(_faction_roster_pos只回tile_pos/reuse既有_find_own_outpost已在constitution_baseline_v2.txt標legit零新gv_mapscan site/util一字未改僅target_pos解析加fallback);★④不成立——親讀用戶ratified原文(2026-08-04-blueprint-to-systems-bootstrap-ratified-GO.md:19)『分裂=名冊凍成belief快照帶走(對方後續新建/棄置不知、會過時)』=帶走一份會變舊的快照,MVP的faction-gate讀當下faction_id=分裂瞬間零資訊(連快照都沒有過)非「有快照但會過時」,兩者機制不同非同outcome換包裝;spec文字『達④outcome』是自我認證過頭需訂正非事實錯;non-blocking(現況Part2消費者只鎖同勢力,ex-faction位置無人讀)但必如實標『非④全模型,已知gap待未來slice若需消費』非聲稱已滿足"
---

# R②判決：bootstrap fix spec — CLEAN + 必訂正一項（④）

## ①②③⑤——親驗坐實
親讀worktree(`.worktrees/info-network-whole`)`decision_context.gd:341-369`確認`help_need_severity`/`scout_staleness`兩條util公式跟severity/staleness×人格formula在這次修動前就已經在(S-herald/S-scout commit d17cd050/d4766834既有)，這次bootstrap fix**完全沒碰這兩段**——只加`target_pos`解析的fallback，genuine非crank claim坐實。`_find_own_outpost`(faction_ai_system.gd:4082-4087)親讀確認只回`tile.tile_pos`(結構性欄位`outpost_level`/`outpost_owner`比對，零讀target的runway/resources/pop等動態欄)，①站得住。這函式本身已經在`constitution_baseline_v2.txt:72`標`legit-self: 掃own outpost`——spec的`_faction_roster_pos`直接reuse同一函式(換target參數傳別的team而非caller自己)不會產生新gv_mapscan fingerprint，gate不會重跳，④無框內平行求解器成立、非增殖。②(移動隊零own outpost→函式天然回-1)③(同勢力gate)邏輯上沿這個函式的既有行為自然成立，符合設計。

## ★④——不成立，需訂正spec措辭非阻塞build
親讀用戶親口ratified的硬界原文(`2026-08-04-blueprint-to-systems-bootstrap-ratified-GO.md:19`)：

> **分裂 = 名冊凍成 belief 快照帶走**（對方後續新建/棄置不知、會過時）

這句話的機制是：分裂那一刻，成員**帶走一份**當時的位置快照，這份快照**之後不再更新**（對方後續蓋新據點/棄置舊據點都不知道）、但**曾經知道的部分還在、只是逐漸過時**。

spec(`2026-08-04-infonet-bootstrap-fix-HOW.md:29`)的MVP做法是`_faction_roster_pos`每次呼叫都**讀當下`faction_id`**比對——分裂那一刻`target.faction_id != member.faction_id`立刻成立，helper**瞬間回(-1,-1)**。這代表成員在分裂當下**連一份舊快照都沒有**——不是「有快照但沒更新」，是「從頭到尾沒建立過快照、現在也讀不到」。這跟ratified原文描述的「凍住帶走、會過時」是**兩種不同機制**：一個是「曾經有、現在舊了」，一個是「現在起完全沒有」。spec自己寫「MVP的faction-gate已守『不live-track對方』硬界」——這句話只證明了**不live-track**（原文也要求這個），但沒有證明**有帶走快照**（原文同時要求這個）；spec接著寫「達④outcome」是把「滿足其中一半」講成「滿足全部」，這個措辭需要訂正，非我認定機制錯（機制本身簡單/安全，沒有god-view疑慮）。

**是否阻塞這次build**：不阻塞。這次bootstrap fix要解的病是「同勢力成員找領主/子民的位置」，Part2(求援/偵察)的消費者從頭到尾只鎖`target.faction_id==member.faction_id`（同勢力），ex-faction的位置本來就不會被這條路徑讀取——換句話說，就算之後真的補上frozen-snapshot全模型，也不會改變這次herald/scout die-fire的修法一個字。所以這個gap對「治bootstrap死結」這個任務目標是無害的。

**要求**：
1. spec§4④的「達④outcome」改成如實描述——例如「MVP用faction-gate達成『不live-track對方』這半個outcome，frozen-snapshot(『帶走會過時的舊快照』)那半未做，標tracking」，避免之後有人拿這段文字誤以為④已經全解。
2. 這個gap記一筆tracking item（非另開slice指令、只要有紀錄），等未來真有功能要消費「ex-faction前領地位置」時再補。

## determinism / need-gated / 感知鐵律
零新randf；help/scout既有need-gate（`help_need_severity>0`/領主+info-gap）不動；`_faction_roster_pos`回傳只是結構性位置查詢，跟god-view broadcast/whole-map決策掃無關(掃全tile找`outpost_owner==id`是既有`_find_own_outpost`的機制，非這次新增)。

## 判決
**CLEAN + 必訂正一項（spec§4④措辭，非阻塞）→ 回systems訂正後→build（續`feat/info-network-whole`）→ re-measure whole → QA故事稽核。** ①②③⑤皆親驗坐實可直接build；④訂正只是文字誠實度要求，不需要重新設計或多等一輪R②。
