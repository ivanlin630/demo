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
	var f := FileAccess.open(KI, FileAccess.READ)
	if f == null:
		print("[KI-ANCHOR-GATE] ★FAIL：讀不到 %s（★★讀不到不是通過）" % KI)
		quit(1); return
	var text: String = f.get_as_text(); f.close()

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

	if bad.is_empty():
		print("[KI-ANCHOR-GATE] PASS：%d 個相異新錨全部指得到現場" % seen.size())
		return
	print("[KI-ANCHOR-GATE] ★FAIL：%d 個新錨指不到" % bad.size())
	for b in bad: print("   ★ ", b)
	print("★處置：符號真的沒了 ⇒ 該條目是【真 stale 候選】，回頭判它還成不成立；")
	print("★★符號只是改名 ⇒ 更新錨。★★★兩者都【不是】把錨改回行號。")
	quit(1)
