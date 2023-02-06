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
	Public AppsList 				As List			'-- All Installed Apps
	Public NormalAppsList 			As List			'-- Normal Apps to show
	Public HomeApps 				As List			'-- Home Screen Apps
	Public ShowToastLog 			As Boolean = True
	Public LogMode 					As Boolean = True
	Public LogList 					As List
	
	Public Pref 					As Settings
	
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
			 ShowIconHomeApp As Boolean)

End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	
	CreateDB
	
	PhoneEvent.InitializeWithPhoneState("PhoneEvent", PhID)
	LogList.Initialize
	
	SetupSettings
	SetupAppsList(False)

End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	LogColor(StackTrace, Colors.Red)
	LogColor(Error.Message, Colors.Red)
	MyLog("Application_Error: " & Error & ":" & StackTrace)
	Return True
End Sub

Sub Service_Destroy

End Sub

Sub PhoneEvent_PackageRemoved (Package As String, Intent As Intent)
	MyLog("*** Event: PE_PackageRemoved => " & Package)
	
	Dim name As String = B4XPages.MainPage.GetAppNamebyPackage(Package)
	SetupAppsList(True)
	
	B4XPages.MainPage.RemoveAppItem_JustFromAppList(Package)
	B4XPages.MainPage.RemoveAsRecently(Package)
	B4XPages.MainPage.RemoveHomeItem(Package)
	B4XPages.MainPage.SaveHomeList
	ToastMessageShow(name & " Removed!", True)
End Sub

Sub PhoneEvent_PackageAdded (Package As String, Intent As Intent)
	MyLog("*** Event: PE_PackageAdded => " & Package)
	
	SetupAppsList(True)
	Dim name As String = B4XPages.MainPage.GetAppNamebyPackage(Package)
	
	B4XPages.MainPage.AddToRecently(name, Package, True)
	B4XPages.MainPage.txtAppsSearch.Text = B4XPages.MainPage.txtAppsSearch.Text
	ToastMessageShow(name & " Installed!", True)
End Sub

Public Sub MyLog (Text As String)
	If Not (LogMode) Then Return
'	Dim txtWriter As TextWriter
'		txtWriter.Initialize(File.OpenOutput(File.DirInternalCache, "MyLog.log", True))
'		txtWriter.WriteList(LogList)
'		txtWriter.Close
'	File.WriteString(File.DirInternalCache, "MyLog.log", Text)
	LogList.Add(Text)
	Log(Text)
	If (ShowToastLog) Then ToastMessageShow(Text, False)
End Sub

Public Sub CreateDB
	If Not (File.Exists(File.DirInternal, "MyPhone.db")) Then
		File.Copy(File.DirAssets, "MyPhone.db", File.DirInternal, "MyPhone.db")
		LogColor(">>>>> - Database Replaced ! - <<<<<", Colors.Red)
	End If
	
	sql.Initialize(File.DirInternal, "MyPhone.db", False)
End Sub

Private Sub SetupSettings
	MyLog("Service :=> SetupSettings")
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
				
		End Select
	Next
	CurSettingSql.Close
	
'	LogColor("SetupSettings: " & Pref, Colors.Red)

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
	MyLog("Service :=> SetupAppsList : " & ForceReload)
	
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
	
	If (ForceReload = True) Or (ResApps.RowCount <> packages.Size) Then
		
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
					
				NormalAppsList.Add(currentapp)
				sql.BeginTransaction
'					sql.ExecNonQuery("INSERT OR REPLACE INTO Apps(Name, pkgName, IsHome, IsHidden) VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "',0,0)")
'					sql.ExecNonQuery("INSERT OR REPLACE INTO AllApps(Name, pkgName, IsNormalApp, IsHomeApp) VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "',1,0)")
					sql.ExecNonQuery("INSERT OR REPLACE INTO Apps(Name, pkgName, IsHome, IsHidden) VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "',0,0);" & _ 
									 "INSERT Or REPLACE INTO AllApps(Name, pkgName, IsNormalApp, IsHomeApp) VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "',1,0)")
				sql.EndTransaction
			Else
				Dim currentapp As App
					currentapp.Name = pm.GetApplicationLabel(p)
					currentapp.PackageName = p
'					currentapp.index = i + 1
'					currentapp.Icon = GetPackageIcon(p)
'					currentapp.IsHomeApp = False
'					currentapp.IsHidden = False
				
				sql.ExecNonQuery("INSERT OR REPLACE INTO AllApps(Name, pkgName, IsNormalApp, IsHomeApp) VALUES('" & currentapp.Name & "','" & currentapp.PackageName & "',0,0)")
			End If
			AppsList.Add(currentapp)
			
		Next
		AppsList.SortTypeCaseInsensitive("Name", True)
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
	
End Sub

Public Sub GetPackageIcon(pkgName As String) As Bitmap
	Try
'		LogColor("GetPackageIcon => " & PackageName, Colors.Yellow)
		
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
			MyLog("#Service:Starter => GetPackageIcon: " & pkgName & " - " & LastException.Message)
			Return Null
		End If
	End Try
End Sub

Private Sub GetBmpFromDrawable(Drawable As Object, Size As Int) As Bitmap
	Dim BMP As Bitmap, BG As Canvas, Drect As Rect
	BMP.InitializeMutable(Size,Size)
	Drect.Initialize(0,0,Size,Size)
	BG.Initialize2(BMP)
	BG.DrawDrawable(Drawable,Drect)
	Return BG.Bitmap
End Sub
