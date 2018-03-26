CLINVAR_SIG = {}
CLINVAR_SIG["0"] = 'uncertain'
CLINVAR_SIG["1"] = 'not-provided'
CLINVAR_SIG["2"] = 'benign'
CLINVAR_SIG["3"] = 'likely-benign'
CLINVAR_SIG["4"] = 'likely-pathogenic'
CLINVAR_SIG["5"] = 'pathogenic'
CLINVAR_SIG["6"] = 'drug-response'
CLINVAR_SIG["7"] = 'histocompatibility'
CLINVAR_SIG["255"] = 'other'
CLINVAR_SIG["."] = '.'

function contains(str, tok)
	return string.find(str, tok) ~= nil
end

function intotbl(ud)
	local tbl = {}
	for i=1,#ud do
		tbl[i] = ud[i]
	end
	return tbl
end

function clinvar_sig(vals)
    local t = type(vals)
    -- just a single-value
    if(t == "string" or t == "number") and not contains(vals, "|") then
        return CLINVAR_SIG[vals]
    elseif t ~= "table" then
		if not contains(t, "userdata") then
			vals = {vals}
		else
			vals = intotbl(vals)
		end
    end
    local ret = {}
    for i=1,#vals do
        if not contains(vals[i], "|") then
            ret[#ret+1] = CLINVAR_SIG[vals[i]]
        else
            local invals = vals[i]:split("|")
            local inret = {}
            for j=1,#invals do
                inret[#inret+1] = CLINVAR_SIG[invals[j]]
            end
            ret[#ret+1] = join(inret, "|")
        end
    end
    return join(ret, ",")
end

join = table.concat

function check_clinvar_aaf(clinvar_sig, max_aaf_all, aaf_cutoff)
    -- didn't find an aaf for this so can't be common
    if max_aaf_all == nil or clinvar_sig == nil then
        return false
    end
    if type(clinvar_sig) ~= "string" then
        clinvar_sig = join(clinvar_sig, ",")
    end
    if false == contains(clinvar_sig, "pathogenic") then
        return false
    end
    if type(max_aaf_all) ~= "table" then
        return max_aaf_all > aaf_cutoff
    end
    for i, aaf in pairs(max_aaf_all) do
        if aaf > aaf_cutoff then
            return true
        end
    end
    return false
end

function div(a, b)
	if(a == 0) then return "0.0" end
	return string.format("%.9f", a / b)
end
