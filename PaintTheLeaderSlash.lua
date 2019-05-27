----------------------------------------------------------------------------------------------
-- Allgemeine Initalisierung von Variablen, Arrays usw.										--
----------------------------------------------------------------------------------------------
function PTLeader.SlashOnInit()
    PTLOriginal_OnKeyEnter = EA_ChatWindow.OnKeyEnter											-- Den original Händler Speichern
    EA_ChatWindow.OnKeyEnter = PTL_OnKeyEnter													-- Original Händler durch eigenen ersetzen.
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- EA_ChatWindow.OnKeyEnter Umleitung. Hier kommt das an, was in die Chatbox geschrieben 	--
-- und [ENTER] gedrückt wurde. Hier fangen wir alles ab, was nicht gesendet werden soll.	--
----------------------------------------------------------------------------------------------
function PTL_OnKeyEnter(...)
	local ChatText = EA_TextEntryGroupEntryBoxTextInput.Text									-- ChatText auslesen
    local Befehl																				-- Slashbefehle werden hier gespeichert
	local Args																					-- Argumente, falls es welche gibt.
    local Befehl, Args = ChatText:match(L"^/([a-zA-Z0-9]+)[ ]?(.*)")							-- Befehle und Argumente trennen.
	if Befehl == L"ptl" or Befehl == L"PTL" then												-- SlashBefehl /PTL gefunden ?
		PTL_SlashBoy(Args)																		-- Slashbefehle auswerten
	    EA_TextEntryGroupEntryBoxTextInput.Text = L""											-- Chat Löschen, /PTL Commando wird ausgeführt.
	end
    PTLOriginal_OnKeyEnter(...)																	-- Original Händler ausführen
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Aurgumente des /PTL Slashcommands auswerten											 	--
-- 																							--
----------------------------------------------------------------------------------------------
function PTL_SlashBoy(Args)
	if Args == L"on" or  Args == L"an" then														-- Befehl on/an
		PTLeader.save.active = true																-- Addon Flag einschalten
		PTLeader.save.noself = false															-- Addon Flag automatik
		PTLeader.onWarbandChange()																-- Initalisierung durchführen
		EA_ChatWindow.Print(L"PaintTheLeader an")												-- Chatausgabe
	elseif Args == L"off" or  Args == L"aus" then												-- Befehl off/aus
		PTLeader.save.active = false															-- Addon Flag ausschalten
		PTLeader.onWarbandChange()																-- Initalisierung durchführen
		EA_ChatWindow.Print(L"PaintTheLeader aus")												-- Chatausgabe
	elseif Args == L"noself" then																-- Befehl automatik
		PTLeader.save.active = true																-- Addon Flag einschalten
		PTLeader.save.noself = true																-- Addon Flag automatik
		PTLeader.onWarbandChange()																-- Initalisierung durchführen
		EA_ChatWindow.Print(L"PaintTheLeader automatik")										-- Chatausgabe
	elseif Args == L"lock" then																	-- Befehl lock
		EA_ChatWindow.Print(L"PaintTheLeader Fenster fixiert")									-- Chatausgabe
	elseif Args == L"unlock" then																-- Befehl unlock
		EA_ChatWindow.Print(L"PaintTheLeader Fenster verschiebbar")								-- Chatausgabe
	elseif Args == L"update" then																-- Befehl Update
		PTLeader.SetMarkerWindowII(0)															-- Update durchführen
	else																						-- Ab hier kommen Befehle mit Parameterangabe
		local Befehl, arg = Args:match(L"^([a-zA-Z0-9]+)[ ]?(.*)")								-- Parameter und Befehl trennen
		if Befehl == L"scale" then																-- Befehl scale
			PTLeader.save.scale = tonumber(arg)/100												-- 100% zu Faktor 1 dividieren
			PTLeader.SetMarkerWindowII(0)
			WindowSetScale( "PTL_Window", PTLeader.save.scale )									-- Fenstergröße ändern. zB 0.2 = 20% 
			EA_ChatWindow.Print(L"Symbolgröße auf "..arg..L"% geändert.")						-- Chatausgabe
		elseif Befehl == L"spam" then
			if arg == L"privat" or arg == L"pr" then
				PTLeader.save.Privat = "privat"
				EA_ChatWindow.Print(L"Broadcast privat")										-- Chatausgabe
			elseif arg == L"public" or arg == L"pu" then
				PTLeader.save.Privat = "public"
				EA_ChatWindow.Print(L"Broadcast public")										-- Chatausgabe
			else
				PTLeader.save.Privat = "noop"
				EA_ChatWindow.Print(L"Broadcast aus")											-- Chatausgabe
			end
		else																					-- Keine Befehle mehr gefunden. HilfeText ausgeben
			EA_ChatWindow.Print(L"PaintTheLeader Slashbefehle:")								-- Chatausgabe Hilfetext
			EA_ChatWindow.Print(L"/PTL on - Schaltet das Addon ein")							-- Chatausgabe Hilfetext
			EA_ChatWindow.Print(L"/PTL off - Schaltet das Addon aus")							-- Chatausgabe Hilfetext
			EA_ChatWindow.Print(L"/PTL noself - kein Symbol auf mir selber.")					-- Chatausgabe Hilfetext
			EA_ChatWindow.Print(L"/PTL scale 100 - Symbolgröße in %")							-- Chatausgabe Hilfetext
			EA_ChatWindow.Print(L"/PTL spam privat - Spaming SetGroupPrivat")					-- Chatausgabe Hilfetext
			EA_ChatWindow.Print(L"/PTL spam public - Spaming SetGroupPublic")					-- Chatausgabe Hilfetext
			EA_ChatWindow.Print(L"/PTL spam off - Spaming off")									-- Chatausgabe Hilfetext
			EA_ChatWindow.Print(L"(active="..towstring (booltostring (PTLeader.save.active))..L" noself="..towstring (booltostring (PTLeader.save.noself))..L" scale="..(PTLeader.save.scale*100)..L"%)")
			EA_ChatWindow.Print(L"(Broadcast="..towstring(PTLeader.save.Privat)..L")")
		end
	end
end
----------------------------------------------------------------------------------------------
