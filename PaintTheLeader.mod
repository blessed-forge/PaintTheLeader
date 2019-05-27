<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<UiMod name="Paint the leader" version="1.09" date="20/02/2009" >
		<Author name="Archivar" email="Archivar@ZwergenTeam.de" />
		<Description text="Shows a Icon over the raid leader's character." />
		<Dependencies>
			<Dependency name="EA_ChatWindow" />
		</Dependencies>
		<SavedVariables>
			<SavedVariable name="PTLeader.save" />
		</SavedVariables>
		<Files>
			<File name="PaintTheLeader.xml" />
		</Files>
		<OnInitialize>
			<CallFunction name="PTLeader.OnInitialize" />
		</OnInitialize>
		<OnShutdown>
			<CallFunction name="PTLeader.OnShutdown" />
		</OnShutdown>
		<OnUpdate>
			<CallFunction name="PTLeader.OnUpdate" />
		</OnUpdate>
	</UiMod>

</ModuleFile>

