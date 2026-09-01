extends SceneTree
# @observe-pure
# ★★★known_issues 錨健檢【常駐閘】——防的是「88 條 DRIFT」那個狀態再長回來。
#
# ★背景：第一刀量到 145 個 `檔:行號` 錨裡 88 個指不到現場（行號跟著【編輯】走）。
#   第二刀把 57 條改成 `檔::符號`（符號跟著【語意】走）。
#   ★★而一次性改完不夠 —— ★★★那正是今天整條線反覆的形狀：
#     「落地那天是對的、後來沒人回來看」。所以要有一個每次都跑的東西。
#
# ★判準（兩個，性質不同）：
#   ①★新錨 `檔.gd::符號` ⇒ 該符號必須真的以 func/const/var/class_name 定義在該檔
#      ⇒ ★★指不到 ＝ FAIL（★★★而它【只在符號真的消失時】才紅 —— 那正是「真 stale 候選」）
#   ②★舊錨 `名:行號` ⇒ ★★【不 FAIL，但數字必印】：它是【還沒遷移的規模】
#      ⇒ 形狀同 bed-arm gate 的白名單：★★★它應該單向下降，而印出來才逼得到人看見。

const KI: String = "res://docs/known_issues.md"
# ★★★雙目標（2026-09-02）：43 條⑦群搬進 archive 之後，★它們身上的 8 個 L1 錨【離開了本閘的母體】
#   ⇒ ★★閘照樣印 PASS，而涵蓋率從 51 個相異錨【靜默掉到 43】——★★★那正是「母體縮小看起來像通過」。
#   ⇒ 檢索義務已改雙目標（systems 寫進 01_architect/03_implementer/03b_measurer），★閘跟著改。
const KI_ARCHIVE: String = "res://docs/archive/resolved_issues.md"
const SRC_DIRS: Array = ["res://scripts"]

func _initialize() -> void:
	_run(); quit()

func _gather(dir_path: String, out: Array) -> void:
	var d := DirAccess.open(dir_path)
	if d == null: return
	d.list_dir_begin()
	var n := d.get_next()
	while n != "":
		if d.current_is_dir():
			if not n.begins_with("."): _gather(dir_path.path_join(n), out)
		elif n.ends_with(".gd"):
			out.append(dir_path.path_join(n))
		n = d.get_next()
	d.list_dir_end()

func _run() -> void:
	# ★KI_PATH 覆寫：讓【陽性對照】可以指到別份 known_issues（★對照物不必住在本 repo 樹裡）
	var ki_path: String = OS.get_environment("KI_PATH") if OS.has_environment("KI_PATH") else KI
	var f := FileAccess.open(ki_path, FileAccess.READ)
	if f == null:
		print("[KI-ANCHOR-GATE] ★FAIL：讀不到 %s（★★讀不到不是通過）" % ki_path)
		quit(1); return
	var text: String = f.get_as_text(); f.close()
	# ★archive 併入母體（★KI_PATH 覆寫時不併——那是校準模式，母體要可控）
	var n_ki_chars: int = text.length()
	var n_ar_chars: int = 0
	if not OS.has_environment("KI_PATH"):
		var fa := FileAccess.open(KI_ARCHIVE, FileAccess.READ)
		if fa == null:
			print("[KI-ANCHOR-GATE] ★FAIL：讀不到 %s（★★雙目標的另一半讀不到＝母體缺一半，不是通過）" % KI_ARCHIVE)
			quit(1); return
		var at: String = fa.get_as_text(); fa.close()
		n_ar_chars = at.length()
		text += "
" + at
	print("[KI-ANCHOR-GATE] 母體＝known_issues(%d 字) ＋ archive(%d 字)　★兩份都掃，否則搬家會【靜默縮小母體】"
		% [n_ki_chars, n_ar_chars])

	# 檔名 → 內容
	var paths: Array = []
	for d in SRC_DIRS: _gather(String(d), paths)
	var by_base: Dictionary = {}
	for p in paths:
		by_base[String(p).get_file()] = FileAccess.get_file_as_string(String(p))

	# ①新錨
	var re_new := RegEx.new()
	re_new.compile("`([a-z_0-9]+[.]gd)::([A-Za-z0-9_]+)(\\(\\))?`")
	var seen: Dictionary = {}
	var bad: Array = []
	var n_new: int = 0
	for m in re_new.search_all(text):
		n_new += 1
		var base: String = m.get_string(1)
		var sym: String = m.get_string(2)
		var key: String = base + "::" + sym
		if seen.has(key): continue
		seen[key] = true
		if not by_base.has(base):
			bad.append("%s ★該檔不存在" % key); continue
		var defre := RegEx.new()
		defre.compile("(?m)^\\s*(?:static\\s+)?(?:func|const|var|class_name)\\s+" + sym + "\\b")
		if defre.search(by_base[base]) == null:
			bad.append("%s ★符號在該檔查無定義（★★這是【真 stale 候選】：符號不見了）" % key)

	# ②其餘錨形式 —— ★★★四欄全印，因為【兩個人可以用兩個定義數同一件事】
	#   血證（2026-09-01）：systems 說「行號錨歸零」而我的閘量到 37 ——
	#   ★兩個數字都對：他數的是【簡稱:行號】（那批確實 0），我數的是【任何 名(.gd)?:行號】。
	#   ★★而失效模式（行號跟著編輯走）對兩者一樣成立 ⇒ 兩個都要看得見。
	#   ★★★所以這裡不挑一個定義，四個都印 —— 免得下次又要有人回頭對帳一次。
	var re_abbrev := RegEx.new()
	re_abbrev.compile("`([a-z_][a-z0-9_]*):([0-9]+)`")
	var n_abbrev: int = 0
	for m2 in re_abbrev.search_all(text):
		if not m2.get_string(0).contains(".gd"): n_abbrev += 1
	var re_fileline := RegEx.new()
	re_fileline.compile("`([a-z_][a-z0-9_]*[.]gd):([0-9]+)`")   # ★[.] 取代 \. —— GDScript 字串不吃那個逃脫
	var n_fileline: int = re_fileline.search_all(text).size()
	var re_filelvl := RegEx.new()
	re_filelvl.compile("`([a-z_][a-z0-9_]*[.]gd)`")
	var n_filelvl: int = re_filelvl.search_all(text).size()
	var n_old: int = n_abbrev + n_fileline

	print("=== known_issues 錨健檢 ===")
	print("錨形式四欄（★兩個人可以用兩個定義數同一件事 ⇒ 這裡不挑一個）：")
	print("  L1 `檔.gd::符號`  = %d（相異 %d）★最好：符號跟著語意走" % [n_new, seen.size()])
	print("  L2 `檔.gd`（檔級） = %d ★可接受：不會因編輯指錯，但要人自己找" % n_filelvl)
	print("  L3 `檔.gd:行號`    = %d ★★會漂：行號跟著編輯走" % n_fileline)
	print("  L4 `簡稱:行號`     = %d ★★★最模糊：連是哪個檔都要猜" % n_abbrev)
	# ★★舊錨數字必印 —— 它是【還沒遷移的規模】，而它應該單向下降。
	print("[KI-ANCHOR-GATE] ★註記：會漂的錨（L3+L4）%d 個 ⇒ 【還沒遷移的規模】（★不是通過，是還沒做）" % n_old)
	print("   ★★行號跟著【編輯】走 ⇒ 每次 code 一改就可能再指錯；符號跟著【語意】走。")

	# ★★★③【符號存在 ≠ 符號正確】—— 而這是本閘上線第一天就現形的洞。
	#   血證（2026-09-01）：`reaction_system.gd::_evaluate_life_events` 這個錨
	#     ·★符號【真的存在】（:253）⇒ ★★本閘的①會判它 PASS
	#     ·★★★而它是【退休空殼】：`func _evaluate_life_events(_state, _p, _t, _trials) -> Array: return []`
	#       生育早已搬去 `_tick_breed`（同檔 :90 的註解自己說了）
	#   ⇒ ★所以 known_issues 拿它當「機制實存」的證據，★★而那個證據是死的。
	# ★★判準（★heuristic，明說）：參數【全部】以 `_` 開頭（＝全不用）＋ 函式體只有一行 return/pass
	#   ⇒ ★這是「退休空殼」的形狀。★★WARN 不 FAIL：形狀像空殼不代表錨就錯（判斷要人來）。
	var shell: Array = []
	for key2 in seen:
		var parts: PackedStringArray = String(key2).split("::")
		if parts.size() != 2 or not by_base.has(parts[0]):
			continue
		if _looks_retired_shell(String(by_base[parts[0]]), parts[1]):
			shell.append(String(key2))
	if not shell.is_empty():
		print("[KI-ANCHOR-GATE] ★WARN：%d 個錨指向【看起來已退休的空殼】（符號在，但不做事了）" % shell.size())
		for sh in shell: print("   ★ ", sh)
		print("   ★判準＝參數全 `_` 開頭 ＋ 函式體只有一行 return/pass（★heuristic，會有偽陽）")
		print("   ★★處置＝去看真正做那件事的符號是誰，把錨改指過去；★★★別把它當「機制實存」的證據")

	if bad.is_empty():
		print("[KI-ANCHOR-GATE] PASS：%d 個相異新錨全部指得到現場（★WARN 不擋，見上）" % seen.size())
		return
	print("[KI-ANCHOR-GATE] ★FAIL：%d 個新錨指不到" % bad.size())
	for b in bad: print("   ★ ", b)
	print("★處置：符號真的沒了 ⇒ 該條目是【真 stale 候選】，回頭判它還成不成立；")
	print("★★符號只是改名 ⇒ 更新錨。★★★兩者都【不是】把錨改回行號。")
	quit(1)

# ★★★「退休空殼」偵測（★heuristic —— 它的偽陰在檔尾明說）
#   ★真空殼的兩個共同特徵：①參數全部沒被用到（GDScript 慣例前綴 `_`）②函式體只有一行 return/pass
#   ★★偽陰：空殼但保留了一個真的參數 ⇒ 本判準看不到它
#   ★★★偽陽：小型 accessor（`func _x(_a) -> int: return 0`）也會中 ⇒ 所以是 WARN 不是 FAIL
static func _looks_retired_shell(src: String, sym: String) -> bool:
	var lines: PackedStringArray = src.split("
")
	for i in range(lines.size()):
		var ln: String = lines[i]
		var t: String = ln.strip_edges()
		if not (t.begins_with("func " + sym + "(") or t.begins_with("static func " + sym + "(")):
			continue
		# ★參數：取第一個 "(" 到【該行最後一個 ")"】之間（★不用 [^)]* —— 巢狀括號會咬）
		var a: int = t.find("(")
		var b: int = t.rfind(")")
		if a < 0 or b <= a:
			return false
		var params: String = t.substr(a + 1, b - a - 1).strip_edges()
		if params != "":
			for pr in params.split(","):
				var nm: String = String(pr).strip_edges()
				if nm == "":
					continue
				if not nm.begins_with("_"):
					return false   # ★有一個參數是真的在用 ⇒ 不判空殼
		# ★函式體：往下找第一行【非空非註解】
		for j in range(i + 1, mini(i + 8, lines.size())):
			var bt: String = lines[j].strip_edges()
			if bt == "" or bt.begins_with("#"):
				continue
			if not (bt == "pass" or bt.begins_with("return")):
				return false
			# ★★再往下一行：若還有函式體 ⇒ 不是「只有一行」
			for k in range(j + 1, mini(j + 6, lines.size())):
				var nt: String = lines[k].strip_edges()
				if nt == "" or nt.begins_with("#"):
					continue
				return not lines[k].begins_with("	")   # ★縮排沒了 ⇒ 函式結束 ⇒ 真的只有一行
			return true
		return false
	return false
