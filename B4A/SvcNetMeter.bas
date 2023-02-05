B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	'#StartCommandReturnValue: android.app.Service.START_STICKY
#End Region

Sub Process_Globals
	Dim OW As OverlayWindow
	Dim MaxWidth As Int
	Dim InitialPosX, InitialPosY As Int
	Dim Timer_Svc As Timer
'	Dim C As Cache
	Dim SB As StringBuilder
	Dim Notif As Notification
End Sub

Sub Service_Create
	'Creates a notification
	Notif.Initialize
	Notif.Icon = "icon"
	Notif.OnGoingEvent = True
	Notif.Sound = False
	Notif.Vibrate = False
	Notif.SetInfo("Press to show the main activity", "", Main)

	'Brings the current service to the foreground state and displays the notification
	Service.StartForeground(1, Notif)
End Sub

Sub Service_Start (StartingIntent As Intent)
	'The timer is used to refresh the information every second
	Timer_Svc.Initialize("TimerSvc", 1000)
	Timer_Svc.Enabled = True
End Sub

Sub Service_Destroy
	'Stops the timer
	Timer_Svc.Enabled = False

	'Closes the window
	If OW.IsInitialized Then
		OW.Close
	End If
End Sub

Sub InitWindow
	'Creates the overlay window
	MaxWidth = GetDeviceLayoutValues.Width
	OW.Initialize2(10dip, 10dip, MaxWidth / 2, 60dip, "Pnl")
	Dim Pnl As Panel = OW.Panel
		Pnl.Color = Colors.ARGB(160, 50, 50, 50)

	'Creates the window layout (two labels and two panels)
	Dim lblDateTime As Label
		lblDateTime.Initialize("")
		lblDateTime.TextColor = Colors.White
	Pnl.AddView(lblDateTime, 0, 0, -1, 20dip)

	Dim lblFreeMem As Label
		lblFreeMem.Initialize("")
		lblFreeMem.TextColor = Colors.White
	Pnl.AddView(lblFreeMem, 0, 20dip, -1, 20dip)

	Dim pnlBackground As Panel
		pnlBackground.Initialize("")
		pnlBackground.Color = Colors.Green
	Pnl.AddView(pnlBackground, 0, 47dip, -1, 13dip)

	Dim pnlProgression As Panel
		pnlProgression.Initialize("")
		pnlProgression.Color = Colors.Red
	Pnl.AddView(pnlProgression, 0, 47dip, 50dip, 13dip)

	'Initializes the information (date/time and free memory)
	Dim Ticks As Long = DateTime.Now
	lblDateTime.Text = DateTime.Date(Ticks) & "  " & DateTime.Time(Ticks)
	SB.Initialize
	SB.Append("Free mem: 0").Append(" Kb")
	lblFreeMem.Text = SB.ToString
	pnlProgression.Width = (MaxWidth / 2)
End Sub

Sub ShowWindow
	If Not(OW.IsInitialized) Then
		InitWindow
	End If
	If Not(OW.IsOpen) Then
		OW.Open
	End If
	OW.Visible = True
End Sub

Sub TimerSvc_Tick
	'Ensures that the window is visible
	ShowWindow

	'Refreshes the date and time
	Dim Ticks As Long = DateTime.Now
	Dim lblDateTime As Label = OW.Panel.GetView(0)
	lblDateTime.Text = DateTime.Date(Ticks) & "  " & DateTime.Time(Ticks)

	'Refreshes the free memory amount
	Dim lblFreeMem As Label = OW.Panel.GetView(1)
	SB.Initialize
	SB.Append("Free mem: 0").Append(" Kb")
	lblFreeMem.Text = SB.ToString
	Dim pnlProgression As Panel = OW.Panel.GetView(3)
	Dim NewWidth As Int = (MaxWidth / 2)
	If pnlProgression.Width <> NewWidth Then
		pnlProgression.Width = NewWidth
	End If
End Sub

Sub Pnl_Touch(Action As Int, X As Float, Y As Float, ScreenX As Float, ScreenY As Float)
	'Log(Action & " " & X & "," & Y & " " & ScreenX & "," & ScreenY)
	If Action = 0 Then 'DOWN
		InitialPosX = ScreenX - OW.X
		InitialPosY = ScreenY - OW.Y
	Else If Action = 2 Then 'MOVE
		'Moves the window
		OW.SetPosition(ScreenX - InitialPosX, ScreenY - InitialPosY)
	End If
End Sub
