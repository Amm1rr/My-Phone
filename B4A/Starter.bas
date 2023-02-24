B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.85
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	Dim PhoneEvent As PhoneEvents
	Dim PhID As PhoneId
	
	Public sql 						As SQL
	Public AppsList 				As List		'-- All Installed Apps
	Public NormalAppsList 			As List		'-- Normal Apps to show
	Public HomeApps 				As List		'-- Home Screen Apps
	Public ShowToastLog 			As Boolean  = True
	Public LogMode 					As Boolean  = True
	Public LogShowToast				As Boolean  = True 
	Public LogList 					As List
	Private LogListColor			As Int		= 0xFF4040FF
	Private LogListColorEnd			As Int 		= 0xFF8989FF
	Public Pref 					As Settings
	Public const NAVBARHEIGHT		As Int = 24
	
	Type App(Name As String, _
			PackageName As String, _
			index As Int, _
			IsHomeApp As Boolean, _
			Icon As Bitmap, _
			IsHidden As Boolean)
	
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
	
	PhoneEvent.InitializeWithPhoneState("PhoneEvent", PhID)
	
	FixWallTrans
	
	SetupSettings

End Sub

Sub Service_Start (StartingIntent As Intent)
	MyLog("Service_Start", LogListColor, False)
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

Sub PhoneEvent_PackageRemoved (Package As String, Intent As Intent)
	
	LogShowToast = False
	MyLog("PE_PackageRemoved: " & Package, LogListColor, False)
	
	Dim name As String = B4XPages.MainPage.GetAppNamebyPackage(Package)
	SetupAppsList(True)
	
	B4XPages.MainPage.RemoveAppItem_JustFromAppList(Package)
	B4XPages.MainPage.RemoveAsRecently(Package)
	B4XPages.MainPage.RemoveHomeItem(Package)
	B4XPages.MainPage.SaveHomeList
	ToastMessageShow(name & " Removed!", True)
End Sub

Sub PhoneEvent_PackageAdded (Package As String, Intent As Intent)
	
	LogShowToast = False
	MyLog("PE_PackageAdded: " & Package, LogListColor, False)
	
	SetupAppsList(True)
	Dim name As String = B4XPages.MainPage.GetAppNamebyPackage(Package)
	
	AddToRecently(name, Package, True)
	B4XPages.MainPage.txtAppsSearch.Text = B4XPages.MainPage.txtAppsSearch.Text
	ToastMessageShow(name & " Installed!", True)
End Sub

Public Sub MyLog (Text As String, color As Int, JustShowInDebugMode As Boolean)
	
	If Not (LogMode) Then Return
	
	DateTime.DateFormat="HH:mm:ss.SSS"
	Dim time As String = DateTime.Date(DateTime.Now)
	
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
	MyLog("CreateDB", LogListColor, False)
	If Not (File.Exists(File.DirInternal, "MyPhone.db")) Then
		File.Copy(File.DirAssets, "MyPhone.db", File.DirInternal, "MyPhone.db")
		LogColor(">>>>> - Database Replaced ! - <<<<<", Colors.Red)
	End If
	
	sql.Initialize(File.DirInternal, "MyPhone.db", False)
	MyLog("CreateDB END", LogListColorEnd, False)
End Sub

Private Sub SetupSettings
	
	MyLog("SetupSettings", LogListColor, False)
	
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
	
	MyLog("SetupSettings END", LogListColorEnd, False)
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
	If Not (HomeApps.IsInitialized) Then HomeApps.Initialize
	If Not (NormalAppsList.IsInitialized) Then NormalAppsList.Initialize
	
	AppsList.Clear
	HomeApps.Clear
	NormalAppsList.Clear
'	Dim Count As Int = sql.ExecQuerySingleResult("SELECT count(ID) FROM Apps")


	'// All Apps in Database
	Dim ResApps As ResultSet = sql.ExecQuery("SELECT * FROM AllApps ORDER By Name ASC")
	
	
	'// All Apps in OS
	Dim pm As PackageManager
	Dim packages As List
		packages = pm.GetInstalledPackages
	
	LogColor("RowCount: " & ResApps.RowCount & " - Package Size: " & packages.Size, Colors.Red)
	
	If (ForceReload = True) Or (ResApps.RowCount <> packages.Size) Then
		
		MyLog("SetupAppsList = Reload: TRUE", LogListColor, True)
		
		'# First Time Run after Installation
		'#
		'#------------------------------------
		
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
				
				sql.BeginTransaction
				sql.ExecNonQuery("INSERT OR IGNORE  INTO Apps 	(Name, pkgName, IsHome, 	IsHidden) 	 VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "', 0, 0);" & _
								 "INSERT OR REPLACE INTO AllApps(Name, pkgName, IsHomeApp, 	IsNormalApp) VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "', 0, 1)")
				sql.TransactionSuccessful
				sql.EndTransaction
			Else
				Dim currentapp As App
					currentapp.Name = pm.GetApplicationLabel(p)
					currentapp.PackageName = p
'					currentapp.index = i + 1
'					currentapp.Icon = GetPackageIcon(p)
'					currentapp.IsHomeApp = False
'					currentapp.IsHidden = False
				
				sql.ExecNonQuery("INSERT OR REPLACE INTO AllApps(Name, pkgName, IsHomeApp, IsNormalApp) VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "', 0, 0)")
			End If
			AppsList.Add(currentapp)
			
		Next
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
				
			NormalAppsList.Add(currentapp)
			
		Loop
		ResApps.Close
		NormalAppsList.SortTypeCaseInsensitive("Name", True)
		
		'//----- Load Home
		'
		Dim ResHome As ResultSet = sql.ExecQuery("SELECT * FROM Home ORDER BY ID ASC")
		
		For i = 0 To ResHome.RowCount - 1
			ResHome.Position = i
			
			Dim currentHomeapp As App
				currentHomeapp.PackageName = ResHome.GetString("pkgName")
				currentHomeapp.Name = ResHome.GetString("Name")
				currentHomeapp.index = i + 1
				currentHomeapp.Icon = GetPackageIcon(currentHomeapp.PackageName)
				currentHomeapp.IsHomeApp = True
'				currentHomeapp.IsHidden = False
					
			HomeApps.Add(currentHomeapp)
		Next
		ResHome.Close
'		HomeApps.SortTypeCaseInsensitive("index", True)
	
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
			
			NormalAppsList.Add(currentapp)
			AppsList.Add(currentapp)
			
		Loop
		ResApps.Close
		AppsList.SortTypeCaseInsensitive("Name", True)
		NormalAppsList.SortTypeCaseInsensitive("Name", True)
		
		'//----- Home Apps
		'
		Dim ResHome As ResultSet = sql.ExecQuery("SELECT * FROM Home ORDER BY ID ASC")
		
		For i = 0 To ResHome.RowCount - 1
			ResHome.Position = i
			
			Dim currentHomeapp As App
				currentHomeapp.PackageName = ResHome.GetString("pkgName")
				currentHomeapp.Name = ResHome.GetString("Name")
				currentHomeapp.index = i + 1
				currentHomeapp.Icon = GetPackageIcon(currentHomeapp.PackageName)
				currentHomeapp.IsHomeApp = True
'				currentHomeapp.IsHidden = False
				
			HomeApps.Add(currentHomeapp)
			
		Next
		ResHome.Close
'		HomeApps.SortTypeCaseInsensitive("index", True)
		
	End If
	
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
	
'	'###### { ### Set Navigation Bar Transparent
'	Dim jo As JavaObject
'		jo.InitializeContext
'	Dim window As JavaObject
'	window = jo.RunMethod("getWindow", Null)
'	window.RunMethod("addFlags", Array(Bit.Or(0x00000200, 0x08000000)))
''	root.Height = root.Height + NAVBARHEIGHT
	'}-----
	
	'{###### ### Fix Wallpaper
	Dim r As Reflector
		r.Target = r.GetContext
		r.Target = r.RunStaticMethod("android.app.WallpaperManager", "getInstance", Array As Object(r.GetContext), Array As String("android.content.Context"))
	
'	r.RunMethod4("suggestDesiredDimensions", Array As Object(root.Width * 2, root.height), Array As String("java.lang.int", "java.lang.int"))
	r.RunMethod4("suggestDesiredDimensions", Array As Object(GetDeviceLayoutValues.Width * 2, GetDeviceLayoutValues.Height), Array As String("java.lang.int", "java.lang.int"))
	
	Dim pagesx As Float
		pagesx = 1.00 / 5
	
	Dim pagesy As Float
		pagesy = 1.00
	
	r.RunMethod4("setWallpaperOffsetSteps", Array As Object(pagesx, pagesy), Array As String("java.lang.float", "java.lang.float"))
	'}-----
	
	MyLog("FixWallTrans END" & TAB, LogListColor, False)
End Sub
