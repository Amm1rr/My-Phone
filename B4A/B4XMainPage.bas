B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#IgnoreWarnings: 20, 12, 11
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Public 	Root 						As B4XView
	Private xui 						As XUI
	Public 	panHome 					As B4XView
	Private panSetting 					As B4XView
	Private panApps 					As B4XView
	Private panAppMenuApp 				As B4XView
	Private panHRowMenuHome 			As B4XView
	Private Tabstrip1 					As TabStrip
	Private clvHome 					As CustomListView
	Public 	clvApps 					As CustomListView
	Private clvAppRowMenu 				As CustomListView
	Public 	clvHRowMenu 				As CustomListView
	Private lblClock 					As Label
	Private lblDate 					As Label
	Private lblAppTitle 				As Label
	Private lblHomeAppTitle 			As Label
	Private lblAbout 					As Label
	Private lblVersion 					As Label
	Private chkShowIcons 				As CheckBox
	Private chkShowKeyboard 			As CheckBox
	Private imgPhone 					As B4XImageView
	Private imgCamera 					As B4XImageView
	Private btnSetting 					As Button
	Private cmbPhoneSetting 			As B4XComboBox
	Private cmbCameraSetting 			As B4XComboBox
	Private cmbClockSetting 			As B4XComboBox
	Private imgIconApp 					As ImageView
	Private imgIconHome 				As ImageView
'	Private textAboutInfo 				As TextCrumbs
	Private clocktimer 					As Timer
	Public 	cleanSearchTimer			As Timer			'7.5 sec after GoHome func, txtSearch should be clean with this timer
	Public 	txtAppsSearch 				As EditText
	
	Private lstPackageNames 			As List
	Private HomeApps 					As List		'-- Home Screen Apps
	Public 	RecentlyList 				As List
	Public 	AppRowHeigh 				As Int 		= 50dip
	Public 	AppRowHeighMenu 			As Int 		= 50dip
	Public 	HomeRowHeigh 				As Int 		= 65dip
	Public 	HomeRowHeighMenu 			As Int 		= HomeRowHeigh * 2
	Public 	AutoRunOnFind 				As Boolean
	Public 	FirstStart 					As Boolean 	= True
	Public 	tagColors 					As Int 		= Colors.DarkGray
	Private LogListColor				As Int		= Colors.DarkGray
	Private LogListColorEnd				As Int 		= Colors.Gray
	
'	Public 	StartTimeClick 				As Boolean 	= True
	Private dragAllow 					As Boolean 	= False
	
	Private dragAllowEdge 				As Boolean 	= False
	
	Public 	Manager 					As AdminManager
	Public 	LastRunApp 					As String
	Private movecount 					As Int
	Private LastClick 					As Long
	Private gestHome 					As Gestures
	Private gestApps 					As Gestures
	Private dragger 					As CLVDragger
	Private draggerEdge 				As CLVDragger
	Private IMElib 						As IME
	Private dd 							As DDD
	Private OP 							As OverlayPermission
	
'	Private CurrentAppApp As App
'	Private CurrentHomeApp As App
	
	Public 	tagApps 					As ASScrollingTags
	Private lblInfo 					As Label
	Private chkAutoRun 					As CheckBox
	Private lblVersionHome 				As Label
	Private panLog 						As B4XView
	Private clvLog 						As CustomListView
	Private btnLogClose 				As Button
	Private chkShowToastLog 			As CheckBox
	Private chklogDebugMode 			As CheckBox
	Private chkShowIconsHome 			As CheckBox
	Private btnSetAsDefault 			As Button
	Private btnHiddenAppsDelete 		As Button
	Private panHideManager 				As B4XView
	Private clvHiddenApp 				As CustomListView
	Private CLVSelection 				As CLVSelections
	Private lblHomRowMenuRowAppTitle 	As Label
'	Private panHomeRowMenuRowHome 		As B4XView
'	Private panHomRowMenuRow 			As B4XView
	Private imgHomRowMenuRowIconHome 	As B4XView
	Private lblAppRowMenuRowAppTitle 	As Label
	Private imgAppRowMenuRowIconHome 	As B4XView
	Private clvEdge 					As CustomListView
	Public 	panEdge 					As Panel
	
	Private x_dblClick 					As Int
	Private y_dblClick 					As Int
	Private XclvMenu As Float
	Private YclvMenu As Float
	Private lblCameraSetting 			As Label
	Private lblClockSetting 			As Label
	
	Private AlphabetTable As IndexedTable
	Public AlphabetLastChars As String
	Public Alphabet As Map
	Private panHomRow As B4XView
	
	'//-- panHomeRow_LongClick
	Private TimerLongClick As Timer
	Dim longCLickFirstimeTouched As Long
	Dim longClickX As Float = 0
	Dim longClickY As Float = 0
	Dim longClickX0, longClickY0 As Float
	Dim longClickClvIndex As Int
	Dim longClickClvPNL As B4XView
	Dim ClickPanCLV As Boolean
	Dim clvLongClick As Int	' 0 = clvHome
							' 1 = clvApps
							' 2 = clvHomeMenu
							' 3 = clvAppMenu
	'//-- panHomeRow_LongClick END
	
	Private panAppRow As B4XView
	Private panPhone As B4XView
	Private panCamera As Panel
	Private HiddenListChanged As Boolean = False
	Private panHomeRowMenu As B4XView
	Private panAppRowMenu As B4XView
	Private chkLogAllowed As B4XView
	Public 	panBattery 		As B4XView
	Private cprBattery 		As CircularProgressBar
	Private thread 						As Thread
	Private threadSearchApp 			As Thread
	Private threadRunDefaultClockApp	As Thread
	Private threadSearchAppLock		As Lock
	Private lblClearSearch 	As B4XView
	Private OldSearchText As String
	Private NewSearchText As String
	Private btnHiddenApps As Button
	Private IsBusy As Boolean		'این متغیر برای چک کردن وضعیت جستجو است
End Sub

Private Sub MyLog (Text As String, color As Int, JustInDebugMode As Boolean)
	Starter.MyLog(Text, color, JustInDebugMode)
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
	Starter.ShowToastLog = False
	MyLog("###### Initialize", 0xFFC95E08, False)
	ToastMessageShow_Custom("Initialize", False, Colors.RGB(18, 118, 0))
	
	StartService(Starter)
'	StartTimeClick = True
	
	DateTime.TimeFormat = "hh:mm:ss"
	lblClock.Initialize("")
	lblClock.Text = DateTime.Time(DateTime.Now)
	
	DateTime.DateFormat = "dd.MMM.yyyy"
	lblDate.Initialize("")
	lblDate.Text = DateTime.Time(DateTime.Now)
	
	dd.Initialize
	'The designer script calls the DDD class. A new class instance will be created if needed.
	'In this case we want to create it ourselves as we want to access it in our code.
	xui.RegisterDesignerClass(dd)
	
	IMElib.Initialize("")
	
	Alphabet.Initialize
	AlphabetTable.Initialize("")
	
	clocktimer.Initialize("clocktimer", 1000)
	clocktimer.Enabled = True
	
	cleanSearchTimer.Initialize("cleanSearchTimer", 7500)
	cleanSearchTimer.Enabled = False
	
	TimerLongClick.Initialize("TimerLongClick", 100)
	TimerLongClick.Enabled = False
	
'	If Not (panLog.IsInitialized) Then panLog.Initialize("panLog")
	
End Sub

'The thread has terminated. If endedOK is False error holds the reason for failure
Private Sub thread_Ended(endedOK As Boolean, error As String)
	If Not (endedOK) Then
		MyLog($"Loading Apps Thread Error: ${error}"$, Colors.Red, False)
	End If
	
End Sub

Private Sub threadSearchApp_Ended(endedOK As Boolean, error As String)
	If Not (endedOK) Then
		MyLog($"Search In Apps Thread Error: ${error}"$, Colors.Red, False)
	End If
	
	SearchDone
	
End Sub

Private Sub SearchDone
	lblClearSearch.Enabled = True
	threadSearchAppLock.Unlock
End Sub

Private Sub RunSetupThread
	Starter.SetupAppsList(False)
	Setup
'	LoadRecentlyList
End Sub

'This event will be called once, before the page becomes visible.

Private Sub B4XPage_Created (Root1 As B4XView)
	MyLog("B4XPage_Created", LogListColor, False)
	
	Root = Root1
	Root.LoadLayout("MainPage")
	B4XPages.SetTitle(Me,"My Phone")
	
	Tabstrip1.LoadLayout("Home", "Home")
	Tabstrip1.LoadLayout("Apps", "Apps")
	
	lblVersionHome.Text = "Build " & Application.VersionCode & " " & Application.VersionName
	
	CLVSelection.Initialize(clvHome)
	CLVSelection.Mode = CLVSelection.MODE_SINGLE_ITEM_TEMP
	
	SetBackgroundTintList(txtAppsSearch, Colors.Transparent, Colors.Transparent)
	
	HideAppMenu(True)
	
	If (FirstStart) Then
		
'		'###### { ### Set Statusbar Colour
		Dim jo 		As JavaObject
		Dim window 	As JavaObject
			window = jo.InitializeContext.RunMethod("getWindow", Null)
			window.RunMethod("addFlags", Array(Bit.Or(0x00000200, 0x08000000)))
'		Root.Height = Root.Height + Starter.NAVBARHEIGHT
'		'}-----
		
		SetupHomeList
		
'		Starter.SetupAppsList(False)
'		Setup
'		LoadRecentlyList
		
		If Not (imgPhone.IsInitialized) Then imgPhone.Initialize("", "")
		imgPhone.Load(File.DirAssets, "Phone.png")
		
		If Not (imgCamera.IsInitialized) Then imgCamera.Initialize("", "")
		imgCamera.Load(File.DirAssets, "Camera.png")
		
		gestHome.SetOnTouchListener(panHome, "gestHome_gesture")
		gestApps.SetOnTouchListener(panApps, "gestApps_gesture")
		
		'//-- After Screen On, set as top on other apps
'		Dim jo As JavaObject = Root
'		Dim Window As JavaObject = jo.RunMethodJO("getContext", Null).RunMethod("getWindow", Null)
'		Window.RunMethod("addFlags", Array As Object(524288)) 'FLAG_SHOW_WHEN_LOCKED
'		Window.RunMethod("addFlags", Array As Object(128)) 'FLAG_KEEP_SCREEN_ON
		'//--
		
		dragger.Initialize(clvHome)
		dragger.SetDefaults(20dip, xui.Color_Black, xui.Color_Yellow)
		
		Dim R As Reflector
			R.Target = clvHome.AsView
			R.SetOnTouchListener("clvHome_Touch")
		
		If (panHomRow.IsInitialized) Then panHomRow.Tag = panHomRow.Color
		If (panAppRow.IsInitialized) Then panAppRow.Tag = panAppRow.Color
		If (panHomeRowMenu.IsInitialized) Then panHomeRowMenu.Tag = panHomeRowMenu.Color
		If (panAppRowMenu.IsInitialized) Then panAppRowMenu.Tag = panAppRowMenu.Color
		
		Try
			If Not (imgIconApp.IsInitialized) Then imgIconApp.Initialize("")
			If Not (lblAppTitle.IsInitialized) Then lblAppTitle.Initialize("")
			imgIconApp.Visible = False
'			If Starter.Pref.ShowIcon Then
'				imgIconApp.Visible = True
''				lblAppTitle.Left = 35dip
'				lblAppTitle.Left = imgIconHome.Left + imgIconHome.Width + 12dip
'			Else
'				imgIconApp.Visible = False
'				lblAppTitle.Left = 5dip
'			End If
			
			If Not (imgIconHome.IsInitialized) Then imgIconHome.Initialize("")
			If Starter.Pref.ShowIconHomeApp Then
				imgIconHome.Visible = True
'				lblAppTitle.Left = 35dip
				lblAppTitle.Left = imgIconHome.Left + imgIconHome.Width + 12dip
			Else
				imgIconHome.Visible = False
				lblAppTitle.Left = 5dip
			End If
			
		Catch
			MyLog("B4XPage_Created ERROR : " & LastException, LogListColor, True)
		End Try
		
		
		If (IsDebugMode) Then
			RunSetupThread
		Else
			thread.Initialise("thread")
'			thread.Start(Me, "RunSetupThread", Null)
			thread.RunOnGuiThread("RunSetupThread", Null)
			
			threadSearchApp.Initialise("threadSearchApp")
			threadRunDefaultClockApp.Initialise("threadOpenDefaultClockApp")
		End If
'		StartTimeClick = False
		
'		EdgeLoad
'		Open_Edgebar
		
		FirstStart = False
	Else
		FirstStart = False
	End If
	
	MyLog("B4XPage_Created END", LogListColorEnd, False)
	
End Sub

Public Sub BatteryVisiblity(show As Boolean, level As Int)
	MyLog("BatteryVisiblity: " & show & " - " & level & "%", LogListColor, True)
	panBattery.SetVisibleAnimated(500, show)
	If cprBattery.IsInitialized Then cprBattery.Value = level
End Sub

Public Sub BatterySetValue(level As Float)
	MyLog($"BatterySetValue: ${level}%"$, LogListColor, True)
	If cprBattery.IsInitialized Then cprBattery.Value = level
End Sub

Private Sub clocktimer_Tick
	DateTime.TimeFormat = "hh:mm:ss"
	lblClock.Text = DateTime.Time(DateTime.Now)
	
	DateTime.DateFormat = "dd.MMM.yyyy"
	lblDate.Text = DateTime.Date(DateTime.Now)
	
End Sub

Public Sub cleanSearchTimer_Tick
	
	MyLog("cleanSearchTimer_Tick", LogListColor, True)
	
	cleanSearchTimer.Enabled = False
	If (txtAppsSearch.Text <> "") Then txtAppsSearch.Text = ""
	If (clvApps.Size > 0) Then clvApps.ScrollToItem(0)
	
End Sub

Public Sub ClickSimulation
	Try
		XUIViewsUtils.PerformHapticFeedback(Sender)
	Catch
		XUIViewsUtils.PerformHapticFeedback(panApps)
		LogColor("ClickSimulation: It's a Handaled Runtime Exeption. It's Ok, Leave It." & CRLF & TAB & TAB & LastException.Message, LogListColorEnd)
	End Try
End Sub

Private Sub TimerLongClick_Tick
	If DateTime.Now - longCLickFirstimeTouched > 400 And longClickX - longClickX0 < 10dip And longClickY - longClickY0 < 10dip Then
		TimerLongClick.Enabled = False
		ClickPanCLV = False
		XUIViewsUtils.PerformHapticFeedback(longClickClvPNL)
				
		Select clvLongClick
			Case 0:	'clvHome
				If panHomRow.Tag = "" Then panHomRow.Tag = 0
'				longClickClvPNL.SetColorAndBorder(panHomRow.Tag, 0, Colors.Blue, 15dip)
				longClickClvPNL.SetColorAnimated(300, Colors.LightGray, Colors.Gray)
				clvHome_ItemLongClick(longClickClvIndex, clvHome.GetValue(longClickClvIndex))
				clvLongClick = -1
			Case 1:	'clvApps
				If panAppRow.Tag = "" Then panAppRow.Tag = 0
'				longClickClvPNL.SetColorAndBorder(panAppRow.Tag, 0, Colors.Blue, 15dip)
				longClickClvPNL.SetColorAnimated(300, Colors.LightGray, Colors.Gray)
				clvApps_ItemLongClick(longClickClvIndex, clvApps.GetValue(longClickClvIndex))
				clvLongClick = -1
		End Select
	End If
End Sub

Public Sub SetupHomeList
	
	Starter.ShowToastLog = False
	MyLog("SetupHomeList", LogListColor, False)
	
	If Not (HomeApps.IsInitialized) Then HomeApps.Initialize
	
	clvHome.sv.Enabled = False
	clvHome.Clear
	HomeApps.Clear
	
	'//----- Load Home
	'
	Dim ResHome As ResultSet = Starter.sql.ExecQuery("SELECT * FROM Home ORDER BY ID ASC")
	
	For i = 0 To ResHome.RowCount - 1
		ResHome.Position = i
		
		Dim CurrentHomeApp As App
			CurrentHomeApp.PackageName = ResHome.GetString("pkgName")
			CurrentHomeApp.Name = ResHome.GetString("Name")
			CurrentHomeApp.index = i + 1
			CurrentHomeApp.Icon = Starter.GetPackageIcon(CurrentHomeApp.PackageName)
			CurrentHomeApp.IsHomeApp = True
			CurrentHomeApp.IsHidden = False
'			CurrentHomeApp.VersionCode = ResHome.GetInt("VersionCode")
			
'		HomeApps.Add(CurrentHomeApp)
		AddToHomeList(CurrentHomeApp.Name, CurrentHomeApp.PackageName, clvHome.sv.Width, True)
	Next
	ResHome.Close
'	HomeApps.SortTypeCaseInsensitive("index", True)
	
	clvHome.sv.Enabled = False
	
	Starter.ShowToastLog = False
	MyLog("SetupHomeList END", LogListColorEnd, False)
	
End Sub

Public Sub GetSetting(Key As String) As String
	MyLog("GetSetting: " & Key, LogListColor, True)
	Dim tmpResult As String
	Private CurSql As Cursor
	CurSql = Starter.sql.ExecQuery("SELECT " & Key & " FROM Settings")
	CurSql.Position = 0
	tmpResult = CurSql.GetString("")
	CurSql.Close
	Return tmpResult
End Sub

Public Sub Open_Edgebar()
	Starter.ShowToastLog = False
	MyLog("Open_Edgebar", LogListColor, True)
	If OP.RequestPermission("OP") Then
		'A permission to draw overlays over applications is required
		Wait For OP_DrawPermission(Allowed As Boolean)
	End If
	
	'Opens the overlay window
	If OP.IsAllowed Then
		ToastMessageShow("You can move the window with your finger.", True)
		CallSubDelayed(SvcEdgebar, "ShowWindow")
		StartService(SvcEdgebar)
	End If
	
	'#####################
	'#
	'# 	Second Method
	'#
	'#  Still need to work
	'#
	'#####################
	
'	Dim pEdge As Panel = panEdge
'		pEdge.Initialize("panEdge")
'		pEdge.LoadLayout("EdgePanel")
'		pEdge.Width = panHome.Width
'		pEdge.Height = panHome.Height
'		pEdge.Top = 0
'		pEdge.Left = 0
'		pEdge.Color = Colors.Transparent
'		pEdge.Visible = True
'	
''	panHome.AddView(pEdge, pEdge.Left, pEdge.Top, pEdge.Width, pEdge.Height)
'	AddPanelToOverlay(pEdge, panHome.Width, panHome.Height)
	
End Sub

Public Sub Open_NetMeterOverlay()
	
	MyLog("Open_NetMeterOverlay", LogListColor, True)
	
	If OP.RequestPermission("OP") Then
		'A permission to draw overlays over applications is required
		Wait For OP_DrawPermission(Allowed As Boolean)
	End If
	
	'Opens the overlay window
	If OP.IsAllowed Then
		ToastMessageShow("You can move the window with your finger.", True)
		CallSubDelayed(SvcNetMeter, "ShowWindow")
		StartService(SvcNetMeter)
	End If	
	
End Sub

'--/ Edge Drawer
Private Sub EdgeLoad
	
	MyLog("EdgeLoad", LogListColor, False)
	
	If Not (draggerEdge.IsInitialized) Then
		draggerEdge.Initialize(clvEdge)
		draggerEdge.SetDefaults(25dip, xui.Color_Black, xui.Color_Yellow)
	End If
	
	Dim ResEdgeApp As ResultSet
		ResEdgeApp = Starter.sql.ExecQuery("SELECT * FROM EdgeBar ORDER By 'Index' ASC")
	
	For i = 0 To ResEdgeApp.RowCount - 1
		ResEdgeApp.Position = i
		Dim value As String = ResEdgeApp.GetString("pkgName")
		clvEdge.AddTextItem(ResEdgeApp.GetString("Name"), value)
	Next
	
	If (ResEdgeApp.RowCount <= 0) Then
		clvEdge.AddTextItem("[Select App]", "[SelectApp]")
	End If
	
	MyLog("EdgeLoad END", LogListColorEnd, False)
	
End Sub

Private Sub Run_Info(PackageName As String)
	
	MyLog("Run_Info = " & PackageName, LogListColor, True)
	
	Main.GoHomeAllow = False
	
	Dim p As Phone
	Dim i As Intent

	If p.SdkVersion > 8 Then
		i.Initialize("android.settings.APPLICATION_DETAILS_SETTINGS", "package:" & PackageName)
	Else
		i.Initialize("", "")
		i.SetComponent("com.android.settings/.InstalledAppDetails")
		i.PutExtra("pkg", PackageName)
	End If

	StartActivity(i)
End Sub

Private Sub DisableEdgeEdit
	
	MyLog("DisableEdgeEdit", LogListColor, True)
	
	If (dragAllowEdge) Then
		draggerEdge.RemoveDragButtons
		dragAllowEdge = False
	End If
End Sub

Private Sub gestApps_gesture(o As Object, ptrID As Int, action As Int, x As Float, y As Float) As Boolean
	
'	Starter.LogShowToast = False
'	MyLog("gestApps_gesture", LogListColor, True)
	
	If action = gestApps.ACTION_MOVE Then
		movecount = movecount + 1
		' noise on the touch screen electroincs can cause lots of apparent move events
		' this loop slows the rate down to one comfortable for LogCat
		' adjust the value for your device if necessary
		If movecount < 10 Then
'			LogColor("movecount Apps: " & movecount, Colors.Red)
			Return True ' need to return true otherwise we don't get any other events in the gesture
		End If
		movecount = 0
	End If
	
	Select action
		Case gestApps.ACTION_DOWN 				' Down
			
			MyLog("gestApps_gesture Down", LogListColor, True)
			
			cleanSearchTimer.Enabled = False
			
			HideAppMenu(True)
			
			If (DblClick(x, y)) Then DoubleTap
			
		Case gestApps.ACTION_UP					' Up
			'// Double Tap Time Variable
			LastClick = DateTime.Now
			
			MyLog("gestApps_gesture Up", LogListColor, True)
			
		Case gestApps.ACTION_POINTER_DOWN		' PtrDown
			MyLog("gestApps_gesture PtrDown", LogListColor, True)
			
		Case gestApps.ACTION_POINTER_UP			' PtrUp
			MyLog("gestApps_gesture PtrUp", LogListColor, True)
			
		Case gestApps.ACTION_MOVE				' Action Move
			LogColor("gestApps_gesture MOVE", Colors.Red)
			
	End Select
	
	Return False
	
End Sub

Private Sub gestHome_gesture(o As Object, ptrID As Int, action As Int, x As Float, y As Float) As Boolean
	
'	Starter.LogShowToast = False
'	MyLog("gestHome_gesture", LogListColor, True)
	
	If action = gestHome.ACTION_MOVE Then
		movecount = movecount + 1
		' noise on the touch screen electroincs can cause lots of apparent move events
		' this loop slows the rate down to one comfortable for LogCat
		' adjust the value for your device if necessary
		If movecount < 10 Then
			MyLog($"movecount: ${movecount}"$, Colors.Red, True)
			Return True ' need to return true otherwise we don't get any other events in the gesture
		End If
		movecount = 0
	End If
	
	Select action
		Case gestHome.ACTION_DOWN 				' Down
			
			MyLog("gestHome_gesture Down", LogListColor, True)
			
			HideHomeMenu(True)
			DisableEdgeEdit
			HideKeyboard
			
			If (DblClick(x, y)) Then DoubleTap
			
		Case gestHome.ACTION_UP					' Up
			'// Double Tap Time Variable
			LastClick = DateTime.Now
			
			MyLog("gestHome_gesture Up", LogListColor, True)
			
		Case gestHome.ACTION_POINTER_DOWN		' PtrDown
			MyLog("gestHome_gesture PtrDown", LogListColor, True)
			
		Case gestHome.ACTION_POINTER_UP			' PtrUp
			MyLog("gestHome_gesture PtrUp", LogListColor, True)
			
		Case gestHome.ACTION_MOVE				' Action Move
			LogColor("gestHome_gesture MOVE", Colors.Red)
			
	End Select
	
	
'	Dim ix, iy, count As Int
'		ix = x
'		iy = y
'	count = gestHome.GetPointerCount
'	Dim id As Int
'	For i = 0 To count -1
'		id = gestHome.GetPointerID(i)
'		ix = gestHome.GetX(id)
'		iy = gestHome.GetY(id)
'	Next
	
	' Need to return true otherwise we don't get any other events in the gesture
	Return False
End Sub

'Private Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
'	
'	MyLog("B4XMainPage: Activity_KeyPress = " & KeyCode, LogListColor, False)
'	
'	Select KeyCode
'		Case KeyCodes.KEYCODE_BACK
'			GoHome(False, False)
'			If (txtAppsSearch.Text <> "") Then txtAppsSearch.Text = ""
''			Return True
'		Case KeyCodes.KEYCODE_HOME
'			GoHome(True, False)
''			Return True
'	End Select
'	Return False
'	
'End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

' How to Use:
' FontToBitmap(Chr(0xF013), False, 28b, Colors.White)
' 
Public Sub FontToBitmap (text As String, IsMaterialIcons As Boolean, FontSize As Float, color As Int) As B4XBitmap
	Dim xui As XUI
	Dim p 	As Panel = xui.CreatePanel("")
		p.SetLayoutAnimated(0, 0, 0, 32dip, 32dip)
	Dim cvs1 As B4XCanvas
		cvs1.Initialize(p)
	Dim t As Typeface
	If IsMaterialIcons Then t = Typeface.MATERIALICONS Else t = Typeface.FONTAWESOME
	Dim fnt As B4XFont = xui.CreateFont(t, FontSize)
	Dim r As B4XRect = cvs1.MeasureText(text, fnt)
	Dim BaseLine As Int = cvs1.TargetRect.CenterY - r.Height / 2 - r.Top
	cvs1.DrawText(text, cvs1.TargetRect.CenterX, BaseLine, fnt, color, "CENTER")
	Dim b As B4XBitmap = cvs1.CreateBitmap
	cvs1.Release
	Return b
End Sub

Public Sub GoHome(ClearSearch As Boolean, HideKeybord As Boolean)
	MyLog("GoHome = Clear Search: " & ClearSearch, LogListColor, True)
	Try
		Tabstrip1.ScrollTo(0, True)
		HideHomeMenu(True)
		HideAppMenu(False)
'		If ClearSearch Then txtAppsSearch.Text = ""
		If HideKeybord Then HideKeyboard
		cleanSearchTimer.Enabled = True
		
	Catch
		ToastMessageShow(LastException.Message, True)
		MyLog($"GoHome Error = Clear Search : ${ClearSearch} - ${LastException.Message}"$, LogListColor, True)
	End Try
End Sub

Private Sub TabStrip1_PageSelected (Position As Int)
	
	MyLog($"TabStrip1_pageSelected = Position: ${Position}"$, LogListColor, False)

	HideHomeMenu(True)
	DisableEdgeEdit
	
	If (Position = 1) Then	'// Apps
		
		cleanSearchTimer.Enabled = False
		
		If (tagApps.CLV.Size < 1) Then LoadRecentlyList
		
		If Starter.Pref.ShowKeyboard Then ShowKeyboard
		
		' This IF conditation maybe is not need, Because on the module Main.bas
		' event Activity_Resume, We have another IF condition that make sure to
		' check if clvApps listview is empty or not, like IF condition below
		If Not (IsBusy) Then
			If (txtAppsSearch.Text = "") And (clvApps.Size  < 1) Then
					txtAppsSearch.Text = ""
			End If
		end if
	Else					'// Home
		cleanSearchTimer.Enabled = True
		HideAppMenu(True)
		CloseSetting
	End If
	
End Sub

Private Sub SaveRecentlyList
	
	MyLog("SaveRecentlyList", LogListColor, True)
	
	Dim Str As StringBuilder
	Str.Initialize
	
	Dim query As String
	Dim tmp As String
	For i = 0 To RecentlyList.Size - 1
		tmp = "('" & GetAppNamebyPackage(RecentlyList.Get(i)) & "','" & RecentlyList.Get(i) & "')," & tmp
	Next
	
	If tmp <> "" Then
		tmp = tmp.SubString2(0, tmp.Length - 1)
		query = "INSERT OR REPLACE INTO RecentlyApps(Name, pkgName) VALUE" & tmp
		Starter.sql.ExecNonQuery(query)
	End If
	
	MyLog("SaveRecentlyList", LogListColorEnd, True)
	
End Sub

Private Sub LoadRecentlyList
	
	MyLog("# # # # # # LoadRecentlyList", 0xFF389318, True)
	
	If Not (RecentlyList.IsInitialized) Then RecentlyList.Initialize
	
	Dim ResRecentApps As ResultSet
'	ResRecentApps = Starter.sql.ExecQuery("SELECT * FROM RecentlyApps WHERE ID IN (SELECT ID FROM RecentlyApps ORDER By ID DESC NULLS FIRST LIMIT 5)")
	ResRecentApps = Starter.sql.ExecQuery("SELECT * FROM RecentlyApps ORDER By ID DESC NULLS FIRST LIMIT 5")
	
	tagApps.CLV.Clear
	
	For i = 0 To ResRecentApps.RowCount - 1
		ResRecentApps.Position = i
		Dim pkg As String = ResRecentApps.GetString("pkgName")
		Starter.AddToRecently(ResRecentApps.GetString("Name"), pkg, False)
'		tagApps.AddTag(ResRecentApps.GetString("Name"), tagColors, pkg)
'		RecentlyList.Add(pkg)
	Next
	
	MyLog("# # # # # # LoadRecentlyList END", 0xFF389318, True)
	
End Sub

Public Sub FindRecentlyItem(pkgName As String) As Boolean
	
	MyLog("FindRecentlyItem = pkgName: " & pkgName, LogListColor, True)
	
	pkgName = GetPackage(pkgName)
	
	Dim i As Int = 0
	For i = 0 To tagApps.CLV.Size - 1
		If (tagApps.CLV.GetValue(i) = pkgName) Then Return True
	Next
	Return False
End Sub

Public Sub GetPackage(pkg As String) As String
	
	MyLog("GetPackage= pkg: " & pkg, LogListColor, True)
	
	Dim pkgName As String
	
	Try
		If (pkg.Length >= 8) Then
			If (pkg.As(String).SubString2(0, 8) = "package:") Then
				pkgName = pkg.As(String).SubString(8)
			Else
				pkgName = pkg
			End If
		Else
			pkgName = pkg
		End If
	Catch
		pkgName = pkg
	End Try
	
	MyLog("GetPackage= pkg> " & pkgName, LogListColor, True)
	Return pkgName
	
End Sub

Private Sub ReverseList(lst As List) As List
	
	MyLog("ReverseList", LogListColor, True)
	
	Dim java As JavaObject
		java.InitializeStatic("java.util.Collections").RunMethod("reverse", Array(lst))
	Return lst
	
End Sub

Public Sub RemoveAsRecently (Value As String)
'							(Index As Int)
	MyLog("RemoveAsRecently = " & Value, LogListColor, True)
	Value = GetPackage(Value.As(String))
	
	If Not (RecentlyList.IsInitialized) Then Return
	
	Starter.sql.BeginTransaction
	
	Dim i As Int
'	For i = 0 To tagApps.CLV.Size - 1
	For i = 0 To RecentlyList.Size - 1
		If RecentlyList.Get(i) = Value Then
			tagApps.CLV.RemoveAt(i)
			RecentlyList.RemoveAt(i)
			Starter.sql.ExecNonQuery("DELETE FROM RecentlyApps WHERE pkgName = '" & Value & "'")
			Exit
		End If
	Next
	
	'Commit the database transaction
	Starter.sql.TransactionSuccessful
	Starter.sql.EndTransaction
	
'	SaveRecentlyList
	
'	For Each ap In RecentlyList
'		If ap = tagApps.CLV.GetValue(Index) Then
'			tagApps.CLV.RemoveAt(Index)
'			RecentlyList.RemoveAt(Index)
'			Exit
'		End If
'	Next
	
	MyLog("RemoveAsRecently END => " & Value, LogListColorEnd, True)
	
End Sub

'Private Sub ConfigCurrentAppApp(Position As String, Value As String)
'	
'	Starter.LogShowToast = False
'	MyLog($"ConfigCurrentAppApp => Position: ${Position} - Value: ${Value}"$, LogListColor, True)
'	
'	CurrentAppApp.index 		= Position
'	CurrentAppApp.PackageName 	= Value.As(String)
'	
'	'Every custom list view has a panel within
'	Dim p 		As Panel 	= clvApps.GetRawListItem(Position).Panel.GetView(0)
'	CurrentAppApp.Name 		= dd.GetViewByName(p, "lblAppTitle").Text
'
'End Sub

'Private Sub ConfigCurrentHomeApp(Position As String, Value As String)
'	
'	Starter.LogShowToast = False
'	MyLog($"ConfigCurrentHomeApp => Position: ${Position} - Value: ${Value}"$, LogListColor, True)
'	
'	CurrentHomeApp.index = Position
'	CurrentHomeApp.PackageName = Value.As(String)
''	CurrentHomeApp.Name = clvHome.GetPanel(Position).GetView(0).Text
'End Sub

Private Sub clvHome_ItemClick (Index As Int, Value As Object)
	
	Starter.LogShowToast = False
	MyLog($"clvHome_ItemClick => Index: " ${Index}  - Value: ${Value}"$, LogListColor, True)
	
	ClickSimulation
	
	If (dragAllow = False) Then
'		ConfigCurrentHomeApp(Index, Value.As(String))
''		CurrentHomeApp.Name = clvHome.GetPanel(Index).GetView(0).Text
		clvHome.AsView.BringToFront
		RunApp(Value)
	End If
	HideHomeMenu(True)
	
End Sub


Private Sub clvHome_ItemLongClick (Index As Int, Value As Object)
	
	Starter.LogShowToast = False
	MyLog($"clvHome_ItemLongClick= Index: ${Index} - Value: ${Value}"$, LogListColor, True)
	
	HideHomeMenu(True)
	Sleep(50)
	
	If (dragAllow = False) Then
'		ConfigCurrentHomeApp(Index, Value.As(String))
		CreateHomeMenu(Index, Value)
	Else
		dragger.RemoveDragButtons
		dragAllow = False
	End If
End Sub

Private Sub CreateHomeMenu (Index As Int, Value As Object)
	
	MyLog($"CreateHomeMenu= Index: ${Index} - Value: ${Value}"$, LogListColor, True)
	
	panHRowMenuHome.RemoveAllViews
	panHRowMenuHome.RequestFocus
	panHRowMenuHome.LoadLayout("HomeRowMenu")
	panHRowMenuHome.Enabled = True
	panHRowMenuHome.BringToFront

	Dim Top As Int = clvHome.GetPanel(Index).Parent.Top - clvHome.sv.ScrollViewOffsetY + clvHome.GetBase.Top + clvHome.GetPanel(Index).Height
	panHRowMenuHome.As(B4XView).SetLayoutAnimated(300, clvHome.AsView.Left + (clvHome.AsView.Width - panHRowMenuHome.As(B4XView).Width) / 2, Top, panHRowMenuHome.As(B4XView).Width, panHRowMenuHome.As(B4XView).Height)
'	panHRowMenuHome.As(B4XView).SetLayoutAnimated(300, clvHome.AsView.Left - (panHRowMenuHome.As(B4XView).Width - panHRowMenuHome.As(B4XView).Width) / 2, Top, panHRowMenuHome.As(B4XView).Width, panHRowMenuHome.As(B4XView).Height)
'	panHRowMenuHome.As(B4XView).SetLayoutAnimated(0, clvHome.AsView.Left + (clvHome.AsView.Width - panHRowMenuHome.As(B4XView).Width) / 2, Top, panHRowMenuHome.As(B4XView).Width, panHRowMenuHome.As(B4XView).Height)
	panHRowMenuHome.SetVisibleAnimated(30, True)
	
	clvHRowMenu.Clear
'	clvHRowMenu.sv.SetColorAndBorder(Colors.White, 2dip, Colors.DarkGray, 20dip)
'	clvHRowMenu.sv.SetColorAnimated(300, Colors.LightGray, Colors.DarkGray)
	Dim he As Int = 130
	Dim we As Int = 80
	clvHRowMenu.Add(CreateListItemHomeMenu("Info", "Info", we, he, Value), "Info")
	clvHRowMenu.Add(CreateListItemHomeMenu("Delete", "Delete", we, he, Value), "Delete")
	clvHRowMenu.Add(CreateListItemHomeMenu("Sort", "Sort", we, he, Value), "Sort")

End Sub

Private Sub CreateListItemHomeMenu(Text 	As String, _
								   Value 	As String, _
								   Width 	As Int, _
								   Height 	As Int, _
								   Tag 		As String) As Panel
	
	Starter.ShowToastLog = False
	MyLog($"CreateListItemHomeMenu= ${Text} : ${Value} : ${Width.As(String)}  : ${Height.As(String)} : ${Tag}"$, LogListColor, False)
	
	Dim p As B4XView = xui.CreatePanel("")
	
		p.SetLayoutAnimated(0, 0, 0, Width, Height)
		p.LoadLayout("HomeRowMenuRow")

'	Dim p As Panel = panHomeRowMenuRowHome
'	panHomeRowMenuRowHome.SetLayoutAnimated(0,0,0, Width, Height)
'	panHomeRowMenuRowHome.LoadLayout("HomeRowMenu")
	
	'Note that we call DDD.CollectViewsData in HomeRow designer script. This is required if we want to get views with dd.GetViewByName.
	dd.GetViewByName(p, "lblHomRowMenuRowAppTitle").Text = Text
	dd.GetViewByName(p, "lblHomRowMenuRowAppTitle").Tag = Tag
	
'	If Starter.Pref.ShowIconHomeApp Then
'		imgHomRowMenuRowIconHome.Visible = True
'		lblHomRowMenuRowAppTitle.Left = 35dip
'	Else
	imgHomRowMenuRowIconHome.Visible = False
	lblHomRowMenuRowAppTitle.Left = 5dip
'	End If
	
'	Try
'		imgHomRowMenuRowIconHome.Bitmap = Starter.GetPackageIcon(Value)
'	Catch
'		Log("CreateListItemHome-Icon=> " & LastException)
'	End Try
	
	Return p
End Sub

Private Sub clvApps_ItemClick (Index As Int, Value As Object)
	
	Main.GoHomeAllow = False
	
	Starter.LogShowToast = False
	MyLog($"clvApps_ItemClick= Index: ${Index}  - Value: ${Value}"$, LogListColor, False)
	
	ClickSimulation
	
	Dim ap As App
		ap.PackageName = Value
		ap.Name = GetAppNamebyPackage(ap.Name)
'	ConfigCurrentAppApp(Position, Value)
	
	If (panAppMenuApp.IsInitialized And panAppMenuApp.Visible) Then
		HideAppMenu(True)
	Else
'		tagApps.LabelProperties.TextColor = Colors.Magenta
		Starter.AddToRecently(ap.Name, ap.PackageName, False)
'		SaveRecentlyList
		RunApp(Value)
	End If
End Sub

Private Sub clvApps_ItemLongClick (Position As Int, Value As Object)
	Starter.LogShowToast = False
	MyLog("clvApps_ItemLongClick", LogListColor, False)
	HideKeyboard
'	ConfigCurrentAppApp(Position, Value)
	CreateAppMenu(Value)
End Sub

Private Sub CreateAppMenu(Value As Object)
	
	
	Starter.ShowToastLog = False
	MyLog($"CreateAppMenu= Value: ${Value}"$, LogListColor, True)
	
	HideAppMenu(True)
	
	panAppMenuApp.RemoveAllViews
	panAppMenuApp.LoadLayout("AppRowMenu")
	panAppMenuApp.RequestFocus
	panAppMenuApp.Enabled = True
	panAppMenuApp.BringToFront
	panAppMenuApp.SetVisibleAnimated(150, True)
	
	Value = Value.As(String)
	
	Dim ap As App
		ap.PackageName 	= Value
		ap.Name 		= GetAppNamebyPackage(Value)
	
	clvAppRowMenu.Clear
'	clvAppRowMenu.sv.SetColorAndBorder(Colors.White, 2dip, Colors.DarkGray, 20dip)
'	clvAppRowMenu.sv.SetColorAnimated(300, Colors.LightGray, Colors.DarkGray)
	Dim he As Int = 130
	Dim we As Int = 80
	clvAppRowMenu.Add(CreateListItemAppMenu("Info", "Info", we, he, Value), "Info")
	clvAppRowMenu.Add(CreateListItemAppMenu(ap.Name, ap.PackageName, we, he, Value), ap.PackageName)
	If (FindHomeItem(ap.PackageName) = True) Then
		clvAppRowMenu.Add(CreateListItemAppMenu("Remove from Home", "RemoveFromHome", we, he, Value), "RemoveFromHome")
	Else
		clvAppRowMenu.Add(CreateListItemAppMenu("Add to Home", "AddToHome", we, he, Value), "AddToHome")
	End If
	clvAppRowMenu.Add(CreateListItemAppMenu("Uninstall", "Uninstall", we, he, Value), "Uninstall")
	clvAppRowMenu.Add(CreateListItemAppMenu("Hidden", "Hidden", we, he, Value), "Hidden")
	clvAppRowMenu.Add(CreateListItemAppMenu("Rename", "Rename", we, he, Value), "Rename")
	
End Sub

Private Sub clvHRowMenu_ItemClick (Index As Int, Value As Object)
	Starter.LogShowToast = False
	MyLog($"clvHRowMenu_ItemClick= Index: ${Index}: - Value: ${Value.As(String)}"$, LogListColor, True)
	
	ClickSimulation
	HideHomeMenu(True)
	dragAllow = False
	
	Main.GoHomeAllow = False
	
	Dim pnl 	As B4XView	= clvHRowMenu.GetPanel(Index)
	Dim pkg 	As String 	= dd.GetViewByName(pnl, "lblHomRowMenuRowAppTitle").Tag
	
	If (pkg = Null) Then Return
	
	Select Value
		Case "Info"
			Run_Info(pkg)
'			CurrentHomeApp.index = -1
		Case "Delete"
			RemoveHomeItem(pkg)
'			CurrentHomeApp.index = -1
			Log("Delete " & pkg)
			ToastMessageShow("Delete " & pkg, False)
		Case "Sort"
			dragAllow = True
			dragger.AddDragButtons
	End Select
	
End Sub

Public Sub AddToHomeList(Name As String, pkgName As String, Widt As Int, Save As Boolean)
	
	MyLog("AddToHomeList = pkgName: " & pkgName & " -  Name: " & Name, LogListColor, False)
	
'	If (pkgName Or Name = Null Or "" Or "null") Then Return
	If (pkgName = Null) Or (pkgName.Trim = "") Or (pkgName.ToLowerCase = "null") Then Return
	If (Name = Null) Or (Name.Trim = "") Or (Name.ToLowerCase = "null") Then Name = GetAppNamebyPackage(pkgName)
	
	If (FindHomeItem(pkgName) = False) Then
		clvHome.Add(CreateListItemHome(Name, pkgName, Widt, HomeRowHeigh), pkgName)
		If (Save) Then
			Dim query As String = "INSERT OR REPLACE INTO Home(ID, Name, pkgName) VALUES(" & clvHome.Size & ",'" & Name & "','" & pkgName & "')"
			Starter.sql.ExecNonQuery(query)
		End If
		
		Dim ico As Bitmap = Starter.GetPackageIcon(pkgName)
		Dim app As App
			app.Name = Name
			app.PackageName = pkgName
			If (ico.IsInitialized) Then app.Icon = ico
			app.index = clvHome.Size + 1
			app.IsHomeApp = True
			
		HomeApps.Add(app)
	End If
	
	MyLog("AddToHomeList END = pkgName: " & pkgName & " -  Name: " & Name, LogListColorEnd, True)
	
End Sub

Public Sub HideApp(pkgName As String)
	MyLog("HideApp: " & pkgName, LogListColor, False)
	
	pkgName = GetPackage(pkgName)
	RemoveHideAppItem_JustFromAppList(pkgName, False)
	
'	Dim query As String = "INSERT OR REPLACE INTO Apps(Name, pkgName, IsHome, IsHidden) VALUES('" & GetAppNamebyPackage(pkgName) & "','" & pkgName & "', 0, 1)"
'	Starter.sql.ExecNonQuery(query)
	
	Dim query As String = "INSERT OR REPLACE INTO Apps(Name, pkgName, IsHome, IsHidden) VALUES(?, ?, 0, 1)"
	Dim appName As String = GetAppNamebyPackage(pkgName)
	Dim args As List
		args.Initialize
		args.Add(appName)
		args.Add(pkgName)
	Starter.sql.ExecNonQuery2(query, args)
	
	Starter.SetupAppsList(False)
'	SetupHomeList
	RemoveAsRecently(pkgName)
	RemoveHomeItem(pkgName)
'	txtAppsSearch_TextChanged("", txtAppsSearch.Text)
	
	MyLog("HideApp END: " & pkgName, LogListColorEnd, True)
End Sub

Public Sub UninstallApp(pkgName As String)
	MyLog("UninstallApp", LogListColor, False)
	
	Main.GoHomeAllow = False
	
	pkgName = GetPackage(pkgName)
	
	Dim im As Intent
	im.Initialize("android.intent.action.DELETE", "package:" & pkgName)
	
	StartActivity(im)
	
End Sub

Private Sub CreateListItemApp(Text 		As String, _
							  Value 	As String, _
							  Width 	As Int, _
							  Height 	As Int, _
							  Tag 		As String) As Panel
	
'	Starter.LogShowToast = False
'	MyLog("CreateListItemApp = " & Text & ":" & Value & ":" & Width & ":" & Height.As, LogListColor, False)
	
	Dim p As B4XView = xui.CreatePanel("")
		p.SetLayoutAnimated(0, 0, 0, Width, Height)
		p.LoadLayout("AppRow")
	
	'Note that we call DDD.CollectViewsData in AppRow designer script. This is required if we want to get views with dd.GetViewByName. 
	dd.GetViewByName(p, "lblAppTitle").Text = Text.Trim
	dd.GetViewByName(p, "lblAppTitle").Tag = Tag
	
'	lblAppTitle.Text = Text.Trim
'	lblAppTitle.Tag = Tag
	
	Try

		If Starter.Pref.ShowIcon Then
			If Not (lblAppTitle.IsInitialized) Then lblAppTitle.Initialize("")
			Dim ico As Bitmap = Starter.GetPackageIcon(Value)
			If (ico.IsInitialized) Then
				imgIconApp.Bitmap = ico
				imgIconApp.Visible = True
'				lblAppTitle.Left = 35dip
				lblAppTitle.Left = imgIconHome.Left + imgIconHome.Width + 12dip
			Else
				lblAppTitle.Left = 5dip
				imgIconApp.Visible = False
			End If
		Else
			lblAppTitle.Left = 5dip
			imgIconApp.Visible = False
		End If
	Catch
		Return p
	End Try
	
	Return p
	
End Sub

Private Sub CreateListItemAppMenu(Text 	 As String, _
								  Value  As String, _
								  Width  As Int, _
								  Height As Int, _
								  Tag As String) As Panel
	
	Starter.LogShowToast = False
	MyLog($"CreateListItemAppMenu = ${Text} : ${Value} : ${Width} : ${Height}"$, LogListColor, False)
	
	Dim p As B4XView = xui.CreatePanel("")
		p.SetLayoutAnimated(0, 0, 0, Width, Height)
		p.LoadLayout("AppRowMenuRow")
	
	'Note that we call DDD.CollectViewsData in HomeRow designer script. This is required if we want to get views with dd.GetViewByName.
	dd.GetViewByName(p, "lblAppRowMenuRowAppTitle").Text = Text
	dd.GetViewByName(p, "lblAppRowMenuRowAppTitle").Tag = Tag
	
	If Starter.Pref.ShowIconHomeApp Then
		imgAppRowMenuRowIconHome.Visible = True
		lblAppRowMenuRowAppTitle.Left = 12dip
	Else
		imgAppRowMenuRowIconHome.Visible = False
		lblAppRowMenuRowAppTitle.Left = 5dip
	End If
	
'	Try
'		imgAppRowMenuRowIconHome.Bitmap = Starter.GetPackageIcon(Value)
'	Catch
'		Log("CreateListItemHome-Icon=> " & LastException)
'	End Try
	
	Return p
End Sub

Private Sub CreateListItemHome(Text 	As String, _
							   Value 	As String, _
							   Width 	As Int, _
							   Height 	As Int) As Panel
	
	Starter.LogShowToast = False
	MyLog($"CreateListItemHome = ${Text} : ${Value}  : ${Width} : ${Height}"$, LogListColor, False)
	
	Dim p As B4XView = xui.CreatePanel("")
	
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	p.LoadLayout("HomeRow")
	
	'Note that we call DDD.CollectViewsData in HomeRow designer script. This is required if we want to get views with dd.GetViewByName. 
	dd.GetViewByName(p, "lblHomeAppTitle").Text = Text
'	dd.GetViewByName(p, "lblHomeAppTitle").Tag = Value
	
	If Starter.Pref.ShowIconHomeApp Then
		Dim ico As Bitmap = Starter.GetPackageIcon(Value)
		If (ico.IsInitialized) Then
			imgIconHome.Visible = True
'			lblHomeAppTitle.Left = 35dip
			lblHomeAppTitle.Left = imgIconHome.Left + imgIconHome.Width + 22dip
			imgIconHome.Bitmap = ico
		Else
			imgIconHome.Visible = False
			lblAppTitle.Left = 18dip
		End If
	Else
		imgIconHome.Visible = False
		lblHomeAppTitle.Left = 18dip
	End If
	
'	MyLog("CreateListItemHome END => " & Text & ":" & Value & ":" & Width.As(String) & ":" & Height.As(String), LogListColorEnd, False)
	
	Return p
	
End Sub

Public Sub GetOverlayPermission() As ResumableSub
	
	MyLog("GetOverlayPermission", LogListColor, True)
	
	Dim c As RequestDrawOverPermission 'this is the name of the class
	c.Initialize
	Wait For (c.GetPermission) Complete (Success As Boolean)
	MyLog("Permission: " & Success, LogListColor, True)
	Return Success
End Sub

Public Sub Is_NormalApp(pkgName As String) As Boolean
	
	Starter.LogShowToast = False
	MyLog("Is_NormalApp => " & pkgName, LogListColor, True)
	
	For Each app As App In Starter.NormalAppsList
		If (app.PackageName = pkgName) Then
			MyLog("Is_NormalApp END => " & app.Name & ": " & pkgName, LogListColorEnd, True)
			Return True
		End If
	Next
	
	MyLog("Is_NormalApp END = FALSE: " & pkgName, LogListColorEnd, True)
	
	Return False
	
	'# Second Method with Get from OS
	'#
'	Dim pm As PackageManager
'	Dim packages As List
'	packages = pm.GetInstalledPackages
'	
'	For i = 0 To packages.Size - 1
'		Dim p As String = packages.Get(i)
'		
'		'//-- This will test whether the app is a 'regular' app that
'		'//-- can be launched and if so you can then show it in your app drawer.
'		'//-- If the app has been uninstalled, or if it isn't for normal use,
'		'//-- then it will return false.
'		If (p = pkgName) Then
'			If pm.GetApplicationIntent(p).IsInitialized Then Return True
'		End If
'	Next
'	
'	Return False
	
End Sub

Public Sub Setup
	
	MyLog("Setup", LogListColor, False)
	
'	'-- Add Apps to Home ListView
'	clvHome.Clear
'	For Each app As App In HomeApps
''		LogColor(app, Colors.Green)
'		AddToHomeList(app.Name, app.PackageName, clvHome.sv.Width, False)
'	Next
	
	Starter.AppsList.SortTypeCaseInsensitive("Name", True)
	Starter.NormalAppsList.SortTypeCaseInsensitive("Name", True)
	
	txtAppsSearch_TextChanged("", txtAppsSearch.Text)
	
	MyLog("Setup END", LogListColorEnd, False)
	
End Sub

Public Sub Is_HomeApp(pkgName As String) As Boolean
	
	MyLog("Is_HomeApps = pkgName: " & pkgName, LogListColor, True)
	
	Dim i As Int
	
	For i = 0 To HomeApps.Size - 1
		If (HomeApps.Get(i) = pkgName) Then Return True
	Next
'	For Each ap In Starter.HomeApps
'		If (pkgName = ap) Then Return True
'	Next
	
	MyLog("Is_HomeApps END= Return: FALSE - " & pkgName, LogListColorEnd, True)
	Return False
	
End Sub

public Sub RemoveHomeItem(pkgName As String)
	
	MyLog("RemoveHomeItem = " & pkgName, LogListColor, True)
	
	pkgName = GetPackage(pkgName)
	
	For i = 0 To clvHome.Size - 1
		If (i < clvHome.Size) Then ' I just used this if condition for fix array size issue. I don't know why error happen without this IF
			Dim homevalue As String = clvHome.GetValue(i).As(String).ToLowerCase
			If homevalue = pkgName Then
				clvHome.RemoveAt(i)
				HomeApps.RemoveAt(i)
'				ToastMessageShow(pkgName & " Deleted. " & i, False)
'				Exit
			End If
		End If
	Next
	Dim query As String = "DELETE FROM Home WHERE pkgName='" & pkgName & "'"
	Starter.sql.ExecNonQuery(query)
	
'	'//-- It's an extra function, just need one of this FOR (above or below)
'	'//
'	For i = 0 To HomeApps.Size - 1
'		Dim homevalue As String = HomeApps.Get(i)
'		If homevalue = pkgName Then
'			HomeApps.RemoveAt(i)
'			ToastMessageShow(pkgName & " Deleted. " & i, False)
''			Exit
'		End If
'	Next
	
'	SetupHomeList
	
	MyLog("RemoveHomeItem END => " & pkgName, LogListColorEnd, True)
	
End Sub

public Sub RemoveHideAppItem_JustFromAppList(pkgName As String, Remove As Boolean)
	
	MyLog("RemoveAppItem_JustFromAppList = " & pkgName, LogListColor, True)
	
	IsBusy = True
	
	pkgName = GetPackage(pkgName)
	
	Starter.sql.BeginTransaction
	
	If (Remove) Then
		Dim query As String = $"DELETE FROM ${Starter.TABLE_APPS} WHERE pkgName=?"$
		Starter.sql.ExecNonQuery2(query, Array As String(pkgName))
		
		query = $"DELETE FROM ${Starter.TABLE_ALL_APPS} WHERE pkgName=?"$
		Starter.sql.ExecNonQuery2(query, Array As String(pkgName))
		
		Starter.sql.TransactionSuccessful
		Starter.sql.EndTransaction
	End If
	
	For i = 0 To clvApps.Size - 1
		If (pkgName = clvApps.GetValue(i).As(String).ToLowerCase) Then
			clvApps.RemoveAt(i)
			Exit
		End If
	Next
	
	IsBusy = False
	
	MyLog("RemoveAppItem_JustFromAppList END = " & query, LogListColorEnd, True)
	
End Sub

Public Sub FindHomeItem(pkgName As String) As Boolean
	
	Starter.LogShowToast = False
	MyLog("FindHomeItem: " & pkgName, LogListColor, True)
	
	pkgName = GetPackage(pkgName)
	
	If (pkgName = Null) Or (pkgName = "") Then
		Return False
	End If
	
'	For Each ap As App In HomeApps
'		If (ap.PackageName = pkgName) Then
''			MyLog("FindHomeItem => " & pkgName & " - True", LogListColor)
'			Return True
'		End If
'	Next
	
	For i = 0 To clvHome.Size - 1
		If (clvHome.GetValue(i) = pkgName) Then
			LogColor(HomeApps.Get(i).As(String), Colors.Red)
'			MyLog("FindHomeItem => " & pkgName & " - True", LogListColor)
			Return True
		End If
	Next
	
	MyLog("FindHomeItem END = Return: False - " & pkgName, LogListColorEnd, True)
	Return False
End Sub

Public Sub GetAppNamebyPackage(pkgName As String) As String
	
	Starter.LogShowToast = False
	MyLog("GetAppNamebyPackage = pkgName: " & pkgName, LogListColor, True)
	
	pkgName = GetPackage(pkgName)
	
	'// First Method, Search in AppList, a List Variable
	For Each app As App In Starter.NormalAppsList
		If (app.PackageName = pkgName) Then
'			MyLog("End GetAppNamebyPackage => " & pkgName, LogListColorEnd)
			Return app.Name
		End If
	Next

'	'// Anothder Method to take apps from database	
'	Dim resName As ResultSet
'	resName = Starter.sql.ExecQuery("SELECT Name FROM AllApps WHERE pkgName='" & pkgName & "'")
'	If (resName.RowCount > 0) Then
'		resName.Position = 0
'		Return resName.GetString("Name")
'	End If
	
	MyLog("GetAppNamebyPackage END = pkgName: " & pkgName, LogListColorEnd, True)
	
	Return ""
End Sub

Public Sub ShowKeyboard
'	MyLog("ShowKeyboard", LogListColorEnd, True)
	txtAppsSearch.RequestFocus
	IMElib.ShowKeyboard(txtAppsSearch)
End Sub

Public Sub HideKeyboard
'	MyLog("HideKeyboard", LogListColorEnd, True)
	clvHome.AsView.RequestFocus
	IMElib.HideKeyboard
End Sub

' Hide Home Popup Menu
' DisHomeDrag = Disable Home Drag and Drop
Public Sub HideHomeMenu (DisHomeDrag As Boolean)
	
'	Starter.LogShowToast = False
'	Starter.MyLog("HideHomeMenu", Colors.LightGray, True)
	
	panHRowMenuHome.SetVisibleAnimated(100, False)
	
	'//-- Save and Disabled Drag and Drop Home List App
	If (dragAllow) And (DisHomeDrag) Then
		dragger.RemoveDragButtons
		MyLog("HideHomeMenu and Drag", Colors.Green, True)
		SaveHomeList
		dragAllow = False
	End If
	
End Sub

' Hide Apps Popup Menu
Public Sub HideAppMenu(hideKeybord As Boolean)
	
'	Starter.LogShowToast = False
'	MyLog("HideAppMenu", LogListColor, True)
	
	panAppMenuApp.SetVisibleAnimated(100, False)
	AlphabetTable.HideHoverLabel
	If (hideKeybord) Then HideKeyboard
	
End Sub

Private Sub RunApp(pkgName As String)
	
	MyLog("RunApp => " & pkgName, LogListColor, False)
	
	Try
		pkgName = GetPackage(pkgName)
		
		Dim pm 		As PackageManager
		Dim Intent1 As Intent
			Intent1 = pm.GetApplicationIntent (pkgName)
		If 	Intent1.IsInitialized Then
			StartActivity (Intent1)
			Main.GoHomeAllow = False
		End If
	Catch
		ToastMessageShow(pkgName & " : " & LastException.Message, False)
		MyLog("RunApp => " & pkgName & " - " & LastException, Colors.Red, True)
	End Try
End Sub

Private Sub panApps_Click
	
	Starter.LogShowToast = False
	MyLog("panApps_Click", LogListColor, True)
	
	HideAppMenu(True)
	
End Sub

Sub AnimateView(View As B4XView, Duration As Int, Left As Int, Top As Int, Width As Int, Height As Int)
	Dim cx As Int = Left + Width / 2
	Dim cy As Int = Top + Height / 2
	View.SetLayoutAnimated(0, cx, cy, 0, 0)
	Dim start As Long = DateTime.Now
	Do While DateTime.Now < start + Duration
		Dim p As Float = (DateTime.Now - start) / Duration
		Dim f As Float = 1 - Cos(p * 3 * cPI) * (1 - p)
		Dim w As Int = Width * f
		Dim h As Int = Height * f
		View.SetLayoutAnimated(0, cx - w / 2, cy - h / 2, w, h)
		Sleep(16)
	Loop
	View.SetLayoutAnimated(0, Left, Top, Width, Height)
End Sub

Private Sub btnSetting_Click
	
	Starter.LogShowToast = False
	MyLog("btnSetting_Click", LogListColor, False)
	
	ClickSimulation
	
	HideAppMenu(True)
	
	btnSetting.Enabled = False
	panSetting.RemoveAllViews
	panSetting.Visible = True
	btnSetting.RequestFocus
'	panSetting.SetLayoutAnimated(3000, 1000, 1000, 1000, 1000)
'	AnimateView(panSetting, 1000,1000,1000,1000,1000)
	panSetting.LoadLayout("Settings")
	panSetting.BringToFront
	
'	LogColor(Starter.Pref, Colors.Red)
	
	chkShowKeyboard.Checked = Starter.Pref.ShowKeyboard
	chkShowIcons.Checked = Starter.Pref.ShowIcon
	chkShowIcons.Tag = chkShowIcons.Checked
	chkShowIconsHome.Checked = Starter.Pref.ShowIconHomeApp
	chkShowIconsHome.Tag = chkShowIconsHome.Checked
	chkAutoRun.Checked = Starter.Pref.AutoRunApp
	chklogDebugMode.Checked = Starter.Pref.DebugMode
	chkLogAllowed.Checked = Starter.LogMode
	lblAbout.Text = "Made with Love, by Amir (C) 2023"
	lblVersion.Text = Application.LabelName & ", Build " & Application.VersionCode & " " & Application.VersionName
	
'	Dim crumblist As List
'		crumblist.Initialize
'		crumblist.AddAll(Array As String("About","Support","Made with Love","Display","Amir","Update"))
'	textAboutInfo.Initialize("", "", crumblist, lblAbout, " | ")

'	If (cmbPhone.IsInitialized <> False) Then
	If Starter.NormalAppsList.IsInitialized Then
		Dim i As Int = 0
		Dim lst As List
		Dim CameraIndex, PhoneIndex, ClockIndex As Int = -1
		lst.Initialize
		lstPackageNames.Initialize
			
		For Each app In Starter.NormalAppsList
				Dim r As Reflector
					r.Target = app
				Dim str As String
					str = r.GetField("Name").As(String)
				
				Dim pkgName As String
					pkgName = r.GetField("PackageName").As(String)
				
			If (Starter.Pref.CameraApp <> Null) And (pkgName.ToLowerCase = Starter.Pref.CameraApp.ToLowerCase) Then _
					CameraIndex = i
				
			If (Starter.Pref.PhoneApp <> Null) And (pkgName.ToLowerCase = Starter.Pref.PhoneApp.ToLowerCase) Then _
					PhoneIndex = i
				
			If (Starter.Pref.ClockApp <> Null) And (pkgName.ToLowerCase = Starter.Pref.ClockApp.ToLowerCase) Then _
					ClockIndex = i
				
				lst.Add(str)
				lstPackageNames.Add(pkgName)
				i = i + 1
		Next
		
		If (lst.Size > -1) Then
			lst.Add("[Select App]")
			lstPackageNames.Add("[UNKNOWN]")
			cmbCameraSetting.SetItems(lst)
			cmbPhoneSetting.SetItems(lst)
			cmbClockSetting.SetItems(lst)
			
			If (CameraIndex > 0) Then
				cmbCameraSetting.SelectedIndex = CameraIndex
				cmbCameraSetting.Tag = lstPackageNames.Get(CameraIndex).As(String)
			Else
				cmbCameraSetting.SelectedIndex = cmbCameraSetting.Size - 1
				cmbCameraSetting.Tag = "[UNKNOWN]"
			End If
			
			If (PhoneIndex > 0) Then
				cmbPhoneSetting.SelectedIndex = PhoneIndex
				cmbPhoneSetting.Tag = lstPackageNames.Get(PhoneIndex).As(String)
			Else
				cmbPhoneSetting.SelectedIndex = cmbPhoneSetting.Size - 1
				cmbPhoneSetting.Tag = "[UNKNOWN]"
			End If
			
			If (ClockIndex > 0) Then
				cmbClockSetting.SelectedIndex = ClockIndex
				cmbClockSetting.Tag = lstPackageNames.Get(ClockIndex).As(String)
			Else
				cmbClockSetting.SelectedIndex = cmbClockSetting.Size - 1
				cmbClockSetting.Tag = "[UNKNOWN]"
			End If
		
		End If
			
	End If
		
'	End If
	
	MyLog("btnSetting_Click END", LogListColorEnd, False)
	
End Sub

Private Sub btnSave_Click
	
	Starter.LogShowToast = False
	MyLog("btnSave_Click", LogListColor, False)
	
	ClickSimulation
	
	SaveSettings
	SaveHomeList
	
	If (chkShowIconsHome.Tag <> chkShowIconsHome.Checked) Then _
		SetupHomeList
	
	If (chkShowIcons.Tag <> chkShowIcons.Checked) Or _
	   (HiddenListChanged = True) Then
	   
		txtAppsSearch_TextChanged("", txtAppsSearch.Text)
		HiddenListChanged = False
		
	End If
	
	MyLog("btnSave_Click END", LogListColorEnd, True)
	
End Sub

Private Sub CloseSetting
	
	Starter.LogShowToast = False
	MyLog("        CloseSetting", LogListColor, True)
	
	btnSetting.Enabled = True
	panSetting.Enabled = True
	panSetting.SetVisibleAnimated(100, False)
	Sleep(100)
	panSetting.RemoveAllViews
	
	MyLog("CloseSetting END", LogListColorEnd, True)
	
End Sub

Public Sub SaveSettings
	
	Starter.LogShowToast = False
	MyLog("SaveSettings", LogListColor, True)
	
	CloseSetting
	
	Starter.Pref.ShowKeyboard = chkShowKeyboard.Checked
	
	If (cmbClockSetting.Tag.As(String) = "[UNKNOWN]") Then
		Starter.Pref.ClockApp = ""
	Else
		Starter.Pref.ClockApp = cmbClockSetting.Tag.As(String)
	End If
	
	If (cmbCameraSetting.Tag.As(String) = "[UNKNOWN]") Then
		Starter.Pref.CameraApp = ""
	Else
		Starter.Pref.CameraApp = cmbCameraSetting.Tag.As(String)
	End If
	
	If (cmbPhoneSetting.Tag.As(String) = "[UNKNOWN]") Then
		Starter.Pref.PhoneApp = ""
	Else
		Starter.Pref.PhoneApp = cmbPhoneSetting.Tag.As(String)
	End If
	
	Starter.Pref.ShowIcon 		 = chkShowIcons.Checked
	Starter.Pref.ShowIconHomeApp = chkShowIconsHome.Checked
	Starter.Pref.AutoRunApp 	 = chkAutoRun.Checked
	Starter.Pref.DebugMode 		 = chklogDebugMode.Checked
	Starter.LogMode 			 = chkLogAllowed.Checked
	
'	LogColor(Starter.Pref, Colors.Red)
	
	Dim query As String = "INSERT OR REPLACE INTO Settings(KeySetting, Value) " & _
						  "VALUES('ShowKeyboard','" & Starter.Pref.ShowKeyboard & "'), " & _
						  "('CameraApp','" & Starter.Pref.CameraApp & "'), " & _
						  "('PhoneApp','" & Starter.Pref.PhoneApp & "'), " & _
						  "('ClockApp','" & Starter.Pref.ClockApp & "'), " & _
						  "('ShowIcon','" & Starter.Pref.ShowIcon & "'), " & _
						  "('ShowIconHomeApp','" & Starter.Pref.ShowIconHomeApp & "'), " & _
						  "('AutoRunApp','" & Starter.Pref.AutoRunApp & "')"
	Starter.sql.ExecNonQuery(query)
	
	ToastMessageShow("Settings Changed and Saved !", False)
	
	MyLog("SaveSettings END", LogListColorEnd, True)
	
End Sub

Public Sub SaveHomeList
	
	Starter.LogShowToast = False
	MyLog("SaveHomeList", LogListColor, True)
	
	Starter.sql.ExecNonQuery("DELETE FROM Home")
	HomeApps.Clear
	
	Dim query As String
	For i = 0 To clvHome.Size - 1
		Dim pkg 	As String = clvHome.GetValue(i)
		Dim name 	As String = GetAppNamebyPackage(pkg)
		query = "INSERT OR REPLACE INTO Home(ID, Name, pkgName) VALUES(" & i & ",'" & GetAppNamebyPackage(pkg) & "', '" & pkg & "');" & query
			Starter.sql.ExecNonQuery("INSERT OR REPLACE INTO Home(ID, Name, pkgName) VALUES(" & i & ",'" & GetAppNamebyPackage(pkg) & "', '" & pkg & "');")
'		LogColor(query, Colors.Red)
		
		Dim app As App
			app.PackageName = pkg
			app.Name = name
			app.index = i + 1
			app.Icon = Starter.GetPackageIcon(pkg)
			app.IsHomeApp = True
'			app.IsHidden = False`
		
		HomeApps.Add(app)
	Next
	
	LogColor("Query SaveHomeList => " & query, Colors.Red)
'	If (query <> "") Then Starter.sql.ExecNonQuery(query)
'	HomeApps.SortTypeCaseInsensitive("ID", True)
	
	MyLog("SaveHomeList END", LogListColorEnd, True)
	
End Sub

Private Sub lblClock_Click
	
	Starter.ShowToastLog = False
	MyLog("lblClock_Click", LogListColor, True)
	
	ClickSimulation
	
	Main.GoHomeAllow = False
	
	HideHomeMenu(True)
	If (Starter.Pref.ClockApp = "") Then
		ToastMessageShow_Custom("First select Clock App from Setting page", False, Colors.Blue - 100)
		Tabstrip1.ScrollTo(1, True)
		Sleep(200)
		btnSetting_Click
		lblClockSetting.Color = Colors.RGB(123, 121, 18)
	Else
		RunApp(Starter.Pref.ClockApp)
	End If
End Sub

Public Sub Run_PhoneDialer
	Main.GoHomeAllow = False
	HideHomeMenu(True)
	Dim Intent1 As Intent
	Intent1.Initialize(Intent1.ACTION_VIEW, "tel:")
	StartActivity (Intent1)
End Sub

Public Sub Run_Calendar
	Try
		Main.GoHomeAllow = False
		Dim i As Intent
		Dim PhIIID As String = "phid"
		i.Initialize("android.intent.action.VIEW", "content://com.android.calendar/time/" & DateTime.Now)
		i.AddCategory("android.intent.category.DEFAULT")'add cat launcher
		i.PutExtra("id", PhIIID)
		StartActivity(i)'start the activity
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
	
End Sub

Public Sub Run_Alarm
	Try
		MyLog("Run_Alarm", LogListColor, True)
		
		Main.GoHomeAllow = False
		
		HideHomeMenu(True)
		
		If (IsDebugMode) Then
			threadOpenDefaultClockApp
		Else
			threadSearchApp.Start(Me, "threadOpenDefaultClockApp", Null)
		End If
		
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
End Sub

Private Sub threadOpenDefaultClockApp
	Dim i As Intent
		i.Initialize("android.intent.action.SET_ALARM", "")
	StartActivity(i)
End Sub

Private Sub panPhone_Click
	
	MyLog("panPhone_Click", LogListColor, True)
	
	ClickSimulation
	
	Main.GoHomeAllow = False
	
	HideHomeMenu(True)
	If (Starter.Pref.PhoneApp = "") Then
		Run_PhoneDialer
	Else
		RunApp(Starter.Pref.PhoneApp)
	End If
	
End Sub

Private Sub panCamera_Click
	
	MyLog("panCamera_Click", LogListColor, True)
	
	ClickSimulation
	
	Main.GoHomeAllow = False
	HideHomeMenu(True)
	
	If (Starter.Pref.CameraApp = "") Then
		ToastMessageShow_Custom("First select Camera App from Setting page", False, Colors.Blue - 100)
		Tabstrip1.ScrollTo(1, True)
		Sleep(200)
		btnSetting_Click
		lblCameraSetting.Color = Colors.RGB(123, 121, 18)
	Else
		RunApp(Starter.Pref.CameraApp)
	End If
	
End Sub

Public Sub getClassName() As Object
	
	Dim jo As JavaObject
	Dim cls As String =  Application.PackageName & ".main"
	'cls = cls.SubString("class ".Length)
	jo.InitializeStatic(cls)
	Return jo.GetField("processBA")
	
End Sub

Private Sub AddPanelToOverlay(pan As Panel, width As Int, height As Int)
	
	Dim vSystem 	As Int = 2006 	'2010 - Show On Everythin, It's used for System Errors. Nav Keyboards are also behind and dosn't work
	Dim vtype 		As Int = -1   	'-1 , TYPE_KEYGUARD_DIALOG = 2009, TYPE_PHON = 2002 (Deprecated), TYPE_APPLICATION_OVERLAY = 2038
	Dim pixelFormat As Int = -3
	
	Dim mlp As JavaObject
		mlp.InitializeNewInstance("android.view.WindowManager$LayoutParams", Array(vtype, height, vSystem, width, pixelFormat))
'		mlp.SetField("gravity", Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.LEFT))
		
	Dim windowManager As JavaObject = GetContext.RunMethod("getSystemService", Array("window"))
		windowManager.RunMethod("addView", Array(pan, mlp))
End Sub

Private Sub GetContext As JavaObject
    Dim jo As JavaObject
    	jo.InitializeContext
    Return jo
End Sub

Private Sub btnDelete_Click
	
	MyLog("btnDelete_Click", LogListColor, True)
	
	ClickSimulation
	
	'//-- Get Button On HomeRow
	Dim btn As Button = Sender
	btn.Visible = False
	
'	'//-- Get Button On HomeRow
'	Dim index As Int
'	index = clvHome.GetItemFromView(Sender)
	
	'//-- Get All Elements in List HomeRow
	For i = 0 To clvHome.GetSize - 1
		Dim p As Panel = clvHome.GetPanel(i)
		Dim lbl As Label = p.GetView(0)
		Dim chk As B4XView  = p.GetView(1)
		Dim checked As B4XSwitch = chk.Tag
		If checked.Value Then
			Log(checked.Tag)
			Log(lbl.Text)
		End If
	Next
	
End Sub

Private Sub panSettings_Touch (Action As Int, X As Float, Y As Float)
	
'	Starter.LogShowToast = False
'	MyLog("panSettings_Touch = Action: " & Action, Colors.LightGray, True)
	
	HideAppMenu(True)
	
	Select Action
		Case 0 ' Down
			If (DblClick(x, y)) Then CloseSetting
		Case 1 ' Up
			LastClick = DateTime.Now '// Double Tap Time Variable
	End Select
End Sub

Public Sub DblClick(x As Float, y As Float) As Boolean
	
	MyLog("DblClick", LogListColor, True)
	
	If (DateTime.Now - LastClick) < 200 Then
		
		Dim ix 			As Int = x
		Dim iy 			As Int = y
		Dim Tolerance 	As Int = 50 '80
		
		Dim res_x 		As Int = x_dblClick - ix
			If (res_x < 0) Then res_x = res_x * -1
		
		Dim res_y 		As Int = y_dblClick - iy
			If (res_y < 0) Then res_y = res_y * -1
			
'		LogColor("x: " & (x_dblClick - ix), Colors.Red)
'		LogColor("y: " & (y_dblClick - iy), Colors.Red)
'		Log("-----")
		
		If (Tolerance >= res_x) And (Tolerance >= res_y) Then _
			Return True
		
	End If
	'// Double Tap Time Variable
	LastClick = DateTime.Now
	x_dblClick = x
	y_dblClick = y
	Return False
End Sub

Private Sub cmbPhoneSetting_SelectedIndexChanged (Index As Int)
	cmbPhoneSetting.Tag = lstPackageNames.Get(Index).As(String)
End Sub

Private Sub cmbCameraSetting_SelectedIndexChanged (Index As Int)
	cmbCameraSetting.Tag = lstPackageNames.Get(Index).As(String)
End Sub

Private Sub cmbClockSetting_SelectedIndexChanged (Index As Int)
	cmbClockSetting.Tag = lstPackageNames.Get(Index).As(String)
End Sub

Private Sub lblDate_Click
	
	MyLog("lblDate_Click", LogListColor, True)
	
	ClickSimulation
	
	Main.GoHomeAllow = False
	
	HideHomeMenu(True)
	Run_Calendar
	
End Sub

Private Sub DoubleTap
	Try
		MyLog("DoubleTap", LogListColor, True)
		
		If Manager.Enabled Then
			Manager.LockScreen
		Else
			Manager.Enable("Please enable administrator access to active 'Lock Screen' by Double Tap.")
			If Manager.Enabled Then Manager.LockScreen
		End If
	Catch
		MyLog("*+*+*+ DoubleTap : " & LastException, Colors.Red, True)
	End Try
End Sub

Private Sub RunSettings(Setting As String)', _ 
					   'Setting as AndroidSettings)

	Main.GoHomeAllow = False
	
	Dim inte As Intent
	Dim pm As PackageManager
	
	inte = pm.GetApplicationIntent("com.android.settings")
	
	If inte.IsInitialized Then
		inte.SetComponent("com.android.settings/." & Setting)
		StartActivity(inte)
	End If

End Sub

Private Sub isColorDark(color As Int) As Boolean
    
	Dim darkness As Int = 1 - (0.299 * GetARGB(color)(1) + 0.587 * GetARGB(color)(2) + 0.114 * GetARGB(color)(3))/255
    
	If darkness <= 0.5 Then
		Return    False 'It's a light color
	Else
		Return    True 'It's a dark color
	End If
    
End Sub

Private Sub GetARGB(Color As Int) As Int()
	Dim res(4) As Int
		res(0) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff000000), 24)
		res(1) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff0000), 16)
		res(2) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff00), 8)
		res(3) = Bit.And(Color, 0xff)
	Return res
End Sub

Private Sub panSettings_LongClick
	
	MyLog("panSettings_LongClick", LogListColor, True)
	
	CloseSetting
	
End Sub

Private Sub clvHome_ScrollChanged (Offset As Int)
	
'	MyLog("clvHome_ScrollChanged", LogListColor, True)
	
	'//-- Hide Home List Popup Menu
	panHRowMenuHome.Visible = False
	HideHomeMenu(False)
	
End Sub

Private Sub clvApps_ScrollChanged (Offset As Int)
	If (Offset < 450) Then HideAppMenu(False)
End Sub

Private Sub panApps_Touch (Action As Int, X As Float, Y As Float)
	
'	Starter.LogShowToast = False
'	MyLog("panApps_Touch => A: " & Action & " : HideKeyboard", LogListColor, True)
	
	If (Action = panApps.TOUCH_ACTION_DOWN) Then
		Starter.LogShowToast = False
		MyLog("panApps_Touch = Action: " & Action, LogListColor, True)

		HideAppMenu(True)
	End If
End Sub

Private Sub tagApps_ItemClick (Index As Int, Value As Object)
	ClickSimulation
	HideAppMenu(True)
	RunApp(Value.As(String))
	Starter.AddToRecently(GetAppNamebyPackage(Value), Value, False)
End Sub

Private Sub tagApps_ItemLongClick (Index As Int, Value As Object)
	
	
	HideAppMenu(False)
	CreateAppMenu(Value)
	
	
'	Dim Result As Int
'	Msgbox2Async("Do you want to delete this app?", GetAppNamebyPackage(Value), "Yes", "", "No", Null, True)
'	Wait For Msgbox_Result(Result As Int)
'
'	Select Result
'		Case DialogResponse.POSITIVE
'			' User clicked "Yes"
'			RemoveAsRecently(Value.As(String))
'		Case DialogResponse.NEGATIVE
'			' User clicked "No"
'			' Do nothing
'	End Select
	
	
End Sub

Private Sub chkAutoRun_CheckedChange(Checked As Boolean)
	
End Sub

Public Sub SetDefaultLauncher
	
	Starter.LogShowToast = False
	MyLog("SetDefaultLauncher", LogListColor, True)
	
	If (GetDefaultLauncher <> Starter.Pref.MyPackage) Then
		Dim in As Intent
		in.Initialize("android.settings.HOME_SETTINGS", "")
		StartActivity(in)
	Else
		ToastMessageShow_Custom(Application.LabelName & " already set as default launcher." & CRLF & "have Fun ;)", False, Colors.DarkGray - 75)
	End If
	
End Sub

Public Sub GetDefaultLauncher As String
	Dim Jo As JavaObject
		Jo.InitializeContext
		Jo = Jo.RunMethod("getPackageManager",Null)
	Dim intent As Intent
		intent.Initialize("android.intent.action.MAIN","")
		intent.AddCategory("android.intent.category.HOME")
		Jo = Jo.RunMethod("resolveActivity",Array(intent,0x00010000))
		Jo = Jo.GetFieldJO("activityInfo")
	Dim DefaultSystemLauncher As String = Jo.GetField("packageName").As(String)
	
	Return DefaultSystemLauncher
End Sub

' Check for Private network address
Private Sub IsPrivateIpAddress(ipStr As String) As Boolean

	Dim m As Matcher = Regex.Matcher("^(\d+)\.(\d+)\.(\d+)\.(\d+)$", ipStr)
	If m.Find = False Then
		Log("INVALID IP ADDRESS")
		Return False
	End If

	Select m.Group(1)
		Case 10
			If Not(inRange(m.Group(2), 0, 255)) Or Not(inRange(m.Group(3), 0, 255)) Or Not(inRange(m.Group(4), 0, 255)) Then Return False
			Return True  ' Class A: 10.0.0.0 to 10.255.255.255.
		Case 172
			If Not(inRange(m.Group(2), 16, 31)) Or Not(inRange(m.Group(3), 0, 255)) Or Not(inRange(m.Group(4), 0, 255)) Then Return False
			Return True   ' Class B: 172.16.0.0 to 172.31.255.255.
		Case 192
			If m.Group(2) <> 168 Or Not(inRange(m.Group(3), 0, 255)) Or Not(inRange(m.Group(4), 0, 255)) Then Return False
			Return True   ' Class C: 192.168.0.0 to 192.168.255.255.
		Case Else
			Return False
	End Select
End Sub
Private Sub inRange(num As Int, n1 As Int, n2 As Int) As Boolean
	Return num >= n1 And num <= n2
End Sub

'	//-- Example, How to use:
'	ShowCustomToast("Testing...", True, Colors.Green)
'	Sleep(3000)
'	'-- Or
'	Dim cs As CSBuilder
'		cs.Initialize.Color(Colors.Blue).Size(20).Append("Custom Toast").PopAll
'	ShowCustomToast(cs, True, Colors.Red)
Public Sub ToastMessageShow_Custom(Text As Object, LongDuration As Boolean, BackgroundColor As Int)
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim duration As Int
	If LongDuration Then duration = 1 Else duration = 0
	Dim toast As JavaObject
	toast = toast.InitializeStatic("android.widget.Toast").RunMethod("makeText", Array(ctxt, Text, duration))
	Dim v As View = toast.RunMethod("getView", Null)
	Dim cd As ColorDrawable
	cd.Initialize(BackgroundColor, 20dip)
	v.Background = cd
	
	'uncomment to show toast in the center:
	'   toast.RunMethod("setGravity", Array( _
	'       Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL), 0, 0))
	toast.RunMethod("show", Null)
'	toast.RunMethod("cancel", Null) '//-- For Hide Toast
	
	'//-- Example, How to use:
'	ShowCustomToast("Testing...", True, Colors.Green)
'	Sleep(3000)
'	'//-- Or
'	Dim cs As CSBuilder
'	cs.Initialize.Color(Colors.Blue).Size(20).Append("Custom Toast").PopAll
'	ShowCustomToast(cs, True, Colors.Red)
	
End Sub

Private Sub ShowAndroidSettings
	Dim in As Intent
	in.Initialize("android.settings.SETTINGS", "")
	StartActivity(in)
End Sub


Private Sub btnLogClose_Click
	ClickSimulation
	Starter.ShowToastLog = chkShowToastLog.Checked
	Starter.sql.ExecNonQuery("INSERT OR REPLACE INTO Settings(KeySetting, Value) " & _
							 "VALUES('ShowToastLog','" & Starter.ShowToastLog & "'), " & _
							 	   "('DebugMode','" 	 & Starter.Pref.DebugMode & "')")
	
	panLog.Visible = False
	panSetting.Visible = True
End Sub

Private Sub btnLogClose_LongClick
	
	MyLog("btnLogClose_LongClick", LogListColor, False)
	
	ClickSimulation
	clvLog.Clear
	
	Dim ls As List
		ls.Initialize
	
	Dim List1 As List
		List1.Initialize
		List1 = File.ReadList(File.DirInternal, "MyLog.log")
	
	If (List1.Size <= 0) Then
		File.WriteList(File.DirInternal, "MyLog.log", Starter.LogList)
		List1 = Starter.LogList
	End If
	
	If (List1.Size > 200) Then
		
		For i = List1.Size - 200 To List1.Size - 1
			
			clvLog.AddTextItem(List1.Get(i), "")
		Next
	Else
		For i = 0 To List1.Size - 1
			
			clvLog.AddTextItem(List1.Get(i), "")
		Next
		
	End If
	
	ToastMessageShow("Logs Loaded... " & List1.Size, False)
End Sub

Private Sub clvLog_ItemClick (Index As Int, Value As Object)
	Dim cb As BClipboard
	ToastMessageShow(Value.As(String), True)
	cb.setText(Value)
End Sub

Private Sub lblVersion_Click
	
	MyLog("lblVersion_Click", LogListColor, False)
	
	ClickSimulation
	
	panLog.SetVisibleAnimated(150, True)
'	panSetting.Visible = False
	
	chkShowToastLog.Checked = Starter.ShowToastLog
	
	btnLogClose.Text = $"Close (${Starter.LogList.Size})"$
	
	For Each item In Starter.LogList
		clvLog.AddTextItem(item, item)
	Next
	
	If (clvLog.Size > 5) Then
		Sleep(0)
		clvLog.JumpToItem(clvLog.Size - 1)
	End If
	
End Sub

Private Sub lblVersion_LongClick
	MyLog("lblVersion_LongClick", LogListColor, False)
	ToastMessageShow("Log list reset successfull.", False)
	clvLog.Clear
	Starter.LogList.Clear
'	File.WriteList(File.DirInternal, "MyLog.log", Starter.LogList)
	
	btnLogClose_Click
End Sub

Private Sub lblAbout_Click
	lblVersion_Click
End Sub

Private Sub lblAbout_LongClick
	lblVersion_LongClick
End Sub

Public Sub setAlwaysOnTop(frm As Object, Value As Boolean)
	Dim frmJO As JavaObject = frm
	Dim stage As JavaObject = frmJO.GetField("stage")
		stage.RunMethod("setAlwaysOnTop", Array(Value))
End Sub

Private Sub clvAppRowMenu_ItemClick (Index As Int, Value As Object)
	
	Starter.LogShowToast = False
	MyLog($"clvAppRowMenu_ItemClick= Index: ${Index} - Value: ${Value}"$, LogListColor, True)
	
	ClickSimulation
	
	HideAppMenu(True)
	dragAllow = False
	
	Dim pnl 	As B4XView	= clvAppRowMenu.GetPanel(Index)
	Dim pkg 	As String 	= dd.GetViewByName(pnl, "lblAppRowMenuRowAppTitle").Tag
	
	If (pkg = Null) Then Return
	
	Dim ap As App
		ap.PackageName = pkg
		ap.Name = GetAppNamebyPackage(pkg)
	
	Main.GoHomeAllow = False
	
	Select Value
		
		Case "Info"
			Run_Info(pkg)
			
		Case "AddToHome"
			AddToHomeList(ap.Name, pkg, clvApps.sv.Width, True)
		
		Case "RemoveFromHome"
			RemoveHomeItem(pkg)
			
		Case "Uninstall"
			UninstallApp(pkg)
			
		Case "Hidden"
			HideApp(pkg)
			
		Case "Rename"
			ToastMessageShow("Rename => " & ap.Name, False)
			
		Case pkg		'Run App
'			tagApps.LabelProperties.TextColor = Colors.Magenta
			Starter.AddToRecently(ap.Name, pkg, False)
'			SaveRecentlyList
			RunApp(Value.As(String))
			clvApps.AsView.BringToFront
			
	End Select
	
End Sub

' Change EditText Background Colour
Private Sub SetBackgroundTintList(View As View,Active As Int, Enabled As Int)
	Dim States(2,1) As Int
		States(0,0) = 16842908     	'Active
		States(1,0) = 16842910    	'Enabled
	Dim Color(2) As Int = Array As Int(Active,Enabled)
	Dim CSL As JavaObject
		CSL.InitializeNewInstance("android.content.res.ColorStateList",Array As Object(States,Color))
	Dim jo As JavaObject
		jo.InitializeStatic("android.support.v4.view.ViewCompat")
		jo.RunMethod("setBackgroundTintList", Array(View, CSL))
End Sub

Private Sub txtAppsSearch_EnterPressed
	HideAppMenu(False)
	If Not (txtAppsSearch.Text = "") Then _
		txtAppsSearch_TextChanged("", txtAppsSearch.Text)
End Sub


Private Sub txtAppsSearch_FocusChanged (HasFocus As Boolean)
	MyLog("txtAppsSearch_FocusChanged = HasFocus: " & HasFocus, LogListColor, True)
	HideAppMenu(Not(HasFocus))
End Sub

Private Sub CheckCommand(cmd As String) As Boolean
	Select cmd.ToLowerCase
		Case "!fixdb"
			Dim res As Int
			res = Msgbox2("Check to Fix Database?", "Fix DB", "Yes", "", "No", Null)
			If (res = DialogResponse.POSITIVE) Then
				Starter.FixDatabase
			End If
			Return True
	End Select
	Return False
End Sub

Public Sub txtAppsSearch_TextChanged(Old As String, New As String)
	
	OldSearchText = Old
	NewSearchText = New
	
	If (IsBusy) Then Return
	SearchStart
	
	HideAppMenu(False)
	
	If Not (Starter.NormalAppsList.IsInitialized) Then Return
	
	If (CheckCommand(New)) Then Return
	
	If IsDebugMode Then
		SearchInApp(Old, New)
	Else
		threadSearchAppLock.Initialize(True)
'		threadSearchApp.RunOnGuiThread("SearchInApp", Array(Old, New))
		threadSearchApp.Start(Me, "SearchInApp", Array(Old, New))
	End If
	
End Sub

Private Sub IsDebugMode As Boolean
	Dim r 		As Reflector
	Dim debug 	As Boolean = r.GetStaticField("anywheresoftware.b4a.BA", "debugMode")
	If debug Then Return True
	Return False
End Sub

Private Sub SearchCanceled
	IsBusy = False
End Sub
Private Sub SearchStart
	IsBusy = True
End Sub

Private Sub SearchInApp(Old As String, New As String)
	
'	Starter.LogShowToast = False
'	MyLog("SearchApp = " & OldTextSearch & " : " & NewTextSearch, LogListColor, True)
	
	Sleep(0) '// Just For Refresh UI
	
	clvApps.Clear
	Alphabet.Clear
	
	#Region Database Mode Region
'	Dim rsApps As ResultSet
'	
'	If (New = "") Then
'		rsApps = Starter.sql.ExecQuery("SELECT * FROM Apps ORDER By 'Name' ASC")
'	Else
'		rsApps = Starter.sql.ExecQuery("SELECT * FROM Apps WHERE Name='%" & New & "%' ORDER By 'Name' ASC")
'	End If
'	Sleep(0)
'	
'	Do While rsApps.NextRow
'		Dim package As String = rsApps.GetString("pkgName")
'		Dim appName 	As String = rsApps.GetString("Name")
'		
'		clvApps.Add(CreateListItemApp(appName, package, clvApps.AsView.Width, AppRowHeigh), package)
'		AppCount = AppCount + 1
'		AddtoAlphabetlist(appName, i)
'	Loop
	#End Region
	
	Dim appsList 		As List = Starter.NormalAppsList
	Dim numApps 		As Int 	= appsList.Size - 1
	Dim width 			As Int 	= clvApps.AsView.Width
	Dim AppCountFound 	As Int 	= 0
	
	If (New = "") Then
		
		lblInfo.Text = (numApps + 1) & " apps"
		AppCountFound = numApps
		For i = 0 To numApps
			Dim App As App = appsList.Get(i)
			clvApps.Add(CreateListItemApp(App.Name, App.PackageName, width, AppRowHeigh, App.PackageName), App.PackageName)
			AddtoAlphabetlist(App.Name, i)
			Sleep(0)
			If (New <> NewSearchText) Then
				SearchCanceled
				Return
			End If
		Next
	Else
		
		Dim searchTextLower As String = New.ToLowerCase
		For i = 0 To numApps
			Dim App As App = appsList.Get(i)
			If App.Name.ToLowerCase.Contains(searchTextLower) Then
				clvApps.Add(CreateListItemApp(App.Name, App.PackageName, width, AppRowHeigh, App.PackageName), App.PackageName)
				AddtoAlphabetlist(App.Name, i)
				AppCountFound = AppCountFound + 1
'				Sleep(0)
				If (New <> NewSearchText) Then
					SearchCanceled
					Exit
				End If
			End If
		Next
		
		lblInfo.Text = AppCountFound & " matching apps"
		
	End If
	
	If (New <> NewSearchText) Then
		SearchCanceled
		Return
	End If
	
	If (AppCountFound > 20) Then
		AlphabetTable.LoadAlphabetlist(panApps, Alphabet, False, clvApps.AsView.Top)
	Else
		' This line code is mean,
		' Just Remove Last AlphaList from UI
		AlphabetTable.LoadAlphabetlist(panApps, Alphabet, True, clvApps.AsView.Top)
	End If
	AlphabetLastChars = ""
	
	If (Old <> New) Then
		If (txtAppsSearch.Text = New) And (AppCountFound = 1) Then
			If (Starter.Pref.AutoRunApp = True) Then
				Dim pkg As String = clvApps.GetValue(0).As(String)
				If (LastRunApp <> pkg) Then
					LastRunApp = pkg
					Starter.AddToRecently(GetAppNamebyPackage(pkg), pkg, False)
					RunApp(pkg)
				End If
			End If
		End If
	End If
	
	SearchCanceled
'	SearchDone
	
'	MyLog("SearchApp END = " & OldTextSearch & " : " & NewTextSearch, LogListColorEnd, True)
	
End Sub

Private Sub AddtoAlphabetlist(AppName As String, Index As Int)
	
'	MyLog("AddtoAlphabetlist = " & AppName & " Index: " & Index, LogListColorEnd, True)
	
	Dim FirstChars As String = AppName.Trim.CharAt(0).As(String).ToUpperCase
	If (FirstChars = B4XPages.MainPage.AlphabetLastChars) Then Return
	
'	For i = 0 To Alphabet.Size - 1
'		If (Alphabet.Get(i) = FirstChars) Then
'			Return
'		End If
'	Next

	B4XPages.MainPage.AlphabetLastChars = FirstChars
	B4XPages.MainPage.Alphabet.Put(FirstChars, Index)
'	If Not (Alphabet.ContainsKey(Index)) Then
'		Alphabet.Put(FirstChars, Index)
'	End If
	
End Sub


Private Sub btnHiddenAppsDelete_Click
	Try
		
		MyLog("btnHiddenAppsDelete_Click", LogListColor, True)
		
		ClickSimulation
		
		If clvHiddenApp.Size < 1 Then Return
		If CLVSelection.SelectedItems.AsList.Size < 1 Then Return
		
'		Dim index As Int = clvHiddenApp.GetItemFromView(Sender)
'		Dim value As String = clvHiddenApp.GetValue(index)
		
		Dim selected 	As Object = CLVSelection.SelectedItems.AsList.Get(0)
		Dim value 		As String = clvHiddenApp.GetValue(selected)
		clvHiddenApp.RemoveAt(selected.As(Int))
		Starter.sql.ExecNonQuery("UPDATE Apps SET IsHidden=0 WHERE pkgName='" & value & "'")
'		CLVSelection.ItemClicked(-1)
		HiddenListChanged = True
	Catch
		MyLog("btnHiddenAppsDelete_Click ERROR = " & LastException, Colors.Red, False)
	End Try
End Sub

Private Sub btnHiddenAppsClose_Click
	ClickSimulation
	CloseHiddenManager
End Sub

Private Sub btnHiddenApps_Click
	
	Starter.LogShowToast = False
	MyLog("btnHiddenApps_Click", LogListColor, True)
	
	ClickSimulation
	
	panHideManager.RemoveAllViews
	panHideManager.LoadLayout("HiddenApps")
	panHideManager.SetVisibleAnimated(300, True)
	panHideManager.Enabled = True
	panHideManager.BringToFront
	panHideManager.RequestFocus
	
	panHideManager.Top = chkShowKeyboard.Top
'	panHideManager.Left = 10dip
'	panHideManager.Width = panSetting.Width - 20dip
	panHideManager.Height = panSetting.Height
	
	LoadHiddenManager
	
	HiddenListChanged = False
	
End Sub

Private Sub panHiddenApps_Touch (Action As Int, X As Float, Y As Float)
	
	HideKeyboard
	Select Action
		Case 0 ' Down
			MyLog("panHiddenApps_Touch Down = Action: " & Action, LogListColor, True)
			
			If (DblClick(x, y)) Then CloseHiddenManager
		Case 1 ' Up
			LastClick = DateTime.Now '// Double Tap Time Variable
			MyLog("panHiddenApps_Touch Up = Action: " & Action, LogListColor, True)
	End Select
End Sub

Private Sub panHiddenApps_LongClick
	CloseHiddenManager
End Sub

Private Sub CloseHiddenManager
	
	Starter.LogShowToast = False
	MyLog("CloseHiddenManager", LogListColor, True)
	
	panHideManager.SetVisibleAnimated(300, False)
	Sleep(300)
	panHideManager.RemoveAllViews
	Starter.SetupAppsList(False)
'	SetupHomeList
End Sub

Private Sub clvHiddenApp_ItemClick (Index As Int, Value As Object)
	ClickSimulation
	CLVSelection.ItemClicked(Index)
End Sub

Private Sub LoadHiddenManager
	
	Starter.LogShowToast = False
	MyLog("LoadHiddenManager", LogListColor, True)
	
	CLVSelection.Initialize(clvHiddenApp)
	CLVSelection.Mode = CLVSelection.MODE_SINGLE_ITEM_PERMANENT
	
	Dim ResHidden As ResultSet = Starter.sql.ExecQuery("SELECT * FROM Apps WHERE IsHidden=1 ORDER BY Name ASC")
	clvHiddenApp.sv.Enabled = False
	clvHiddenApp.Clear
	For i = 0 To ResHidden.RowCount - 1
		ResHidden.Position = i
		
		Dim pkg As String = ResHidden.GetString("pkgName")
		
		Dim app As App
			app.PackageName = pkg
			app.Name = ResHidden.GetString("Name")
			app.index = i + 1
			app.Icon = Starter.GetPackageIcon(pkg)
			app.IsHomeApp = True
			app.IsHidden = True
		
		clvHiddenApp.AddTextItem(app.Name, app.PackageName)
	Next
	ResHidden.Close
	clvHome.sv.Enabled = True
End Sub

Private Sub btnHiddenApps_LongClick
	
	Msgbox2Async("Rebuild Applications ?", "Notice", "Yes", "", "No", Null, True)
	Wait For Msgbox_Result(Result As Int)
	
	Select Result
		Case DialogResponse.POSITIVE
			' User clicked "Yes"
			Starter.SetupAppsList(True)
			SetupHomeList
			LoadRecentlyList
			txtAppsSearch.Text = txtAppsSearch.Text
			CloseSetting
			ToastMessageShow("Apps Rebuild Successfully!", False)
			
		Case DialogResponse.NEGATIVE
			' User clicked "No"
			' Do nothing
	End Select
	
End Sub

Private Sub clvEdge_ItemClick (Index As Int, Value As Object)

	ClickSimulation
	If (Value.As(String) = "[SelectApp]") Then
		ToastMessageShow("Select..." & Value.As(String), False)
	Else
		RunApp(Value.As(String))
	End If

End Sub

Private Sub clvEdge_ItemLongClick (Index As Int, Value As Object)
	If (dragAllowEdge = False) Then
		dragAllowEdge = True
		draggerEdge.AddDragButtons
	Else
		draggerEdge.RemoveDragButtons
		dragAllowEdge = False
	End If
End Sub

Private Sub btnSetAsDefault_Click
	ClickSimulation
	SetDefaultLauncher
End Sub

Private Sub btnSetAsDefault_LongClick
	
	Msgbox2Async("Replace Database ?", "Notice", "Yes", "", "No", Null, True)
	Wait For Msgbox_Result(Result As Int)
	
	Select Result
		Case DialogResponse.POSITIVE
			' User clicked "Yes"
			Starter.CreateDB(True)
			Starter.SetupAppsList(True)
			SetupHomeList
			LoadRecentlyList
			txtAppsSearch.Text = txtAppsSearch.Text
			CloseSetting
			ToastMessageShow("Database Replaced and Apps Rebuild Successfully!", False)
			
		Case DialogResponse.NEGATIVE
			' User clicked "No"
			' Do nothing
	End Select
	
End Sub

Private Sub btnClose_Click
	ClickSimulation
	If (HiddenListChanged = True) Then
		txtAppsSearch_TextChanged("", txtAppsSearch.Text)
		HiddenListChanged = False
	End If
	CloseSetting
End Sub

Private Sub panHomRow_Touch (Action As Int, X As Float, Y As Float) As Boolean
	
'	Starter.ShowToastLog = False
'	MyLog("panHomRow_Touch", LogListColor, True)
	
	longClickClvIndex = clvHome.GetItemFromView(Sender)
	longClickClvPNL = clvHome.GetPanel(longClickClvIndex)
	
	Select Action
		Case 0 ' Down
			longClickClvPNL.SetColorAndBorder(Colors.Gray, 1dip, Colors.Blue, 15dip)
			ClickPanCLV = True
			
			MyLog("panHomRow_Touch Down", LogListColor, True)
			
			HideKeyboard
			HideHomeMenu(False)
			
				' Long Click
				longCLickFirstimeTouched = DateTime.Now
				longClickX0 = X
				longClickY0 = Y
				clvLongClick = 0
				TimerLongClick.Enabled = True
			
		Case 1 ' Up
			MyLog("panHomRow_Touch Up", LogListColor, True)
			
			TimerLongClick.Enabled = False
			If panHomRow.Tag = "" Then panHomRow.Tag = 0
			longClickClvPNL.SetColorAndBorder(panHomRow.Tag, 0, Colors.Blue, 15dip)
			If (ClickPanCLV) And (dragAllow = False) Then _
				clvHome_ItemClick(longClickClvIndex, clvHome.GetValue(longClickClvIndex))
			
		Case 3 ' Move
			TimerLongClick.Enabled = False
			If panHomRow.Tag = "" Then panHomRow.Tag = 0
			longClickClvPNL.SetColorAndBorder(panHomRow.Tag, 0, Colors.Blue, 15dip)
			
	End Select
	
	Return False
	
End Sub

Private Sub panAppRow_Touch (Action As Int, X As Float, Y As Float) As Boolean
	
'	MyLog("panAppRow_Touch", LogListColor, True)
	
	longClickClvIndex = clvApps.GetItemFromView(Sender)
	longClickClvPNL = clvApps.GetPanel(longClickClvIndex)
	
	Select Action
		Case 0 ' Down
			longClickClvPNL.SetColorAndBorder(Colors.Gray, 1dip, Colors.Blue, 15dip)
			ClickPanCLV = True
			
			
			HideAppMenu(True)
			
				' Long Click
				longCLickFirstimeTouched = DateTime.Now
				longClickX0 = X
				longClickY0 = Y
				clvLongClick = 1
				TimerLongClick.Enabled = True
			
			MyLog("panAppRow_Touch Down", LogListColor, True)
			
		Case 1 ' Up
			TimerLongClick.Enabled = False
			MyLog("panAppRow_Touch Up", LogListColor, True)
			If panAppRow.Tag = "" Then panAppRow.Tag = 0
			longClickClvPNL.SetColorAndBorder(panAppRow.Tag, 0, Colors.Blue, 15dip)
			If (ClickPanCLV) Then _
				clvApps_ItemClick(longClickClvIndex, clvApps.GetValue(longClickClvIndex))
			
		Case 3 ' Move
			TimerLongClick.Enabled = False
			If panAppRow.Tag = "" Then panAppRow.Tag = 0
			longClickClvPNL.SetColorAndBorder(panAppRow.Tag, 0, Colors.Blue, 15dip)
			
	End Select
	
	Return False
End Sub

Private Sub panHomeRowMenu_Touch (Action As Int, X As Float, Y As Float) As Boolean
	
'	Starter.ShowToastLog = False
'	MyLog("panHomeRowMenu_Touch", LogListColor, True)
	
	longClickClvIndex = clvHRowMenu.GetItemFromView(Sender)
	longClickClvPNL = clvHRowMenu.GetPanel(longClickClvIndex)
	
	Select Action
		Case 0 ' Down
			longClickClvPNL.SetColorAndBorder(Colors.Gray, 1dip, Colors.Blue, 15dip)
			
			MyLog("panHomeRowMenu_Touch Down", LogListColor, True)
			
			HideKeyboard
			
			XclvMenu = X
			YclvMenu = Y
			
		Case 1 ' Up
			MyLog("panHomeRowMenu_Touch Up", LogListColor, True)
			
			If panHomeRowMenu.Tag = "" Then panHomeRowMenu.Tag = 0
			longClickClvPNL.SetColorAndBorder(panHomeRowMenu.Tag, 0, Colors.Blue, 15dip)
			
			HideHomeMenu(True)
			
			Dim ix 			As Int = x
			Dim iy 			As Int = y
			Dim Tolerance 	As Int = 80
			
			Dim res_x 		As Int = XclvMenu - ix
			If (res_x < 0) Then res_x = res_x * -1
			
			Dim res_y 		As Int = YclvMenu - iy
			If (res_y < 0) Then res_y = res_y * -1
			
			If (Tolerance >= res_x) And (Tolerance >= res_y) Then _
				clvHRowMenu_ItemClick(longClickClvIndex, clvHRowMenu.GetValue(longClickClvIndex))
			
		Case 3 ' Move
			TimerLongClick.Enabled = False
			If panHomeRowMenu.Tag = "" Then panHomeRowMenu.Tag = 0
			longClickClvPNL.SetColorAndBorder(panHomeRowMenu.Tag, 0, Colors.Blue, 15dip)
			
	End Select
	
	Return True
	
End Sub

Private Sub panAppRowMenu_Touch (Action As Int, X As Float, Y As Float) As Boolean
	
'	Starter.ShowToastLog = False
'	MyLog("panAppRowMenu_Touch", LogListColor, True)
	
	longClickClvIndex = clvAppRowMenu.GetItemFromView(Sender)
	longClickClvPNL = clvAppRowMenu.GetPanel(longClickClvIndex)
	
	Select Action
		Case 0 ' Down
			longClickClvPNL.SetColorAndBorder(Colors.Gray, 1dip, Colors.Blue, 15dip)
			MyLog("panAppRowMenu_Touch Down", LogListColor, True)
			
			HideKeyboard
			
			XclvMenu = X
			YclvMenu = Y
			
		Case 1 ' Up
			MyLog("panAppRowMenu_Touch Up", LogListColor, True)
			
			If panAppRowMenu.Tag = "" Then panAppRowMenu.Tag = 0
			longClickClvPNL.SetColorAndBorder(panAppRowMenu.Tag, 0, Colors.Blue, 15dip)
			
			HideAppMenu(True)
			
			Dim ix 			As Int = x
			Dim iy 			As Int = y
			Dim Tolerance 	As Int = 80
			
			Dim res_x 		As Int = XclvMenu - ix
			If (res_x < 0) Then res_x = res_x * -1
			
			Dim res_y 		As Int = YclvMenu - iy
			If (res_y < 0) Then res_y = res_y * -1
			
			If (Tolerance >= res_x) And (Tolerance >= res_y) Then _
				clvAppRowMenu_ItemClick(longClickClvIndex, clvAppRowMenu.GetValue(longClickClvIndex))
			
		Case 3 ' Move
			TimerLongClick.Enabled = False
			If panAppRowMenu.Tag = "" Then panAppRowMenu.Tag = 0
			longClickClvPNL.SetColorAndBorder(panAppRowMenu.Tag, 0, Colors.Blue, 15dip)
			
	End Select
	
	Return False
	
End Sub

Private Sub lblClearSearch_Click
	
	MyLog("lblClearSearch_Click", LogListColor, True)
	
	'###
	'	 This Sleep(0) make allowed to see if other thread is still
	'	 running and loading clvApps listview
	Dim count As Int = clvApps.Size
	Sleep(0)
	If (clvApps.Size <> count) Then Return
	'###
	
	ClickSimulation
	lblClearSearch.Enabled = False
	If (Starter.Pref.ShowKeyboard) Then ShowKeyboard
	txtAppsSearch.Text = ""
	HideAppMenu(False)
	
	MyLog("lblClearSearch_Click END", LogListColorEnd, True)
	
End Sub


Private Sub panLog_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Private Sub panBattery_Click
	ClickSimulation
	Dim target As Int = Rnd(0, 101)
	cprBattery.Value = target
End Sub


Private Sub textAboutInfo_CrumbClick (Crumbs As List)
	LogColor(Crumbs.Get(Crumbs.Size - 1), Colors.Red)
	Dim ClickedItem As String = Crumbs.Get(Crumbs.Size - 1)
	Select ClickedItem
		Case "About":
			lblVersion_Click
		Case "Default":
			btnSetAsDefault_Click
		Case "Hidden":
			btnHiddenApps_Click
	End Select
End Sub

'Example:
'SetShadow(Pane1, 4dip, 0xFF757575)
'SetShadow(Button1, 4dip, 0xFF757575)
'
Public Sub SetShadow (View As B4XView, Offset As Double, Color As Int)
    #if B4J
    Dim DropShadow As JavaObject
	'You might prefer to ignore panels as the shadow is different.
	'If View Is Pane Then Return
    DropShadow.InitializeNewInstance(IIf(View Is Pane, "javafx.scene.effect.InnerShadow", "javafx.scene.effect.DropShadow"), Null)
    DropShadow.RunMethod("setOffsetX", Array(Offset))
    DropShadow.RunMethod("setOffsetY", Array(Offset))
    DropShadow.RunMethod("setRadius", Array(Offset))
    Dim fx As JFX
    DropShadow.RunMethod("setColor", Array(fx.Colors.From32Bit(Color)))
    View.As(JavaObject).RunMethod("setEffect", Array(DropShadow))
    #Else If B4A
	Offset = Offset * 2
	View.As(JavaObject).RunMethod("setElevation", Array(Offset.As(Float)))
    #Else If B4i
    View.As(View).SetShadow(Color, Offset, Offset, 0.5, False)
    #End If
End Sub


Private Sub chklogDebugMode_CheckedChange(Checked As Boolean)
	btnSetAsDefault.SetVisibleAnimated(400, Checked)
	btnHiddenApps.SetVisibleAnimated(400, Checked)
End Sub
