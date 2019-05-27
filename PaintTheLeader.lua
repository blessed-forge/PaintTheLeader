PTLeader=
{
	TimeLeft = 0;																				-- Variable zur Update/Zeitmessung
	Time = 0;																					-- Variable Interne Uhr
	oldLeader = 0;																				-- Variable Interne Uhr
	newLeader = 0;																				-- Variable Interne Uhr
	curLeader = nil;
}

----------------------------------------------------------------------------------------------
-- Allgemeine Initalisierung von Variablen, Arrays usw.										--
----------------------------------------------------------------------------------------------
function PTLeader.OnInitialize()
	if not PTLeader.save then																	-- Save Variablen noch nicht angelegt ?
		PTLeader.save = {}																		-- Variable Dimensionieren
		PTLeader.save.active = true																-- Addon Standard Eingeschaltet
		PTLeader.save.noself = false															-- Automatik Standard Aus
		PTLeader.save.scale = 1.0																-- Automatik Standard Aus
		PTLeader.save.Privat = "noop"															-- Keine Aktion
	end
	RegisterEventHandler (SystemData.Events.INTERFACE_RELOADED,"PTLeader.OnReloadUI")			-- Event f�r ReloadUI registrieren
  RegisterEventHandler (SystemData.Events.BATTLEGROUP_UPDATED,"PTLeader.onWarbandChange")		-- Event f�r BattleGroup registrieren
	RegisterEventHandler (SystemData.Events.LOADING_END,"PTLeader.OnReloadUI");					-- Event f�r LOADING_END registrieren
  CreateWindow("PTL_Window", false)
	EA_ChatWindow.Print(L"PTLeader Addon ist jetzt geladen. Slash: /ptl");						-- Begr��ungstext wird hier in den Chat geschrieben.
	PTLeader.SlashOnInit()																		-- Internen SlashHandler initalisieren
end   
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Die Funktion PTLeader.OnShutdown wird beim Spiel beenden oder ausloggen ausgef�hrt. Wir	--
-- unregistrieren hier nur die Eventhandler. Und das auch nur weil's sch�n ordentlich ist :)--
----------------------------------------------------------------------------------------------
function PTLeader.OnShutdown()
	UnregisterEventHandler (SystemData.Events.INTERFACE_RELOADED,"PTLeader.OnReloadUI")			-- Event f�r ReloadUI l�schen
    UnregisterEventHandler (SystemData.Events.BATTLEGROUP_UPDATED,"PTLeader.onWarbandChange")	-- Event f�r BattleGroup l�schen
	UnregisterEventHandler (SystemData.Events.LOADING_END,"PTLeader.OnReloadUI");				-- Event f�r LOADING_END l�schen
end   
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Sobald sich irgendetwas im Schlachtzug tut, wie Gruppen verschieben, Lebensanzeige etc 	--
-- wird dieses Update event ausgef�hrt. Hier schauen wir dann wer zZ unser Leader ist		--
----------------------------------------------------------------------------------------------
function PTLeader.onWarbandChange()
  local NewID
  if (IsWarBandActive()) then
    NewID = PTLeader.getWarbandLeader()	-- 
    if not PTLeader.save.active then -- Addon aus ?
      NewID = 0
    end;
    if PTLeader.save.noself and (NewID == GameData.Player.worldObjNum) then 		-- Automatik an, und ich bin Leader ?
      NewID = 0
    end
  else 
    NewID = PTLeader.getGroupLeader()
  end
	if NewID then
		PTLeader.SetMarkerWindowII(NewID)
	end
end
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- Sobald sich irgendetwas im Schlachtzug tut, wie Gruppen verschieben, Lebensanzeige etc 	--
-- wird dieses Update event ausgef�hrt. Hier schauen wir dann wer zZ unser Leader ist		--
----------------------------------------------------------------------------------------------
function PTLeader.getWarbandLeader()
	local warband = GetBattlegroupMemberData()													-- Array mit den Daten der Gruppen auslesen
	local MyID = nil
	local LeaderID = nil
	for k,v in ipairs(warband) do																-- Schleife bilden, um die Gruppen auszulesen
		for l,z in ipairs(v.players) do															-- Schleife um die einzelnen Mitglieder der Gruppe zu durchsuchen
			if z.isGroupLeader == true then														-- Ist das Gruppenmmitglied Leader ?
				--DebugText(L"Found Leader")
				LeaderID = z.worldObjNum															-- ja, ist es, also Merken.
			end    
			if z.worldObjNum == GameData.Player.worldObjNum then														-- Ist das Gruppenmmitglied Leader ?
				--DebugText(L"Found Me")
				MyID = z.worldObjNum															-- ja, ist es, also Merken.
			end    
		end
	end
	if LeaderID and MyID then
		return LeaderID
	end
	return 0																					-- Kein Leader in der Warband gefunden. (keine Warband!)
end
----------------------------------------------------------------------------------------------

function PTLeader.getGroupLeader()
  local group = GetGroupData()
  local LeaderID = nil
  for k,v in ipairs(group) do
    if (v.isMainAssist == true) then
      LeaderID = v.worldObjNum
    end
  end
  return LeaderID
end
----------------------------------------------------------------------------------------------
-- Die StandartUpdate Funktion. Hier mal ohne Funktion :) Wir steuern alles �ber Events. 	--
-- Ist aber immer gut zur Fehlersuche, darum lasse ich sie hier drinn.						--
----------------------------------------------------------------------------------------------
function PTLeader.OnUpdate(elapsedTime)
	-- ADDONBREMSE -------------------------------------------------
	PTLeader.TimeLeft = PTLeader.TimeLeft - elapsedTime											-- vergangene Zeit (elapsedTime) abziehen
    if PTLeader.TimeLeft > 0 then return; end;													-- Solange PTLeader.TimeLeft �ber 0 ist, abbrechen
	PTLeader.TimeLeft = 5.0																		-- Zeit wieder auf 3 Sekunden Setzen, und Update durchf�hren
	-- ADDONBREMSE -------------------------------------------------
	PTLeader.onWarbandChange()
	if PTLeader.curLeader and PTLeader.curLeader == GameData.Player.worldObjNum then
		if PTLeader.save.Privat == "noop" then
			-- noop
		elseif PTLeader.save.Privat == "public" then
			SystemData.UserInput.ChatText = L"/warbandconvert 1"
			BroadcastEvent( SystemData.Events.SEND_CHAT_TEXT )
		elseif PTLeader.save.Privat == "privat" then
			SystemData.UserInput.ChatText = L"/warbandconvert 0"
			BroadcastEvent( SystemData.Events.SEND_CHAT_TEXT )
		end
	end
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Diese �u�erst komplizierte und verschachtelte Funktion kann mit vorhergehender 			--
-- Kausalit�tspr�fung ein Fenster schlie�en. Ja echt krass, hier geht ein Fenster zu! :D	--
----------------------------------------------------------------------------------------------
function PTLeader.SetMarkerWindowII(NewID)
	if NewID == 0 then																			--Leader l�schen
		if PTLeader.curLeader then 																-- Falls wir ein Fenster haben, l�schen
			--DebugText(L"[PTL]l�sche Ankerung")
			--DebugText(PTLeader.curLeader)
			DetachWindowFromWorldObject("PTL_Window", PTLeader.curLeader) 						-- Fenster vom alten Leader l�sen
			PTLeader.curLeader = nil
		end
		--DebugText(L"[PTL] verstecke Window")
		WindowSetShowing("PTL_Window", false)													-- dann schlie�en
	elseif not PTLeader.curLeader then 															-- Erster Aufruf, noch kein Fenster.
		PTLeader.curLeader = NewID
		--DebugText(L"[PTL]Erste Ankerung an Leader")
		--DebugText(PTLeader.curLeader)
	    AttachWindowToWorldObject("PTL_Window", PTLeader.curLeader)
		WindowSetShowing("PTL_Window", true)													-- dann schlie�en
	elseif PTLeader.curLeader ~= NewID then 													-- Leader wechselt
		DetachWindowFromWorldObject("PTL_Window", PTLeader.curLeader) 							-- Fenster vom alten Leader l�sen
		PTLeader.curLeader = NewID
		--DebugText(L"[PTL]erneute Ankerung an Leader")
		--DebugText(PTLeader.curLeader)
	    AttachWindowToWorldObject("PTL_Window", PTLeader.curLeader)
		WindowSetShowing("PTL_Window", true)													-- dann schlie�en
	end
end

----------------------------------------------------------------------------------------------
-- Nach einem ReloadUI wird hier daf�r gesorgt, das unser symbol wieder am Leader			--
-- verankert wird.																			--
----------------------------------------------------------------------------------------------
function PTLeader.OnReloadUI()
	PTLeader.SetMarkerWindowII(0)																-- Fenster l�schen
	PTLeader.onWarbandChange()																	-- Alles neu initalisieren.
end



