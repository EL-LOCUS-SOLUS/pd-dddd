-- load the dddd package
local dddd = require("dddd")

-- create a Pd object
local ex1 = pd.Class:new():register("dddd.ex1")

-- ─────────────────────────────────────
-- initialization
function ex1:initialize()
	self.inlets = 1
	self.outlets = 1
	return true
end

-- ─────────────────────────────────────
-- receive a regular Pd list
function ex1:in_1_list(atoms)
	-- convert Pd atoms → Lua table (supports nested lists)
	local tbl = dddd:table_from_atoms(atoms)

	-- add arbitraty data to object
	tbl["hello_from_dddd"] = "hello"

	-- wrap table into a dddd object
	local obj = dddd:new_from_table(self, tbl)

	-- send structured data to outlet
	obj:output(1)
end

-- ─────────────────────────────────────
-- receive a dddd object from another object
function ex1:in_1_dddd(atoms)
	-- reconstruct dddd object from Pd reference
	local obj = dddd:new_from_atoms(self, atoms)

	-- extract the actual Lua table (data)
	local tbl = obj:get_table()

	-- access previously added data
	pd.post(tbl["hello_from_dddd"]) -- prints "hello"

	-- optional: print full structure
	obj:print()
end

-- ─────────────────────────────────────
-- reload helper (no Pd restart needed)
function ex1:in_1_reload()
	self:dofilex(self._scriptname)
	self:initialize()
end
