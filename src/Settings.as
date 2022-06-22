int screenOffset = 0;

[Setting category="General" name="Enabled" description="Please change the settings in the \"Script\" tab. Below are the raw values."]
bool enabled = true;

[Setting category="General" name="Color"]
vec4 Setting_Color = vec4(0, 0, 0, 1.f);

[Setting category="General" name="Size"]
vec2 Setting_Size = vec2(40, 0);

[Setting category="General" name="Order"]
int Setting_Order = -999;

dictionary orderList = {
	{"Lowest", -999},
	{"Records UI", -3},
	{"Game UI", -2},
	{"Middle", 1},
	{"Other UI", 70},
	{"Menu UI", 76},
	{"Highest", 999}
};

string GetCurrentOrder()
{
	string[] keys = orderList.GetKeys();
	for (uint i = 0; i < keys.Length; i++) {
		if (int(orderList[keys[i]]) == Setting_Order) {
			return keys[i];
		}
	}
	return "Custom";
}

void RenderMenu()
{
	if (UI::MenuItem("\\$9f3" + Icons::WindowMaximize + "\\$z Borders", "", enabled))
		enabled = !enabled;
}

// We have to implement our own Settings window because regular settings don't support dynamic slider range
void RenderSettings()
{
	auto window = cast<CSystemWindow>(GetApp().Viewport.SystemWindow);

	// Checking window aspect ratio to automatically adjust position and width offset
	if (window.Ratio > 1.77778)
		screenOffset = int(Math::Ceil(((window.SizeX / (window.SizeY / 9.f)) * 10.f) - 160.f));
	else if (screenOffset > 0)
		screenOffset = 0;

	vec3 colorVec3 = UI::InputColor3("Color", vec3(Setting_Color.x, Setting_Color.y, Setting_Color.z));
	float colorOpacity = UI::SliderFloat("Opacity", Setting_Color.w, 0.f, 1.f);

	Setting_Color = vec4(colorVec3.x, colorVec3.y, colorVec3.z, colorOpacity);
	Setting_Size.x = UI::SliderInt("Width", int(Setting_Size.x), 0, 160 + screenOffset);
	Setting_Size.y = UI::SliderInt("Height", int(Setting_Size.y), 0, 90);

	if (UI::BeginCombo("Order", GetCurrentOrder())) {
		string[] keys = orderList.GetKeys();
		for (uint i = 0; i < keys.Length; i++) {
			if (UI::Selectable(keys[i], false)) {
				Setting_Order = int(orderList[keys[i]]);
			}
		}
		UI::EndCombo();
	}
	
	// Applying settings immediately when settings are open
	OnSettingsChanged();
}

void OnSettingsChanged()
{
	if (overlay !is null && enabled) {
		overlay.ApplySettings();
	}
}

void OnDisabled()
{
	if (playgroundTM !is null) {
		DestroyLayer();
	}
}