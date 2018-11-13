local mi = MI_Globals                -- Title, Version, Author, Description[1], Description[2]
local DigKal = DigsitesKalimdor      -- "Name", "Location", "Zone", "Type"
local DigEK = DigsitesEasternKingdoms
local DigOut = DigsitesOutland
local DigNorth = DigsitesNorthrend
local DigPan = DigsitesPandaria
local DigDra = DigsitesDraenor
local DigBro = DigsitesBrokenIsles
local DigKul = DigsitesKulTiras
local DigZan = DigsitesZandalar
local mapdt = MapData                -- uiMapID, "Map Name", Left, Right, Top, Bottom, "Map Type", "Parent Map", "Description"

local frame, events = CreateFrame("Frame"), {}
MapInfoData01 = {}

function logmap()
-- write in-game map data to file, the data is in MapTable.lua
	tinsert(MapInfoData01,"uiMapID, Map Name, Left, Right, Top, Bottom")
	TableWrite(1, 210 )	TableWrite(213, 213 )
	TableWrite(217, 277 ) TableWrite(279, 325 )
	TableWrite(327, 483 ) TableWrite(486, 582 )
	TableWrite(585, 590 ) TableWrite(593, 602 )
	TableWrite(606, 624 ) TableWrite(626, 721 ) 
	TableWrite(723, 723 ) TableWrite(725, 726 ) 
	TableWrite(728, 729 ) TableWrite(731, 877 ) 
	TableWrite(879, 904 ) TableWrite(906, 936 )
	TableWrite(938, 943 ) TableWrite(947, 947 )
	TableWrite(971, 981 ) TableWrite(998, 998 )
	TableWrite(1004, 1004 ) TableWrite(1009, 1010 )
	TableWrite(1012, 1013 ) TableWrite(1015, 1018 )
	TableWrite(1021, 1021 ) TableWrite(1029, 1031 )
	TableWrite(1038, 1040 ) TableWrite(1042, 1045 )
	TableWrite(1148, 1157 ) TableWrite(1159, 1167 )
	TableWrite(1169, 1169 ) TableWrite(1176, 1177 )
	TableWrite(1179, 1198 )
end

function TableWrite(firstid,lastid)
-- write in-game map data to file, the data is in MapTable.lua
	for id = firstid, lastid do
		local v0, v5 = CreateVector2D(0, 0), CreateVector2D(0.5, 0.5) 
		local _, tL = C_Map.GetWorldPosFromMapPos(id, v0) 
		local _, bR = C_Map.GetWorldPosFromMapPos(id, v5) 
		local t, l = tL:GetXY() 
		local b, r = bR:GetXY() 
		b = t + (b - t) * 2 
		r = l + (r - l) * 2
		local nm = C_Map.GetMapInfo(id).name
		tinsert(MapInfoData01,format("%s, %s, %s, %s, %s, %s",id,nm,l,r,t,b))
	end
	print("Written ID:"..lastid)
end
	
function MapPos()
-- position of the player on the current map
	local uiMap = C_Map.GetBestMapForUnit("player") 
	local nm = C_Map.GetMapInfo(uiMap).name 
	local x,y = C_Map.GetPlayerMapPosition(uiMap,"player"):GetXY() 
	print(100*x,100*y, uiMap)
	return 100*x, 100*y, uiMap
end

function WrldPos()
-- position of the player in world coordinates. z is zero.
	local y, x, z, instanceID = UnitPosition("player") 
	print(x, y, instanceID) 
	return x, y, instanceID
end

function WorldfromMap(x,y,uiMap)
-- calculate world coordinates from map coordinates
	local a = x / 100
	local b = y / 100
	local v0 = CreateVector2D(a, b)
	local continID, tL = C_Map.GetWorldPosFromMapPos(uiMap, v0) 
	local c, d = tL:GetXY() 
	local nm = C_Map.GetMapInfo(uiMap).name
	return c, d, continID
end

function Compare(a,b)
-- compare if two strings are equal
    local n = 0
	for x = 1, a:len() do
		if string.byte(a,x) == string.byte(b,x) then n = n + 1 end -- 49 <= 1  48 <= 0
	end
	if n > a:len()-3 then return true end
end

function FindSiteWorld(Dig,Arr)
-- find a digsite name in the given array from digsites.lua
-- return race (Troll, Night Elf ..)and zonename
	local retV, Zne     
	for i = 1, #Arr do
		if Compare(Arr[i][1],Dig) then retV = Arr[i][4] Zne = Arr[i][3] end
	end
	return retV, Zne
end

function ZoneName(uiMapID)
-- find the corresponding name to a map ID
	local Zone
	for i = 1, #mapdt do
		if mapdt[i][1] == uiMapID then Zone = mapdt[i][2] end
	end
	return Zone
end

function Children(continent)
-- enumerate the map children of a continent
	local Maps = {}
	local Zones = {}
	k = 1
	for i = 1, #mapdt do
		if mapdt[i][8] == continent and mapdt[i][7] == "Zone" then Zones[k] = mapdt[i][2] Maps[k] = mapdt[i][1] k = k + 1 end
	end
	return Maps,Zones
end

function FindZoneWorld(Zn,Continent)
-- give map info from a zone
	local Left, Right, Top, Bottom, uiMapID
	for i = 1, #mapdt do
		if Compare(mapdt[i][2],Zn) and mapdt[i][7] == "Zone" and mapdt[i][8] == Continent then Left = mapdt[i][3] Right = mapdt[i][4] Top = mapdt[i][5] Bottom = mapdt[i][6] uiMapID = mapdt[i][1] end
	end
	return Left, Right, Top, Bottom, uiMapID
end

function WorldToMap(x, y, Left, Right, Top, Bottom, uiMapID)
--transform left to 0 and right to 100
	local map_x = (x - Left) * 100 / (Right - Left)
--transform top to 0 and bottom to 100
	local map_y = (y - Top) * 100 / (Bottom - Top)
	return map_x, map_y, uiMapID
end

function Unique(Ar)
-- test make a unique array from local Ar = {1,2,4,2,3,4,2,3,4,"A", "B", "A"}
	local Ar2 = {}
	local k = 1
	local flags = {} 
	for i = 1,#Ar do 
		if not(flags[Ar[i]]) then 
			--print(" "..Ar[i]) 
			flags[Ar[i]] = true 
			Ar2[k] = Ar[i] 
			k = k + 1
		end 
	end
	return(Ar2)
end

function WorldDigSites2(continent)
-- list active archeology digsites
	local Ar = {}
	local Map = {}
	if continent == "Kalimdor" then Ar = DigKal ContinentNumber = 12
	elseif continent == "Eastern Kingdoms" then Ar=DigEK ContinentNumber = 13
	elseif continent == "Outland" then Ar=DigOut ContinentNumber = 101
	elseif continent == "Northrend" then Ar=DigNorth ContinentNumber = 113
	elseif continent == "Pandaria" then Ar=DigPan ContinentNumber = 424
	elseif continent == "Draenor" then Ar=DigDra ContinentNumber = 572
	elseif continent == "Broken Isles" then Ar=DigBro ContinentNumber = 619
	elseif continent == "Kul Tiras" then Ar=DigKul ContinentNumber = 876
	elseif continent == "Zandalar" then Ar=DigZan ContinentNumber = 875
	else return
	end
	print("Digsites on "..continent)
	Map,Zn = Children(continent)
	-- print(#Map,#Zn)
	for i = 1,#Map do
		-- print("Map nr: ", i,#Map,Map[i],Zn[i])   
		local td2 = C_ResearchInfo.GetDigSitesForMap(Map[i]) 
		-- print("Map nr: ", i," ",Zn[i],"Digsites for this map: ", #td2)
		for j = 1, #td2 do  
			-- print("Digsite", j, " of ",#td2)
			local nam=td2[j].name
			local mapx,mapy=td2[j].position:GetXY()  -- Map position on Zone Map
			local r,ResearchZone = FindSiteWorld(nam, Ar)
			--print(Zn[i],ResearchZone)
			if Compare(Zn[i],ResearchZone) then
				DEFAULT_CHAT_FRAME:AddMessage(format("%s - %s, %s: %.1f, %.1f", r, nam, Zn[i], mapx*100, mapy*100))	
			end
		end
	end
end

SLASH_MAPINFO1 = "/digsite"
SLASH_MAPINFO2 = "/dig"

SlashCmdList["MAPINFO"] = function(msg)
	local cmd = msg
	if cmd == "Kalimdor" then WorldDigSites2("Kalimdor")
	elseif cmd == "Eastern Kingdoms" then WorldDigSites2("Eastern Kingdoms")
	elseif cmd == "Outland" then WorldDigSites2("Outland")
	elseif cmd == "Northrend" then WorldDigSites2("Northrend")
	elseif cmd == "Pandaria" then WorldDigSites2("Pandaria")
	elseif cmd == "Draenor" then WorldDigSites2("Draenor")
	elseif cmd == "Broken Isles" then WorldDigSites2("Broken Isles")
	elseif cmd == "Kul Tiras" then WorldDigSites2("Kul Tiras")
	elseif cmd == "Zandalar" then WorldDigSites2("Zandalar")
	else
		print("/digsite /dig") 
		print("gives a listing of active digsites in the specified continent. The list includes TomTom location and Race (Troll, Dwarf, ..)")
		print("usage: /dig [ Kalimdor || Eastern Kingdoms || Outland || Northrend || Pandaria || Draenor || Broken Isles || Kul Tiras || Zandalar ] ")
		print("Example: /dig Kalimdor")
	end
end