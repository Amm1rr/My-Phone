﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private panHome As B4XView
	Private panSetting As B4XView
	Private panApps As B4XView
	Private panHRowMenuHome As B4XView
	Private Tabstrip1 As TabStrip
	Private clvHome As CustomListView
	Private clvApps As CustomListView
	Private lblClock As Label
	Private lblDate As Label
	Private lblAppTitle As Label
	Private lblHomeAppTitle As Label
	Private lblAbout As Label
	Private lblVersion As Label
	Private chkShowIcons As CheckBox
	Private chkShowKeyboard As CheckBox
	Private imgPhone As B4XImageView
	Private imgCamera As B4XImageView
	Private btnSetting As Button
	Private btnDelete As Button
	Private cmbPhoneSetting As B4XComboBox
	Private cmbCameraSetting As B4XComboBox
	Private cmbClockSetting As B4XComboBox
	Private imgIconApp As ImageView
	Private clocktimer As Timer
	Public txtAppsSearch As AS_TextFieldAdvanced
	
	Public AppsList As List
	Private lstPackageNames As List
	Private RecentlyList As List
	Public HomeApps() As String	'-- Home Screen Apps
	Private ConfigFileName As String = "MyPhone.conf"
	Public AppRowHeigh As Int = 50dip
	Public HomeRowHeigh As Int = 50dip
	Public HomeRowHeighMenu As Int = 55dip
	Public AutoRunOnFind As Boolean
	Public LogMode As Boolean = True
	Public LogList As List
	Public FirstStart As Boolean = True
	Public ShowToastLog As Boolean = True
	
	Public StartTimeClick As Boolean = True
	Private dragAllow As Boolean = False
	
	Private YPos As Float
	Private XPos As Float
	
	Public Pref As Settings
	
	Type App(Name As String, _
			PackageName As String, _
			index As Int, _
			IsHomeApp As Boolean, _
			Icon As Bitmap)
	
	Type Settings(CameraApp As String, _
			 PhoneApp As String, _
			 ClockApp As String, _
			 ShowIcon As Boolean, _
			 ShowKeyboard As Boolean, _
			 AutoRunApp As Boolean, _
			 MyPackage As String, _
			 ShowIconHomeApps As Boolean)
	
	Public Manager As AdminManager
	Private movecount As Int
	Private LastClick As Long
	Private gestHome As Gestures
	Private dragger As CLVDragger
	Private IMElib As IME
	Private dd As DDD
	
	Public clvHRowMenu As CustomListView
	Public AppMenu As ListView
	
	Public CurrentAppApp As App
	Public CurrentHomeApp As App
	
	Private lblInfo As Label
	Public tagApps As ASScrollingTags
	Private chkAutoRun As CheckBox
	Public lblSetAsDefaultLauncher As Label
	Private lblVersionHome As Label
	Private panLog As Panel
	Private clvLog As CustomListView
	Private btnLogClose As Button
	Private chkShowToastLog As CheckBox
	Private imgIconHome As ImageView
	Private chkShowIconsHome As CheckBox
End Sub

Public Sub MyLog (Text As String)
	If (LogMode) Then
'		Dim txtWriter As TextWriter
'		txtWriter.Initialize(File.OpenOutput(File.DirInternalCache, "MyLog.log", True))
'			txtWriter.WriteList(LogList)
'			txtWriter.Close
'		File.WriteString(File.DirInternalCache, "MyLog.log", Text)
		LogList.Add(Text)
		Log(Text)
		If (ShowToastLog) Then ToastMessageShow(Text, False)
	End If
End Sub

Public Sub Initialize
	B4XPages.GetManager.LogEvents = True
	If Not (LogList.IsInitialized) Then LogList.Initialize

	MyLog("Func: Initialize")
	
	StartTimeClick = True
	
	dd.Initialize
	'The designer script calls the DDD class. A new class instance will be created if needed.
	'In this case we want to create it ourselves as we want to access it in our code.
	xui.RegisterDesignerClass(dd)
	
	IMElib.Initialize("")
	
	Dim Setting As KeyValueStore
	Setting.Initialize(File.DirInternal, ConfigFileName)
	Dim apps As String = Setting.GetDefault("HomeApps", "")
	HomeApps = Regex.Split("\|", apps)
	
	If Not (RecentlyList.IsInitialized) Then _
		RecentlyList.Initialize
	
	Pref.CameraApp = Setting.GetDefault("CameraApp", "")
	Pref.PhoneApp = Setting.GetDefault("PhoneApp", "")
	Pref.ClockApp = Setting.GetDefault("ClockApp", "")
	Pref.ShowIcon = Setting.GetDefault("ShowIcon", False).As(Boolean)
	Pref.ShowIconHomeApps = Setting.GetDefault("ShowIconHomeApp", False).As(Boolean)
	Pref.ShowKeyboard = Setting.GetDefault("ShowKeyboard", True).As(Boolean)
	Pref.AutoRunApp = Setting.GetDefault("AutoRunApp", True)
	Pref.MyPackage = "my.phone"
	
	ShowToastLog = Setting.GetDefault("ShowToastLog", True).As(Boolean)
	
	DateTime.TimeFormat = "hh:mm:ss"
	lblClock.Initialize("")
	lblClock.Text = DateTime.Time(DateTime.Now)
	
	lblDate.Initialize("")
	DateTime.DateFormat = "dd.MMM.yyyy"
	lblDate.Text = DateTime.Time(DateTime.Now)
	
	clocktimer.Initialize("clocktimer", 1000)
	clocktimer.Enabled = True
	
	If Not (panLog.IsInitialized) Then panLog.Initialize("panLog")
	
End Sub

Private Sub clocktimer_Tick
	lblClock.Text = DateTime.Time(DateTime.Now)
	lblDate.Text = DateTime.Date(DateTime.Now)
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	MyLog("Event: B4XPage_Created")
	
	Root = Root1
	Root.LoadLayout("MainPage")
	
	FixWallTrans
	
	Tabstrip1.LoadLayout("Home", "Home")
	Tabstrip1.LoadLayout("Apps", "Apps")
	
	lblVersionHome.Text = Application.LabelName & " " & Application.VersionCode & " " & Application.VersionName
	
	If (FirstStart) Then
	
		SetupInstalledApps
		
		LoadRecentlyList
		
		imgPhone.Load(File.DirAssets, "Phone.png")
		imgCamera.Load(File.DirAssets, "Camera.png")
		
		gestHome.SetOnTouchListener(panHome, "gestHome_gesture")
'		gestHomeList.SetOnTouchListener(clvHome.AsView, "gestHomeList_gesture")
'		gestSetting.SetOnTouchListener(panSetting, "gestSetting_gesture")
		
		'//-- After Screen On, set as top on other apps
		Dim jo As JavaObject = Root
		Dim Window As JavaObject = jo.RunMethodJO("getContext", Null).RunMethod("getWindow", Null)
		Window.RunMethod("addFlags", Array As Object(524288)) 'FLAG_SHOW_WHEN_LOCKED
		Window.RunMethod("addFlags", Array As Object(128)) 'FLAG_KEEP_SCREEN_ON
		'//--
		
		dragger.Initialize(clvHome)
		
		If Pref.ShowIcon Then
			imgIconApp.Visible = True
			lblAppTitle.Left = 35dip
		Else
			imgIconApp.Visible = False
			lblAppTitle.Left = 5dip
		End If
		If Pref.ShowIconHomeApps Then
			imgIconHome.Visible = True
			lblAppTitle.Left = 35dip
		Else
			imgIconHome.Visible = False
			lblAppTitle.Left = 5dip
		End If
		StartTimeClick = False
		
		If (GetDefaultLauncher <> Pref.MyPackage) Then _
			lblSetAsDefaultLauncher.Visible = True
		
		StartService(Starter)
		
		FirstStart = False
	Else
		FirstStart = False
	End If
	
End Sub

Private Sub Run_Info(PackageName As String)
	MyLog("Func: Run_Info => " & PackageName)
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

Private Sub gestSetting_gesture(o As Object, ptrID As Int, action As Int, x As Float, y As Float) As Boolean
	MyLog("Event: gestSetting_gesture")
	If (DblClick) Then
		'// Double Tap
		If (DateTime.Now - LastClick) < 250 Then
			DoubleTap
			CloseSetting
		End If
	End If
	
	Return True
End Sub

Private Sub gestHomeList_gesture(o As Object, ptrID As Int, action As Int, x As Float, y As Float) As Boolean
	MyLog("Event: gestHomeList_gesture")
	DisableDragAndDrop
	XPos = x
	YPos = y
	Return True
End Sub

Private Sub gestHome_gesture(o As Object, ptrID As Int, action As Int, x As Float, y As Float) As Boolean
'	MyLog("Event: gestHome_gesture")
	DisableDragAndDrop
	If action = gestHome.ACTION_MOVE Then
		movecount = movecount + 1
		' noise on the touch screen electroincs can cause lots of apparent move events
		' this loop slows the rate down to one comfortable for LogCat
		' adjust the value for your device if necessary
		If movecount < 10 Then
			Return True ' need to return true otherwise we don't get any other events in the gesture
		End If
		movecount = 0
	End If
	
	Dim v As View
	v = o
	Dim a As String = action
	
	Select action
		Case gestHome.ACTION_DOWN
			a = "Down "
'			Log("Gesture started")
			
'			'// Double Tap
'			If (DateTime.Now - LastClick) < 250 Then
''				Log("Double Click => " & (DateTime.Now - LastClick))
'				DoubleTap
'			End If
			If DblClick Then DoubleTap
			
		Case gestHome.ACTION_UP
			'// Double Tap Time Variable
			LastClick = DateTime.Now
			
			a = "Up "
			
		Case gestHome.ACTION_POINTER_DOWN
			a = "PtrDown "
		Case gestHome.ACTION_POINTER_UP
			a = "PtrUp "
		Case gestHome.ACTION_MOVE
			a = "Move "
	End Select
	Dim ix, iy, count As Int
	ix = x
	iy = y
	count = gestHome.GetPointerCount
	Dim msg As String = v.Tag & " id" & ptrID & " " & a & " x" & ix & " y" & iy & " cnt" & count' event parameters
	Dim id As Int
	For i = 0 To count -1
		id = gestHome.GetPointerID(i)
		ix = gestHome.GetX(id)
		iy = gestHome.GetY(id)
		msg = msg & " : id" & id & " x" & ix & " y" & iy ' retrieved data
	Next
	
'	Log(msg)
	If action = gestHome.ACTION_UP Then
'		Log("Gesture ended")
	End If
	Return True ' need to return true otherwise we don't get any other events in the gesture
End Sub

'Private Sub Activity_Resume
'	MyLog("Event: Activity_Resume")
'	If (GetDefaultLauncher <> Pref.MyPackage) Then _
'		lblSetAsDefaultLauncher.Visible = True
'End Sub
'
'Private Sub Activity_Pause(UserClosed As Boolean)
'	MyLog("Event: Activity_Pause")
'	If (B4XPages.MainPage.GetDefaultLauncher <> B4XPages.MainPage.Pref.MyPackage) Then _
'		B4XPages.MainPage.lblSetAsDefaultLauncher.Visible = True
'	GoHome(False)
'End Sub

Private Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	MyLog("Event Activity_KeyPress & => " & KeyCode)
	Select KeyCode
		Case KeyCodes.KEYCODE_BACK
			GoHome(False)
'			Return True
		Case KeyCodes.KEYCODE_HOME
			GoHome(True)
'			Return True
	End Select
	Return True
End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

' How to User:
' FontToBitmap(Chr(0xF013), False, 28b, Colors.White)
' 
Public Sub FontToBitmap (text As String, IsMaterialIcons As Boolean, FontSize As Float, color As Int) As B4XBitmap
	Dim xui As XUI
	Dim p As Panel = xui.CreatePanel("")
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

Public Sub GoHome(ClearSearch As Boolean)
	MyLog("Func: GoHome & => ClearSearch" & ClearSearch.As(String))
	Try
		Tabstrip1.ScrollTo(0, True)
		DisableDragAndDrop
'		If (HomeMenu.IsInitialized) Then HomeMenu.Visible = False
'		If (AppMenu.IsInitialized) Then AppMenu.Visible = False
'		If ClearSearch Then txtAppsSearch.Text = ""
		ShowHideKeyboard(False)
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
End Sub

Private Sub FixWallTrans
'	MyLog("Func: FixWallTrans")
	'------{ ### Set Navigation Bar Transparent
	Dim jo As JavaObject
	Dim window As JavaObject = jo.InitializeContext.RunMethod("getWindow", Null)
	window.RunMethod("addFlags", Array(Bit.Or(0x00000200, 0x08000000)))
	Root.Height = Root.Height + 24dip
	'}-----
	
	'{----- ### Fix Wallpaper
	Dim r As Reflector
	r.Target = r.RunStaticMethod("android.app.WallpaperManager", "getInstance", Array As Object(r.GetContext), Array As String("android.content.Context"))
	
	r.RunMethod4("suggestDesiredDimensions", Array As Object(Root.Width * 2, Root.height), Array As String("java.lang.int", "java.lang.int"))
	Dim pagesx As Float
	
	Dim pagesy As Float
	pagesx = 1.00 / 5
	pagesy = 1.00
	r.RunMethod4("setWallpaperOffsetSteps", Array As Object(pagesx, pagesy), Array As String("java.lang.float", "java.lang.float"))
	'}-----
End Sub

Private Sub TabStrip1_PageSelected (Position As Int)
'	MyLog("Event: TabStrip1_pageSelected")
	Log($"Current page: ${Position}"$)
	DisableDragAndDrop
	CloseSetting
	If (Position = 1) Then
		MyLog("Event: TabStrip1_pageSelected => ShowHideKey(True)")
		If Pref.ShowKeyboard Then ShowHideKeyboard(True)
	Else
		Try
			MyLog("Event: TabStrip1_pageSelected => ShowHideKey(False)")
			ShowHideKeyboard(False)
		Catch
			MyLog("Event: TabStrip1_pageSelected => Error Caught => " & LastException.Message)
			ToastMessageShow(LastException.Message, True)
			Log("Error Caught: " & LastException)
		End Try
	End If
End Sub

Private Sub clvApps_ItemClick (Position As Int, Value As Object)
	MyLog("Event clvApps_ItemClick & => " & Value)
	ConfigCurrentAppApp(Position, Value)
	
	If (AppMenu.IsInitialized And AppMenu.Visible) Then
		DisableDragAndDrop
	Else
		RunApp(Value.As(String))
		clvApps.AsView.BringToFront
'		tagApps.LabelProperties.TextColor = Colors.Magenta
		AddToRecently(CurrentAppApp.Name, CurrentAppApp.PackageName)
		SaveRecentlyList
	End If
End Sub

Private Sub SaveRecentlyList
	MyLog("Func: SaveRecentlyList")
	Dim setting As KeyValueStore
	setting.Initialize(File.DirInternal, ConfigFileName)
	
	Dim Str As StringBuilder
	Str.Initialize
	
	Dim i As Int = 0
	For i = 0 To RecentlyList.Size - 1
		Str.Append(RecentlyList.Get(i)).Append("|")
	Next
	setting.Put("RecentlyApps", Str.ToString)
End Sub

Private Sub LoadRecentlyList
	MyLog("Func: LoadRecentlyList")
	Dim setting As KeyValueStore
	setting.Initialize(File.DirInternal, ConfigFileName)
	
	tagApps.CLV.Clear
	Dim apps As String = setting.GetDefault("RecentlyApps", "")
	If apps = "" Then Return
	
	Dim tmpTags() As String = Regex.Split("\|", apps)
	
	Dim i As Int = 0
	For i = 0 To tmpTags.Length - 1
		AddToRecently(GetAppNamebyPackage(tmpTags(i)), tmpTags(i))
	Next
	
End Sub

Private Sub FindRecentlyItem(pkgName As String) As Boolean
	MyLog("Func: FindRecentlyItem & => " & pkgName)
	Dim i As Int = 0
	For i = 0 To tagApps.CLV.Size - 1
		If (tagApps.CLV.GetValue(i) = pkgName) Then Return True
	Next
	Return False
End Sub

Public Sub AddToRecently(Text As String, Value As String)
	MyLog("Func: AddToRecently & => " & Value)
	
'	tagApps.CLV.AddTextItem(Text, Value)
	
'	If (RecentlyList.Size > 0) Then
'		If (Value = tagApps.CLV.GetValue(tagApps.CLV.Size - 0)) Then Return
'		If (Value = RecentlyList.Get(RecentlyList.Size - 1)) Then Return
'	End If

'	If PhEvent Then
''		Log(Value)
'		Value = Value.SubString(8)
''		Log(Value)
'		Text = GetAppNamebyPackage(Value)
''		Log("Text: " & Text)
'		ToastMessageShow("Text: " & Text, True)
'	End If

	Dim tagColors As Int = Colors.DarkGray
	
	'//-- Check if This Function Called from Service
	'//-- If Text is "" , that is mean it's called from Service
	'//-- 
	If Text = "" Then
		Value = Value.SubString(8)
		Text = GetAppNamebyPackage(Value)
		tagColors = Colors.DarkGray
		tagApps.LabelProperties.TextColor = Colors.Yellow
	Else
		tagColors = Colors.DarkGray
		tagApps.LabelProperties.TextColor = Colors.White
	End If
	
	If (FindRecentlyItem(Value)) Then Return
	If Not (Is_NormalApp(Value)) Then Return
	
	If (RecentlyList.Size < 5) And (RecentlyList.Size > 0) Then
'		If (Value = tagApps.CLV.GetValue(tagApps.CLV.Size - 1)) Then Return
'		If (Value = RecentlyList.Get(RecentlyList.Size - 1)) Then Return
		
		tagApps.AddTag(Text, tagColors, Value)
		RecentlyList.Add(Value)
		
'		Dim lstReverse As List = ReverseList(RecentlyList)
'		RecentlyList = lstReverse
'		tagApps.CLV.Clear
'		For Each item In lstReverse
'			tagApps.AddTag(GetAppNamebyPackage(item), Colors.DarkGray, item)
'		Next
		
	Else If (RecentlyList.Size >= 5) Then
'		If (Value = tagApps.CLV.GetValue(tagApps.CLV.Size - 1)) Then Return
'		If (Value = RecentlyList.Get(RecentlyList.Size - 1)) Then Return
		
		
		tagApps.mBase.Enabled = False
		tagApps.CLV.Clear
		
		tagApps.AddTag(Text, tagColors, Value)
		tagApps.AddTag(GetAppNamebyPackage(RecentlyList.Get(0)), tagColors, RecentlyList.Get(0))
		tagApps.AddTag(GetAppNamebyPackage(RecentlyList.Get(1)), tagColors, RecentlyList.Get(1))
		tagApps.AddTag(GetAppNamebyPackage(RecentlyList.Get(2)), tagColors, RecentlyList.Get(2))
		tagApps.AddTag(GetAppNamebyPackage(RecentlyList.Get(3)), tagColors, RecentlyList.Get(3))
		
		Dim i0 As Object = RecentlyList.Get(0)
		Dim i1 As Object = RecentlyList.Get(1)
		Dim i2 As Object = RecentlyList.Get(2)
		Dim i3 As Object = RecentlyList.Get(3)
		
		RecentlyList.Clear
		RecentlyList.Add(Value)
		RecentlyList.Add(i0)
		RecentlyList.Add(i1)
		RecentlyList.Add(i2)
		RecentlyList.Add(i3)
		
		tagApps.mBase.Enabled = True
		
	Else
		
		tagApps.AddTag(Text, tagColors, Value)
		RecentlyList.Add(Value)
		
	End If
	
	SaveRecentlyList
	
End Sub

Private Sub ReverseList(lst As List) As List
	Dim java As JavaObject
	java.InitializeStatic("java.util.Collections").RunMethod("reverse", Array(lst))
	Return lst
End Sub

Public Sub RemoveAsRecently (Value As Object)
'							(Index As Int)
	
	
	If Value.As(String).SubString(8) = "package:" Then
		Value = Value.As(String).SubString(8)
	End If
	
	MyLog("Func: RemoveAsRecently => " & Value.As(String))
	
	Dim i As Int
	For i = 0 To RecentlyList.Size - 1
		If RecentlyList.Get(i) = Value Then
			tagApps.CLV.RemoveAt(i)
			RecentlyList.RemoveAt(i)
			MyLog("Func: RemoveAsRecently => " & Value.As(String) & " - Removed.")
			Exit
		End If
	Next
	
	SaveRecentlyList
	
'	For Each ap In RecentlyList
'		If ap = tagApps.CLV.GetValue(Index) Then
'			tagApps.CLV.RemoveAt(Index)
'			RecentlyList.RemoveAt(Index)
'			Exit
'		End If
'	Next
	
End Sub

Private Sub clvApps_ItemLongClick (Position As Int, Value As Object)
	MyLog("Event clvApps_ItemLongClick - ShowHideKeyboard(False)")
	ShowHideKeyboard(False)
	ConfigCurrentAppApp(Position, Value.As(String))
	CreateAppMenu(Position, Value)
End Sub

Private Sub clvHome_ItemClick (Position As Int, Value As Object)
'	MyLog("Event: clvHome_ItemClick")
	If (dragAllow = False) Then
'		If (HomeMenu.IsInitialized = True) Then
'			If (HomeMenu.Visible = False) Then
				ConfigCurrentHomeApp(Position, Value.As(String))
'				CurrentHomeApp.Name = clvHome.GetPanel(Position).GetView(0).Text
				clvHome.AsView.BringToFront
				RunApp(CurrentHomeApp.PackageName)
'			End If
'		End If
	End If
	DisableDragAndDrop
End Sub

Private Sub ConfigCurrentAppApp(Position As String, Value As String)
'	MyLog("Func: ConfigCurrentAppApp")
	CurrentAppApp.index = Position
	CurrentAppApp.PackageName = Value.As(String)
	CurrentAppApp.Name = clvApps.GetPanel(Position).GetView(0).Text
End Sub

Private Sub ConfigCurrentHomeApp(Position As String, Value As String)
'	MyLog("Func: ConfigCurrentAppApp")
	CurrentHomeApp.index = Position
	CurrentHomeApp.PackageName = Value.As(String)
'	Dim pnl As B4XView = clvHome.GetPanel(Position)
'	CurrentHomeApp.Name = pnl.GetView(0).Text
End Sub

Private Sub clvHome_ItemLongClick (Position As Int, Value As Object)
	MyLog("Event: clvHome_ItemLongClick")
	If (dragAllow = False) Then
		ConfigCurrentHomeApp(Position, Value.As(String))
		CreateHomeMenu(Position, Value)		
	Else
		dragger.RemoveDragButtons
		dragAllow = False
	End If
End Sub

Private Sub CreateHomeMenu(Position As Int, Value As Object)
	MyLog("Func: CreateHomeMenu")
	ConfigCurrentHomeApp(Position, Value.As(String))
	
	panHRowMenuHome.RemoveAllViews
	panHRowMenuHome.RequestFocus
	panHRowMenuHome.LoadLayout("HomeRowMenu")
	panHRowMenuHome.Enabled = True
	panHRowMenuHome.BringToFront
	panHRowMenuHome.Visible = True
	
	clvHRowMenu.Clear
'	clvHRowMenu.sv.SetColorAndBorder(Colors.White, 2dip, Colors.DarkGray, 20dip)
'	clvHRowMenu.sv.SetColorAnimated(300, Colors.LightGray, Colors.DarkGray)
	clvHRowMenu.AddTextItem("Info", "Info")
	clvHRowMenu.AddTextItem("Delete", "Delete")
	clvHRowMenu.AddTextItem("Sort", "Sort")
	
	Dim lft As Int
	Dim tp As Int
	Dim wdh As Int
	Dim hig As Int
	
	wdh = 50%x
	HomeRowHeighMenu = 55dip
	
	lft = (panHome.Width / 2) + (wdh  / 2)
	hig = (clvHRowMenu.Size * HomeRowHeighMenu) '- HomeRowHeigh / 4
	
	panHRowMenuHome.Left = lft '(panHome.Width - clvHRowMenu.sv.Width) + 8dip
	panHRowMenuHome.Width = 50%x / 2
	
	tp = (panHome.Height / 2) - (hig / 2)
		panHRowMenuHome.Top = tp + 50dip
		panHRowMenuHome.Height = hig
	clvHRowMenu.sv.Height = hig
	clvHRowMenu.sv.Width = wdh
	clvHRowMenu.sv.Left = 10dip
'	Log("X: " & XPos)
'	Log("Y: " & YPos)

End Sub

Private Sub CreateAppMenu(Position As Int, Value As Object)
	MyLog("Func: CreateAppMenu => " & Value.As(String))
	DisableDragAndDrop
	ConfigCurrentAppApp(Position, Value.As(String))
	If (AppMenu.IsInitialized) Then
		AppMenu.Visible = True
	Else
		AppMenu.Initialize("AppMenu")
		AppMenu.SetColorAnimated(300, Colors.Gray, Colors.DarkGray)
		AppMenu.AddSingleLine("Info")
		AppMenu.AddSingleLine(CurrentAppApp.Name)
		If (FindHomeItem(CurrentAppApp.PackageName) = False) Then
			AppMenu.AddSingleLine("Add to Home")
		Else
			AppMenu.AddSingleLine("Remove from Home")
		End If
		AppMenu.AddSingleLine("Uninstall")
		AppMenu.AddSingleLine("Hide")
		AppMenu.AddSingleLine("Rename")
		
		Dim lft As Int
		Dim tp As Int
		Dim wdh As Int
		Dim hig As Int
		
		wdh = 50%x
		hig = (AppMenu.Size * AppRowHeigh) + AppRowHeigh / 4
		
		lft = (panApps.Width / 2) - (wdh / 2)
		tp = (panApps.Height / 2) - (hig / 2)
		
		Root.AddView(AppMenu, lft, tp, wdh, hig)
	End If
End Sub

Private Sub clvHRowMenu_ItemClick (Position As Int, Value As Object)
	MyLog("Event: clvRowMenu_Click => " & Value.As(String))
	DisableDragAndDrop
	dragAllow = False
	
	Select Value
		Case "Info"
			Run_Info(CurrentHomeApp.PackageName)
'			CurrentHomeApp.index = -1
		Case "Delete"
			clvHome.RemoveAt(CurrentHomeApp.index)
			SaveHomeList
'			CurrentHomeApp.index = -1
			Log("Delete " & CurrentHomeApp.PackageName)
			ToastMessageShow("Delete " & CurrentHomeApp.PackageName, False)
		Case "Sort"
			dragAllow = True
			dragger.SetDefaults(50dip, xui.Color_Black, xui.Color_White)
			dragger.AddDragButtons
	End Select
	
End Sub

Private Sub AppMenu_ItemClick (Postion As Int, Value As Object)
	MyLog("Event: AppMenu_ItemClick")
	AppMenu.Visible = False
	Sleep(0)
	Select Value
		Case "Info"
			Run_Info(CurrentAppApp.PackageName)
			
		Case "Add to Home"
			If (FindHomeItem(CurrentHomeApp.PackageName) = False) Then
				clvHome.Add(CreateListItemHome(CurrentAppApp.Name, CurrentAppApp.PackageName, clvHome.sv.Width, HomeRowHeigh), CurrentAppApp.PackageName)
				SaveHomeList
			End If
		
		Case "Remove from Home"
			RemoveHomeItem(CurrentAppApp.PackageName)
			SaveHomeList
			
		Case CurrentAppApp.Name
			RunApp(CurrentAppApp.PackageName)
			
		Case "Uninstall"
			UninstallApp(CurrentAppApp.PackageName)
			
		Case "Hide"
			
		Case "Rename"
			
	End Select
'	CurrentAppApp.index = -1
End Sub

Public Sub UninstallApp(pkgName As String)
	MyLog("Func: UninstallApp")
	
	Dim im As Intent
'	If (pkgName.SubString(8) <> "package:") Then pkgName = "package:" & pkgName
	im.Initialize("android.intent.action.DELETE", "package:" & pkgName)
	
	StartActivity(im)
	
End Sub

Sub GetPackageIcon(PackageName As String) As Bitmap
	Dim PM As PackageManager, Data As Object = PM.GetApplicationIcon(PackageName)
	If Data Is BitmapDrawable Then
		Dim Icon As BitmapDrawable = Data
		Return Icon.Bitmap
	Else
		Return GetBmpFromDrawable(Data, 48dip)
	End If
End Sub

Sub GetBmpFromDrawable(Drawable As Object, Size As Int) As Bitmap
	Dim BMP As Bitmap, BG As Canvas, Drect As Rect
	BMP.InitializeMutable(Size,Size)
	Drect.Initialize(0,0,Size,Size)
	BG.Initialize2(BMP)
	BG.DrawDrawable(Drawable,Drect)
	Return BG.Bitmap
End Sub

Private Sub CreateListItemApp(Text As String, _
							  Tag As String, _
							  Width As Int, _
							  Height As Int, _
							  icon As Bitmap) As Panel
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	p.LoadLayout("AppRow")
	
	'Note that we call DDD.CollectViewsData in AppRow designer script. This is required if we want to get views with dd.GetViewByName. 
	dd.GetViewByName(p, "lblAppTitle").Text = Text.Trim
	dd.GetViewByName(p, "lblAppTitle").Tag = Tag.Trim
'	lblAppTitle.Text = Text

	If Pref.ShowIcon Then
		imgIconApp.Visible = True
		lblAppTitle.Left = 35dip
	Else
		imgIconApp.Visible = False
		lblAppTitle.Left = 5dip
	End If
	
	Try
		imgIconApp.Bitmap = icon
	Catch
		Log("CreateListItemApp-Icon=> " & LastException)
	End Try
	
	Return p
	
End Sub

Private Sub CreateListItemHome(Text As String, _
							   Value As String, _
							   Width As Int, _
							   Height As Int) As Panel
	
	Dim p As B4XView = xui.CreatePanel("")
	
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	p.LoadLayout("HomeRow")
	
	'Note that we call DDD.CollectViewsData in HomeRow designer script. This is required if we want to get views with dd.GetViewByName. 
	dd.GetViewByName(p, "lblHomeAppTitle").Text = Text
	dd.GetViewByName(p, "lblHomeAppTitle").Tag = Value
	
	If Pref.ShowIconHomeApps Then
		imgIconHome.Visible = True
		lblHomeAppTitle.Left = 35dip
	Else
		imgIconHome.Visible = False
		lblHomeAppTitle.Left = 5dip
	End If
	
	Try
		imgIconHome.Bitmap = GetPackageIcon(Value)
	Catch
		Log("CreateListItemHome-Icon=> " & LastException)
	End Try
	
	Return p
End Sub

Private Sub txtAppsSearch_TextChanged(Text As String)
	Dim i As Int
	Dim AppCount As Int
	clvApps.Clear
	For i = 0 To AppsList.Size - 1
		Dim Ap As App
		Ap = AppsList.Get(i)
		If Ap.Name.ToLowerCase.Contains(txtAppsSearch.Text.ToLowerCase) = True Then
			clvApps.Add(CreateListItemApp(Ap.Name, Ap.PackageName, clvApps.AsView.Width, AppRowHeigh, Ap.Icon), Ap.PackageName.As(String))
			AppCount = AppCount + 1
		End If
	Next
	
	If (txtAppsSearch.Text = Text) And (AppCount = 1) Then
		If (Pref.AutoRunApp) Then
			Dim pkg As String = clvApps.GetValue(0).As(String)
			RunApp(pkg)
			AddToRecently(GetAppNamebyPackage(pkg), pkg)
		End If
	End If
	
	lblInfo.Text = AppCount & " apps"
	
End Sub

Public Sub Is_NormalApp(pkgName As String) As Boolean
	Dim pm As PackageManager
	Dim packages As List
	packages = pm.GetInstalledPackages
	
	
	For i = 0 To packages.Size - 1
		Dim p As String = packages.Get(i)
		
		'//-- This will test whether the app is a 'regular' app that
		'//-- can be launched and if so you can then show it in your app drawer.
		'//-- If the app has been uninstalled, or if it isn't for normal use,
		'//-- then it will return false.
		If (p = pkgName) Then
			If pm.GetApplicationIntent(p).IsInitialized Then Return True
		End If
	Next
	
	Return False
	
End Sub

Public Sub SetupInstalledApps
	
	MyLog("Func: SetupInstalledApps")

'	Dim args(1) As Object
'	Dim Obj1, Obj2, Obj3 As Reflector
'	Dim size, i, flags As Int
'	Dim Types(1), name, packName As String
'	
'	Obj1.Target = Obj1.GetContext
'	Obj1.Target = Obj1.RunMethod("getPackageManager") ' PackageManager
'	Obj2.Target = Obj1.RunMethod2("getInstalledPackages", 0, "java.lang.int") ' List<PackageInfo>
'	size = Obj2.RunMethod("size")
	
	'##
	'## Create a List (AppsList) as Installed Softwares 
	'##	and Sorting that to add ListBox control.
	'##
	
	If Not (AppsList.IsInitialized) Then AppsList.Initialize
	
	AppsList.Clear
	
	Dim sortindex As Int
	
	Dim i As Int
	Dim pm As PackageManager
	Dim packages As List
	packages = pm.GetInstalledPackages
	
	
	Dim setting As KeyValueStore
	setting.Initialize(File.DirInternal, ConfigFileName)
	Dim AppSize As Int = setting.GetDefault("AppSize", -1).As(Int)
	Dim Str As StringBuilder
	Str.Initialize
	
	If AppSize = packages.Size Then
		
		Dim apps As String = setting.GetDefault("Apps", "").As(String)
		Dim strApps() As String = Regex.Split("\|", apps)
		
		Dim i As Int
		For i = 0 To strApps.Length - 1
			
			Dim currentapp As App
			currentapp.PackageName = strApps(i)
			currentapp.Name = GetAppNamebyPackage(currentapp.PackageName)
			sortindex = sortindex + 1
			currentapp.index = sortindex
				
			Try
				currentapp.Icon = GetPackageIcon(currentapp.PackageName)
			Catch
				Log("SetupInstalledApps Second - Icon => " & LastException)
			End Try
				
			If (Is_HomeApp(currentapp.PackageName)) Then
				currentapp.IsHomeApp = True
				clvHome.Add(CreateListItemHome(currentapp.Name, currentapp.PackageName, clvHome.AsView.Width, HomeRowHeigh), currentapp.PackageName)
			End If
				
			AppsList.Add(currentapp)
			
		Next
		
	Else
	
		For i = 0 To packages.Size - 1
			Dim p As String = packages.Get(i)
			
			'//-- This will test whether the app is a 'regular' app that 
			'//-- can be launched and if so you can then show it in your app drawer.
			'//-- If the app has been uninstalled, or if it isn't for normal use,
			'//-- then it will return false.
			If pm.GetApplicationIntent(p).IsInitialized Then
				Dim currentapp As App
				currentapp.Name = pm.GetApplicationLabel(p)
				currentapp.PackageName = p
				sortindex = sortindex + 1
				currentapp.index = sortindex
				
				Str.Append(p & "|")
				
				Try
					currentapp.Icon = GetPackageIcon(p)
				Catch
					Log("SetupInstalledApps - Icon => " & LastException)
				End Try
				
				If (Is_HomeApp(currentapp.PackageName)) Then
					currentapp.IsHomeApp = True
					
					'//-- Here We Can add Home apps to HomeListView
					'//-- but to solve sort home list as saved
					'//-- We add Home List Apps after Sort them.
					'//-- Performance and Loading Time are same.
	'				Dim r As Reflector
	'				r.Target = currentapp
	'				clvHome.Add(CreateListItemHome(currentapp.Name, currentapp.PackageName, clvHome.AsView.Width, HomeRowHeigh), currentapp.PackageName)
				End If
				
				AppsList.Add(currentapp)
			End If
		Next
		
		
		'//-- 			[Installed Apps]
		'//-- #####################################
		'//-- Alternative Mehtod for Get Installed Apps List
		'//-- ,by Calling Java Functions --//
	'	
	'	For i = 0 To size - 1
	'		Obj3.Target = Obj2.RunMethod2("get", i, "java.lang.int") ' PackageInfo
	'		packName = Obj3.GetField("packageName")
	'
	'		Obj3.Target = Obj3.GetField("applicationInfo") ' ApplicationInfo
	'		flags = Obj3.GetField("flags")
	'		
	''		If Bit.And(flags, 1) = 0 Then '//-- Only Show Installed apps by User
	'		If Bit.And(flags, 0) = 0 Then '//-- Show All Apps, Include System Apps
	'			args(0) = Obj3.Target
	'			Types(0) = "android.content.pm.ApplicationInfo"
	'			name = Obj1.RunMethod4("getApplicationLabel", args, Types)
	'			
	''			Try
	''				Dim icon As BitmapDrawable
	''				icon = Obj1.RunMethod4("getApplicationIcon", args, Types)
	''			Catch
	''				Log("Icon SetupInstalledApps - " & LastException)
	''			End Try
	'			
	'			Dim currentapp As App
	'			currentapp.Name = name
	'			currentapp.PackageName = packName
	'			sortindex = sortindex + 1
	'			currentapp.index = sortindex
	''			currentapp.Icon = icon
	'			
	'			If (Is_HomeApp(currentapp.PackageName)) Then currentapp.IsHomeApp = True
	'			
	'			AppsList.Add(currentapp)
	'			
	'		End If
	'	Next

		'//-- End of Alternative Method for Get Installed Apps
		'//-- #####################################
		'//-- 			[Installed Apps]	   --//
		
		
		'-- Add Apps to Home ListView
		clvHome.Clear
		Dim i As Int
		For i = 0 To HomeApps.Length - 1
			For Each app In AppsList
				Dim ap As App = app
				If HomeApps(i) = ap.PackageName Then
					clvHome.Add(CreateListItemHome(ap.Name, ap.PackageName, clvHome.AsView.Width, HomeRowHeigh), ap.PackageName)
					Exit
				End If
			Next
		Next
		
		AppsList.SortTypeCaseInsensitive("Name", True)
		
		setting.Put("AppSize", AppsList.Size)
		setting.Put("Apps", Str.ToString)
		
		txtAppsSearch_TextChanged("")
		
	'	For i = 0 To HomeApps.Length - 1
	'		For Each app In AppsList
	'			Dim r As Reflector
	'			r.Target = app
	'			If (r.GetField("PackageName").As(String) = HomeApps(i).As(String)) Then
	'				Dim ap As App = app
	'				clvHome.Add(CreateListItemHome(ap.Name, clvHome.AsView.Width, HomeRowHeigh), ap.PackageName)
	'			End If
	'		Next
	''		Dim l As Int
	''		For l = 0 To AppsList.Size - 1
	''			Dim tt As String
	''			Dim r As Reflector
	''			r.Target = AppsList.Get(l)
	''			tt = r.GetField("PackageName")
	''			If (tt = HomeApps(i)) Then
	''				Dim app As App = AppsList.Get(l)
	''				clvHome.AddTextItem(app.Name, app.PackageName)
	''			End If
	''		Next
	''	Next
	End If
	
End Sub

Public Sub Is_HomeApp(pkgName As String) As Boolean
'	Log(HomeApps)
	Dim i As Int
	
	For i = 0 To HomeApps.Length - 1
		If (HomeApps(i) = pkgName) Then Return True
	Next
'	For Each ap In HomeApps
'		If (pkgName = ap) Then Return True
'	Next
	
	Return False
	
End Sub

public Sub RemoveHomeItem(pkgName As String)
	Dim i As Int = 0
	For i = 0 To clvHome.Size - 1
		If (i < clvHome.Size) Then ' I used this IF just for fix array size issue. I don't know why error happen without this IF
			Dim homevalue As String = clvHome.GetValue(i).As(String).ToLowerCase
			If homevalue = pkgName Then
				clvHome.RemoveAt(i)
				ToastMessageShow(pkgName & " Deleted. " & i, False)
'				Exit
			End If
		End If
	Next
End Sub

Public Sub FindHomeItem(pkgName As String) As Boolean
	MyLog("Func: FindHomeItem => " & pkgName)
	Dim i As Int = 0
	For i = 0 To clvHome.Size - 1
		If (clvHome.GetValue(i) = pkgName) Then Return True
	Next
	Return False
End Sub

Public Sub GetAppNamebyPackage(pkgName As String) As String
	
	If pkgName.SubString(8) = "package:" Then pkgName = pkgName.SubString(8)
	
	For Each app In AppsList
		Dim ap As App = app
		If (ap.PackageName = pkgName) Then Return ap.Name
	Next
	Return ""
End Sub

Public Sub ShowHideKeyboard(Show As Boolean)
	If Show Then
		IMElib.ShowKeyboard(txtAppsSearch.TextField)
	Else
		IMElib.HideKeyboard
	End If
End Sub

Private Sub DisableDragAndDrop
	Try
		
		'//-- Hide Home List Popup Menu
		panHRowMenuHome.Visible = False
		
		'//-- Hide App List Popup Menu
		If (AppMenu.IsInitialized) Then
			AppMenu.Visible = False
			AppMenu = Null
		End If
		
		'//-- Save and Disabled Drag and Drop Home List App
		If (dragAllow) Then
			dragger.RemoveDragButtons
			MyLog("Func: DisableDragAndDrop => ShowHideKey(False)")
			ShowHideKeyboard(False)
			SaveHomeList
		End If
		
		dragAllow = False
		
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
End Sub

Private Sub RunApp(package As String)
	MyLog("Func: RunApp")
	Try
		Dim Intent1 As Intent
		Dim pm As PackageManager
		Intent1 = pm.GetApplicationIntent (package)
		If Intent1.IsInitialized Then StartActivity (Intent1)
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
End Sub

Private Sub panApps_Click
	MyLog("Event: panApps_Click => ShowHideKey(False)")
	ShowHideKeyboard(False)
	DisableDragAndDrop
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
	
	MyLog("Event: btnSetting_Click => ShowHideKey(False)")
	ShowHideKeyboard(False)
	DisableDragAndDrop
	
	btnSetting.Enabled = False
	panSetting.RemoveAllViews
	panSetting.Visible = True
	btnSetting.RequestFocus
'	panSetting.SetLayoutAnimated(3000, 1000, 1000, 1000, 1000)
'	AnimateView(panSetting, 1000,1000,1000,1000,1000)
	panSetting.LoadLayout("Settings")
	panSetting.BringToFront
	
	
	chkShowKeyboard.Checked = Pref.ShowKeyboard
	chkShowIcons.Checked = Pref.ShowIcon
	chkShowIconsHome.Checked = Pref.ShowIconHomeApps
	chkAutoRun.Checked = Pref.AutoRunApp
	lblAbout.Text = "Made with Love, by Amir (C) 2023"
	lblVersion.Text = Application.LabelName & ", Build " & Application.VersionCode & " " & Application.VersionName
	
'	If (cmbPhone.IsInitialized <> False) Then
		If AppsList.IsInitialized Then
			Dim i As Int = 0
			Dim lst As List
			Dim CameraIndex, PhoneIndex, ClockIndex As Int = -1
			lst.Initialize
			lstPackageNames.Initialize
			
			For Each app In AppsList
				Dim r As Reflector
				Dim str As String
				r.Target = app
				str = r.GetField("Name").As(String)
				
				Dim pkgName As String
				pkgName = r.GetField("PackageName").As(String)
				
				If (pkgName.ToLowerCase = Pref.CameraApp.ToLowerCase) Then _
					CameraIndex = i
				
				If (pkgName.ToLowerCase = Pref.PhoneApp.ToLowerCase) Then _
					PhoneIndex = i
				
				If (pkgName.ToLowerCase = Pref.ClockApp.ToLowerCase) Then _
					ClockIndex = i
				
				lst.Add(str)
				lstPackageNames.Add(pkgName)
				i = i + 1
			Next
			
			If (lst.Size > -1) Then
				cmbPhoneSetting.SetItems(lst)
				cmbCameraSetting.SetItems(lst)
				cmbClockSetting.SetItems(lst)
				
				If (CameraIndex > -1) Then
					cmbCameraSetting.SelectedIndex = CameraIndex
					cmbCameraSetting.Tag = lstPackageNames.Get(CameraIndex).As(String)
				Else
					cmbCameraSetting.cmbBox.Add("[Select Camera App]")
					cmbCameraSetting.SelectedIndex = cmbCameraSetting.Size - 1
				End If
				
				If (PhoneIndex > -1) Then
					cmbPhoneSetting.SelectedIndex = PhoneIndex
					cmbPhoneSetting.Tag = lstPackageNames.Get(PhoneIndex).As(String)
				Else
					cmbPhoneSetting.cmbBox.Add("[Select Phone App]")
					cmbPhoneSetting.SelectedIndex = cmbPhoneSetting.Size - 1
				End If
				
				If (ClockIndex > -1) Then
					cmbClockSetting.SelectedIndex = ClockIndex
					cmbClockSetting.Tag = lstPackageNames.Get(ClockIndex).As(String)
				Else
					cmbClockSetting.cmbBox.Add("[Select Clock App]")
					cmbClockSetting.SelectedIndex = cmbClockSetting.Size - 1
				End If
			
			End If
			
		End If
		
'	End If
	
End Sub

Private Sub btnClose_Click
	SaveSettings
	SetupInstalledApps
'	txtAppsSearch_TextChanged(txtAppsSearch.Text)
End Sub

Private Sub CloseSetting
	btnSetting.Enabled = True
	panSetting.Enabled = True
	panSetting.Visible = False
	panSetting.RemoveAllViews
End Sub

Public Sub SaveSettings
	MyLog("Func: SaveSettings ")
	
	CloseSetting
	
	Pref.ShowKeyboard = chkShowKeyboard.Checked
	
	Pref.ClockApp = cmbClockSetting.Tag.As(String)
	Pref.CameraApp = cmbCameraSetting.Tag.As(String)
	Pref.PhoneApp = cmbPhoneSetting.Tag.As(String)
	Pref.ShowIcon = chkShowIcons.Checked
	Pref.ShowIconHomeApps = chkShowIconsHome.Checked
	Pref.AutoRunApp = chkAutoRun.Checked
	
	Dim setting As KeyValueStore
'	xui.SetDataFolder("MyPhone")
	setting.Initialize(File.DirInternal, ConfigFileName)
	
	Dim Str As StringBuilder
	Str.Initialize
	
	Dim i As Int = 0
	For i = 0 To clvHome.Size - 1
		Str.Append(clvHome.GetValue(i)).Append("|")
	Next
	setting.Put("HomeApps", Str.ToString)
	setting.Put("ShowKeyboard", Pref.ShowKeyboard)
	setting.Put("CameraApp", Pref.CameraApp)
	setting.Put("PhoneApp", Pref.PhoneApp)
	setting.Put("ClockApp", Pref.ClockApp)
	setting.Put("ShowIcon", Pref.ShowIcon)
	setting.Put("ShowIconHomeApp", Pref.ShowIcon)
	setting.Put("AutoRunApp", Pref.AutoRunApp)
	
	ToastMessageShow("Settings Changed and Saved !", False)
	
End Sub

Public Sub SaveHomeList
	MyLog("Func: SaveHomeList")
	Dim setting As KeyValueStore
	setting.Initialize(File.DirInternal, ConfigFileName)
	
	Dim Str As StringBuilder
	Str.Initialize
	
	Dim i As Int = 0
	For i = 0 To clvHome.Size - 1
		Str.Append(clvHome.GetValue(i)).Append("|")
	Next
	setting.Put("HomeApps", Str.ToString)
	HomeApps = Regex.Split("\|", Str.ToString)
End Sub

Private Sub lblClock_Click
	DisableDragAndDrop
	Run_Clock
End Sub

Private Sub btnPhone_Click
	DisableDragAndDrop
	Run_PhoneDialer
End Sub

Public Sub Run_PhoneDialer
	DisableDragAndDrop
	Dim Intent1 As Intent
	Intent1.Initialize(Intent1.ACTION_VIEW, "tel:")
	StartActivity (Intent1)
End Sub

Public Sub Run_Clock
	Try
		RunApp(Pref.ClockApp)
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
End Sub

Public Sub Run_Calendar
	Try
		DisableDragAndDrop
		Dim i As Intent
		Dim phid As String = "phid"
		i.Initialize("android.intent.action.VIEW", "content://com.android.calendar/time/" & DateTime.Now)
		i.AddCategory("android.intent.category.DEFAULT")'add cat launcher
		i.PutExtra("id", phid)
		StartActivity(i)'start the activity
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
End Sub

Public Sub Run_Alarm
	Try
		DisableDragAndDrop
		Dim i As Intent
		i.Initialize("android.intent.action.SET_ALARM", "")
		StartActivity(i)
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
End Sub

Private Sub panPhone_Click
	DisableDragAndDrop
	If (Pref.PhoneApp = "") Then
		Run_PhoneDialer
	Else
		RunApp(Pref.PhoneApp)
	End If
End Sub

Private Sub panCamera_Click
	DisableDragAndDrop
	RunApp(Pref.CameraApp)
End Sub

Private Sub btnDelete_Click
	
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

Private Sub panSettings_Click
	MyLog("Event: panSettings_Click => ShowHideKey(False)")
	ShowHideKeyboard(False)
	If DblClick Then CloseSetting
End Sub

Private Sub DblClick() As Boolean
	If (DateTime.Now - LastClick) < 250 Then Return True
	'// Double Tap Time Variable
	LastClick = DateTime.Now
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
	lblClock_Click
End Sub

Private Sub DoubleTap
	Try
		Log("DoubleTap")
		If Manager.Enabled Then
'			Manager.LockScreen
		Else
			Manager.Enable("Please enable in order to get access to the secured server.")
			If Manager.Enabled Then Manager.LockScreen
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Private Sub RunSettings(Setting As String)', _ 
					   'Setting as AndroidSettings)

	Dim inte As Intent
	Dim pm As PackageManager
	
	inte = pm.GetApplicationIntent("com.android.settings")
	
	If inte.IsInitialized Then
		inte.SetComponent("com.android.settings/." & Setting)
		StartActivity(inte)
	End If

End Sub

Public Sub isColorDark(color As Int) As Boolean
    
	Dim darkness As Int = 1 - (0.299 * GetARGB(color)(1) + 0.587 * GetARGB(color)(2) + 0.114 * GetARGB(color)(3))/255
    
	If darkness <= 0.5 Then
		Return    False 'It's a light color
	Else
		Return    True 'It's a dark color
	End If
    
End Sub

Sub GetARGB(Color As Int) As Int()
	Dim res(4) As Int
	res(0) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff000000), 24)
	res(1) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff0000), 16)
	res(2) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff00), 8)
	res(3) = Bit.And(Color, 0xff)
	Return res
End Sub

Private Sub panSettings_LongClick
	MyLog("Event: panSettings_LongClick - ShowHideKeyboard(False)")
	ShowHideKeyboard(False)
	CloseSetting
End Sub

Private Sub clvHome_ScrollChanged (Offset As Int)
	'//-- Hide Home List Popup Menu
	panHRowMenuHome.Visible = False
'	DisableDragAndDrop
End Sub

Private Sub clvApps_ScrollChanged (Offset As Int)
	ShowHideKeyboard(False)
	DisableDragAndDrop
End Sub

Private Sub txtAppsSearch_FocusChanged (HasFocus As Boolean)
	If HasFocus = False Then
		MyLog("Event: txtAppsSearch_FocusChanged => ShowHideKey(False)")
		ShowHideKeyboard(False)
	End If
	DisableDragAndDrop
End Sub

Private Sub panApps_Touch (Action As Int, X As Float, Y As Float)
	MyLog("Event: panApps_Touch => ShowHideKey(False)")
	ShowHideKeyboard(False)
	DisableDragAndDrop
End Sub


Private Sub tagApps_ItemClick (Index As Int, Value As Object)
	RunApp(Value.As(String))
End Sub

Private Sub tagApps_ItemLongClick (Index As Int, Value As Object)
	RemoveAsRecently(Value)
End Sub

Private Sub txtAppsSearch_ClearButtonClick
	MyLog("Event: txtAppsSearch_ClearButtonClick => ShowHideKey(False)")
	ShowHideKeyboard(True)
	DisableDragAndDrop
End Sub


Private Sub chkAutoRun_CheckedChange(Checked As Boolean)
	
End Sub

Private Sub lblSetAsDefaultLauncher_Click
	SetDefaultLauncher
End Sub

Private Sub SetDefaultLauncher
	
	If (GetDefaultLauncher <> Pref.MyPackage) Then
		Dim in As Intent
		in.Initialize("android.settings.HOME_SETTINGS", "")
		StartActivity(in)
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
Sub IsPrivateIpAddress(ipStr As String) As Boolean

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
Sub inRange(num As Int, n1 As Int, n2 As Int) As Boolean
	Return num >= n1 And num <= n2
End Sub

Public Sub ShowCustomToast(Text As Object, LongDuration As Boolean, BackgroundColor As Int)
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
	
	'//-- Example, Hot to use this method:
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
	Dim Setting As KeyValueStore
	Setting.Initialize(File.DirInternal, ConfigFileName)
	Setting.Put("ShowToastLog", chkShowToastLog.Checked.As(String))
	ShowToastLog = chkShowToastLog.Checked
	
	panLog.Visible = False
	panSetting.Visible = True
End Sub

Private Sub clvLog_ItemClick (Index As Int, Value As Object)
	Dim cb As BClipboard
	ToastMessageShow(Value.As(String), True)
	cb.setText(Value)
End Sub


Private Sub lblVersion_Click
	panLog.Visible = True
'	panSetting.Visible = False
	
	Dim Setting As KeyValueStore
	Setting.Initialize(File.DirInternal, ConfigFileName)
	chkShowToastLog.Checked = ShowToastLog
	
	For Each item In LogList
		clvLog.AddTextItem(item, item)
	Next
	
End Sub

Private Sub lblVersion_LongClick
	ToastMessageShow("Log List Reset Success.", False)
	LogList.Clear
	clvLog.Clear
	File.WriteList(File.DirInternalCache, "MyLog.log", LogList)
	
	btnLogClose_Click
End Sub

Private Sub lblAbout_Click
	lblVersion_Click
End Sub

Private Sub lblAbout_LongClick
	lblVersion_LongClick
End Sub