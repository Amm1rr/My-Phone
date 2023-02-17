B4A=true
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
	Private Root 						As B4XView
	Private xui 						As XUI
	Public panHome 						As B4XView
	Private panSetting 					As B4XView
	Private panApps 					As B4XView
	Private panAppMenuApp 				As B4XView
	Private panHRowMenuHome 			As B4XView
	Private Tabstrip1 					As TabStrip
	Private clvHome 					As CustomListView
	Public clvApps 						As CustomListView
	Private clvAppRowMenu 				As CustomListView
	Public clvHRowMenu 					As CustomListView
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
	Private imgIconApp As 				ImageView
	Private imgIconHome As 				ImageView
	Private clocktimer 					As Timer
	Public txtAppsSearch 				As EditText
	
	Private lstPackageNames 			As List
	Private RecentlyList 				As List
	Public AppRowHeigh 					As Int = 50dip
	Public AppRowHeighMenu 				As Int = 50dip
	Public HomeRowHeigh 				As Int = 60dip
	Public HomeRowHeighMenu 			As Int = HomeRowHeigh * 2
	Public AutoRunOnFind 				As Boolean
	Public FirstStart 					As Boolean = True
	Private tagColors 					As Int = Colors.DarkGray
	
	Public StartTimeClick 				As Boolean = True
	Private dragAllow 					As Boolean = False
	Private dragAllowEdge 				As Boolean = False
	
	Public 	Manager 					As AdminManager
	Public 	LastRunApp 					As String
	Private movecount 					As Int
	Private LastClick 					As Long
	Private gestHome 					As Gestures
	Private dragger 					As CLVDragger
	Private draggerEdge 				As CLVDragger
	Private IMElib 						As IME
	Private dd 							As DDD
	Private OP 							As OverlayPermission
	
	Private CurrentAppApp As App
	Private CurrentHomeApp As App
	
	Public 	tagApps 					As ASScrollingTags
	Private lblInfo 					As Label
	Private chkAutoRun 					As CheckBox
	Private lblVersionHome 				As Label
	Private panLog 						As B4XView
	Private clvLog 						As CustomListView
	Private btnLogClose 				As Button
	Private chkShowToastLog 			As CheckBox
	Private chkShowIconsHome 			As CheckBox
	Private btnSetAsDefault 			As Button
	Private btnHiddenAppsDelete 		As Button
	Private panHideManager 				As B4XView
	Private clvHiddenApp 				As CustomListView
	Private CLVSelection 				As CLVSelections
	Private lblHomRowMenuRowAppTitle 	As Label
	Private panHomeRowMenuRowHome 		As B4XView
	Private panHomRowMenuRow 			As B4XView
	Private imgHomRowMenuRowIconHome 	As B4XView
	Private lblAppRowMenuRowAppTitle 	As Label
	Private imgAppRowMenuRowIconHome 	As B4XView
	Private clvEdge 					As CustomListView
	Public 	panEdge 					As Panel
	
	Private x_dblClick 					As Int
	Private y_dblClick 					As Int
	Private lblCameraSetting 			As Label
	Private lblClockSetting 			As Label
	
	Private AlphabetTable As IndexedTable
	Private AlphabetLastChars As String
	Public Alphabet As Map
	Private panHomRow As B4XView
	
	'panHomeRow_LongClick
	Private TimerLongClick As Timer
	Dim longCLickFirstimeTouched As Long
	Dim longClickX As Float
	Dim longClickY As Float
	Dim longClickX0, longClickY0 As Float
	Dim longClickClvIndex As Int
	Dim longClickClvPNL As B4XView
	Dim ClickPanCLV As Boolean
	Dim clvLongClick As Int	' 0 = clvHome
							' 1 = clvApps
	Private panAppRow As B4XView
End Sub

Private Sub MyLog (Text As String)
	Starter.MyLog(Text)
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True

	MyLog("###### Initialize")
	
	StartTimeClick = True
	
	dd.Initialize
	'The designer script calls the DDD class. A new class instance will be created if needed.
	'In this case we want to create it ourselves as we want to access it in our code.
	xui.RegisterDesignerClass(dd)
	
	IMElib.Initialize("")
	
	Alphabet.Initialize
	AlphabetTable.Initialize("")
	
	DateTime.TimeFormat = "hh:mm:ss"
	lblClock.Initialize("")
	lblClock.Text = DateTime.Time(DateTime.Now)
	
	lblDate.Initialize("")
	DateTime.DateFormat = "dd.MMM.yyyy"
	lblDate.Text = DateTime.Time(DateTime.Now)
	
	clocktimer.Initialize("clocktimer", 1000)
	clocktimer.Enabled = True
	
	TimerLongClick.Initialize("TimerLongClick", 100)
	TimerLongClick.Enabled = False
	
'	If Not (panLog.IsInitialized) Then panLog.Initialize("panLog")
	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	MyLog("###### Event: B4XPage_Created")
	
	Root = Root1
	Root.LoadLayout("MainPage")
	B4XPages.SetTitle(Me,"My Phone")
	
	Tabstrip1.LoadLayout("Home", "Home")
	Tabstrip1.LoadLayout("Apps", "Apps")
	
	lblVersionHome.Text = "Build " & Application.VersionCode & " " & Application.VersionName
	
	CLVSelection.Initialize(clvHome)
	CLVSelection.Mode = CLVSelection.MODE_SINGLE_ITEM_TEMP
	
	SetBackgroundTintList(txtAppsSearch, Colors.Transparent, Colors.Transparent)
	
	HideAppMenu
	
	If (FirstStart) Then
	
		FixWallTrans
		
		Setup
		
		LoadRecentlyList
		
		If Not (imgPhone.IsInitialized) Then imgPhone.Initialize("", "")
		imgPhone.Load(File.DirAssets, "Phone.png")
		
		If Not (imgCamera.IsInitialized) Then imgCamera.Initialize("", "")
		imgCamera.Load(File.DirAssets, "Camera.png")
		
		gestHome.SetOnTouchListener(panHome, "gestHome_gesture")
		
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
		
		panHomRow.Tag = panHomRow.Color
		panAppRow.Tag = panAppRow.Color
		
		Try
			If Not (imgIconApp.IsInitialized) Then imgIconApp.Initialize("")
			If Starter.Pref.ShowIcon Then
				imgIconApp.Visible = True
				lblAppTitle.Left = 35dip
			Else
				imgIconApp.Visible = False
				lblAppTitle.Left = 5dip
			End If
			
			If Not (imgIconHome.IsInitialized) Then imgIconHome.Initialize("")
			If Starter.Pref.ShowIconHomeApp Then
				imgIconHome.Visible = True
				lblAppTitle.Left = 35dip
			Else
				imgIconHome.Visible = False
				lblAppTitle.Left = 5dip
			End If
			
		Catch
			MyLog("+++***+++*** B4XPage_Created: " & LastException)
		End Try
		
		StartTimeClick = False
		
'		EdgeLoad
'		Open_Edgebar
		
		StartService(Starter)
		
		FirstStart = False
	Else
		FirstStart = False
	End If
	
End Sub

Private Sub clocktimer_Tick
	lblClock.Text = DateTime.Time(DateTime.Now)
	lblDate.Text = DateTime.Date(DateTime.Now)
End Sub

Private Sub TimerLongClick_Tick
	If DateTime.Now - longCLickFirstimeTouched > 400 And longClickX - longClickX0 < 10dip And longClickY - longClickY0 < 10dip Then
		TimerLongClick.Enabled = False
		ClickPanCLV = False
		XUIViewsUtils.PerformHapticFeedback(longClickClvPNL)
				
		Select clvLongClick
			Case 0:	'clvHome
				If panHomRow.Tag = "" Then panHomRow.Tag = 0
				longClickClvPNL.SetColorAndBorder(panHomRow.Tag, 0, Colors.Blue, 15dip)
				clvHome_ItemLongClick(longClickClvIndex, clvHome.GetValue(longClickClvIndex))
				clvLongClick = -1
			Case 1:	'clvApps
				If panAppRow.Tag = "" Then panAppRow.Tag = 0
				longClickClvPNL.SetColorAndBorder(panAppRow.Tag, 0, Colors.Blue, 15dip)
				clvApps_ItemLongClick(longClickClvIndex, clvApps.GetValue(longClickClvIndex))
				clvLongClick = -1
		End Select
				
				
	End If
End Sub

Public Sub GetSetting(Key As String) As String
	Dim tmpResult As String
	Private CurSql As Cursor
	CurSql = Starter.sql.ExecQuery("SELECT " & Key & " FROM Settings")
	CurSql.Position = 0
	tmpResult = CurSql.GetString("")
	CurSql.Close
	Return tmpResult
End Sub

Public Sub Open_Edgebar()
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
	
	MyLog("Func: EdgeLoad")
	
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
	
	
End Sub

Public Sub FixWallTrans
	Starter.LogShowToast = False
	MyLog("FixWallTrans")
	'------{ ### Set Navigation Bar Transparent
	Dim jo As JavaObject
	Dim window As JavaObject = jo.InitializeContext.RunMethod("getWindow", Null)
	window.RunMethod("addFlags", Array(Bit.Or(0x00000200, 0x08000000)))
	Root.Height = Root.Height + Starter.NAVBARHEIGHT
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

Private Sub Run_Info(PackageName As String)
	MyLog("Run_Info => " & PackageName)
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
	If (dragAllowEdge) Then
		draggerEdge.RemoveDragButtons
		dragAllowEdge = False
	End If
End Sub

Private Sub gestHome_gesture(o As Object, ptrID As Int, action As Int, x As Float, y As Float) As Boolean
'	Starter.LogShowToast = False
'	MyLog("*** Event: gestHome_gesture")
	
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
			
			HideHomeMenu(True)
			DisableEdgeEdit
			
'			'// Double Tap
'			If (DateTime.Now - LastClick) < 250 Then
''				Log("Double Click => " & (DateTime.Now - LastClick))
'				DoubleTap
'			End If
			If (DblClick(x, y)) Then DoubleTap
			
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
'	MyLog("*** Event: Activity_Resume")
'	SetDefaultLauncher
'	btnSetAsDefaultLauncher.Visible = True
'End Sub
'
'Private Sub Activity_Pause(UserClosed As Boolean)
'	MyLog("*** Event: Activity_Pause")
'	B4XPages.MainPage.SetDefaultLauncher
'	B4XPages.MainPage.btnSetAsDefaultLauncher.Visible = True
'	GoHome(False)
'End Sub

Private Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	MyLog("*** Event B4XMainPage: Activity_KeyPress & => " & KeyCode)
	LogColor("*** Event B4XMainPage: Activity_KeyPress & => " & KeyCode, Colors.Red)
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

Public Sub GoHome(ClearSearch As Boolean)
	MyLog("GoHome: ClearSearch => " & ClearSearch)
	Try
		Tabstrip1.ScrollTo(0, True)
		HideHomeMenu(True)
'		If (HomeMenu.IsInitialized) Then HomeMenu.Visible = False
'		If (AppMenu.IsInitialized) Then AppMenu.Visible = False
'		If ClearSearch Then txtAppsSearch.Text = ""

		HideKeyboard
		
	Catch
		ToastMessageShow(LastException.Message, True)
		MyLog("++++++++++++ Error Caught: GoHome => " & LastException)
	End Try
End Sub

Private Sub TabStrip1_PageSelected (Position As Int)
	
'	MyLog("*** Event: TabStrip1_pageSelected => " & Position)

	HideHomeMenu(True)
	CloseSetting
	DisableEdgeEdit
	
	If (Position = 1) Then
'		MyLog("*** Event: TabStrip1_pageSelected => ShowHideKey(True)")
		If Starter.Pref.ShowKeyboard Then ShowKeyboard
	Else
		Try
'			MyLog("*** Event: TabStrip1_pageSelected => ShowHideKey(False)")
			HideKeyboard
		Catch
			MyLog("+++***+++*** Event: TabStrip1_pageSelected => Error Caught => " & LastException.Message)
			ToastMessageShow(LastException.Message, True)
			Log("Error Caught: TabStrip1_PageSelected => " & LastException)
		End Try
	End If
End Sub

Private Sub SaveRecentlyList
	
	MyLog("SaveRecentlyList")
	
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
	
End Sub

Private Sub LoadRecentlyList
	
	MyLog("###### LoadRecentlyList")
	
	If Not (RecentlyList.IsInitialized) Then RecentlyList.Initialize
	
	Dim ResRecentApps As ResultSet
	ResRecentApps = Starter.sql.ExecQuery("SELECT * FROM RecentlyApps WHERE ID IN (SELECT ID FROM RecentlyApps ORDER By ID DESC NULLS FIRST LIMIT 5)")
	
	tagApps.CLV.Clear
	
	For i = 0 To ResRecentApps.RowCount - 1
		ResRecentApps.Position = i
		Dim value As String = ResRecentApps.GetString("pkgName")
		AddToRecently(ResRecentApps.GetString("Name"), value, False)
'		tagApps.AddTag(ResRecentApps.GetString("Name"), tagColors, value)
'		RecentlyList.Add(value)
	Next
	
End Sub

Private Sub FindRecentlyItem(pkgName As String) As Boolean
'	MyLog("FindRecentlyItem => " & pkgName)
	
	pkgName = GetPackage(pkgName)
	
	Dim i As Int = 0
	For i = 0 To tagApps.CLV.Size - 1
		If (tagApps.CLV.GetValue(i) = pkgName) Then Return True
	Next
	Return False
End Sub

Public Sub GetPackage(pkg As String) As String
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
		Return pkg
	End Try
	
	Return pkgName
	
End Sub

Public Sub AddToRecently(Text As String, Value As String, IsNewInstalledApp As Boolean)
	MyLog("AddToRecently => " & Text & " - " & Value)
	
	Value = GetPackage(Value)
	
	If Not (RecentlyList.IsInitialized) Then RecentlyList.Initialize
	
	If (FindRecentlyItem(Value)) Then Return
	If Not (Is_NormalApp(Value)) Then Return
	
	If Text = "" Then _
		Text = GetAppNamebyPackage(Value)
	
	tagApps.mBase.Enabled = False
	tagApps.CLV.Clear
	tagColors = Colors.DarkGray
	
	RecentlyList.AddAllAt(0, Array(Value))
	
	If (RecentlyList.Size > 5) Then _
		RecentlyList.RemoveAt(RecentlyList.Size - 1)
	
	Starter.sql.ExecNonQuery("DELETE FROM RecentlyApps")
	
	Dim j As Int
	If (IsNewInstalledApp) Then
		tagApps.LabelProperties.TextColor = Colors.Yellow
		tagApps.AddTag(Text, tagColors, Value)
		j = 1
	Else
		j = 0
	End If
	tagApps.LabelProperties.TextColor = Colors.LightGray
	
	Dim query As String = "INSERT OR REPLACE INTO RecentlyApps(Name, pkgName) VALUES"
	Dim tmp As String
	For i = j To RecentlyList.Size - 1
		Dim appName As String = GetAppNamebyPackage(RecentlyList.Get(i))
		tagApps.AddTag(appName, tagColors, RecentlyList.Get(i))
		tmp = "('" & appName & "','" & RecentlyList.Get(i) & "')," & tmp
	Next
	If (tmp.Length > 0) Then
		query = query & tmp.SubString2(0, tmp.Length - 1)
		Starter.sql.ExecNonQuery(query)
	End If
	
'	Dim tmp As String
'	For Each pkg In RecentlyList
'		tmp = "('" & GetAppNamebyPackage(pkg) & "','" & pkg & "')," & tmp
'	Next
'	If (tmp <> "") Then
'		tmp = tmp.SubString2(0, tmp.Length - 1)
'		query = "INSERT OR REPLACE INTO RecentlyApps(Name, pkgName) VALUES" & tmp
'		Starter.sql.ExecNonQuery(query)
'	End If
	
	
	tagApps.mBase.Enabled = True
	
	
'	tagColors = Colors.DarkGray
'	If (IsNewInstalledApp) Then
'		tagApps.LabelProperties.TextColor = Colors.Yellow
'	Else
'		tagApps.LabelProperties.TextColor = Colors.LightGray
'	End If
'	
'	If (RecentlyList.Size < 5) And (RecentlyList.Size > 0) Then
'		
'		tagApps.AddTag(Text, tagColors, Value)
'		
'		RecentlyList.Add(Value)
'		
'		Dim q As String = "INSERT OR REPLACE INTO RecentlyApps(Name, pkgName) VALUES ('" & Text & "','" & Value & "')"
''		LogColor(q, Colors.Green)
'		
'		Starter.sql.ExecNonQuery(q)
'		
''		Dim lstReverse As List = ReverseList(RecentlyList)
''		RecentlyList = lstReverse
''		tagApps.CLV.Clear
''		For Each item In lstReverse
''			tagApps.AddTag(GetAppNamebyPackage(item), Colors.DarkGray, item)
''		Next
'		
'	Else If (RecentlyList.Size >= 5) Then
'		Try
'			'		If (Value = tagApps.CLV.GetValue(tagApps.CLV.Size - 1)) Then Return
'			'		If (Value = RecentlyList.Get(RecentlyList.Size - 1)) Then Return
'
'			tagApps.mBase.Enabled = False
'			
'			tagApps.CLV.Clear
'			tagApps.AddTag(Text, tagColors, Value)
'			tagApps.LabelProperties.TextColor = Colors.LightGray
'			tagApps.AddTag(GetAppNamebyPackage(RecentlyList.Get(0)), tagColors, RecentlyList.Get(0))
'			tagApps.AddTag(GetAppNamebyPackage(RecentlyList.Get(1)), tagColors, RecentlyList.Get(1))
'			tagApps.AddTag(GetAppNamebyPackage(RecentlyList.Get(2)), tagColors, RecentlyList.Get(2))
'			tagApps.AddTag(GetAppNamebyPackage(RecentlyList.Get(3)), tagColors, RecentlyList.Get(3))
'			
'			Dim i0 As Object = RecentlyList.Get(0)
'			Dim i1 As Object = RecentlyList.Get(1)
'			Dim i2 As Object = RecentlyList.Get(2)
'			Dim i3 As Object = RecentlyList.Get(3)
'			
'			RecentlyList.Clear
'			RecentlyList.Add(Value)
'			RecentlyList.Add(i0)
'			RecentlyList.Add(i1)
'			RecentlyList.Add(i2)
'			RecentlyList.Add(i3)
'			
'			Dim q As String = "INSERT OR REPLACE INTO RecentlyApps(Name, pkgName) VALUES ('" & Text & "','" & Value & "')"
'			Starter.sql.ExecNonQuery(q)
'			
'		Catch
'			MyLog("++++++++++++ Func: AddToRecently => " & LastException)
'		End Try
'		
'		tagApps.mBase.Enabled = True
'		
'	Else
'		
'		tagApps.AddTag(Text, tagColors, Value)
'		RecentlyList.Add(Value)
'		Dim q As String = "INSERT OR REPLACE INTO RecentlyApps(Name, pkgName) VALUES ('" & Text & "','" & Value & "')"
'		Starter.sql.ExecNonQuery(q)
'		
'	End If
'	
'	'//----- Reset RecentlyBar Color to Default
'	tagColors = Colors.DarkGray
'	tagApps.LabelProperties.TextColor = Colors.LightGray
'	
''	SaveRecentlyList
	
End Sub

Private Sub ReverseList(lst As List) As List
	Dim java As JavaObject
	java.InitializeStatic("java.util.Collections").RunMethod("reverse", Array(lst))
	Return lst
End Sub

Public Sub RemoveAsRecently (Value As String)
'							(Index As Int)
	MyLog("RemoveAsRecently => " & Value)
	Value = GetPackage(Value.As(String))
	
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
	
'	SaveRecentlyList
	
'	For Each ap In RecentlyList
'		If ap = tagApps.CLV.GetValue(Index) Then
'			tagApps.CLV.RemoveAt(Index)
'			RecentlyList.RemoveAt(Index)
'			Exit
'		End If
'	Next
	
End Sub

Private Sub ConfigCurrentAppApp(Position As String, Value As String)
	
	Starter.LogShowToast = False
	MyLog("ConfigCurrentAppApp: Position: " & Position & " - Value: " & Value)
	
	CurrentAppApp.index 		= Position
	CurrentAppApp.PackageName 	= Value.As(String)
	
	'Every custom list view has a panel within
	Dim p 		As Panel 	= clvApps.GetRawListItem(Position).Panel.GetView(0)
	CurrentAppApp.Name 		= dd.GetViewByName(p, "lblAppTitle").Text

End Sub

Private Sub ConfigCurrentHomeApp(Position As String, Value As String)
	
	Starter.LogShowToast = False
	MyLog("ConfigCurrentHomeApp: => Position: " & Position & " - Value: " & Value)
	
	CurrentHomeApp.index = Position
	CurrentHomeApp.PackageName = Value.As(String)
'	CurrentHomeApp.Name = panHome.GetView(0).Text
'	CurrentHomeApp.Name = clvHome.GetPanel(Position).GetView(0).Text
End Sub

Private Sub clvHome_ItemClick (Position As Int, Value As Object)
	
	Starter.LogShowToast = False
	MyLog("*** Event: clvHome_ItemClick => Position: " & Position & " - Value: " & Value)

	If (dragAllow = False) Then
		ConfigCurrentHomeApp(Position, Value.As(String))
'		CurrentHomeApp.Name = clvHome.GetPanel(Position).GetView(0).Text
		clvHome.AsView.BringToFront
		RunApp(CurrentHomeApp.PackageName)
	End If
	HideHomeMenu(True)
	
End Sub


Private Sub clvHome_ItemLongClick (Position As Int, Value As Object)
	
	Starter.LogShowToast = False
	MyLog("*** Event: clvHome_ItemLongClick: => Position: " & Position & " - Value: " & Value)
	
	HideHomeMenu(True)
	Sleep(50)
	
	If (dragAllow = False) Then
		ConfigCurrentHomeApp(Position, Value.As(String))
		CreateHomeMenu(Position)
	Else
		dragger.RemoveDragButtons
		dragAllow = False
	End If
End Sub

Private Sub CreateHomeMenu (Position As Int)
	MyLog("CreateHomeMenu")
	
	panHRowMenuHome.RemoveAllViews
	panHRowMenuHome.RequestFocus
	panHRowMenuHome.LoadLayout("HomeRowMenu")
	panHRowMenuHome.Enabled = True
	panHRowMenuHome.BringToFront

	Dim Top As Int = clvHome.GetPanel(Position).Parent.Top - clvHome.sv.ScrollViewOffsetY + clvHome.GetBase.Top + clvHome.GetPanel(Position).Height
	panHRowMenuHome.As(B4XView).SetLayoutAnimated(300, clvHome.AsView.Left + (clvHome.AsView.Width - panHRowMenuHome.As(B4XView).Width) / 2, Top, panHRowMenuHome.As(B4XView).Width, panHRowMenuHome.As(B4XView).Height)
'	panHRowMenuHome.As(B4XView).SetLayoutAnimated(300, clvHome.AsView.Left - (panHRowMenuHome.As(B4XView).Width - panHRowMenuHome.As(B4XView).Width) / 2, Top, panHRowMenuHome.As(B4XView).Width, panHRowMenuHome.As(B4XView).Height)
'	panHRowMenuHome.As(B4XView).SetLayoutAnimated(0, clvHome.AsView.Left + (clvHome.AsView.Width - panHRowMenuHome.As(B4XView).Width) / 2, Top, panHRowMenuHome.As(B4XView).Width, panHRowMenuHome.As(B4XView).Height)
	panHRowMenuHome.SetVisibleAnimated(30, True)
	
	clvHRowMenu.Clear
'	clvHRowMenu.sv.SetColorAndBorder(Colors.White, 2dip, Colors.DarkGray, 20dip)
'	clvHRowMenu.sv.SetColorAnimated(300, Colors.LightGray, Colors.DarkGray)
	Dim he As Int = 130
	Dim we As Int = 80
	clvHRowMenu.Add(CreateListItemHomeMenu("Info", "Info", we, he), "Info")
	clvHRowMenu.Add(CreateListItemHomeMenu("Delete", "Delete", we, he), "Delete")
	clvHRowMenu.Add(CreateListItemHomeMenu("Sort", "Sort", we, he), "Sort")

End Sub

Private Sub CreateListItemHomeMenu(Text As String, _
							   Value As String, _
							   Width As Int, _
							   Height As Int) As Panel
	
'	MyLog("CreateListItemAppMenu => " & Text & ":" & Value & ":" & Width.As(String) & ":" & Height.As(String))
	Dim p As B4XView = xui.CreatePanel("")
	
		p.SetLayoutAnimated(0, 0, 0, Width, Height)
		p.LoadLayout("HomeRowMenuRow")

'	Dim p As Panel = panHomeRowMenuRowHome
'	panHomeRowMenuRowHome.SetLayoutAnimated(0,0,0, Width, Height)
'	panHomeRowMenuRowHome.LoadLayout("HomeRowMenu")
	
	'Note that we call DDD.CollectViewsData in HomeRow designer script. This is required if we want to get views with dd.GetViewByName.
	dd.GetViewByName(p, "lblHomRowMenuRowAppTitle").Text = Text
	dd.GetViewByName(p, "lblHomRowMenuRowAppTitle").Tag = Value
	
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

Private Sub clvApps_ItemClick (Position As Int, Value As Object)
	
	Starter.LogShowToast = False
	MyLog("Event clvApps_ItemClick => Position:" & Position & " - Value:" & Value)
	
	ConfigCurrentAppApp(Position, Value)
	
	If (panAppMenuApp.IsInitialized) Then
		HideAppMenu
	Else
'		tagApps.LabelProperties.TextColor = Colors.Magenta
		AddToRecently(CurrentAppApp.Name, CurrentAppApp.PackageName, False)
'		SaveRecentlyList
		RunApp(Value.As(String))
		clvApps.AsView.BringToFront
	End If
End Sub

Private Sub clvApps_ItemLongClick (Position As Int, Value As Object)
	Starter.LogShowToast = False
	MyLog("*** Event clvApps_ItemLongClick - HideKeyboard")
	HideKeyboard
	ConfigCurrentAppApp(Position, Value.As(String))
	CreateAppMenu(Value)
End Sub

Private Sub CreateAppMenu(Value As Object)
	MyLog("CreateAppMenu => " & Value.As(String))
	HideAppMenu
	
	panAppMenuApp.RemoveAllViews
	panAppMenuApp.LoadLayout("AppRowMenu")
	panAppMenuApp.RequestFocus
	panAppMenuApp.Enabled = True
	panAppMenuApp.BringToFront
	panAppMenuApp.SetVisibleAnimated(150, True)
	
	clvAppRowMenu.Clear
'	clvAppRowMenu.sv.SetColorAndBorder(Colors.White, 2dip, Colors.DarkGray, 20dip)
'	clvAppRowMenu.sv.SetColorAnimated(300, Colors.LightGray, Colors.DarkGray)
	Dim he As Int = 130
	Dim we As Int = 80
	clvAppRowMenu.Add(CreateListItemAppMenu("Info", "Info", we, he), "Info")
	clvAppRowMenu.Add(CreateListItemAppMenu(CurrentAppApp.Name, CurrentAppApp.PackageName, we, he), CurrentAppApp.PackageName)
	If (FindHomeItem(CurrentAppApp.PackageName) = True) Then
		clvAppRowMenu.Add(CreateListItemAppMenu("Remove from Home", "RemoveFromHome", we, he), "RemoveFromHome")
	Else
		clvAppRowMenu.Add(CreateListItemAppMenu("Add to Home", "AddToHome", we, he), "AddToHome")
	End If
	clvAppRowMenu.Add(CreateListItemAppMenu("Uninstall", "Uninstall", we, he), "Uninstall")
	clvAppRowMenu.Add(CreateListItemAppMenu("Hidden", "Hidden", we, he), "Hidden")
	clvAppRowMenu.Add(CreateListItemAppMenu("Rename", "Rename", we, he), "Rename")

End Sub

Private Sub clvHRowMenu_ItemClick (Position As Int, Value As Object)
	Starter.LogShowToast = False
	MyLog("*** Event: clvRowMenu_Click => " & Value.As(String))
	HideHomeMenu(True)
	dragAllow = False
	
	Select Value
		Case "Info"
			Run_Info(CurrentHomeApp.PackageName)
'			CurrentHomeApp.index = -1
		Case "Delete"
			RemoveHomeItem(CurrentHomeApp.PackageName)
'			CurrentHomeApp.index = -1
			Log("Delete " & CurrentHomeApp.PackageName)
			ToastMessageShow("Delete " & CurrentHomeApp.PackageName, False)
		Case "Sort"
			dragAllow = True
			dragger.AddDragButtons
	End Select
	
End Sub

Public Sub AddToHomeList(Name As String, pkgName As String, Widt As Int, Save As Boolean)
	
	MyLog("AddToHomeList => pkgName: " & pkgName & " -  Name: " & Name)
	
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
'			ap.IsHidden = False
			
		Starter.HomeApps.Add(app)
	End If
	
End Sub

Public Sub HideApp(pkgName As String)
	MyLog("HideApp: " & pkgName)
	pkgName = GetPackage(pkgName)
	RemoveAppItem_JustFromAppList(pkgName)
	Dim query As String = "INSERT OR REPLACE INTO Apps(Name, pkgName, IsHome, IsHidden) VALUES('" & GetAppNamebyPackage(pkgName) & "','" & pkgName & "',0,1)"
	Starter.sql.ExecNonQuery(query)
	Starter.SetupAppsList(False)
	RemoveAsRecently(pkgName)
	RemoveHomeItem(pkgName)
'	ResetHomeList
End Sub

Public Sub UninstallApp(pkgName As String)
	MyLog("UninstallApp")
	
	pkgName = GetPackage(pkgName)
	
	Dim im As Intent
	im.Initialize("android.intent.action.DELETE", "package:" & pkgName)
	
	StartActivity(im)
	
End Sub

Private Sub CreateListItemApp(Text As String, _
							  Value As String, _
							  Width As Int, _
							  Height As Int) As Panel
	
'	Starter.LogShowToast = False
'	MyLog("CreateListItemApp => " & Text & ":" & Value & ":" & Width.As(String) & ":" & Height.As(String))
	
	Dim p As B4XView = xui.CreatePanel("")
		p.SetLayoutAnimated(0, 0, 0, Width, Height)
		p.LoadLayout("AppRow")
	
	'Note that we call DDD.CollectViewsData in AppRow designer script. This is required if we want to get views with dd.GetViewByName. 
	dd.GetViewByName(p, "lblAppTitle").Text = Text.Trim
	dd.GetViewByName(p, "lblAppTitle").Tag = Value.Trim
'	lblAppTitle.Text = Text

	Try
		
		If Starter.Pref.ShowIcon Then
			Dim ico As Bitmap = Starter.GetPackageIcon(Value)
			If (ico.IsInitialized) Then
				imgIconApp.Bitmap = ico
				imgIconApp.Visible = True
				lblAppTitle.Left = 35dip
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

Private Sub CreateListItemAppMenu(Text As String, _
							   Value As String, _
							   Width As Int, _
							   Height As Int) As Panel
	
	Starter.LogShowToast = False
	MyLog("CreateListItemAppMenu => " & Text & ":" & Value & ":" & Width.As(String) & ":" & Height.As(String))
	Dim p As B4XView = xui.CreatePanel("")
	
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	p.LoadLayout("AppRowMenuRow")
	
	'Note that we call DDD.CollectViewsData in HomeRow designer script. This is required if we want to get views with dd.GetViewByName.
	dd.GetViewByName(p, "lblAppRowMenuRowAppTitle").Text = Text
	dd.GetViewByName(p, "lblAppRowMenuRowAppTitle").Tag = Value
	
	If Starter.Pref.ShowIconHomeApp Then
		imgAppRowMenuRowIconHome.Visible = True
		lblAppRowMenuRowAppTitle.Left = 35dip
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

Private Sub CreateListItemHome(Text As String, _
							   Value As String, _
							   Width As Int, _
							   Height As Int) As Panel
	
	Starter.LogShowToast = False
	MyLog("CreateListItemHome => " & Text & ":" & Value & ":" & Width.As(String) & ":" & Height.As(String))
	Dim p As B4XView = xui.CreatePanel("")
	
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	p.LoadLayout("HomeRow")
	
	'Note that we call DDD.CollectViewsData in HomeRow designer script. This is required if we want to get views with dd.GetViewByName. 
	dd.GetViewByName(p, "lblHomeAppTitle").Text = Text
	dd.GetViewByName(p, "lblHomeAppTitle").Tag = Value
	
	If Starter.Pref.ShowIconHomeApp Then
		Dim ico As Bitmap = Starter.GetPackageIcon(Value)
		If (ico.IsInitialized) Then
			imgIconHome.Visible = True
			lblHomeAppTitle.Left = 35dip
			imgIconHome.Bitmap = ico
		Else
			imgIconHome.Visible = False
			lblAppTitle.Left = 5dip
		End If
	Else
		imgIconHome.Visible = False
		lblHomeAppTitle.Left = 5dip
	End If
	
	Return p
	
End Sub

Public Sub AddtoAlphabetlist(AppName As String, Index As Int)
	
	Dim FirstChars As String = AppName.Trim.CharAt(0).As(String).ToUpperCase
	If (FirstChars = AlphabetLastChars) Then Return
	
'	For i = 0 To Alphabet.Size - 1
'		If (Alphabet.Get(i) = FirstChars) Then
'			Return
'		End If
'	Next

	AlphabetLastChars = FirstChars
	Alphabet.Put(FirstChars, Index)
'	If Not (Alphabet.ContainsKey(Index)) Then
'		Alphabet.Put(FirstChars, Index)
'	End If
	
End Sub

Public Sub GetOverlayPermission() As ResumableSub
	Dim c As RequestDrawOverPermission 'this is the name of the class
	c.Initialize
	Wait For (c.GetPermission) Complete (Success As Boolean)
	MyLog("Permission: " & Success)
	Return Success
End Sub

Public Sub Is_NormalApp(pkgName As String) As Boolean
	Starter.LogShowToast = False
	MyLog("Is_NormalApp => " & pkgName)
	
	For Each app As App In Starter.NormalAppsList
		If (app.PackageName = pkgName) Then
'			LogColor(app & " - " & pkgName, Colors.Red)
			Return True
		End If
	Next

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
	
	MyLog("###### Setup")
	
	'-- Add Apps to Home ListView
	clvHome.Clear
	For Each app As App In Starter.HomeApps
'		LogColor(app, Colors.Green)
		AddToHomeList(app.Name, app.PackageName, clvHome.sv.Width, False)
	Next
	
	Starter.AppsList.SortTypeCaseInsensitive("Name", True)
	Starter.NormalAppsList.SortTypeCaseInsensitive("Name", True)
	
	txtAppsSearch_TextChanged("", "")
	
End Sub

Public Sub Is_HomeApp(pkgName As String) As Boolean
	Starter.LogShowToast = False
	MyLog("Is_HomeApps:" & pkgName)
	Dim i As Int
	
	For i = 0 To Starter.HomeApps.Size - 1
		If (Starter.HomeApps.Get(i) = pkgName) Then Return True
	Next
'	For Each ap In Starter.HomeApps
'		If (pkgName = ap) Then Return True
'	Next
	
	Return False
	
End Sub

public Sub RemoveHomeItem(pkgName As String)
	Starter.LogShowToast = False
	MyLog("RemoveHomeItem => " & pkgName)
	
	pkgName = GetPackage(pkgName)
	
	For i = 0 To clvHome.Size - 1
		If (i < clvHome.Size) Then ' I just used this if condition for fix array size issue. I don't know why error happen without this IF
			Dim homevalue As String = clvHome.GetValue(i).As(String).ToLowerCase
			If homevalue = pkgName Then
				clvHome.RemoveAt(i)
				Starter.HomeApps.RemoveAt(i)
'				ToastMessageShow(pkgName & " Deleted. " & i, False)
'				Exit
			End If
		End If
	Next
	Dim query As String = "DELETE FROM Home WHERE pkgName='" & pkgName & "'"
	Starter.sql.ExecNonQuery(query)
	
'	'//-- It's an extra function, just need one of this FOR (above or below)
'	'//
'	For i = 0 To Starter.HomeApps.Size - 1
'		Dim homevalue As String = Starter.HomeApps.Get(i)
'		If homevalue = pkgName Then
'			Starter.HomeApps.RemoveAt(i)
'			ToastMessageShow(pkgName & " Deleted. " & i, False)
''			Exit
'		End If
'	Next
	
	ResetHomeList
	
End Sub

public Sub RemoveAppItem_JustFromAppList(pkgName As String)
	Starter.LogShowToast = False
	MyLog("RemoveAppItem_JustFromAppList => " & pkgName)
	
	pkgName = GetPackage(pkgName)
	
	Dim query As String = "DELETE FROM Apps WHERE pkgName='" & pkgName & "'"
	Starter.sql.ExecNonQuery(query)
	
	For i = 0 To clvApps.Size - 1
		If (i < clvApps.Size) Then ' I used this IF just for fix array size issue. I don't know why error happen without this IF
			Dim appvalue As String = clvApps.GetValue(i).As(String).ToLowerCase
			If appvalue = pkgName Then
				clvApps.RemoveAt(i)
'				Starter.clvApps.RemoveAt(i)
'				ToastMessageShow(pkgName & " Deleted. " & i, False)
'				Exit
			End If
		End If
	Next
	
'	LogColor(query, Colors.Green)
End Sub

Public Sub FindHomeItem(pkgName As String) As Boolean
	
	Starter.LogShowToast = False
	MyLog("B4XMainPage: " & pkgName)
	
	pkgName = GetPackage(pkgName)
	
	If (pkgName = Null) Or (pkgName = "") Then
		Return False
	End If
	
'	For i = 0 To Starter.HomeApps.Size - 1
	For i = 0 To clvHome.Size - 1
	If (clvHome.GetValue(i) = pkgName) Then
'	If (Starter.HomeApps.Get(i) = pkgName) Then
			MyLog("FindHomeItem => " & pkgName & " - True")
			Return True
	End If
	Next
	
'	MyLog("FindHomeItem => " & pkgName & " - False")
	Return False
End Sub

Public Sub GetAppNamebyPackage(pkgName As String) As String
	Starter.LogShowToast = False
	MyLog("GetAppNamebyPackage => " & pkgName)
	
	pkgName = GetPackage(pkgName)
	
	'// First Method, Search in AppList, a List Variable
	For Each app As App In Starter.NormalAppsList
		If (app.PackageName = pkgName) Then Return app.Name
	Next

'	'// Anothder Method to take apps from database	
'	Dim resName As ResultSet
'	resName = Starter.sql.ExecQuery("SELECT Name FROM AllApps WHERE pkgName='" & pkgName & "'")
'	If (resName.RowCount > 0) Then
'		resName.Position = 0
'		Return resName.GetString("Name")
'	End If
	
	Return ""
End Sub

Public Sub ShowKeyboard
	IMElib.ShowKeyboard(txtAppsSearch)
End Sub

Public Sub HideKeyboard
	IMElib.HideKeyboard
End Sub

' Hide Home Popup Menu
' DisHomeDrag = Disable Home Drag and Drop
Public Sub HideHomeMenu (DisHomeDrag As Boolean)
	panHRowMenuHome.SetVisibleAnimated(100, False)
	
	'//-- Save and Disabled Drag and Drop Home List App
	If (dragAllow) And (DisHomeDrag) Then
		dragger.RemoveDragButtons
		MyLog("HideHomeMenu and Disable Home Drag and Drop List")
		SaveHomeList
		dragAllow = False
	End If
	
End Sub

' Hide App Popup Menu
Public Sub HideAppMenu
	panAppMenuApp.SetVisibleAnimated(100, False)
End Sub

Private Sub RunApp(pkgName As String)
	
	MyLog("RunApp => " & pkgName)
	
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
		MyLog("++++++ Error Caught : RunApp => " & pkgName & " - " & LastException)
	End Try
End Sub

Private Sub panApps_Click
	
	Starter.LogShowToast = False
	MyLog("*** Event: panApps_Click => HideKeyboard")
	
	HideKeyboard
	HideAppMenu
	
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
	MyLog("*** Event: btnSetting_Click => HideKeyboard")
	HideKeyboard
	HideAppMenu
	
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
	lblAbout.Text = "Made with Love, by Amir (C) 2023"
	lblVersion.Text = Application.LabelName & ", Build " & Application.VersionCode & " " & Application.VersionName
	
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
	
End Sub

Private Sub btnSave_Click
	Starter.LogShowToast = False
	MyLog("btnSave_Click")
	SaveSettings
	SaveHomeList
	If (chkShowIconsHome.Tag <> chkShowIconsHome.Checked) Then _
		ResetHomeList
	
	If (chkShowIcons.Tag <> chkShowIcons.Checked) Then _
		txtAppsSearch_TextChanged("", txtAppsSearch.Text)
End Sub

Public Sub ResetHomeList
	Starter.LogShowToast = False
	MyLog("ResetHomeList")
	Dim ResHome As ResultSet = Starter.sql.ExecQuery("SELECT * FROM Home ORDER BY ID ASC")
	Starter.HomeApps.Clear
	clvHome.sv.Enabled = False
	clvHome.Clear
	For i = 0 To ResHome.RowCount - 1
		ResHome.Position = i
		
		Dim pkg As String = ResHome.GetString("pkgName")
		
		Dim app As App
			app.PackageName = pkg
			app.Name = ResHome.GetString("Name")
			app.index = i + 1
			app.Icon = Starter.GetPackageIcon(pkg)
			app.IsHomeApp = True
'			app.IsHidden = False
		
		clvHome.Add(CreateListItemHome(app.Name, pkg, clvHome.sv.Width, HomeRowHeigh), pkg)
		Starter.HomeApps.Add(app)
	Next
	ResHome.Close
'	Starter.HomeApps.SortTypeCaseInsensitive("index", True)
	clvHome.sv.Enabled = True
End Sub

Private Sub CloseSetting
	Starter.LogShowToast = False
	MyLog("        CloseSetting")
	btnSetting.Enabled = True
	panSetting.Enabled = True
	panSetting.SetVisibleAnimated(150, False)
	Sleep(150)
	panSetting.RemoveAllViews
	MyLog("END CloseSetting")
End Sub

Public Sub SaveSettings
	Starter.LogShowToast = False
	MyLog("SaveSettings")
	
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
	
	Starter.Pref.ShowIcon = chkShowIcons.Checked
	Starter.Pref.ShowIconHomeApp = chkShowIconsHome.Checked
	Starter.Pref.AutoRunApp = chkAutoRun.Checked
	
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
	
End Sub

Public Sub SaveHomeList
	Starter.LogShowToast = False
	MyLog("SaveHomeList")
	
	Starter.sql.ExecNonQuery("DELETE FROM Home")
	Starter.HomeApps.Clear
	
	For i = 0 To clvHome.Size - 1
		Dim pkg As String = clvHome.GetValue(i)
		Dim name As String = GetAppNamebyPackage(pkg)
		Dim query As String = "INSERT OR REPLACE INTO Home(ID, Name, pkgName) VALUES(" & i & ",'" & GetAppNamebyPackage(pkg) & "', '" & pkg & "')"
		Starter.sql.ExecNonQuery(query)
'		LogColor(query, Colors.Red)
		
		Dim app As App
			app.PackageName = pkg
			app.Name = name
			app.index = i + 1
			app.Icon = Starter.GetPackageIcon(pkg)
			app.IsHomeApp = True
'			app.IsHidden = False
		
		Starter.HomeApps.Add(app)
	Next
'	Starter.HomeApps.SortTypeCaseInsensitive("ID", True)
	
End Sub

Private Sub lblClock_Click
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

Private Sub btnPhone_Click
	HideHomeMenu(True)
	Run_PhoneDialer
End Sub

Public Sub Run_PhoneDialer
	HideHomeMenu(True)
	Dim Intent1 As Intent
	Intent1.Initialize(Intent1.ACTION_VIEW, "tel:")
	StartActivity (Intent1)
End Sub

Public Sub Run_Calendar
	Try
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
		HideHomeMenu(True)
		Dim i As Intent
		i.Initialize("android.intent.action.SET_ALARM", "")
		StartActivity(i)
	Catch
		ToastMessageShow(LastException.Message, True)
		Log("Error Caught: " & LastException)
	End Try
End Sub

Private Sub panPhone_Click
	HideHomeMenu(True)
	If (Starter.Pref.PhoneApp = "") Then
		Run_PhoneDialer
	Else
		RunApp(Starter.Pref.PhoneApp)
	End If
End Sub

Private Sub panCamera_Click
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
	Starter.LogShowToast = False
	MyLog("*** Event: panSettings_Touch => Action: " & Action)
	HideKeyboard
	Select Action
		Case 0 ' Down
			If (DblClick(x, y)) Then CloseSetting
		Case 1 ' Up
			LastClick = DateTime.Now '// Double Tap Time Variable
	End Select
End Sub

Public Sub DblClick(x As Float, y As Float) As Boolean
	
	If (DateTime.Now - LastClick) < 250 Then
		
		Dim ix As Int = x
		Dim iy As Int = y
		Dim Tolerance As Int = 80
		
		Dim res_x As Int = x_dblClick - ix
			If (res_x < 0) Then res_x = res_x * -1
		
		Dim res_y As Int = y_dblClick - iy
			If (res_y < 0) Then res_y = res_y * -1
			
'		LogColor("x: " & (x_dblClick - ix), Colors.Red)
'		LogColor("y: " & (y_dblClick - iy), Colors.Red)
'		Log("-----")
		
		If (Tolerance >= res_x) And (Tolerance >= res_y) Then
			Return True
		End If
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
	lblClock_Click
End Sub

Private Sub DoubleTap
	Try
		MyLog("DoubleTap")
		If Manager.Enabled Then
			Manager.LockScreen
		Else
			Manager.Enable("Please enable administrator access to active 'Lock Screen' by Double Tap.")
			If Manager.Enabled Then Manager.LockScreen
		End If
	Catch
		MyLog("*+*+*+ DoubleTap : " & LastException)
		LogColor("*+*+*+ DoubleTap : " & LastException, Colors.Red)
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
	MyLog("*** Event: panSettings_LongClick - HideKeyboard")
	HideKeyboard
	CloseSetting
End Sub

Private Sub clvHome_ScrollChanged (Offset As Int)
	'//-- Hide Home List Popup Menu
	panHRowMenuHome.Visible = False
	HideHomeMenu(False)
End Sub

Private Sub clvApps_ScrollChanged (Offset As Int)
	panAppMenuApp.SetVisibleAnimated(130, False)
	HideKeyboard
	HideAppMenu
End Sub

Private Sub panApps_Touch (Action As Int, X As Float, Y As Float)
'	Starter.LogShowToast = False
'	MyLog("*** Event: panApps_Touch => A: " & Action & " : HideKeyboard")
	If (Action = 0) Then
		HideKeyboard
		HideAppMenu
	End If
End Sub

Private Sub tagApps_ItemClick (Index As Int, Value As Object)
	RunApp(Value.As(String))
End Sub

Private Sub tagApps_ItemLongClick (Index As Int, Value As Object)
	RemoveAsRecently(Value.As(String))
End Sub

Private Sub chkAutoRun_CheckedChange(Checked As Boolean)
	
End Sub

Public Sub SetDefaultLauncher
	
	Starter.LogShowToast = False
	MyLog("SetDefaultLauncher")
	
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
	Starter.ShowToastLog = chkShowToastLog.Checked
	Starter.sql.ExecNonQuery("INSERT OR REPLACE INTO Settings(KeySetting, Value) VALUES('ShowToastLog'," & Starter.ShowToastLog & ")")
	
	panLog.Visible = False
	panSetting.Visible = True
End Sub

Private Sub clvLog_ItemClick (Index As Int, Value As Object)
	Dim cb As BClipboard
	ToastMessageShow(Value.As(String), True)
	cb.setText(Value)
End Sub


Private Sub lblVersion_Click
	panLog.SetVisibleAnimated(150, True)
'	panSetting.Visible = False
	
	chkShowToastLog.Checked = Starter.ShowToastLog
	
	For Each item In Starter.LogList
		clvLog.AddTextItem(item, item)
	Next
	
End Sub

Private Sub lblVersion_LongClick
	ToastMessageShow("Log list reset successfull.", False)
	Starter.LogList.Clear
	clvLog.Clear
	File.WriteList(File.DirInternalCache, "MyLog.log", Starter.LogList)
	
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

Public Sub SetupInstalledApps_OLD
	
'	MyLog("SetupInstalledApps_OLD")
'
''	Dim args(1) As Object
''	Dim Obj1, Obj2, Obj3 As Reflector
''	Dim size, i, flags As Int
''	Dim Types(1), name, packName As String
''	
''	Obj1.Target = Obj1.GetContext
''	Obj1.Target = Obj1.RunMethod("getPackageManager") ' PackageManager
''	Obj2.Target = Obj1.RunMethod2("getInstalledPackages", 0, "java.lang.int") ' List<PackageInfo>
''	size = Obj2.RunMethod("size")
'	
'	'##
'	'## Create a List (Starter.AppsList) as Installed Softwares
'	'##	and Sorting that to add ListBox control.
'	'##
'	
'	If Not (Starter.AppsList.IsInitialized) Then Starter.AppsList.Initialize
'	
'	Starter.AppsList.Clear
'	
'	Dim sortindex As Int
'	
'	Dim i As Int
'	Dim pm As PackageManager
'	Dim packages As List
'	packages = pm.GetInstalledPackages
'	
'	Dim setting As KeyValueStore
'	setting.Initialize(File.DirInternal, ConfigFileName)
'	Dim AppSize As Int = setting.GetDefault("AppSize", -1).As(Int)
'	Dim Str As StringBuilder
'	Str.Initialize
'	
'	If AppSize = packages.Size Then
'		
'		Dim apps As String = setting.GetDefault("Apps", "").As(String)
'		Dim strApps() As String = Regex.Split("\|", apps)
'		
'		Dim i As Int
'		For i = 0 To strApps.Length - 1
'			
'			Dim currentapp As App
'			currentapp.PackageName = strApps(i)
'			currentapp.Name = GetAppNamebyPackage(currentapp.PackageName)
'			sortindex = sortindex + 1
'			currentapp.index = sortindex
'				
'			Try
'				currentapp.Icon = Starter.GetPackageIcon(currentapp.PackageName)
'			Catch
'				Log("SetupInstalledApps Second - Icon => " & LastException)
'			End Try
'				
'			If (Is_HomeApp(currentapp.PackageName)) Then
'				currentapp.IsHomeApp = True
'				clvHome.Add(CreateListItemHome(currentapp.Name, currentapp.PackageName, clvHome.AsView.Width, HomeRowHeigh), currentapp.PackageName)
'			End If
'				
'			Starter.AppsList.Add(currentapp)
'			
'		Next
'		
'	Else
'	
'		For i = 0 To packages.Size - 1
'			Dim p As String = packages.Get(i)
'			
'			'//-- This will test whether the app is a 'regular' app that
'			'//-- can be launched and if so you can then show it in your app drawer.
'			'//-- If the app has been uninstalled, or if it isn't for normal use,
'			'//-- then it will return false.
'			If pm.GetApplicationIntent(p).IsInitialized Then
'				Dim currentapp As App
'				currentapp.Name = pm.GetApplicationLabel(p)
'				currentapp.PackageName = p
'				sortindex = sortindex + 1
'				currentapp.index = sortindex
'				
'				Str.Append(p & "|")
'				
'				Try
'					currentapp.Icon = Starter.GetPackageIcon(p)
'				Catch
'					Log("SetupInstalledApps - Icon => " & LastException)
'				End Try
'				
'				If (Is_HomeApp(currentapp.PackageName)) Then
'					currentapp.IsHomeApp = True
'					
'					'//-- Here We Can add Home apps to HomeListView
'					'//-- but to solve sort home list as saved
'					'//-- We add Home List Apps after Sort them.
'					'//-- Performance and Loading Time are same.
'					'				Dim r As Reflector
'					'				r.Target = currentapp
'					'				clvHome.Add(CreateListItemHome(currentapp.Name, currentapp.PackageName, clvHome.AsView.Width, HomeRowHeigh), currentapp.PackageName)
'				End If
'				
'				Starter.AppsList.Add(currentapp)
'			End If
'		Next
'		
'		
'		'//-- 			[Installed Apps]
'		'//-- #####################################
'		'//-- Alternative Mehtod for Get Installed Apps List
'		'//-- ,by Calling Java Functions --//
'		'
'		'	For i = 0 To size - 1
'		'		Obj3.Target = Obj2.RunMethod2("get", i, "java.lang.int") ' PackageInfo
'		'		packName = Obj3.GetField("packageName")
'		'
'		'		Obj3.Target = Obj3.GetField("applicationInfo") ' ApplicationInfo
'		'		flags = Obj3.GetField("flags")
'		'
'		''		If Bit.And(flags, 1) = 0 Then '//-- Only Show Installed apps by User
'		'		If Bit.And(flags, 0) = 0 Then '//-- Show All Apps, Include System Apps
'		'			args(0) = Obj3.Target
'		'			Types(0) = "android.content.pm.ApplicationInfo"
'		'			name = Obj1.RunMethod4("getApplicationLabel", args, Types)
'		'
'		''			Try
'		''				Dim icon As BitmapDrawable
'		''				icon = Obj1.RunMethod4("getApplicationIcon", args, Types)
'		''			Catch
'		''				Log("Icon SetupInstalledApps - " & LastException)
'		''			End Try
'		'
'		'			Dim currentapp As App
'		'			currentapp.Name = name
'		'			currentapp.PackageName = packName
'		'			sortindex = sortindex + 1
'		'			currentapp.index = sortindex
'		''			currentapp.Icon = icon
'		'
'		'			If (Is_HomeApp(currentapp.PackageName)) Then currentapp.IsHomeApp = True
'		'
'		'			AppsList.Add(currentapp)
'		'
'		'		End If
'		'	Next
'
'		'//-- End of Alternative Method for Get Installed Apps
'		'//-- #####################################
'		'//-- 			[Installed Apps]	   --//
'		
'		
'		'-- Add Apps to Home ListView
'		clvHome.Clear
'		Dim i As Int
'		For i = 0 To Starter.HomeApps.Size - 1
'			For Each app In Starter.AppsList
'				Dim ap As App = app
'				If Starter.HomeApps.Get(i) = ap.PackageName Then
'					clvHome.Add(CreateListItemHome(ap.Name, ap.PackageName, clvHome.AsView.Width, HomeRowHeigh), ap.PackageName)
'					Exit
'				End If
'			Next
'		Next
'		
'		Starter.AppsList.SortTypeCaseInsensitive("Name", True)
'		
'		setting.Put("AppSize", Starter.AppsList.Size)
'		setting.Put("Apps", Str.ToString)
'		
'		txtAppsSearch_TextChanged("")
'		
'		'	For i = 0 To HomeApps.Length - 1
'		'		For Each app In AppsList
'		'			Dim r As Reflector
'		'			r.Target = app
'		'			If (r.GetField("PackageName").As(String) = HomeApps(i).As(String)) Then
'		'				Dim ap As App = app
'		'				clvHome.Add(CreateListItemHome(ap.Name, clvHome.AsView.Width, HomeRowHeigh), ap.PackageName)
'		'			End If
'		'		Next
'		''		Dim l As Int
'		''		For l = 0 To AppsList.Size - 1
'		''			Dim tt As String
'		''			Dim r As Reflector
'		''			r.Target = AppsList.Get(l)
'		''			tt = r.GetField("PackageName")
'		''			If (tt = HomeApps(i)) Then
'		''				Dim app As App = AppsList.Get(l)
'		''				clvHome.AddTextItem(app.Name, app.PackageName)
'		''			End If
'		''		Next
'		''	Next
'	End If
	
End Sub

Private Sub clvAppRowMenu_ItemClick (Index As Int, Value As Object)
	
	Starter.LogShowToast = False
	MyLog("*** Event: AppsClick: => Index: " & Index & " - Value: " & Value)
	
	Dim pkgName As String = CurrentAppApp.PackageName
	Dim Name As String = CurrentAppApp.Name
	
	HideAppMenu
	dragAllow = False
	
	Select Value
		
		Case "Info"
			Run_Info(pkgName)
			
		Case "AddToHome"
			AddToHomeList(Name, pkgName, clvApps.sv.Width, True)
		
		Case "RemoveFromHome"
			RemoveHomeItem(pkgName)
			
		Case "Uninstall"
			UninstallApp(pkgName)
			
		Case "Hidden"
			HideApp(pkgName)
			
		Case "Rename"
			ToastMessageShow("Rename => " & Name, False)
			
		Case pkgName	'Run App
'			tagApps.LabelProperties.TextColor = Colors.Magenta
			AddToRecently(Name, pkgName, False)
'			SaveRecentlyList
			RunApp(Value.As(String))
			clvApps.AsView.BringToFront
			
	End Select
	
End Sub

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


'Private Sub txtAppsSearch_ClearButtonClick
'	
'	MyLog("*** Event: txtAppsSearch_ClearButtonClick => ShowKeyboard")
'	
'	HideAppMenu
'	ShowHideKeyboard(True)
'	
'End Sub

Private Sub txtAppsSearch_EnterPressed
	txtAppsSearch_TextChanged("", txtAppsSearch.Text)
End Sub


Private Sub txtAppsSearch_FocusChanged (HasFocus As Boolean)
'	If HasFocus = False Then
'		MyLog("*** Event: txtAppsSearch_FocusChanged => HideKeyboard")
'		ShowHideKeyboard(False)
'	End If
'	HideAppMenu
End Sub

Private Sub txtAppsSearch_TextChanged(Old As String, New As String)
	
	Dim i, AppCount As Int = 0
	
	clvApps.Clear
	Alphabet.Clear
	For Each App As App In Starter.NormalAppsList
		If App.Name.ToLowerCase.Contains(txtAppsSearch.Text.ToLowerCase) = True Then
			clvApps.Add(CreateListItemApp(App.Name, App.PackageName, clvApps.AsView.Width, AppRowHeigh), App.PackageName.As(String))
			AppCount = AppCount + 1
			AddtoAlphabetlist(App.Name, i)
			i = i + 1
		End If
	Next
	
	If (AppCount > 20) Then
		AlphabetTable.LoadAlphabetlist(panApps, Alphabet, False, clvApps.AsView.Top)
	Else
		' This line code is mean,
		' Just Remove Last AlphaList from UI
		AlphabetTable.LoadAlphabetlist(panApps, Alphabet, True, clvApps.AsView.Top)
	End If
	AlphabetLastChars = ""
	
	If (Old <> New) Then
		If (txtAppsSearch.Text = New) And (AppCount = 1) Then
			If (Starter.Pref.AutoRunApp = True) Then
				Dim pkg As String = clvApps.GetValue(0).As(String)
				If (LastRunApp <> pkg) Then
					LastRunApp = pkg
					AddToRecently(GetAppNamebyPackage(pkg), pkg, False)
					RunApp(pkg)
					clvApps.AsView.BringToFront
				End If
			End If
		End If
	End If
	
	lblInfo.Text = AppCount & " apps"
	
End Sub

Private Sub btnHiddenAppsDelete_Click
	Try
'		MyLog("*** Event: btnHiddenAppsDelete_Click")
		If clvHiddenApp.Size = 0 Then Return
		If CLVSelection.SelectedItems.AsList.Size = 0 Then Return
		
'		Dim index As Int = clvHiddenApp.GetItemFromView(Sender)
'		Dim value As String = clvHiddenApp.GetValue(index)
		
		Dim selected As Object = CLVSelection.SelectedItems.AsList.Get(0)
		Dim value As 	String = clvHiddenApp.GetValue(selected)
		clvHiddenApp.RemoveAt(selected.As(Int))
		Starter.sql.ExecNonQuery("UPDATE Apps SET IsHidden=0 WHERE pkgName='" & value & "'")
'		CLVSelection.ItemClicked(-1)
	Catch
		MyLog("Error Caught: btnHiddenAppsDelete_Click => " & LastException)
	End Try
End Sub

Private Sub btnHiddenAppsClose_Click
	CloseHiddenManager
End Sub

Private Sub btnHiddenApps_Click
	Starter.LogShowToast = False
	MyLog("*** Event: btnHiddenApps_Click")
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
	
End Sub

Private Sub panHiddenApps_Touch (Action As Int, X As Float, Y As Float)
'	Starter.LogShowToast = False
'	MyLog("*** Event: panSettings_Touch => Action: " & Action)
	HideKeyboard
	Select Action
		Case 0 ' Down
			If (DblClick(x, y)) Then CloseHiddenManager
		Case 1 ' Up
			LastClick = DateTime.Now '// Double Tap Time Variable
	End Select
End Sub

Private Sub panHiddenApps_LongClick
	CloseHiddenManager
End Sub

Private Sub CloseHiddenManager
	
	Starter.LogShowToast = False
	MyLog("CloseHiddenManager")
	
	panHideManager.SetVisibleAnimated(300, False)
	Sleep(300)
	panHideManager.RemoveAllViews
	Starter.SetupAppsList(False)
End Sub

Private Sub clvHiddenApp_ItemClick (Index As Int, Value As Object)
	CLVSelection.ItemClicked(Index)
End Sub

Private Sub LoadHiddenManager
	
	Starter.LogShowToast = False
	MyLog("LoadHiddenManager")
	
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
	Starter.SetupAppsList(True)
	ResetHomeList
	LoadRecentlyList
	txtAppsSearch.Text = txtAppsSearch.Text
	CloseSetting
	ToastMessageShow("Apps Rebuild Successfull!", False)
End Sub

Private Sub clvEdge_ItemClick (Index As Int, Value As Object)

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
	SetDefaultLauncher
End Sub

Private Sub btnClose_Click
	CloseSetting
End Sub

Private Sub panHomRow_Touch (Action As Int, X As Float, Y As Float) As Boolean
	
	longClickClvIndex = clvHome.GetItemFromView(Sender)
	longClickClvPNL = clvHome.GetPanel(longClickClvIndex)
	
	Select Action
		Case 0 ' Down
			longClickClvPNL.SetColorAndBorder(Colors.Gray, 1dip, Colors.Blue, 15dip)
			ClickPanCLV = True
			
				' Long Click
				longCLickFirstimeTouched = DateTime.Now
				longClickX0 = X
				longClickY0 = Y
				clvLongClick = 0
				TimerLongClick.Enabled = True
			
			HideHomeMenu(False)
		Case 1 ' Up
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
	
	Return True
	
End Sub

Private Sub panAppRow_Touch (Action As Int, X As Float, Y As Float) As Boolean
	longClickClvIndex = clvApps.GetItemFromView(Sender)
	longClickClvPNL = clvApps.GetPanel(longClickClvIndex)
	
	Select Action
		Case 0 ' Down
			longClickClvPNL.SetColorAndBorder(Colors.Gray, 1dip, Colors.Blue, 15dip)
			ClickPanCLV = True
			
				' Long Click
				longCLickFirstimeTouched = DateTime.Now
				longClickX0 = X
				longClickY0 = Y
				clvLongClick = 1
				TimerLongClick.Enabled = True
			
			HideAppMenu
			
		Case 1 ' Up
			TimerLongClick.Enabled = False
			If panAppRow.Tag = "" Then panAppRow.Tag = 0
			longClickClvPNL.SetColorAndBorder(panAppRow.Tag, 0, Colors.Blue, 15dip)
			If (ClickPanCLV) Then _
				clvApps_ItemClick(longClickClvIndex, clvApps.GetValue(longClickClvIndex))
			
		Case 3 ' Move
			TimerLongClick.Enabled = False
			If panAppRow.Tag = "" Then panAppRow.Tag = 0
			longClickClvPNL.SetColorAndBorder(panAppRow.Tag, 0, Colors.Blue, 15dip)
			
	End Select
	
	Return True
End Sub
