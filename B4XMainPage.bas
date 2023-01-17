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
	Private lblAppTitle As Label
	Private lblHomeAppTitle As Label
	Private lblDate As Label
	Private lblAbout As Label
	Private lblVersion As Label
	Private chkFav As CheckBox
	
	Private imgPhone As B4XImageView
	Private imgCamera As B4XImageView
	Private btnSetting As Button
	Private btnDelete As Button
	Private cmbPhone As B4XComboBox
	Private cmbCamera As B4XComboBox
	Private cmbClock As B4XComboBox
	Private imgIconApp As ImageView
	Private clocktimer As Timer
	Public txtAppsSearch As AS_TextFieldAdvanced
	
	Private AppsList As List
	Private lstPackageNames As List
	Public HomeApps() As String	'-- Home Screen Apps
	Public Version As String = "My Phone v0.1 Alpha"
	Private ConfigFileName As String = "MyPhone.conf"
	Public AppRowHeigh As Int = 50dip
	Public HomeRowHeigh As Int = 50dip
	Public HomeRowHeighMenu As Int = 30dip
	Public AutoRunOnFind As Boolean
	Public LogMode As Boolean = True
	
	Public StartTime As Boolean = True
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
			 MyPackage As String)
	
	Public Manager As AdminManager
	Private movecount As Int
	Private LastClick As Long
	Private gestHome As Gestures
	Private gestSettings As Gestures
	Private gestHomeList As Gestures
	Private dragger As CLVDragger
	Private IMElib As IME
	Private dd As DDD
	
	Public clvHRowMenu As CustomListView
	Public AppMenu As ListView
	
	Public CurrentAppApp As App
	Public CurrentHomeApp As App
	
	Private AndroidSetting As AndroidSettings
			AndroidSetting.WirelessSettings = "WirelessSettings"
			AndroidSetting.WifiSettings = "WifiSettings"
			AndroidSetting.AdvancedWifiSettings = "AdvancedWifiSettings"
			AndroidSetting.BluetoothSettings = "BluetoothSettings"
			AndroidSetting.TetherSettings = "TetherSettings"
			AndroidSetting.WifiP2pSettings = "WifiP2pSettings"
			AndroidSetting.VpnSettings = "VpnSettings"
			AndroidSetting.DateTimeSettings = "DateTimeSettings"
			AndroidSetting.LocalePicker = "LocalePicker"
			AndroidSetting.InputMethodAndLanguageSettings = "InputMethodAndLanguageSettings"
			AndroidSetting.SpellCheckersSettings = "SpellCheckersSettings"
			AndroidSetting.UserDictionaryList = "UserDictionaryList"
			AndroidSetting.UserDictionarySettings = "UserDictionarySettings"
			AndroidSetting.SoundSettings = "SoundSettings"
			AndroidSetting.DeviceInfoSettings = "DeviceInfoSettings"
			AndroidSetting.ManageApplications = "ManageApplications"
			AndroidSetting.ProcessStatsUi = "ProcessStatsUi"
			AndroidSetting.NotificationStation = "NotificationStation"
			AndroidSetting.LocationSettings = "LocationSettings"
			AndroidSetting.SecuritySettings = "SecuritySettings"
			AndroidSetting.PrivacySettings = "PrivacySettings"
			AndroidSetting.DeviceAdminSettings = "DeviceAdminSettings"
			AndroidSetting.AccessibilitySettings = "AccessibilitySettings"
			AndroidSetting.ToggleCaptioningPreferenceFragment = "ToggleCaptioningPreferenceFragment"
			AndroidSetting.TextToSpeechSettings = "TextToSpeechSettings"
			AndroidSetting.Memory = "Memory"
			AndroidSetting.DevelopmentSettings = "DevelopmentSettings"
			AndroidSetting.UsbSettings = "UsbSettings"
			AndroidSetting.AndroidBeam = "AndroidBeam"
			AndroidSetting.WifiDisplaySettings = "WifiDisplaySettings"
			AndroidSetting.PowerUsageSummary = "PowerUsageSummary"
			AndroidSetting.AccountSyncSettings = "AccountSyncSettings"
			AndroidSetting.CryptKeeperSettings = "CryptKeeperSettings"
			AndroidSetting.DataUsageSummary = "DataUsageSummary"
			AndroidSetting.DreamSettings = "DreamSettings"
			AndroidSetting.UserSettings = "UserSettings"
			AndroidSetting.NotificationAccessSettings = "NotificationAccessSettings"
			AndroidSetting.ManageAccountsSettings = "ManageAccountsSettings"
			AndroidSetting.PrintSettingsFragment = "PrintSettingsFragment"
			AndroidSetting.PrintJobSettingsFragment = "PrintJobSettingsFragment"
			AndroidSetting.TrustedCredentialsSettings = "TrustedCredentialsSettings"
			AndroidSetting.PaymentSettings = "PaymentSettings"
			AndroidSetting.KeyboardLayoutPickerFragment = "KeyboardLayoutPickerFragment"
			AndroidSetting.InstalledAppDetails = "InstalledAppDetails"
	
	Type AndroidSettings(WirelessSettings As String, _
						WifiSettings As String, _
						AdvancedWifiSettings As String, _
						BluetoothSettings As String, _
						TetherSettings As String, _
						WifiP2pSettings As String, _
						VpnSettings As String, _
						DateTimeSettings As String, _
						LocalePicker As String, _
						InputMethodAndLanguageSettings As String, _
						SpellCheckersSettings As String, _
						UserDictionaryList As String, _
						UserDictionarySettings As String, _
						SoundSettings As String, _
						DisplaySettings As String, _
						DeviceInfoSettings As String, _
						ManageApplications As String, _
						ProcessStatsUi As String, _
						NotificationStation As String, _
						LocationSettings As String, _
						SecuritySettings As String, _
						PrivacySettings As String, _
						DeviceAdminSettings As String, _
						AccessibilitySettings As String, _
						ToggleCaptioningPreferenceFragment As String, _
						TextToSpeechSettings As String, _
						Memory As String, _
						DevelopmentSettings As String, _
						UsbSettings As String, _
						AndroidBeam As String, _
						WifiDisplaySettings As String, _
						PowerUsageSummary As String, _
						AccountSyncSettings As String, _
						CryptKeeperSettings As String, _
						DataUsageSummary As String, _
						DreamSettings As String, _
						UserSettings As String, _
						NotificationAccessSettings As String, _
						ManageAccountsSettings As String, _
						PrintSettingsFragment As String, _
						PrintJobSettingsFragment As String, _
						TrustedCredentialsSettings As String, _
						PaymentSettings As String, _
						KeyboardLayoutPickerFragment As String, _
						InstalledAppDetails As String)
	
	Private lblInfo As Label
	Private tagApps As ASScrollingTags
	Public lblSetAsDefaultLauncher As Label
	Private MadeWithLove1 As MadeWithLove
	Private chkAutoRun As CheckBox
	Private chkShowIcons As CheckBox
	Private chkShowKeyboard As CheckBox
End Sub

Public Sub MyLog (Text As String)
	If LogMode Then
		Log(Text)
		ToastMessageShow(Text, False)
	End If
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True

	MyLog("Func: Initialize")
	
	
	StartTime = True
	
	dd.Initialize
	'The designer script calls the DDD class. A new class instance will be created if needed.
	'In this case we want to create it ourselves as we want to access it in our code.
	xui.RegisterDesignerClass(dd)
	
	IMElib.Initialize("")
	
	Dim Setting As KeyValueStore
	Setting.Initialize(File.DirInternal, ConfigFileName)
	Dim apps As String = Setting.GetDefault("HomeApps", "")
	HomeApps = Regex.Split("\|", apps)
	
	Pref.CameraApp = Setting.GetDefault("CameraApp", "")
	Pref.PhoneApp = Setting.GetDefault("PhoneApp", "")
	Pref.ClockApp = Setting.GetDefault("ClockApp", "")
	Pref.ShowIcon = Setting.GetDefault("ShowIcon", False).As(Boolean)
	Pref.ShowKeyboard = Setting.GetDefault("ShowKeyboard", True).As(Boolean)
	Pref.AutoRunApp = Setting.GetDefault("AutoRunApp", True)
	Pref.MyPackage = "my.phone"
	
	DateTime.TimeFormat = "hh:mm:ss"
	lblClock.Initialize("")
	lblClock.Text = DateTime.Time(DateTime.Now)
	
	lblDate.Initialize("")
	DateTime.DateFormat = "dd.MMM.yyyy"
	lblDate.Text = DateTime.Time(DateTime.Now)
	
	clocktimer.Initialize("clocktimer", 1000)
	clocktimer.Enabled = True
	
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
	
	B4XPages.SetTitle(Me, "My & Phone")
	
	FixWallTrans
	
	Tabstrip1.LoadLayout("Home", "Home")
	Tabstrip1.LoadLayout("Apps", "Apps")
	
	imgPhone.Load(File.DirAssets, "Phone.png")
	imgCamera.Load(File.DirAssets, "Camera.png")
	
'	gestHome.SetOnTouchListener(panHome, "gestHome_gesture")
	gestHomeList.SetOnTouchListener(clvHome.AsView, "gestHomeList_gesture")
'	gestSettings.SetOnTouchListener(panSetting, "gestSettings_gesture")
	
	
	SetupInstalledApps
	
	
	'//-- After Screen On, set as top on other apps
'	Dim jo As JavaObject = Root
'	Dim Window As JavaObject = jo.RunMethodJO("getContext", Null).RunMethod("getWindow", Null)
'	Window.RunMethod("addFlags", Array As Object(524288)) 'FLAG_SHOW_WHEN_LOCKED
'	Window.RunMethod("addFlags", Array As Object(128)) 'FLAG_KEEP_SCREEN_ON
	'//--
	
	dragger.Initialize(clvHome)
	
	If Pref.ShowIcon Then
		imgIconApp.Visible = True
		lblAppTitle.Left = 35dip
	Else
		imgIconApp.Visible = False
		lblAppTitle.Left = 5dip
	End If
	StartTime = False
	
	If (GetDefaultLauncher <> Pref.MyPackage) Then _
		lblSetAsDefaultLauncher.Visible = True
	
	StartService(Starter)
	
End Sub

Private Sub Run_Info(PackageName As String)
	MyLog("Func: Run_Info")
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

Private Sub gestSettings_gesture(o As Object, ptrID As Int, action As Int, x As Float, y As Float) As Boolean
	MyLog("Event: gestSettings_gesture")
	'// Double Tap
	If (DateTime.Now - LastClick) < 250 Then
		DoubleTap
		SaveSettings(False)
	End If
	SaveSettings(False)
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
	MyLog("Event: gestHome_gesture")
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
			
			'// Double Tap
			If (DateTime.Now - LastClick) < 250 Then
'				Log("Double Click => " & (DateTime.Now - LastClick))
				DoubleTap
				MyLog("gestHome_gesture")
			End If
			
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

Private Sub Activity_Resume
	MyLog("Event: Activity_Resume")
	If (GetDefaultLauncher <> Pref.MyPackage) Then _
		lblSetAsDefaultLauncher.Visible = True
	GoHome(False)
End Sub

Private Sub Activity_Pause(UserClosed As Boolean)
	MyLog("Event: Activity_Pause")
	If (B4XPages.MainPage.GetDefaultLauncher <> B4XPages.MainPage.Pref.MyPackage) Then _
		B4XPages.MainPage.lblSetAsDefaultLauncher.Visible = True
	GoHome(False)
End Sub

Private Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	MyLog("Event Activity_KeyPress")
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
	MyLog("Func: GoHome")
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
'	Log($"Current page: ${Position}"$)
	DisableDragAndDrop
	SaveSettings(False)
	If (Position = 1) Then
		If Pref.ShowKeyboard Then ShowHideKeyboard(True)
	Else
		Try
			ShowHideKeyboard(False)
		Catch
			ToastMessageShow(LastException.Message, True)
			Log("Error Caught: " & LastException)
		End Try
	End If
End Sub

Private Sub clvApps_ItemClick (Position As Int, Value As Object)
	MyLog("Event clvApps_ItemClick")
	ConfigCurrentAppApp(Position, Value)
	
	If (AppMenu.IsInitialized And AppMenu.Visible) Then
		DisableDragAndDrop
	Else
		clvApps.AsView.BringToFront
'		tagApps.LabelProperties.TextColor = 2
		tagApps.AddTag(CurrentAppApp.Name, Colors.DarkGray, CurrentAppApp.PackageName)
		RunApp(Value.As(String))
	End If
End Sub

Private Sub clvApps_ItemLongClick (Position As Int, Value As Object)
	MyLog("Event clvApps_ItemLongClick")
	ShowHideKeyboard(False)
	ConfigCurrentAppApp(Position, Value.As(String))
	CreateAppMenu(Position, Value)
End Sub

Private Sub clvHome_ItemClick (Position As Int, Value As Object)
	MyLog("Event: clvHome_ItemClick")
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
	MyLog("Func: ConfigCurrentAppApp")
	CurrentAppApp.index = Position
	CurrentAppApp.PackageName = Value.As(String)
	CurrentAppApp.Name = clvApps.GetPanel(Position).GetView(0).Text
End Sub

Private Sub ConfigCurrentHomeApp(Position As String, Value As String)
	MyLog("Func: ConfigCurrentAppApp")
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
	clvHRowMenu.sv.SetColorAndBorder(Colors.LightGray, 2dip, Colors.Magenta, 0)
	clvHRowMenu.sv.SetColorAnimated(300, Colors.LightGray, Colors.DarkGray)
	clvHRowMenu.AddTextItem("Info", "Info")
	clvHRowMenu.AddTextItem("Delete", "Delete")
	clvHRowMenu.AddTextItem("Sort", "Sort")
	
	Dim lft As Int
	Dim tp As Int
	Dim wdh As Int
	Dim hig As Int
	
	wdh = 50%x
	HomeRowHeighMenu = 60dip
	hig = (clvHRowMenu.Size * HomeRowHeighMenu)' + HomeRowHeigh / 4
	
	lft = (panHome.Width / 2) + (wdh  / 2)
	
	panHRowMenuHome.Left = panHome.Width / 2
	panHRowMenuHome.Height = hig
	panHRowMenuHome.Width = 50%x / 2
	tp = (panHome.Height / 2) - (hig / 2)
	panHRowMenuHome.Top = tp
	clvHRowMenu.sv.Height = hig
'	clvHRowMenu.sv.Width = wdh
	clvHRowMenu.sv.Left = 5dip
	Log("X: " & XPos)
	Log("Y: " & YPos)

End Sub

Private Sub CreateAppMenu(Position As Int, Value As Object)
	MyLog("Func: CreateAppMenu")
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
	MyLog("Event: clvRowMenu_Click")
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
			If Ap.IsHomeApp = True Then
				StartTime = True
				chkFav.Checked = True
				StartTime = False
			End If
			AppCount = AppCount + 1
		End If
	Next
	
	If (txtAppsSearch.Text = Text) And (AppCount = 1) Then
		If (Pref.AutoRunApp) Then
			RunApp(clvApps.GetValue(0).As(String))
		End If
	End If
	
	lblInfo.Text = AppCount & " apps"
	
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
	'//-- Another Mehtof for Get Installed Apps List
	'//-- ,by Calling Java Functions --//
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

	'//-- Another Methof for Get Installed Apps
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
	MyLog("Func: FindHomeItem")
	Dim i As Int = 0
	For i = 0 To clvHome.Size - 1
		If (clvHome.GetValue(i) = pkgName) Then Return True
	Next
	Return False
End Sub

Private Sub chkFav_CheckedChange(Checked As Boolean)
	MyLog("Event: chkFav_CheckedChange")
	If StartTime Then Return
	
	Dim indexapp As Int = clvApps.GetItemFromView(Sender)
	Dim pnlapp As B4XView = clvApps.GetPanel(indexapp)
'	Dim lblapp As B4XView = dd.GetViewByName(pnlapp, "lblAppTitle")
	
	Dim r As Reflector
	r.Target = HomeApps
	If Checked Then
		If (FindHomeItem(clvApps.GetValue(indexapp)) = False) Then
			clvHome.Add(CreateListItemHome(pnlapp.GetView(0).Text, clvApps.GetValue(indexapp), clvHome.AsView.Width, HomeRowHeigh), clvApps.GetValue(indexapp))
			Log(clvApps.GetValue(indexapp))
			SaveHomeList
'			clvHome.AddTextItem(pnlapp.GetView(0).Text, clvApps.GetValue(indexapp))
		End If
		
'		Dim i As Int
'		For i = 0 To HomeApps.Length - 1
'			If (HomeApps(i) = clvApps.GetValue(indexapp)) Then
'				Log(clvApps.GetValue(indexapp))
'			End If
'		Next
'		
'		For Each ap In HomeApps
'			Log(clvApps.GetValue(indexapp))
'		Next
		
	Else
		'//-- Get All Elements in List HomeRow
		Try
			RemoveHomeItem(indexapp)
			SaveHomeList
		Catch
			SaveHomeList
			Log(LastException)
		End Try
	End If
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
	ShowHideKeyboard(False)
	DisableDragAndDrop
End Sub

Private Sub btnSetting_Click
	
	ShowHideKeyboard(False)
	DisableDragAndDrop
	
	chkShowKeyboard.Checked = Pref.ShowKeyboard
	chkShowIcons.Checked = Pref.ShowIcon
	chkAutoRun.Checked = Pref.AutoRunApp
	lblAbout.Text = "Made with Love, by Amir (C) 2023"
	lblVersion.Text = Version
	
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
				cmbPhone.SetItems(lst)
				cmbCamera.SetItems(lst)
				cmbClock.SetItems(lst)
				
				If (CameraIndex > -1) Then
					cmbCamera.SelectedIndex = CameraIndex
					cmbCamera.Tag = lstPackageNames.Get(CameraIndex).As(String)
				Else
					cmbCamera.cmbBox.Add("[Select Camera App]")
					cmbCamera.SelectedIndex = cmbCamera.Size - 1
				End If
				
				If (PhoneIndex > -1) Then
					cmbPhone.SelectedIndex = PhoneIndex
					cmbPhone.Tag = lstPackageNames.Get(PhoneIndex).As(String)
				Else
					cmbPhone.cmbBox.Add("[Select Phone App]")
					cmbPhone.SelectedIndex = cmbPhone.Size - 1
				End If
				
				If (ClockIndex > -1) Then
					cmbClock.SelectedIndex = ClockIndex
					cmbClock.Tag = lstPackageNames.Get(ClockIndex).As(String)
				Else
					cmbClock.cmbBox.Add("[Select Clock App]")
					cmbClock.SelectedIndex = cmbClock.Size - 1
				End If
			
			End If
			
		End If
		
'	End If
	
End Sub

Private Sub btnClose_Click
	SaveSettings(True)
End Sub

Private Sub CloseSettingPanel
	btnSetting.Enabled = True
	panSetting.Enabled = True
	panSetting.Visible = False
	panSetting.RemoveAllViews
End Sub

Public Sub SaveSettings(Save As Boolean)
	MyLog("Func: SaveSettings " & Save.As(String))
	
	CloseSettings
	
	If (Save <> True) Then Return
	
	Pref.ShowKeyboard = chkShowKeyboard.Checked
	
	Pref.ClockApp = cmbClock.Tag.As(String)
	Pref.CameraApp = cmbCamera.Tag.As(String)
	Pref.PhoneApp = cmbPhone.Tag.As(String)
	Pref.ShowIcon = chkShowIcons.Checked
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
	setting.Put("AutoRunApp", Pref.AutoRunApp)
	
	ToastMessageShow("Settings Changed and Saved !", False)
	
End Sub

Private Sub CloseSettings
	MyLog("Func: CloseSettings")
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
	ShowHideKeyboard(False)
	If DblClick Then SaveSettings(False)
End Sub

Private Sub DblClick() As Boolean
	If (DateTime.Now - LastClick) < 250 Then Return True
	'// Double Tap Time Variable
	LastClick = DateTime.Now
	Return False
End Sub

Private Sub cmbPhone_SelectedIndexChanged (Index As Int)
	cmbPhone.Tag = lstPackageNames.Get(Index).As(String)
End Sub

Private Sub cmbCamera_SelectedIndexChanged (Index As Int)
	cmbCamera.Tag = lstPackageNames.Get(Index).As(String)
End Sub

Private Sub cmbClock_SelectedIndexChanged (Index As Int)
	cmbClock.Tag = lstPackageNames.Get(Index).As(String)
End Sub

Private Sub lblDate_Click
	lblClock_Click
End Sub

Private Sub DoubleTap
	Try
		ToastMessageShow("Loock Phone!", False)
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
	SaveSettings(False)
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
		ShowHideKeyboard(False)
	End If
	DisableDragAndDrop
End Sub

Private Sub panApps_Touch (Action As Int, X As Float, Y As Float)
	ShowHideKeyboard(False)
	DisableDragAndDrop
End Sub


Private Sub tagApps_ItemClick (Index As Int, Value As Object)
	RunApp(Value.As(String))
End Sub

Private Sub tagApps_ItemLongClick (Index As Int, Value As Object)
	tagApps.CLV.RemoveAt(Index)
End Sub

Private Sub txtAppsSearch_ClearButtonClick
	ShowHideKeyboard(False)
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

Private Sub ShowAndroidSettings
	Dim in As Intent
	in.Initialize("android.settings.SETTINGS", "")
	StartActivity(in)
End Sub

Private Sub panSettings_Touch (Action As Int, X As Float, Y As Float)
	
End Sub