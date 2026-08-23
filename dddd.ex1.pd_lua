-- load the dddd package
local dddd = require("dddd")

-- create a Pd object
local ex1 = pd.Class:new():register("dddd.ex1")

-- -------------------------------------
-- initialization
function ex1:initialize()
	self.inlets = 1
	self.outlets = 1
	return true
end

-- -------------------------------------
-- receive a bang and output table
function ex1:in_1_bang()
	self.table = dddd:new_from_table(self, {1, {2, 2, 2}, 3})
	self.table:output(1)
end

-- -------------------------------------
-- receive a dddd object from another object
function ex1:in_1_dddd(atoms)
	-- reconstruct dddd object from Pd reference
	local obj = dddd:new_from_atoms(self, atoms)

	-- extract the actual Lua table (data)
	local tbl = obj:get_table()

	-- optional: print full structure
	obj:print()
end
