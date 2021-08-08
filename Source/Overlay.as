wstring[] borders;

class BordersOverlay {
	BordersOverlay(CGameUILayer@ layer)
	{	
		int counter = 0;

		while (counter < 4) {
			yield();

			auto localPage = cast<CGameManialinkPage>(layer.LocalPage);
			if (localPage is null) {
				continue;
			}
			
			auto border = cast<CGameManialinkQuad>(localPage.GetFirstChild("" + (counter + 1)));
			if (border is null) {
				continue;
			}

			borders.InsertLast(border);
			counter++;
		}

		ApplySettings();
	}
	
	void ApplySettings()
	{	
		borders[0].Size = vec2(Setting_Size.x, 180);
		borders[0].RelativePosition_V3 = vec2(-160 - screenOffset, 0);

		borders[1].Size = vec2(Setting_Size.x, 180);
		borders[1].RelativePosition_V3 = vec2(160 + screenOffset, 0);

		borders[2].Size = vec2(320 + (screenOffset * 2) - (Setting_Size.x * 2), Setting_Size.y);
		borders[2].RelativePosition_V3 = vec2(0, -90);

		borders[3].Size = vec2(320 + (screenOffset * 2) - (Setting_Size.x * 2), Setting_Size.y);
		borders[3].RelativePosition_V3 = vec2(0, 90);
		
		for (uint i = 0; i < borders.Length; i++) {
			borders[i].Visible = isVisible;
			borders[i].BgColor = vec3(Setting_Color.x, Setting_Color.y, Setting_Color.z);
			borders[i].Opacity = Setting_Color.w;
			borders[i].ZIndex = Setting_Order;
		}
	}
	
	bool visibility
	{
		get {
			return isVisible;
		}
		set {
			isVisible = value;
			ApplySettings();
		}
	}

	private bool isVisible = false;
	private CGameManialinkQuad@[] borders;
}