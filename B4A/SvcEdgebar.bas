B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: True
	'#StartCommandReturnValue: android.app.Service.START_STICKY
#End Region

Sub Process_Globals
	Dim OverlayEdge As OverlayWindow
'	Dim InitialPosX, InitialPosY As Int
'	Dim Notif As Notification
	Dim EdgeWidth As Int = 25
End Sub

Sub Service_Create
'	'Creates a notification
'	Notif.Initialize
'	Notif.Icon = "icon"
'	Notif.OnGoingEvent = True
'	Notif.Sound = False
'	Notif.Vibrate = False
'	Notif.SetInfo("Press to show the main window.", "", Main)
'
'	'Brings the current service to the foreground state and displays the notification
'	Service.StartForeground(1, Notif)
	InitWindow
End Sub

Sub Service_Start (StartingIntent As Intent)
	
End Sub

Sub Service_Destroy

	'Closes the window
	If OverlayEdge.IsInitialized Then
		OverlayEdge.Close
	End If
	
End Sub

Sub InitWindow
	'Creates the overlay window
	Dim MaxHeight As Int = GetDeviceLayoutValues.Height
	OverlayEdge.Initialize2(0, MaxHeight / 3, EdgeWidth, MaxHeight / 4, "OverlayEdge")
	Dim Pnl As Panel = OverlayEdge.Panel
		Pnl.Color = Colors.ARGB(160, 50, 50, 50)

'	Dim pnlBackground As Panel
'		pnlBackground.Initialize("")
''		pnlBackground.RemoveAllViews
''		pnlBackground.LoadLayout("EdgePanel")
'	Pnl.AddView(pnlBackground, 0, 0, -1, 130dip)
	
End Sub

Sub ShowWindow
	If Not(OverlayEdge.IsInitialized) Then
		InitWindow
	End If
	If Not(OverlayEdge.IsOpen) Then
		OverlayEdge.Open
		OverlayEdge.TouchMode = OverlayEdge.TOUCH_INSIDE
	End If
	OverlayEdge.Visible = True
End Sub

Sub OverlayEdge_Touch(Action As Int, X As Float, Y As Float, ScreenX As Float, ScreenY As Float)
	Starter.MyLog("Event: OverlayEdge_Touch => " & Action)
	
	If (Action = 0) Then
		XUIViewsUtils.PerformHapticFeedback(Sender)
		
	Else If (Action = 1) Then
'		If Not (B4XPages.MainPage.Drawer.LeftOpen) Then
'			B4XPages.MainPage.OpenEdge(True)
'			
''			Dim p As Panel
''				p.Initialize("")
''				'p.LoadLayout("EdgePanel")
''				p.Top = 300dip
''				p.Left = 300dip
''				p.Height = 1000dip
''				p.Width = 600dip
''				p.Color = Colors.Red
''				p.Visible = True
'			
'			LogColor("Edgebar SVC Touch", Colors.Red)
'		Else
'			B4XPages.MainPage.OpenEdge(False)
'		End If
	End If
	
	
	'//-- Move Window
'	If Action = 0 Then 'DOWN
'		InitialPosX = ScreenX - OverlayEdge.X
'		InitialPosY = ScreenY - OverlayEdge.Y
'	Else If Action = 2 Then 'MOVE
'		'Moves the window
'		OverlayEdge.SetPosition(ScreenX - InitialPosX, ScreenY - InitialPosY)
'	End If
End Sub
