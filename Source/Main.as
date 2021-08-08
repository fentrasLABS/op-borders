bool created = false;
bool queue = false;

CGameManiaAppPlayground@ playgroundTM = null;
CSmArenaClient@ playgroundSM = null;
BordersOverlay@ overlay = null;
CGameUILayer@ ui = null;

// Create UI layer
CGameUILayer@ CreateLayer()
{
	DestroyLayer();

	auto layer = playgroundTM.UILayerCreate();
	layer.AttachId = manialinkID;
	layer.ManialinkPage = manialinkPage;
	playgroundTM.ClientUI.UILayers.Add(layer);

	return layer;
}

// Find and destroy all existing UI layers with provided ID
void DestroyLayer()
{
	for (uint i = 0; i < playgroundTM.ClientUI.UILayers.Length; ++i) {
		auto currentLayer = cast<CGameUILayer>(playgroundTM.ClientUI.UILayers[i]);
		if (currentLayer.AttachId == manialinkID) {
			playgroundTM.UILayerDestroy(currentLayer);
			// Remove pointer, otherwise we get empty node with 0xfffffff address
			playgroundTM.ClientUI.UILayers.Remove(i);
		}
	}
}

// Overlay resets for Main() checks
void ResetOverlay(bool includePlayground = false)
{
	@overlay = null;
	@ui = null;

	if (includePlayground) {
		@playgroundTM = null;
		@playgroundSM = null;
	}
}

bool IsPlaying()
{
	// Player checks (also useful for editor)
	if (playgroundSM.GameTerminals.Length != 1) {
		return false;
	}

	// Get current player
	auto gameTerminal = playgroundSM.GameTerminals[0];

	// Sequence (MediaTracker) checks
	if (gameTerminal.UISequence_Current != CGameTerminal::ESGamePlaygroundUIConfig__EUISequence::Playing) {
		return false;
	}

	// Spectator checks
	if (gameTerminal.GUIPlayer is null) {
		return false;
	}

	// Multiplayer checks
	if (gameTerminal.ControlledPlayer.IdName != gameTerminal.GUIPlayer.IdName) {
		return false;
	}

	return true;
}

void Main()
{
	auto app = GetApp();

	while (true) {
		yield();

		if (enabled) {
			@playgroundTM = app.Network.ClientManiaAppPlayground;
			@playgroundSM = cast<CSmArenaClient>(app.CurrentPlayground);
			auto playgroundScript = app.Network.PlaygroundClientScriptAPI;

			// Basic check if layer can be created
			if (playgroundTM is null || playgroundSM is null || playgroundScript is null) {
				if (created) {
					ResetOverlay();
					// Queueing in case we are in the editor
					queue = true;
					// Using dedicated variable to avoid checking using in-game API methods
					created = false;
				}
				continue;
			}
			
			if (!created) {
				@ui = CreateLayer();
				if (ui is null) {
					continue;
				}
				
				@overlay = BordersOverlay(ui);
				if (overlay is null) {
					continue;
				}

				created = true;
			}

			// Hiding overlay instead of deleting if we are in game
			if (!overlay.visibility && IsPlaying()) {
				overlay.visibility = true;
			} else if (overlay.visibility && !IsPlaying()) {
				overlay.visibility = false;
			}
		} else if (created || queue) {
			@playgroundTM = app.Network.ClientManiaAppPlayground;
			@playgroundSM = cast<CSmArenaClient>(app.CurrentPlayground);

			// Checks if we can continue to deletion (also useful for editor)
			if (playgroundTM is null || playgroundSM is null) {
				continue;
			}

			DestroyLayer();
			// Without resetting we will have broken playground checks in Main()
			ResetOverlay(true);

			created = false;
			queue = false;
		}
	}
}