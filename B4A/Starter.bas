B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.85
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
'	#StartCommandReturnValue: android.app.Service.START_STICKY
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	Private PhonEvent 				As PhoneEvents
	Private PhID 					As PhoneId
	
	Public sql 						As SQL
	Public AppsList 				As List		'-- All Installed Apps
	Public NormalAppsList 			As List		'-- Normal Apps to show
	Public ShowToastLog 			As Boolean  = True
	Public LogMode 					As Boolean  = True
	Public LogShowToast				As Boolean  = True
	Public LogList 					As List
	Public Pref 					As Settings
	Public const NAVBARHEIGHT		As Int 		= 80dip
	Private LogListColor			As Int		= 0xFF4040FF
	Private LogListColorEnd			As Int 		= 0xFF8989FF
	Private flagPlugged 	As Boolean
	
	Type App(Name As String, _
			PackageName As String, _
			index As Int, _
			IsHomeApp As Boolean, _
			Icon As Bitmap, _
			IsHidden As Boolean, _
			VersionCode As Int)
	
	Type Settings(CameraApp As String, _
			 PhoneApp As String, _
			 ClockApp As String, _
			 ShowIcon As Boolean, _
			 ShowKeyboard As Boolean, _
			 AutoRunApp As Boolean, _
			 MyPackage As String, _
			 ShowIconHomeApp As Boolean, _
			 DebugMode As Boolean)

End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	
	LogList.Initialize
	MyLog("########################### " & CRLF _
			& "                   Service_Create" _
			& CRLF & "########################### " & CRLF, Colors.Magenta, False)
	
	CreateDB	
	
	FixWallTrans
	
	SetupSettings
	
	PhonEvent.InitializeWithPhoneState("PhonEvent", PhID)

End Sub

Sub Service_Start (StartingIntent As Intent)
	MyLog("Service_Start: " & StartingIntent.ExtrasToString, LogListColor, True)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	
	Dim ls As List
	ls.Initialize
	
	For i = 0 To LogList.Size - 1
		
		LogColor(LogList.Get(i), Colors.Green)
		ls.Add(LogList.Get(i))
	Next
	
	File.WriteList(File.DirInternal, "MyLog.log", ls)
	
'	Return False
	
	LogColor(StackTrace, Colors.Red)
	LogColor(Error.Message, Colors.Red)
'	MyLog("Application_Error: " & Error & ":" & StackTrace, LogListColor, True)
	Return True
End Sub

Sub Service_Destroy
	
	Dim ls As List
		ls.Initialize
	File.WriteList(File.DirInternal, "MyLog.log", LogList)
	
End Sub

Sub PhonEvent_PackageRemoved (Package As String, Intent As Intent)
	
	LogShowToast = False
	MyLog("PE_PackageRemoved: " & Package, LogListColor, False)
	
	SetupAppsList(True)
	B4XPages.MainPage.SetupHomeList
	Dim name As String = B4XPages.MainPage.GetAppNamebyPackage(Package)
	
	B4XPages.MainPage.RemoveAppItem_JustFromAppList(Package)
	B4XPages.MainPage.RemoveAsRecently(Package)
	B4XPages.MainPage.RemoveHomeItem(Package)
	B4XPages.MainPage.SaveHomeList
	ToastMessageShow(name & " Removed!", True)
End Sub

Sub PhonEvent_PackageAdded (Package As String, Intent As Intent)
	
	LogShowToast = False
	MyLog("PE_PackageAdded: " & Package, LogListColor, False)
	
	SetupAppsList(True)
	B4XPages.MainPage.SetupHomeList
	Dim name As String = B4XPages.MainPage.GetAppNamebyPackage(Package)
	
	AddToRecently(name, Package, True)
	B4XPages.MainPage.txtAppsSearch.Text = B4XPages.MainPage.txtAppsSearch.Text
	ToastMessageShow(name & " Installed!", True)
End Sub

'Never call this Event Manual
Sub PhonEvent_BatteryChanged (Level As Int, Scale As Int, Plugged As Boolean, Intent As Intent)
	Try
		MyLog("PhonEvent_BatteryChanged= Plugged: " & Plugged & " - " & Level & "%", LogListColor, True)
		
		If Plugged <> flagPlugged Then ' = True Then
			flagPlugged = Plugged
			If Plugged = True Then
				
'				ToastMessageShow("Plugin", False)
				B4XPages.MainPage.BatteryVisiblity(True, Level)
				
				Dim chargeMethod As Int 					'chargeMethod:
				chargeMethod = Intent.GetExtra("plugged")	'	AC = 1
															'	USB = 2
															'	Wireless = 4
				Select chargeMethod
					Case 1:
						MyLog("Plugged in...: " & Level & "%", LogListColor, False)
					Case 2:
						MyLog("USB Charing...: " & Level & "%", LogListColor, False)
					Case 4:
						MyLog("Wireless Charing...: " & Level & "%", LogListColor, False)
					Case Else:
						MyLog("PhonEvent_BatteryChanged, Something Detected!: " & Level & "%", Colors.Red, False)
				End Select
				
			Else
'				ToastMessageShow("Plug-out", False)
				MyLog("Unpluged", LogListColor, False)
				B4XPages.MainPage.BatteryVisiblity(False, Level)
			End If
			
		Else If (Plugged = True) Then
			MyLog("Pluged: " & Level & "%", LogListColor, False)
			B4XPages.MainPage.BatteryVisiblity(True, Level)
'			B4XPages.MainPage.BatterySetValue(Level)
		End If
	Catch
		MyLog(LastException & " - BatteryChanged: " & Level & "%", Colors.Red, False)
	End Try
End Sub

'Private Sub BatteryDetect
'	Dim filter As IntentFilter
'	Dim battery As Intent
'	filter.Initialize("android.intent.action.BATTERY_CHANGED", "")
'	battery = GetApplicationContext.RegisterReceiver("", filter)
'	Dim status As Int = battery.GetExtra("status")
'	Dim isCharging As Boolean = (status = 2) Or (status = 5)
'	If isCharging Then
'		Log("Device is Charging")
'	Else
'		Log("Device is NOT Charging")
'	End If
'End Sub

Public Sub MyLog (Text As String, color As Int, JustShowInDebugMode As Boolean)
	
	If Not (LogMode) Then Return
	
	DateTime.DateFormat="HH:mm:ss.SSS"
	Dim time As String = DateTime.Date(DateTime.Now)
	
	If Not (LogList.IsInitialized) Then LogList.Initialize
	
	If (JustShowInDebugMode) Then
		LogColor(Text & " (" & time & ")", color)
		If (Pref.DebugMode) Then _
			LogList.Add(Text & " (" & time & ")")
	Else
		LogList.Add(Text & " (" & time & ")")
		LogColor(Text & " (" & time & ")", color)
		If (ShowToastLog) Then
			If (LogShowToast) Then
				ToastMessageShow(Text, False)
			End If
		End If
		
	End If
	
	LogShowToast = True
End Sub

Private Sub CreateDB
	MyLog("CreateDB", LogListColor, True)
	If Not (File.Exists(File.DirInternal, "MyPhone.db")) Then
		File.Copy(File.DirAssets, "MyPhone.db", File.DirInternal, "MyPhone.db")
		LogColor(">>>>> - Database Replaced ! - <<<<<", Colors.Red)
		MyLog("CreateDB >>> Database Replaced", LogListColor, False)
	End If
	
	sql.Initialize(File.DirInternal, "MyPhone.db", False)
	MyLog("CreateDB END", LogListColorEnd, True)
End Sub

Private Sub SetupSettings
	
	MyLog("SetupSettings", LogListColor, True)
	
	Dim tmpResult As String
	Dim CurSettingSql As ResultSet
		CurSettingSql = sql.ExecQuery("SELECT * FROM Settings")
	
	Pref.MyPackage = Application.PackageName '"com.my.phone"
	
	For i = 0 To CurSettingSql.RowCount - 1
		CurSettingSql.Position = i
		tmpResult = CurSettingSql.GetString("KeySetting")
		
		Select tmpResult:
			Case "CameraApp"
				Pref.CameraApp = CurSettingSql.GetString("Value")
				
			Case "PhoneApp"
				Pref.PhoneApp = CurSettingSql.GetString("Value")
				
			Case "ClockApp"
				Pref.ClockApp = CurSettingSql.GetString("Value")
				
			Case "ShowToastLog"
				ShowToastLog = ValToBool(CurSettingSql.GetString("Value"))
				
			Case "AutoRunApp"
				Pref.AutoRunApp = ValToBool(CurSettingSql.GetString("Value"))
				
			Case "ShowKeyboard"
				Pref.ShowKeyboard = ValToBool(CurSettingSql.GetString("Value"))
				
			Case "ShowIconHomeApp"
				Pref.ShowIconHomeApp = ValToBool(CurSettingSql.GetString("Value"))
				
			Case "ShowIcon"
				Pref.ShowIcon = ValToBool(CurSettingSql.GetString("Value"))
			
			Case "DebugMode"
				Pref.DebugMode = ValToBool(CurSettingSql.GetString("Value"))
				
		End Select
	Next
	CurSettingSql.Close
	
	MyLog("SetupSettings END", LogListColorEnd, True)
End Sub

Public Sub ValToBool(value As Object) As Boolean
	
	If (value.As(String).Length <= 0) Then Return False
	If (value.As(String).ToLowerCase = "false") Then Return False
	If (value.As(String).ToLowerCase = "true") Then Return True
	
	Dim tmp As Int
	Try
		tmp = value.As(Int)
	Catch
		tmp = 0
	End Try
	
	If (tmp > 0) Then
		Return True
	Else
		Return False
	End If
	
End Sub

Public Sub SetupAppsList(ForceReload As Boolean)
	
	ShowToastLog = False
	MyLog("SetupAppsList = Reload: " & ForceReload, LogListColor, False)
	
	If Not (AppsList.IsInitialized) Then AppsList.Initialize
	If Not (NormalAppsList.IsInitialized) Then NormalAppsList.Initialize
	
	AppsList.Clear
	NormalAppsList.Clear
	
	'// All Apps in Database
	Dim ResApps As ResultSet = sql.ExecQuery("SELECT * FROM AllApps ORDER By Name ASC")
	
	
	'// All Apps in OS
	Dim pm As PackageManager
	Dim packages As List
		packages = pm.GetInstalledPackages
	
	LogColor("RowCount: " & ResApps.RowCount & " - Package Size: " & packages.Size, Colors.Red)
	
	If (ForceReload = True) Or (ResApps.RowCount <> (packages.Size - 1)) Then
		
		MyLog("SetupAppsList = Reload: TRUE", LogListColor, True)
		
		'# First Time Run after Installation
		'#
		'#------------------------------------
		
		Dim queryApps, queryAllApps As String
		sql.ExecNonQuery("DELETE FROM AllApps")
'		sql.ExecNonQuery("DELETE FROM Apps")
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
					currentapp.index = i + 1
					currentapp.Icon = GetPackageIcon(p)
					currentapp.IsHomeApp = False
					currentapp.IsHidden = False
					currentapp.VersionCode = pm.GetVersionCode(p)
				
				queryApps = "INSERT OR IGNORE  INTO Apps 	(Name, pkgName, IsHome, 	IsHidden, 	VersionCode) 	 VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "', 0, 0," & currentapp.VersionCode & ");" & _
							"INSERT OR REPLACE INTO AllApps(Name, pkgName, IsHomeApp, 	IsNormalApp,VersionCode) 	 VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "', 0, 1," & currentapp.VersionCode & ");" & queryApps
			Else
				Dim currentapp As App
					currentapp.Name = pm.GetApplicationLabel(p)
					currentapp.PackageName = p
'					currentapp.index = i + 1
'					currentapp.Icon = GetPackageIcon(p)
'					currentapp.IsHomeApp = False
'					currentapp.IsHidden = False
					currentapp.VersionCode = pm.GetVersionCode(p)
				
				queryAllApps = "INSERT OR REPLACE INTO AllApps(Name, pkgName, IsHomeApp, IsNormalApp, VersionCode) VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "', 0, 0," & currentapp.VersionCode & ");" & queryAllApps
			End If
			AppsList.Add(currentapp)
			
		Next
		sql.ExecNonQuery(queryApps)
		sql.ExecNonQuery(queryAllApps)
		AppsList.SortTypeCaseInsensitive("Name", True)
		
		ResApps.Close
		ResApps = sql.ExecQuery("SELECT * FROM Apps WHERE IsHidden=0 ORDER BY Name ASC")
		
		Dim intCount As Int = 0
		Do While ResApps.NextRow
			
			Dim currentapp As App
				currentapp.PackageName = ResApps.GetString("pkgName")
				currentapp.Name = ResApps.GetString("Name")
				currentapp.IsHomeApp = False
			intCount = intCount + 1
				currentapp.index = intCount
				currentapp.Icon = GetPackageIcon(currentapp.PackageName)
				currentapp.IsHomeApp = False
				currentapp.IsHidden = False 'ValToBool(ResApps.GetInt("IsHidden"))
				currentapp.VersionCode = ResApps.GetInt("VersionCode")
				
			NormalAppsList.Add(currentapp)
			
		Loop
		ResApps.Close
		NormalAppsList.SortTypeCaseInsensitive("Name", True)
		
	Else
		
		'//----- Config Apps List
		'
		ResApps.Close
		ResApps = sql.ExecQuery("SELECT * FROM Apps WHERE IsHidden=0 ORDER BY Name ASC")
		
		Dim intCount As Int = 0
		Do While ResApps.NextRow
			
			Dim currentapp As App
				currentapp.PackageName = ResApps.GetString("pkgName")
				currentapp.Name = ResApps.GetString("Name")
				currentapp.IsHomeApp = False
			intCount = intCount + 1
				currentapp.index = intCount
				currentapp.Icon = GetPackageIcon(currentapp.PackageName)
				currentapp.IsHomeApp = False
				currentapp.IsHidden = False 'ValToBool(ResApps.GetInt("IsHidden"))
				currentapp.VersionCode = ResApps.GetInt("VersionCode")
			
			NormalAppsList.Add(currentapp)
			AppsList.Add(currentapp)
			
		Loop
		ResApps.Close
		AppsList.SortTypeCaseInsensitive("Name", True)
		NormalAppsList.SortTypeCaseInsensitive("Name", True)
		
	End If
	
	ShowToastLog = False
	MyLog("SetupAppsList END = Reload: " & ForceReload, LogListColorEnd, False)
	
End Sub

Public Sub GetPackageIcon(pkgName As String) As Bitmap
	Try
'		LogShowToast = False
'		MyLog("GetPackageIcon => " & pkgName)
		
		Dim pm As PackageManager, Data As Object = pm.GetApplicationIcon(pkgName)
		If Data Is BitmapDrawable Then
			Dim Icon As BitmapDrawable = Data
			Return Icon.Bitmap
		Else
			Return GetBmpFromDrawable(Data, 48dip)
		End If
	Catch
		If (LastException.Message = "java.lang.Exception:  android.content.pm.PackageManager$NameNotFoundException: yes") Then
			Return Null
		Else
			MyLog("GetPackageIcon: " & pkgName & " - " & LastException.Message, LogListColor, True)
			Return Null
		End If
	End Try
End Sub

Private Sub GetBmpFromDrawable(Drawable As Object, Size As Int) As Bitmap
	
	Dim BMP As Bitmap, Drect As Rect, BG As Canvas
	
	BMP.InitializeMutable(Size,Size)
	Drect.Initialize(0,0,Size,Size)
	BG.Initialize2(BMP)
	BG.DrawDrawable(Drawable,Drect)
	
	Return BG.Bitmap
	
End Sub

Public Sub AddToRecently(Text As String, Value As String, IsNewInstalledApp As Boolean)
	
	MyLog("AddToRecently = " & Text & " - " & Value, LogListColor, True)
	
	Value = B4XPages.MainPage.GetPackage(Value)
	
	If Not 	(B4XPages.MainPage.RecentlyList.IsInitialized) Then B4XPages.MainPage.RecentlyList.Initialize
	
	If 		(B4XPages.MainPage.FindRecentlyItem(Value)) Then Return
	If Not 	(B4XPages.MainPage.Is_NormalApp(Value)) 	Then Return
	
	If Text = "" Then _
		Text = B4XPages.MainPage.GetAppNamebyPackage(Value)
	
	B4XPages.MainPage.tagApps.mBase.Enabled = False
	B4XPages.MainPage.tagApps.CLV.Clear
	B4XPages.MainPage.tagColors = Colors.DarkGray
	
	B4XPages.MainPage.RecentlyList.AddAllAt(0, Array(Value))
	
	If (B4XPages.MainPage.RecentlyList.Size > 5) Then _
		B4XPages.MainPage.RecentlyList.RemoveAt(B4XPages.MainPage.RecentlyList.Size - 1)
	
	sql.ExecNonQuery("DELETE FROM RecentlyApps")
	
	Dim j As Int
	If (IsNewInstalledApp) Then
		B4XPages.MainPage.tagApps.LabelProperties.TextColor = Colors.Yellow
		B4XPages.MainPage.tagApps.AddTag(Text, B4XPages.MainPage.tagColors, Value)
		j = 1
	Else
		j = 0
	End If
	B4XPages.MainPage.tagApps.LabelProperties.TextColor = Colors.LightGray
	
	Dim query As String = "INSERT OR REPLACE INTO RecentlyApps(Name, pkgName) VALUES"
	Dim tmp As String
	For i = j To B4XPages.MainPage.RecentlyList.Size - 1
		Dim appName As String = B4XPages.MainPage.GetAppNamebyPackage(B4XPages.MainPage.RecentlyList.Get(i))
		B4XPages.MainPage.tagApps.AddTag(appName, B4XPages.MainPage.tagColors, B4XPages.MainPage.RecentlyList.Get(i))
		tmp = "('" & appName & "','" & B4XPages.MainPage.RecentlyList.Get(i) & "')," & tmp
	Next
	If (tmp.Length > 0) Then
		query = query & tmp.SubString2(0, tmp.Length - 1)
		sql.ExecNonQuery(query)
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
	
	
	B4XPages.MainPage.tagApps.mBase.Enabled = True
	
	MyLog("AddToRecently END = " & Text & " - " & Value, LogListColorEnd, True)
	
'	'//----- Reset RecentlyBar Color to Default for OLD Method used
'	tagColors = Colors.DarkGray
'	tagApps.LabelProperties.TextColor = Colors.LightGray
	
End Sub

Public Sub FixWallTrans
	
	LogShowToast = False
	MyLog("FixWallTrans", LogListColor, False)
	
'	'{###### ### Fix Wallpaper
	Dim r As Reflector
		r.Target = r.GetContext
		r.Target = r.RunStaticMethod("android.app.WallpaperManager", "getInstance", Array As Object(r.GetContext), Array As String("android.content.Context"))
	
'	r.RunMethod4("suggestDesiredDimensions", Array As Object(root.Width * 2, root.height), Array As String("java.lang.int", "java.lang.int"))
	r.RunMethod4("suggestDesiredDimensions", Array As Object(GetDeviceLayoutValues.Width * 2, GetDeviceLayoutValues.Height), Array As String("java.lang.int", "java.lang.int"))
	
	Dim pagesx As Float
		pagesx = (1.00 / 5) '5: Page Screen Count
	
	Dim pagesy As Float
		pagesy = 1.00
	
	r.RunMethod4("setWallpaperOffsetSteps", Array As Object(pagesx, pagesy), Array As String("java.lang.float", "java.lang.float"))
'	'}-----
	
'	'###### { ### Set Navigation Bar Transparent
'	If (window <> Null) Then
'		Dim jo 		As JavaObject
'			jo.InitializeContext
'		Dim window 	As JavaObject
'			window = jo.RunMethod("getWindow", Null)
'			window.RunMethod("addFlags", Array(Bit.Or(0x00000200, 0x08000000)))
'		'root.Height = root.Height + NAVBARHEIGHT
'	End If
'	'}-----
	
	MyLog("FixWallTrans END" & TAB, LogListColor, True)
End Sub

'XpageSize: 1/(numberofpages-1), YpageSize=1 usually
Private Sub LWP_SetDesiredDimensions(VirtualWidth As Int, VirtualHeight As Int, XpageSize As Float, YpageSize As Float)
	Dim r As Reflector'Must add this permission to the manifest: AddPermission("android.permission.SET_WALLPAPER_HINTS") and possibly android.permission.SET_WALLPAPER
		r.Target = r.RunStaticMethod("android.app.WallpaperManager", _
					"getInstance", _
					Array As Object(r.GetContext), _
					Array As String("android.content.Context"))
		r.RunMethod4("suggestDesiredDimensions", _
					Array As Object(VirtualWidth, VirtualHeight), _
					Array As String("java.lang.int", _
					"java.lang.int"))
		r.RunMethod4("setWallpaperOffsetSteps", _
					Array As Object(XpageSize, YpageSize), _
					Array As String("java.lang.float", _
					"java.lang.float"))
End Sub

'Dest: The object that will be hosting the wallpaper (ie: the activity)
Private Sub LWP_SetLocation(Dest As Object, X As Float, Y As Float)
	Dim r As Reflector, o As Reflector
		r.Target = r.RunStaticMethod("android.app.WallpaperManager", _
								 "getInstance", _
								 Array As Object(r.GetContext), _
								 Array As String("android.content.Context"))
	o.Target = Dest
	r.RunMethod4("setWallpaperOffsets", Array As Object(o.RunMethod("getWindowToken"), X, Y), _
										Array As String("android.os.IBinder", _
										"java.lang.float", _
										"java.lang.float"))
	
End Sub

