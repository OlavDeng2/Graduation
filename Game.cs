using Godot;
using System;

public class Game : Spatial
{
	public override void _Ready()
	{
		var vr = ARVRServer.FindInterface("OpenVR");
		if (vr != null && vr.Initialize())
		{
			GetViewport().Arvr = true;
			GetViewport().Hdr = false;

			OS.VsyncEnabled = false;
			Engine.TargetFps = 90;
			// Also, the physics FPS in the project settings is also 90 FPS. This makes the physics
			// run at the same frame rate as the display, which makes things look smoother in VR!
		}
	}
}
